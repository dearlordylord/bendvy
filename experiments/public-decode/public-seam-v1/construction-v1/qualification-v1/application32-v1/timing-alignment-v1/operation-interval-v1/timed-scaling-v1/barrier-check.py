#!/usr/bin/env python3
"""Check the source and emitted timer boundary before consumer comparison."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def ordered(source: str, tokens: tuple[str, ...], context: str) -> list[int]:
    positions = [source.find(token) for token in tokens]
    assert all(pos >= 0 for pos in positions), (context, tokens, positions)
    assert positions == sorted(positions), (context, tokens, positions)
    return positions


def validate(plan: dict) -> dict:
    paths = plan["generated"]
    js_path = Path(paths["js"]["path"])
    c_path = Path(paths["nativeC"]["path"])
    emission_path = Path(paths["emissionReceipt"]["path"])
    barrier_path = Path(paths["barrier"]["path"])
    emission = json.loads(emission_path.read_text())
    assert emission["status"] == "EMIT_JS_C_COMPLETE"
    assert emission["generated"]["js"]["sha256"] == sha(js_path)
    assert emission["generated"]["nativeC"]["sha256"] == sha(c_path)

    bend = (HERE / "bend/main.bend").read_text()
    capture_start = bend.index("def capture_all(")
    selected_start = bend.index("def selected(", capture_start)
    capture_body = bend[capture_start:selected_start]
    bend_positions = ordered(
        capture_body,
        (
            "Clock.begin(interval)",
            "Clock.capture(Common.main())",
            "Clock.end()",
            "capture_all(rest, U32.add(interval, 1))",
        ),
        "Bend fresh-application interval",
    )
    assert "Clock.finish(interval)" in capture_body

    ts = (HERE / "ts/main.mjs").read_text()
    loop_start = ts.index("for (let index = 0;")
    finish_start = ts.index("Clock.finish(repetitions);", loop_start)
    ts_loop = ts[loop_start:finish_start]
    ts_positions = ordered(
        ts_loop,
        (
            "Clock.begin(index);",
            "Clock.capture(commonReport());",
            "Clock.end();",
        ),
        "TypeScript fresh-application interval",
    )
    assert "Clock.finish(repetitions);" in ts[finish_start:]

    js = js_path.read_text()
    c = c_path.read_text()
    for token in (
        "io_interval_begin",
        "io_interval_capture",
        "io_interval_end",
        "io_interval_finish",
        "io_args",
    ):
        assert token in js, ("generated JS missing runtime path", token)
    for token in (
        "io_feature_begin_run",
        "io_feature_capture_run",
        "io_feature_end_run",
        "io_interval_finish_run",
        "io_args_run",
    ):
        assert token in c, ("generated C missing runtime path", token)

    timing_js = (HERE.parent / "timed-v5/ts/timing.mjs").read_text()
    capture_js = next(line for line in timing_js.splitlines() if line.startswith("export function capture("))
    finish_js = next(line for line in timing_js.splitlines() if line.startswith("export function finish("))
    assert "require(ready&&active)" in capture_js and "chunks.push(b)" in capture_js
    assert "process.stdout.write" not in capture_js
    assert "require(ready&&!active&&count===expected)" in finish_js
    assert finish_js.index("process.stderr.write") < finish_js.index("process.stdout.write")

    timing_c = (HERE.parent / "timed-v5/bend/timing.c").read_text()
    capture_start = timing_c.index("Term io_feature_capture_run(")
    end_start = timing_c.index("Term io_feature_end_run(", capture_start)
    finish_start = timing_c.index("Term io_interval_finish_run(", end_start)
    capture_c = timing_c[capture_start:end_start]
    finish_c = timing_c[finish_start:timing_c.index("static void __attribute__((constructor))", finish_start)]
    assert "interval_ready && feature_active" in capture_c
    assert "io_out(" not in capture_c
    assert "interval_count == (uint32_t)f[0]" in finish_c
    assert finish_c.index("fprintf(stderr") < finish_c.index("io_out(stdout")

    barrier = {
        "status": "SCALE_ONE_SOURCE_AND_GENERATED_TIMER_BOUNDARY_PASS",
        "source": {
            "bendEntry": str(HERE / "bend/main.bend"),
            "bendEntrySHA256": sha(HERE / "bend/main.bend"),
            "typescriptEntry": str(HERE / "ts/main.mjs"),
            "typescriptEntrySHA256": sha(HERE / "ts/main.mjs"),
            "bendIntervalTokenPositions": bend_positions,
            "typescriptIntervalTokenPositions": ts_positions,
        },
        "generated": {
            "js": {"path": str(js_path), "bytes": js_path.stat().st_size, "sha256": sha(js_path)},
            "nativeC": {"path": str(c_path), "bytes": c_path.stat().st_size, "sha256": sha(c_path)},
            "emissionReceipt": {"path": str(emission_path), "sha256": sha(emission_path)},
        },
        "timer": {
            "typescriptCaptureBuffersWhileActive": capture_js,
            "typescriptFinishChecksThenFlushes": finish_js,
            "nativeCaptureBuffersWhileActive": capture_c,
            "nativeFinishChecksThenFlushes": finish_c,
        },
        "scope": "Static source/generated path checks only. Runtime acceptance requires complete stdout and timer summary equality at each selected scale.",
    }
    barrier_path.write_text(json.dumps(barrier, indent=2) + "\n")
    return barrier
