# Reference sources

Full source trees downloaded with `git clone --depth 1`. Each clone contains a single commit of history; source files and nested `.git` directories are preserved locally. Exact commit hashes are recorded in [sources.json](sources.json).

- `bevy-ts/`: Sandro Maglione's ECS port.
- `bevy/`: Rust Bevy, including `crates/bevy_ecs`, `bevy_app`, `bevy_state`, and `bevy_time`.
- `bend2/`: the current Bend 2 repository at `bendlang/bend`. The former `HigherOrderCO/Bend2` repository points to this repository.

Each repository was cloned at its HEAD at the time of retrieval. The Bevy checkout is version `0.20.0-dev`; this does not establish which Bevy version Sandro used as the basis for his port. Comparing historical versions requires a separate checkout.

These sources are used for reading and comparison. Dependencies were not installed, upstream tests were not run, and the cloned repositories were not modified.
