# Detached constructor renderer correction

The original oracle d428da2fe and first failed JS receipt remain unchanged.
Runtime mismatch identified a renderer mistake: v1 emitted internal namespace
separator `:`, while Bend displays `.`. This successor is mismatch-informed;
it does not claim no runtime output was consulted.

The correction follows retained compiler sources: bend.ts `name_key` explicitly
replaces the internal colon with a dot; comp.ts Native SHOW_NAMES and JS output
descriptor/tag generation call name_key. The complete finite operation model,
all owner trees, original Raw, Error and Checked observations are unchanged.
Only namespace punctuation changes; source freeze and 21 immutable bodies are
identical. The retained render-source snapshot makes this justification portable.

Whole source completeness and bounded-scope findings from v1 remain applicable.
This is not World restore, an ownership-policy adoption or full #59 acceptance.
Fresh whole JS/Native comparisons and the reached preservation control remain
pending. No backend was run by this reviewer.
