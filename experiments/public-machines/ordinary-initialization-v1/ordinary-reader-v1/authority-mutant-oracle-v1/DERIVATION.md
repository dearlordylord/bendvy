Source-only counteroracle for producer f3dba2fb3, based on the same complete
foreign-disposal operation chain as authority-oracle-v1. All 38 Bend bodies are
preserved under the same relative import paths in the immutable successor
snapshot. Exactly one body differs: ordinary-machine-transition-reader.remove's
St.dispose(stream,id) becomes St.dispose(stream,U32.add(id,1)). source-freeze.json
records both hashes; byte equality with precisely this one expression replacement
was independently checked. Namespace C/JS effects are unchanged and pinned from
the normal immutable snapshot (the producer mutant mirror holds Bend bodies).
No runtime/generated output was consulted.

Registry disposal still validates/removes the actual first/survivor registry.
Foreign disposal still refuses before remove and has identical effects. Accepted
first disposal instead attempts to remove position2, which has not yet activated:
position1=[1,1,1] remains. The survivor then activates/commits position2, preserving
position1, receives Initial A once and then an empty reading. Final accepted
survivor disposal attempts position3, leaving ordered positions [2,1,1],[1,1,1].
No clock, publication, owner, registry or payload field is otherwise changed.
The model recomputes every full snapshot from these operations and checks both
residual positions; no text replacement against observed/golden output is used.
Normal expected bytes must reject this counterwire. Both nominal schemas and all
four actual WorldIO namespaces remain observed, with exact terminal IO framing.
