# Pure String wire correction before execution

The unquoted stdout framing claim in historical `4f3ab2d9/REVIEW.md` is incorrect for these pure String entries. All six `f26c2c77` plans remain unexecuted and unadmitted. Preserve those files and plans without reinterpreting them as qualified wire output.

Pinned compiler source `a950fd683c0d76f09794078e6174fe98a1492876`, `bend2/comp.ts`, C show_chr/show_val and JS show_chr/show_val/io_exit agree: wrap String in double quotes, escape each character, then append one external LF. `main`, `main-mutant` and `flow-only` join their semantic rows without a trailing String LF. Thus the original full semantic observer models are unchanged, while exact expected wire now uses one quoted line containing escaped internal newlines.

`wire.py` independently implements these pinned character rules. Three additive `*-wire.stdout` files bind the complete semantic JSON and source-defined bodies; historical unquoted files stay immutable. `WIRE-BASIS.json` pins the primary compiler source and exact raw hashes. Two no-child tests check complete decode identity for all three models, single external LF and quotes, and source-defined special/non-ASCII character handling. No runtime output was read or used to repair expectations.

Admission requires fresh plans with these full literal files, exact String wire decoding before the complete row parser, and unchanged full neutral models. Reject non-String root, raw truncation/suffix/newline drift, field loss/reordering and checkpoint loss; mutant must reject the entire normal literal and neutral model. This corrects transport only, not pre-frame/initialization public policy or backend qualification. No child launched by reviewer.
