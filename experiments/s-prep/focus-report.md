# Selected evaluator preparation control

`focus-run.py` restricts the frozen Dense/Sparse runner to an explicit schema/workload/count. It preserves the existing full-field validator, same-child fresh warmup/measured worlds, inner64 operations, batch1, reset child RSS and existing build/runtime limits. Default repetitions1 is a preparation control; it authorizes neither optimization nor a keep. Seven repetitions are available only to a subsequently accepted contract.

Actual one-shot Health/Dense256: all three backend verification children and all three sample children pass the full field oracle against a fresh unchanged TS reference. Native/JS artifacts are byte-identical to retained #20 Dense/Sparse artifacts (`e85c67d67e818fdb3645de9b00a23d316c975b57010b04865cb7115d5f950020` Native, `b671f0fa6160d7a9ae659737315a0d96bd1b682987c3fbb9893b2513588728cb` JS). This verifies selected execution, not an implementation change or speedup. The single Native76ms/TS20.461ms/JS152ms observations are descriptive and unqualified. Other preparation agents were active on other CPUs; affinity does not establish exclusive conditions. Differences from historical samples are not attributed to code. Future noise qualification must occur with those owned preparation tasks finished.

Reproduction with fresh output paths:

```sh
python3 experiments/s-perf/overlay.py /tmp/bendvy-prep22-focus-overlay-new
python3 experiments/s-prep/focus-run.py --overlay /tmp/bendvy-prep22-focus-overlay-new --build-dir /tmp/bendvy-prep22-focus-control-new --schema Health --workload dense --count 256 --cpu 2
```

`focus-evidence.json` pins the source closure, validators, launcher, artifacts and full outcomes. Raw outputs remain at the recorded task-local paths and are reconstructed by the command. This control does not establish timer margin, noise qualification, any other workload's capability or product performance.

`freeze.py --verify experiments/s-prep/baseline.json` independently verifies556 retained inputs and three clean pinned source references. `freeze-controls.py` uses fresh temporary Git fixtures: changed/missing/symlinked source and dirty/moved reference controls are rejected; unchanged/restored positives pass. The manifest records the explicitly authorized3600-second future Autoresearch budget and `contractAccepted:false`. It creates no session or execution authority.

Four-cohort construction control: `paired-run.py` default repetitions1 executed reference/candidate/reference/candidate with pinned baseline restoration and protected source closure checks. All four full-field controls passed (86.10 seconds wall); `paired-control-evidence.json` retains commands, source/artifact hashes and complete outcomes. No qualified metric is emitted. Later parser hardening rejects duplicate repetition IDs and nonfinite/nonpositive intervals; its separate malformed-evidence controls do not replace actual seven-rotation qualification.

Final decision-runner replay: four complete repetitions1 cohorts PASS in83.58 seconds. `paired-control-evidence.json` hashes the current runner with executable proposed noise/TS/performance rules. `paired-first-control-evidence.json` and `paired-parser-control-evidence.json` preserve earlier runner-version construction controls. These are source-specific engineering replays; none is noise qualification or an optimization packet.

The proposed minimal PATH/HOME/LANG/LC_ALL/BENDVY_CPU environment also completed a fresh single-case Native/TS/JS full-field gate (`minimal-env-evidence.json`). It used TMPDIR=/tmp for this ordinary preparation control; future accepted boundary creates a per-invocation TMPDIR under the separately proposed artifact root. No inherited environment flags are needed for this selected capability.
