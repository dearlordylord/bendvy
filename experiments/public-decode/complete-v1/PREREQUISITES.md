# Experimental decoder prerequisites

`../typed.bend` and `../utf16.bend` are tracked unchanged to make the existing
complete candidate's source dependencies available from Git. Independent
Spec/Standards review found no blocker for this experimental admission. Their
bytes match the historical `public-gate-v1/finite-gate-v1/evidence.tar.gz`
source objects:

- typed.bend: `bbba271bff35d94e564c0b33f994737c8698942c3d05f9ffc71697c5c8185d26`
- utf16.bend: `343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539`

They import existing Base and the companion UTF16 module only, with no unsafe
implementation, new dependency, semantic law, proof or ownership policy.
Tracking does not promote them into `src/ecs`, qualify relocated execution or
close #46. Historical receipts retain their original source identities.

The low-level decoder still exposes fuel exhaustion and zero-fuel canonical
fallback; the complete wrapper computes its budget separately. Numeric examples
do not prove arbitrary-Nat/JavaScript-number refinement. UTF16 code-unit values
permit lone surrogates, reject units above 65535 and remain distinct from Bend
Unicode-scalar text. Caller projection correctness, generic constructor inverses
and complete error/representation compatibility remain #46 obligations.
