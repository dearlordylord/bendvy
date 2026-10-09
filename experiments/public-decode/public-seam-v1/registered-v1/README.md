# Ordinary registered owned Decode bridge — source prototype

The same typed `Declaration` retains the constructed codec and closed admission
index. Its constructor derives the existing ordinary `Query.Clause{key,Write}`;
`System.define` derives registration access from that clause and stores the
runtime declaration beside the actual affine `Sys.Registry`. Callers provide no
access strings, metadata adapter or replacement codec at run time.

`run` supplies that retained declaration internally, then `Sys.run` performs its
real registration/namespace checks. The reached runner invokes the universal
opaque-H body through existing `Cap.invoke_owned`, with actual validation and
admission. Registration refusal reconstructs the registry owner and returns the
original public args/world. Raw World and the admission callback are confined
to trusted provisioning; public constructors are not claimed secret.

`consumer.bend` assembles an actual world, reserves a handle, creates a descriptor,
registers a body and invokes the registration. Source-only checks pass with
preserved Bend2.0.35, CPU5/shared lock/cap5. Four separate controls reject body
rawWorld access, substituting a read grant, cross-schema input and duplicating
this actual registry owner. Raw outputs and failed intermediate source shapes
remain in evidence. No runtime or backend child was launched for this bridge.

This bridge intentionally supports **non-failing bodies only**; operation
refusals remain arbitrary Type outputs. It does not complete #46. Fallible
assembly must use the existing transaction/rollback path: current Sys.Failed
returns world plus Data error and has no owned-output channel. A generic extension
must account for all affine owners and cannot silently convert failure into
success or discard refusal outputs. Immediate spawn also remains the original
kernel behavior, rather than deferred command admission. Do not freeze this
intermediate bridge as full acceptance.

Next: join the ordinary descriptor with existing transactional bundle requests
and resource journaling; preserve the source-current full 32+12-extension spine,
then independently bind complete models and reached mutations before backend
admission. Existing qualified experimental packets remain historical evidence.
