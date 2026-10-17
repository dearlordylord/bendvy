# Dense runtime input 256×64

These complete expected files use the unchanged generic model and source
`354fde58a` with actual arguments `256 64`. The source freeze retains its initial
`64 64` launch metadata; no source body or original expected file is rewritten.
The per-schema basis binds the distinct256 input explicitly.

Each report includes all16,384 row results,64 audits/statuses,512 physical
allocator slots, all columns/stamps/resources/registrations,256 detached rows
and complete World after that read. Seed writes427 and component updates16,384
produce clock/cursor16,811. All source/resource/model pins, shared pinned TS
full-final/audit assertion hashes and isolated complete Python reproduction pass.
No subject output, backend execution or timing informs these expectations.

Run `python3 ../model.py Motion 256 64` or the Health counterpart, or run
`python3 verify.py.source` for the complete offline pin/raw/gzip/model joins.
These are finite correctness expectations, not larger-size or #21 numerical
qualification. The1024 outputs remain ungenerated.
