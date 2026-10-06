#!/usr/bin/env python3
import argparse
import hashlib
import json
import statistics
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert not a.output.exists()
result = {'scope': 'Raw seven-rotation Dense size observations; no qualification, keep or full-matrix acceptance', 'cohorts': {}, 'receiptPins': {}}
for schema in ['Motion', 'Health']:
    for count in [64,1024]:
        rows = []
        for rotation in range(7):
            path = Path(f'/tmp/bendvy-handoff-v8-dense-{schema.lower()}-{count}-r{rotation}/evidence.json')
            result['receiptPins'][str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
            row = json.loads(path.read_text())
            assert (row['schema'], row['count'], row['rotation']) == (schema,count,rotation)
            rows.append(row)
        cohort = {'statuses': [r['status'] for r in rows], 'complete': all(r['status'] == 'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for r in rows)}
        if cohort['complete']:
            clocks = {role: [r['phaseMS'][role] for r in rows] for role in ['TS','JS','Native']}
            peaks = {role: [r['peakRSSKiB'][role] for r in rows] for role in clocks}
            medians = {role: statistics.median(v) for role,v in clocks.items()}
            cohort.update(rawMS=clocks, medianMS=medians, rangesMS={k:[min(v),max(v)] for k,v in clocks.items()},
                          JSOverTS=medians['JS']/medians['TS'], NativeOverTS=medians['Native']/medians['TS'],
                          NativeSpeedupOverTS=medians['TS']/medians['Native'],
                          rawPeakRSSKiB=peaks, medianPeakRSSKiB={k:statistics.median(v) for k,v in peaks.items()},
                          RSSScope='Fresh Linux direct-child whole-process peak; not simultaneous process-tree or active-Tx memory',
                          nativeClockResolutionMS=1,
                          limit='Count64 short Native intervals are quantized; no separately approved comparison margin or noise qualification')
        result['cohorts'][f'{schema}-{count}'] = cohort
a.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:{f:v[f] for f in ['complete','medianMS','JSOverTS','NativeSpeedupOverTS','medianPeakRSSKiB'] if f in v} for k,v in result['cohorts'].items()}))
