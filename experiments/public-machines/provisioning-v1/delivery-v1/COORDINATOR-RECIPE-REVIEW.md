# Collector reuse check

Root checked `18aea135` (integration `62a97ebd`) without a compiler/runtime child.
Both original collector bytes match the digests in `RECIPE-REUSE.json`;
the complete AST of each `run` function is unchanged. Preparation selects the
new three entries and independent oracle paths; execution gates are retained.

This is a mechanical recipe join, not launch admission. Exact source/model/tool,
resource/environment inventories and prospective plans still require the batched
independent review. Experimental preflight does not select public scheduling policy.
