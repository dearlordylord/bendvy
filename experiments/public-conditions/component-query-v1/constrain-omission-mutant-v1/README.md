# Reached CQ constraint omission

The sole semantic edit in the copied actual canonical ordinary-check-query is in
`constrain`: operational `Q.constrain(source,predicate)` becomes `selected(source)`.
The same library-derived filter-use metadata remains concatenated. This removes
actual With/Without filtering, not descriptions or observation. The normal query
and condition bodies invoke this new CQ helper for both the presence-only and
joined selections. Required/Optional selection and every other operation remain.

Fixture, setup, observer, scenario and main bodies are identical to the frozen
normal consumer apart from variant imports. The same unchanged schema module is
reused by its exact absolute source path; existing canonical CD/Cond/App/query
engine modules are unchanged. SOURCE-DIFF.json asserts this exact body relation.

SOURCE-FREEZE.json pins the complete132-module/203-pin consuming closure. Fixture,
setup, observer and pure scenario PASS pinned CPU5/default5; IO main has the same
five expected foreign-dependent refusals. The unchanged schema source and its
normal check remain source-bound. No backend execution or countermodel result is
claimed by preparation. Root executes only after independent countermodel seal.
Full #54 broad Native qualification and the whole #61 matrix remain separate.
