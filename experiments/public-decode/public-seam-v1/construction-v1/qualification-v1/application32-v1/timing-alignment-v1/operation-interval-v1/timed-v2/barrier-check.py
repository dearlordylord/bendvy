#!/usr/bin/env python3
"""Fail-closed static ordering checks on the actual emitted timer program."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
EMISSION = HERE / "runtime-timed-emit01"
RECEIPT = EMISSION / "EMIT-RECEIPT.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def js_function(source: str, name: str) -> str:
    matches = list(re.finditer(r"^function " + re.escape(name) + r"\(", source, re.M))
    assert len(matches) == 1, (name, len(matches))
    start = matches[0].start()
    next_function = source.find("\nfunction ", start + 1)
    return source[start:next_function if next_function >= 0 else len(source)]


def c_cases(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"WL_CASE\((FID_[A-Z0-9_]+)\)", source))
    names = [match.group(1) for match in matches]
    assert len(names) == len(set(names)), "generated case labels must be unique"
    return {
        match.group(1): source[match.end():matches[index + 1].start() if index + 1 < len(matches) else len(source)]
        for index, match in enumerate(matches)
    }


def c_function(source: str, name: str) -> str:
    matches = list(re.finditer(r"(?:static )?Term " + re.escape(name) + r"\(", source))
    assert len(matches) == 1, (name, len(matches))
    start = matches[0].start()
    end = source.find("\n}", start)
    assert end >= 0, name
    return source[start:end + 2]


def main() -> None:
    receipt = json.loads(RECEIPT.read_text())
    assert receipt["status"] in {"EMIT_ONLY_JS_AND_C_COMPLETE", "EMIT_AND_GENERATED_BARRIER_COMPLETE"}
    basis_path = Path(receipt["sourceBasis"])
    basis_sha = receipt["sourceBasisSHA256"]
    assert sha(basis_path) == basis_sha
    receipt_sha = sha(RECEIPT)
    checker_path = Path(__file__).resolve()
    checker_sha = sha(checker_path)
    previous_barrier = None
    original_emission_receipt = None
    if receipt.get("generatedBarrier"):
        previous_barrier = Path(receipt["generatedBarrier"]["path"])
        assert sha(previous_barrier) == receipt["generatedBarrier"]["sha256"]
        previous = json.loads(previous_barrier.read_text())
        original_emission_receipt = previous.get("emissionReceiptBeforeBarrier")
    artifacts = {row["label"]: row["artifact"] for row in receipt["commands"]}
    assert set(artifacts) == {"JS", "NativeC"}
    js_path = Path(artifacts["JS"]["path"])
    c_path = Path(artifacts["NativeC"]["path"])
    assert sha(js_path) == artifacts["JS"]["sha256"]
    assert sha(c_path) == artifacts["NativeC"]["sha256"]
    js, c = js_path.read_text(), c_path.read_text()

    main_js = js_function(js, "$main$")
    begun_js = js_function(js, "$begun$")
    captured_js = js_function(js, "$captured$")
    assert "$timing$058reset$(" in main_js and "$begun$()" in main_js
    begin_pos = begun_js.find("$timing$058begin$(0,")
    common_pos = begun_js.find("$common$045main$058main$()")
    assert 0 <= begin_pos < common_pos, "work must be evaluated only in the begin continuation"
    capture_pos = captured_js.find("$timing$058capture$(_text_0,")
    end_pos = captured_js.find("$timing$058end$(")
    finish_pos = captured_js.find("$timing$058finish$(1,")
    assert 0 <= capture_pos < end_pos < finish_pos, "capture must precede end; finish follows end"

    cases = c_cases(c)
    required = {
        "FID_MAIN_C3247", "FID_MAIN_C3248", "FID_MAIN_C3249", "FID_MAIN_C3250", "FID_MAIN_K3251",
        "FID_CAPTURED_C3239", "FID_CAPTURED_C3240", "FID_CAPTURED_C3241", "FID_CAPTURED_C3242",
    }
    assert required <= cases.keys(), required - cases.keys()
    assert "FID_TIMING_RESET" in cases["FID_MAIN_C3247"] and "FID_MAIN_C3248" in cases["FID_MAIN_C3247"]
    assert "FID_MAIN_C3249" in cases["FID_MAIN_C3248"]
    assert "FID_TIMING_BEGIN" in cases["FID_MAIN_C3249"] and "0ull" in cases["FID_MAIN_C3249"]
    assert "FID_MAIN_C3250" in cases["FID_MAIN_C3249"]
    assert "FID_COMMON_MAIN_MAIN" in cases["FID_MAIN_C3250"]
    assert "FID_MAIN_K3251" in cases["FID_MAIN_C3250"]
    assert "FID_TIMING_CAPTURE" in cases["FID_CAPTURED_C3239"]
    assert "FID_CAPTURED_C3240" in cases["FID_CAPTURED_C3239"]
    assert "FID_CAPTURED_C3241" in cases["FID_CAPTURED_C3240"]
    assert "FID_TIMING_END" in cases["FID_CAPTURED_C3241"]
    assert "FID_CAPTURED_C3242" in cases["FID_CAPTURED_C3241"]
    assert "FID_TIMING_FINISH" in cases["FID_CAPTURED_C3242"] and "1ull" in cases["FID_CAPTURED_C3242"]

    capture_js_impl = js_function(js, "io_interval_capture")
    finish_js_impl = js_function(js, "io_interval_finish")
    assert "intervalReady&&intervalActive" in capture_js_impl
    assert "intervalChunks.push(b)" in capture_js_impl and "io_out" not in capture_js_impl
    assert "intervalCount===expected" in finish_js_impl and "io_out(1,b)" in finish_js_impl

    capture_c_impl = c_function(c, "io_feature_capture_run")
    end_c_impl = c_function(c, "io_feature_end_run")
    finish_c_impl = c_function(c, "io_interval_finish_run")
    assert "interval_ready && feature_active" in capture_c_impl and "io_out(" not in capture_c_impl
    assert "feature_active = false" in end_c_impl and "interval_count++" in end_c_impl
    assert "interval_count == (uint32_t)f[0]" in finish_c_impl and "!feature_active" in finish_c_impl
    assert finish_c_impl.index("fprintf(stderr") < finish_c_impl.index("io_out(stdout")

    source_c = (HERE / "bend/timing.c").read_text()
    io_step_start = c.find("static void io_step(")
    io_loop_start = c.find("OUTLINE void io_loop(", io_step_start)
    assert io_step_start >= 0 and io_loop_start > io_step_start
    io_step = c[io_step_start:io_loop_start]
    assert io_step.index("Term req = corpus_eval(") < io_step.index("Term x = io_exec(")
    assert "io_feature_capture_run" in source_c and "io_interval_finish_run" in source_c

    result = {
        "status": "GENERATED_JS_NATIVE_TIMER_ORDER_PASS",
        "sourceBasis": {"path": str(basis_path), "sha256": basis_sha},
        "emissionReceiptBeforeBarrier": {"path": str(RECEIPT), "sha256": receipt_sha},
        "originalEmissionReceipt": original_emission_receipt,
        "priorBarrier": {"path": str(previous_barrier), "sha256": sha(previous_barrier)} if previous_barrier else None,
        "checker": {"path": str(checker_path), "sha256": checker_sha},
        "generated": {
            "js": {"path": str(js_path), "bytes": js_path.stat().st_size, "sha256": sha(js_path)},
            "nativeC": {"path": str(c_path), "bytes": c_path.stat().st_size, "sha256": sha(c_path)},
        },
        "js": {
            "mainResetThenContinuation": main_js,
            "beginContinuationComputesCommonMain": begun_js,
            "captureThenEndThenFinish": captured_js,
            "captureDefersStdout": capture_js_impl,
            "finishEmitsAfterExpectedCount": finish_js_impl,
        },
        "native": {
            "resetBeginAndComputeContinuations": {name: cases[name] for name in sorted(required)},
            "captureEndAndFinishContinuations": {name: cases[name] for name in sorted(required)},
            "captureDefersStdout": capture_c_impl,
            "endClosesInterval": end_c_impl,
            "finishChecksThenEmits": finish_c_impl,
            "strictIoRequestBeforeForeignDispatch": io_step,
        },
        "scope": "Static checks on exact emitted JS/C only; no native build, consumer run, TS run, or timing result.",
    }
    out = EMISSION / "GENERATED-BARRIER.json"
    out.write_text(json.dumps(result, indent=2) + "\n")
    receipt["generatedBarrierPending"] = False
    receipt["generatedBarrier"] = {"path": str(out), "sha256": sha(out)}
    receipt["status"] = "EMIT_AND_GENERATED_BARRIER_COMPLETE"
    RECEIPT.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({"status": result["status"], "barrier": str(out), "sha256": sha(out)}, sort_keys=True))


if __name__ == "__main__":
    main()
