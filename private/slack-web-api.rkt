#lang racket/base

(provide
  slack-web-api-logger
  )

(require
  json
  net/url)

;; =============================================================================

(define-logger slack-web-api)

(define *slack-identity* (make-parameter #f))

;; -----------------------------------------------------------------------------
;; --- low-level API

(define (slack-post/json endpoint j# #:token [token (*slack-identity*)])
  (define uu (string->url (string-append "https://slack.com/api/" endpoint)))
  (define headers
    (list "Content-Type: application/json; charset=utf-8"
          (format "Authorization: Bearer ~a" (or (*slack-identity*) (error 'noid)))))
  (define jb (jsexpr->bytes (hash-set j# 'token token)))
  (log-slack-web-api-info "POST ~s~n" jb)
  (read-json (post-pure-port uu jb headers)))
