# Retained App query qualification

`actual-attempt01/manifest.json` binds source `23f1cd0e5`, plans `092fb0f55`,
and independent oracle `60c6234dc` to the complete JS/Native outputs. Both
4,961-byte streams match SHA256
`e1133b87a38f06cb5c6e9aaae0782dd3470eb8f86f91f35593421fffb623b3aa`.
All five emit/build/consumer commands passed; all 17 source/resource guards
were unchanged. No runtime retries or cap changes occurred for this App pair.

The existing object-manifest format retains 474 path bindings, 436 compressed
objects and 22 explicitly external installed ELF identities, including complete
sources, oracle, plans, receipts, raw streams and generated artifacts. Offline
hash/size checks and isolated full independent-model reproduction passed.
The earlier query Native timeout/retry is preserved separately in the parent
query runtime packet and is not reclassified by this successful App pair.

Automatic debug bindings and independent cursors are qualified for the complete
consumer. Full #50 acceptance awaits the independent joined final review.
