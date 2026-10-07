"""Diagnostic-only function entry counts, preserving complete stdout observations."""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("generated_js", type=pathlib.Path)
args = parser.parse_args()
source = args.generated_js.read_text()
names = ["evacuate", "evacuate_taken", "evacuate_phase", "evacuate_pending", "run_clo", "run_loop", "prototype_handoff_read_rows", "prototype_handoff_inspect_state",
         "prepared_swap", "swap_recovered", "recover_current", "seek", "seek_owned", "seek_view", "prepared_view_different", "array_rmw",
         "prepared_view_state", "prepared_view_carrier", "prepared_view_current", "prepared_view_projected",
         "prepared_view_taken", "prepared_view_taken_state",
         "swap_state", "view_taken", "viewed", "unseal", "unseal_erased", "recover_state", "recover_past", "recover_selected_rows",
         "prototype_handoff_recover_rows", "stamped_world", "stamped_store", "tx_set_stamped", "tx_set_fused",
         "lifecycle_world", "swap_world", "with_store_finish", "advance_clock", "get", "get_allowed", "get_world", "get_metadata_owned", "get_live_owned", "get_live_read", "metadata_valid", "valid", "valid_checked", "live_join"]
instrumented = {name: 0 for name in names}
def inject(match):
    function = match.group(1)
    labels = [name for name in names if function == name or (("$058" + name + "$126") in function or function.endswith("$058" + name + "$"))]
    if not labels:
        return match.group(0)
    label = labels[0]
    instrumented[label] += 1
    return match.group(0) + "\n  routeCounts[" + json.dumps(label) + "]++;"
diagnostic = re.sub(r"function ([^\s(]+)\([^)]*\) \{", inject, source)
literal_tags = sorted(set(re.findall(r'\{\$: "([^"]+)"', diagnostic)))
def literal(match):
    tag = match.group(1)
    return '{$: (literalCounts[' + json.dumps(tag) + ']++, ' + json.dumps(tag) + ')'
diagnostic = re.sub(r'\{\$: "([^"]+)"', literal, diagnostic)
diagnostic = "const literalCounts = " + json.dumps({tag: 0 for tag in literal_tags}) + ";\n" + diagnostic
diagnostic = "const routeCounts = " + json.dumps({name: 0 for name in names}) + ";\n" + diagnostic
diagnostic = "process.on('exit', () => process.stderr.write(JSON.stringify({entries:routeCounts,objectLiterals:literalCounts})+'\\n'));\n" + diagnostic
with tempfile.TemporaryDirectory(prefix="bendvy-compose30-profile-") as directory:
    generated = pathlib.Path(directory) / "profile.js"
    generated.write_text(diagnostic)
    result = subprocess.run(["node", str(generated)], timeout=5, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stderr)
    counts = json.loads(result.stderr.strip())
    observation = json.loads(result.stdout)
    print(json.dumps({"generatedSHA256": hashlib.sha256(source.encode()).hexdigest(),
                      "instrumentedFunctions": instrumented, "entries": counts["entries"], "objectLiterals": counts["objectLiterals"],
                      "completeObservation": observation,
                      "scope": "function calls and emitted constructor-literal evaluations; not physical allocation bytes or elapsed timing"}, indent=2))
