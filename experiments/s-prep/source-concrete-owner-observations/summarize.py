#!/usr/bin/env python3
"""Summarize all ten fixed rotations, retaining failures and every raw clock."""
import argparse
import hashlib
import json
import statistics
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--prefix', required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert not a.output.exists()
result = {'scope': 'Raw concrete-owner Dense1024/64ticks/64fresh-worlds diagnosis only; no qualification, keep or full-matrix acceptance',
          'cohorts': {}, 'receiptPins': {}}
for schema in ['Motion', 'Health']:
    records = []
    for rotation in range(10):
        path = Path(a.prefix + '-' + schema.lower() + '-r' + str(rotation)) / 'evidence.json'
        data = path.read_bytes()
        result['receiptPins'][str(path)] = hashlib.sha256(data).hexdigest()
        record = json.loads(data)
        assert record['schema'] == schema and record['rotation'] == rotation
        records.append(record)
    complete = all(r['status'] == 'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for r in records)
    cohort = {'complete': complete, 'statuses': [r['status'] for r in records]}
    if complete:
        clocks = {role: [r['phaseMS'][role] for r in records] for role in records[0]['phaseMS']}
        medians = {role: statistics.median(values) for role, values in clocks.items()}
        cohort.update(rawMS=clocks, medianMS=medians,
                      rangesMS={role: [min(v), max(v)] for role, v in clocks.items()},
                      JSOverTS=medians['handoff-JS'] / medians['TS'],
                      NativeOverTS=medians['handoff-Native'] / medians['TS'],
                      NativeSpeedupOverTS=medians['TS'] / medians['handoff-Native'],
                      JSOverBaselineJS=medians['handoff-JS'] / medians['baseline-JS'],
                      NativeOverBaselineNative=medians['handoff-Native'] / medians['baseline-Native'])
        if all('peakRSSKiB' in r for r in records):
            peaks = {role: [r['peakRSSKiB'][role] for r in records] for role in clocks}
            cohort.update(rawPeakRSSKiB=peaks,
                          medianPeakRSSKiB={role: statistics.median(v) for role, v in peaks.items()},
                          peakRSSRangesKiB={role: [min(v), max(v)] for role, v in peaks.items()},
                          RSSScope='Fresh Linux direct-child whole-process peak; not aggregate process-tree or active-Tx memory')
    result['cohorts'][schema] = cohort
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result['cohorts']))
