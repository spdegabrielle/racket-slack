#lang racket/base

(require racket/contract)
(provide
  slack-web-api-logger
  slack-response?
  )

(require
  json
  net/url)

;; =============================================================================

(define-logger slack-web-api)

(define *slack-identity* (make-parameter #f))

;; -----------------------------------------------------------------------------
;; --- low-level API

(define slack-response? jsexpr?)

(define (slack-post/json endpoint j# #:token [token (*slack-identity*)])
  (define uu (string->url (string-append "https://slack.com/api/" endpoint)))
  (define headers
    (list "Content-Type: application/json; charset=utf-8"
          (format "Authorization: Bearer ~a" (or (*slack-identity*) (error 'noid)))))
  (define jb (jsexpr->bytes (hash-set j# 'token token)))
  (log-slack-web-api-info "POST ~s~n" jb)
  (read-json (post-pure-port uu jb headers)))

(define (slack-ref* h . k*)
  (for/fold ((acc h))
            ((k (in-list k*)))
    (hash-ref acc k)))

;; -----------------------------------------------------------------------------

(provide
  (contract-out
    [slack-channel-name?
      (-> string? boolean?)]
    [channels.create
      (->* [string?] [#:validate? boolean?] any)]
    [channels.setTopic
      (->* [slack-response? string?] any)]))

(define channels.create.endpoint "channels.create")
(define channels.setTopic.endpoint "channels.create")
(define channels.rx #rx"^[-_a-z0-9]*$")
(define channels.max-name-length 21)
(define channels.max-topic-length 251)

;; Reference: <https://api.slack.com/methods/channels.create>
(define (slack-channel-name? x)
  (and (regexp-match? channels.rx x)
       (< 0 (string-length x) (+ 1 channels.max-name-length))))

(define (channels.create c-name #:validate? [validate? #true])
  (when (and validate? (not (slack-channel-name? c-name)))
    (raise-argument-error 'channels.create "slack-channel-name?" c-name))
  ;; success?
  (slack-post/json channels.create.endpoint
              (make-immutable-hasheq `((validate . ,validate?)
                                       (name . ,c-name)))))

(define (channels.setTopic chn topic #:validate? [validate? #true])
  (when (and validate? (not (slack-topic? topic)))
    (raise-argument-error 'channels.setTopic "slack-topic?" topic))
  (define c-name (slack-ref* chn 'channel 'id))
  (slack-post/json channels.setTopic.endpoint
              (make-immutable-hasheq `((channel . ,c-name) (topic . ,topic)))))

(define (slack-topic? str)
  (< 0 (string-length str) (+ 1 channels.max-topic-length)))
