# Copied compiler comparator candidate

No installed compiler or reference checkout changes. This successor preserves the reviewed profile instrumentation and full recursive consumer. Comparator removes JSON serialization allocations; it recursively compares ks and ordered own enumerable arms, observing current mutations without caching. Ordered arm comparison deliberately uses repeated enumeration (quadratic in arm count), so no speedup is claimed.

Source domain: Lay has ks:Kind[] and arms:Record<Name,Lay[]>|null; constants and lay_pack produce dense arrays and plain data objects, with ks then arms property order. lay_node only appends ks padding. Cycles are collapsed to BOX in lay_of. Equality equivalence is claimed only for these ordinary source-created layouts, not arbitrary JS objects/proxies/getters/undefined/cyclic objects or reordered top-level fields. Actual consumer layout values were not captured by the profile.

196 synthetic pair differential comparisons and mutation/padding/ordered-arm controls pass. They are controls, not a formal proof. The full consuming diagnostic must pass independent admission before launch. Profile represents copied source only; no installed ELF/Native/performance qualification.
