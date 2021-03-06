#lang scribble/manual

@(require "util/doc.rkt")

@title{Mocking Out Functions for Testing}

Mocks by themselves provide useful low-level building
blocks, but often to use them a function needs to be
implemented twice - once using mocks for the purpose
of testing, and once using real functions to provide
actual functionality. These syntactic forms provide
shorthands for defining both implementations at once.

@defform[#:id define/mock
         (define/mock header ([mock-id mock-expr] ...) body ...)
         #:grammar ([header id (header arg ...)])
         #:contracts ([mock-expr mock?])]{
  Like @racket[define], but also @racket[define]s a mocked
  version of @racket[id] in a @racket[test] submodule. The
  mocked version uses the same @racket[body ...] as the
  unmocked version, but each @racket[mock-id] is shadowed
  and bound to @racket[mock-expr] in the test submodule and
  used in place of @racket[mock-id] in @racket[body ...].
  Each @racket[mock-id] is left alone in the normal implementation.
  @mock-examples[
    (module m racket
      (require mock)
      (define/mock (displayln-twice v)
        ([displayln (void-mock)])
        (displayln v)
        (displayln v))
      (displayln-twice "sent to real displayln")
      (mock? displayln)
      (module+ test
        (displayln-twice "sent to mock displayln")
        (mock? displayln)))
    (require 'm)
    (require (submod 'm test))
]}

@defform[#:id define/mock-as
         (define/mock-as header (mock-clause ...) body ...)
         #:grammar ([header id (header arg ...)]
                    [mock-clause [mock-id mock-value-id mock-expr]])
         #:contracts ([mock-expr mock?])]{
  Like @racket[define/mock], but in the test submodule each
  @racket[mock-expr] is bound as @racket[mock-value-id] instead.
  This prevents shadowing in the submodule so that both the
  mocked and unmocked versions are available, and allows the
  mock value to be named something other than @racket[mock-id].
  @mock-examples[
    (module m racket
      (require mock)
      (define/mock-as (displayln-twice v)
        ([displayln displayln-mock (void-mock)])
        (displayln v)
        (displayln v))
      (displayln-twice "sent to real displayln")
      (mock? displayln)
      (module+ test
        (displayln-twice "sent to mock displayln")
        (mock? displayln)
        (mock? displayln-mock)))
    (require 'm)
    (require (submod 'm test))
]}
