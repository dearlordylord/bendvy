# Standard Schema host boundary

Implemented: synchronous v1 validator adaptation, output transforms, exact issues/path owner identity (including Symbol/wrapped keys), Promise refusal with rejection handling, constructor decode-before-result precedence. Pinned `Descriptor.ts` is the direct comparison source.

`typedRawConstructor` requires explicit author providers for input, accepted output and issue projection. World-facing DTO representations are exhaustively checked/detached; original host issues remain separately retained. No dependency added. The DTO is not a generated Bend heap object or an affine ECS owner.

**Generated ECS interoperability is absent:** this adapter does not install JavaScript callbacks in emitted Bend registration/World. Bend constructors still use explicit typed input/output/project/undo providers. Native has no JS object/Promise API. Do not count host-only comparison as an end-to-end ECS interoperability test.

`fixture.mjs` preserves complete host/TS result, function precedence, throws, issue identity, typed DTO and representation/provider refusal observations. Syntax checks only so far; exact reference plan admission precedes execution.
