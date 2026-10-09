# Separate construction input codec

Source candidate; no backend run yet. Historical constructor, 80 consumers/models and receipts remain untouched. Existing factory functions default the retained input codec to the saved declaration codec; additive functions accept another input codec. One nominal stored-payload identity and its declaration/projector remain unchanged.

The registered consumer uses `Input.Input` with genuine text and affine arrays, produces `Business.Owner{x:U32,y:U32,original,words:Array<U32>,flags:Array<Bool>}`, and serializes it as `{x,y}`. Its application parser accepts one decimal digit, a comma, one decimal digit. Saved admission requires `x=7` and an integer `y`.

Per schema, operations run in this order:

1. `success`: text `7,8`, registered spawn, actual deferred barrier materializes structured P.
2. `parseRefusal`: text `7;q`, accepted input kind then custom `ParseError`; exact raw owner returned.
3. `wrongKind`: Number 7, input validation rejects before the builder.
4. `downstreamRefusal`: text `9,8` parses; stored-P admission rejects `$.x`; undo returns exact text/arrays with unchanged world and queue.
5. `failure`: accepted text `7,8` then system failure; existing rollback and explicit Local recovery retained.
6. `skip`: supplied text `7,8`, existing Local skip retains state and world.

First schema precedes Second. Every report includes actual before/committed/barrier worlds, complete physical component slots and lifecycle metadata, mailbox owners, Local recoveries, returned owner sentinels, and exact error nesting. No-match/foreign-world scenarios remain in the unchanged historical default cohort; this fixture does not claim they are newly exercised. No dummy incoming projection or changed save representation.

Root owns integrated default-80 qualification and core promotion. The promotion manifest binds the additive source and unchanged default models; other five proposed modules remain import-only. Independent model author must freeze the full twelve reports before any new backend execution.
