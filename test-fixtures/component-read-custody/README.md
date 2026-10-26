# Component read custody

Checks actual created foreign handles, Pending and dead states, absence, reused generations, projector invocation count, retained affine payload/resource arrays and clock state. The expected output is independent of the getter implementation.

From the repository root, use the installed supported Bend and pinned Clang 19.1.7:

```sh
bend test-fixtures/component-read-custody/main.bend -o /tmp/component-read-custody.c
clang -O3 /tmp/component-read-custody.c -o /tmp/component-read-custody -pthread -lm
/tmp/component-read-custody +RTS --threads 1 --gpu off -RTS > /tmp/component-read-custody.stdout
cmp test-fixtures/component-read-custody/expected.stdout /tmp/component-read-custody.stdout
```

The native executable requires no Node.js. The same source can be emitted as JavaScript for a second backend comparison.
