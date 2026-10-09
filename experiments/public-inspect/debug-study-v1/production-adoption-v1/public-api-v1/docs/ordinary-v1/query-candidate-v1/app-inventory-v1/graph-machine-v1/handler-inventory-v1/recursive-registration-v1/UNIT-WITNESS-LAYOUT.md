# Unit-only recursive boxing witness

Owner<A>.link now contains Maybe<Owner<Unit>>, never Owner<A>. Construction remains hold(value) -> Owner{value,None}. Only the intended payload can contain arbitrary affine Type owners; a malformed finite witness tail contains Unit values only and does not hide additional ECS owners. This remains private fixture construction, not a generic user carrier or disposal policy.

Copied comp.ts lay_of lines961–975 traverses constructor domains through ty_holds884–901 and tests the nominal ADT key u.k === t.k, without comparing instantiated arguments. Owner<Unit> has the same nominal key as Owner<A>, hence this source rule returns BOX for the amended declaration. This is source reasoning for the copied compiler, not installed ELF behavior or measured improvement.

The complete successor source check retained in unit-witness-full-source.result.json hit cap5, without diagnostics. No retry or backend was performed; predecessor full source success is not rebound to this repair. Stage/category negatives remain historical; the new witness payload negative checks Array<U32> cannot inhabit Owner<Unit>.
