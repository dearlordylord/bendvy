# #56 retained-output package review

**Result: PASS for portable evidence joins.** This review does not change the
original Native collector status, which remains `INCOMPLETE`.

The delivery index SHA-256 is
`2951310f79351e5a1db5b898998ccdb3d6c036168fb7f54197dedb8db0754020` and the
actual manifest SHA-256 is
`972f0664c383b78b250a3f7a5366e47182f45dbead54f92d0668581734a874a0`. The
portable archive is 5,717,094 bytes, SHA-256
`750f716d73b389a2edb11901c24cfe2bc004311aaa273c66a9fe4b7e3b43f9ee`. ZIP
integrity passed. All 241 manifest rows join to 216 content-addressed members;
each object hash and byte length matches. Eight installed tool/resource pins
are recorded as external metadata and are not redistributed.

The archive includes `FINAL-REVIEW.md` at SHA-256
`4ecb272d9948ec563f57b157dda7dd7cc8693463c91b7bc12485bbee46cbded1`, the
original receipt at SHA-256
`9dc57b866452da1c2475d8853bd1d963ba4fad80563f8f0303df73eb2abcd816` with
status `INCOMPLETE`, retained stdout at SHA-256
`b813d64156ce0d03b9c3e469af8f28a448f89d2dc0585fc4bac351c6f3ba7151`, and the
presentation-rebase manifest/comparison at SHA-256
`22d74ed3486241998e4a13d98a85946223f8fb38b5e4b83efdc481b783f4b0c5` /
`34387945984f86ca189faf06fdc178431f99ece68d93305446840db507174678`.
The frozen README pin is preserved as historical commit `9e146c5a8` with SHA-256
`ebaae69db5742cb080fb39c98b6720a57cb79a58ddea32de5eda5218c5917226`.

No compiler or consumer was rerun, and no package or source file was modified
for this verification.
