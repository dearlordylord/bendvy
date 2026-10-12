# Independent final Spec/Standards review: phase-v1 terminal evidence

## Verdict

The phase-v1 packet is accepted as a bounded, source-bound diagnostic record of the Native first-pass blocker and as a retained/restored archive. It is incomplete for Native compiler, build, runtime, performance, adoption, stock-credit, or issue-54 qualification. The terminal result is useful precisely because it locates the deadline before the first pass reaches its fact boundary; it does not demonstrate a remedy.

## Evidence and binding review

The reviewed durable phase-v1 commit is `cd3e929e4a3da3e0864c16b8dab98aded0d83ec4`. The packet hashes are:

- `DELIVERY.json`: `d3124bfb1013dedaaa25747fed9ef9bd809b26c745942678276f65032089053e`
- `EVIDENCE.zip`: `6337f9b2b6a439f1abfcaf95284f48ef92f184c590c0d91a880e6a8a52bb23ea`
- `RESULT.json`: `28dec161e42b204463f07ffe9ce8c0c0015568d35d9be8d8337c0d432410e3a3`
- `VERIFICATION.json`: `3923699e37331bdce3a99c57b8b8f30232070c16c41d9426d6651fefb685b80ca`
- `OWNED-MANIFEST.json`: `9259799ce26b28dbff87907d5ac8120ae6b99395985da91f0de4df2d788840bb`

The archive contains 49 unique members. Recomputing every member hash against `DELIVERY.json` found no missing, extra, or mismatched member. The retained compiler is phase compiler `6ce9271c87253070d4d6a9ec60d81d6e2bd6dc7cdfbc49b593a0a52e566eeebe`, with only the local marker patch `d283e5051b34926bac29505bf772589f50ea36a60adf6d856289eb2094fa2825` over the budget64 diagnostic candidate. The source closure remains the frozen 53-source SOURCE02 set. Prior 207,834-byte JS output is explicitly retained as diagnostic reuse, not as new Native evidence.

The Native plan is pinned by `96c094958ac6997d282a7853898bd24cdd4bcd9e24c3201fa36517cc420a5dea`; the outer plan by `b5deae527fb08e1c7a274c72197aa9557de24aa43d88d8679f018e061f938e88`. The packet retains the launch review, phase patch, source freeze, runner inputs, guards, raw streams, receipts, and restoration material, so the terminal observation is joined to the reviewed subject and command rather than inferred from a summary.

## Terminal observation

Activation, delivery preflight, and post-activation boundary preflight all exited 0. The configured Native collector exited 1 because its owned emit child reached the 30-second deadline. The emit command was taskset CPU 3 with pinned Bun 1.3.14 and the phase compiler; its receipt records `exit: null`, `failure: child deadline`, and cap 30 seconds. The Native receipt hash is `41d3533645f749d955aada811bcc25ce93dec801a9058de602d46f92058e743e`.

The complete captured stderr is one marker, 77 bytes, SHA `20fac722b4fe276b621868b5ff9b34ad95d68492b59dcad1bf0100aa4b8be5c8`:

    INSPECTOR54_PHASE {"phase":"begin","pass":1,"facts":0,"cpuSeconds":5.551023}

There is no pass-1 end marker and no later-pass marker. The output stream is empty, no `scenario.c` was produced, and build and consumer stages were never started. `RESULT.json` therefore correctly records `INCOMPLETE_NATIVE_PHASE_FIRST_PASS_DEADLINE` and says that the CPU value is cumulative process CPU at the begin point only. It cannot be used as a pass duration, comparative timing, or speedup claim.

This is sufficient to establish that the current Native first pass did not reach the instrumented fact boundary within the cap. It does not test a later repeated pass. Consequently, a repeated-pass skip such as the investigated PR1386 mechanism cannot be credited as the resolution of this observed blocker; the first-pass cost must be addressed or bounded before that mechanism can be evaluated.

## Restoration and control boundary

The outer receipt records activation exit 0, all three preflight exits 0, collector exit 1, and restore exit 0. Its receipt SHA is `15d0cf6d77ce5521e1b341d1ea4fff7dbf7a46fb199d4df38822fd6fe5abad34`. Queue release is true. The five activated unit files match their immutable backups, and the 48 remaining frozen hashes are exact both in the restore snapshot and in the post-terminal live comparison.

The preservation claim has the required qualification: the snapshot was captured under the outer lock and the approved outer code asserted the five changed files before unlock. The other 48 exact values were captured in restore stdout under the lock and compared read-only after terminal completion; they were not a separate pre-unlock assertion. Restore stdout is retained with SHA `a5b4497a4e421bc403370f70a2f6011f6e30364018f720d3ed7a7c4ea1e79a32`. This supports successful restoration and exact post-run comparison without overstating the lock-time assertion boundary.

## Remaining gates and limits

No completed Native C emission, build, runtime, full-oracle comparison, or semantic mutant resulted from this phase. The packet gives no stock Native, adoption, performance, proof, or full issue-54 credit. The source and prior JS joins remain limited to their explicitly recorded diagnostic scopes. A future compiler change or source adaptation needs its own bounded source binding and review; this packet supplies the first-pass diagnostic evidence needed to choose that next investigation, not acceptance of a fix.

No repository or source files were changed during this review.
