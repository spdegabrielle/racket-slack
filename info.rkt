#lang info
(define collection "slack-web-api")
(define deps '("base" "rackunit-lib"))
(define build-deps '("scribble-lib" "racket-doc"))
(define pkg-desc "Bindings for Slack Web API")
(define version "0.1")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/slack-web-api.scrbl" () (tool-library))))
