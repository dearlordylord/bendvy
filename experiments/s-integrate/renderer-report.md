# Actual Data trace renderer — bounded checkpoint

`host-render.bend` consumes actual `host-observations.bend` Data records and emits
one JSON object per event through `render_motion` / `render_health`; callers print
that String using `IO.print`. Generic `render_event` accepts template renderers
for V/AV/F/LV/Mode/P. Those callbacks must emit valid complete JSON values; nominal
wrappers supply the concrete implementations. No Type owner is copied or inspected
by this rendering boundary.

The draft contract was recorded before implementation in the renderer source:
retain all constructor/field values and list order, escape JSON String syntax and
emit absent values as null. It is an unapproved draft, tested at finite inputs;
no ECS/general renderer proof is added. String domain is valid Unicode scalar
strings, including all JSON control characters, quotation mark and backslash.
Arbitrary forged out-of-range Char codes are outside this tested encoding domain.

Encoding uses literal record field names plus `kind` for sum constructors. Handles
retain raw `{namespace,id}`. Four retains `{a,b,c,d}` individually. MainView retains
MotionMain/HealthMain tags. Access retains Found/Mismatch/Missing tags; conversion
to reference-facing terminology is a decoder responsibility. World rows include
both lifecycle marks; pending commands preserve input FIFO; read records include
all queries, counts, boundaries, three lag flags, full messages and handle lists.
ReadDone retains frame/tick/outcome; Snapshot retains worldName/prior; Reserved
retains worldName, raw handle and complete components. No event constant is used
to reconstruct observations.

Reproduce: `python3 experiments/s-integrate/renderer-run.py`. Uses existing T05
build helper: five-second checker/runtime with owned process-group cleanup;
codegen 30 seconds and clang 120 seconds are separate build bounds. Evidence pins
runner/fixture/renderer/event source, complete recursive local import closure,
installed compiler/Base and wrapper/build helper; records every raw JSON line and
parsed value. Expected values are independently written complete fixture inputs,
compared as entire objects rather than hashes/selected-field summaries.

Fourteen complete values pass on Native and JS. Four mutations compile on both
backends and differ at their intended checkpoints: Four c/d swap, handle namespace
replaced by its actual ID, ordered-list reversal, and low control-escape nibble
loss. Early mutation drafts duplicated an affine-bound Data variable and failed
typechecking; those drafts were corrected and do not count as semantic controls.

This tests renderer encoding only. Constructed Data fixtures do not establish
actual Host composition, integrated trace parity, access confinement, general
runtime refinement or performance acceptance. Those remain #19 gates. Source event
API is frozen at `1b6dde6` (extension of `c9271ab`); its file is owned separately.
