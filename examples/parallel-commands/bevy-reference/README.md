# Deferred visibility reference

This development reference uses Bevy commit
`ad678262ce53b5d142fe49ee5e08caff6f00ab60` and the already installed Rust 1.95.0.
The local path and dependency lock match the existing dependency-schedule
reference; no dependency installation or reference-tree edit is required.

Each system run queues an existing entity's component insertion and removal,
then returns a handled error. The dependent observer sees those changes after
an automatic or explicit barrier. An ignored edge or disabled automatic
insertion delays visibility until the default final application. The second
run distinguishes retained system locals from reinitialization and observes
prior final application before the next queue is applied.

`expected.stdout` was derived from those transitions before execution. The
complete eight-line output matched on 2026-10-26 with:

```sh
cargo +1.95.0 run --offline --locked --quiet \
  --manifest-path examples/parallel-commands/bevy-reference/Cargo.toml \
  --target-dir /tmp/bendvy-gh86-bevy-target > /tmp/bendvy-gh86-bevy.stdout
diff -u examples/parallel-commands/bevy-reference/expected.stdout \
  /tmp/bendvy-gh86-bevy.stdout
```

The build and run completed with status 0 and no stderr. Tool identities were
`cargo 1.95.0 (f2d3ce0bd 2026-03-21)` and
`rustc 1.95.0 (59807616e 2026-04-14)`. The output SHA-256 was
`7c6cfbbb38d44d4e5e95e0fe172502c0d2d77c9756d42e844d0e59a56ee456e8`.
The source SHA-256 was
`37b11e5c023ae6f9f427d0fac3fdcd3ef5847b79eee148ba19ea533cf8e74743`;
the lock SHA-256 was
`288f5a5e10e2443479ac434e2845bcfe0e3e95048f886f3cfe7c09e863e4e22e`.

This observation does not qualify a Bend implementation or a canonical evidence
packet. It does not cover panic handling, failed command application, parallel
command application order or query worker buffers.
