# Dense runtime input 1024×64

These complete expected files use unchanged source `354fde58a` and the generic
model sealed at `3a9f352fa`, with actual arguments `1024 64`. The original source
freeze's initial64 launch metadata remains unchanged; each basis explicitly pins
the1024 input. Prior64 and256 expected files are preserved.

Each full report observes65,536 row returns,64 audits/statuses,2,048 allocator
slots, every physical Column and stamp, complete payload/resource fields,
registrations/cursor,1,024 detached rows and complete World after that read.
Seed population performs1,707 component writes;65,536 further writes yield
clock/cursor67,243. Resource updates remain per row and preserve all other cells.

Source/resource/model pins, exact pinned TS logical final/audit assertion hashes
and isolated complete Python reproduction pass. No consumer output was consulted,
no backend was run and no timing or numerical acceptance is claimed.

Run `python3 ../model.py Motion 1024 64` or the Health counterpart. Run
`python3 verify.py.source` for the complete offline pin/raw/gzip/reproduction joins.
These are finite correctness expectations, not a new input policy or universal
capacity/refusal qualification.
