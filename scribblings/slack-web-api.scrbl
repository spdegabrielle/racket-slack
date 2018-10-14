#lang scribble/manual

@require[
  scribble/example
  (for-label
    racket/base
    racket/contract
    slack-web-api)
]

@; -----------------------------------------------------------------------------

@(define (make-slack-eval) (make-base-eval '(require slack-web-api)))

@title{Slack Web API}

@defmodule[slack-web-api]{
  Racket bindings for the Slack Web API.
}

Slack Web API documentation: @url{https://api.slack.com/web}

@defproc[(slack-response? [x any/c]) boolean?]{
  TBA
}

@defproc[(channels.create [channel-name string?] [#:validate? validate? boolean? #true]) slack-response?]{
  Requests a new channel for the current workspace.
  If @racket[validate?] is @racket[#true], then asserts that the given name
   is valid (in the sense of @racket[slack-channel-name?]) and asks Slack to
   double-check.
  If @racket[validate?] if @racket[#false], then Slack create a channel with a
   different name.

  Reference: @url{https://api.slack.com/methods/channels.create}
}

@defproc[(slack-channel-name? [str string?]) boolean?]{
  Predicate for channels names that should pass Slack's validation.

  @examples[#:eval (make-slack-eval)
    (slack-channel-name? "flashback-fm")
    (slack-channel-name? "lips-106")
    (slack-channel-name? "LCFR")]
}

@defproc[(channels.setTopic [channel-info slack-response?] [topic string?] [#:validate? validate? boolean? #true]) slack-response?]{
  Change the topic of the given channel.

  When @racket[validate?] is @racket[#true], asserts that the given topic is
   valid in the sense of @racket[slack-topic?].

  Reference: @url{https://api.slack.com/methods/channels.setTopic}
}

@defproc[(slack-topic? [str string?]) boolean?]{
  Predicate for short-enough Slack channel topics.
}
