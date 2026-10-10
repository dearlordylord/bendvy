# Imported Report transport correction

The first actual production JS run rejected the original whole oracle. The
original `c8db301c2` packet and failed receipt stay unchanged. Its independently
derived body observations remain the basis of this explicit successor.

The mistake was treating imported `Consumer.Report` as a local constructor.
Pinned Bend 2.0.35 source independently determines the prefix: `book_load`
assigns an imported file's path relative to the entry directory as namespace;
`parse_name` qualifies its declarations; `show_main` retains constructor keys;
`name_key` replaces namespace colon with dot. Both full entrypoints import
`./full-consumer.bend`, hence the stock name is `full-consumer.Report`.
JS `show_val` and Native `SHOW_NAMES` use that same key; aliases do not shorten
the backend's output name.

`model.py` prefixes the frozen independent whole Report with the source-derived
14-byte `full-consumer.` namespace. It does not read actual stdout or change
any World, owner, resource, row, outcome or cursor expectation. Normal and
reached-control expectations remain separate, including the owner-probe
companion. Compiler/entry source hashes are explicit successor basis inputs.
