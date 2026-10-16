# Reached Context preservation counter

Frozen source f3deda610 changes the actual schema-author callback's Context:
`Array.set(U32,sentinel,0,112)` replaces the first leaf of its existing two-leaf
Array. Both accepted and refused invocations reach that callback. The original
111 becomes 112; 222, payload, decoder result, original Raw and Issues remain
unchanged. The observer is unchanged except for selecting the mutant witness.

This finite counter was derived before seeing any mutant runtime output. Its
full 513-byte observation differs from the normal model at exactly two bytes,
one in each Context tree. Equal lengths ensure length-only checks cannot catch
this defect. The model verifies all 21 frozen source hashes and the actual
mutation expression. It inherits the corrected source-grounded QName renderer;
no new formatter policy is introduced.

Execution must match this entire counter and reject the entire normal baseline.
A passing affine checker alone would not detect this value-preservation defect.
No World restore, cleanup or general schema-author contract is added.
