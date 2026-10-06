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
result = {'scope': 'Raw same-C TUNE Dense1024/64ticks/64fresh-worlds diagnosis only; no qualification, keep or full-matrix acceptance',
          'cohorts': {}, 'receiptPins': {}}
index_path=Path(a.prefix+'-index.json')
index=json.loads(index_path.read_text());result['receiptPins'][str(index_path)]=hashlib.sha256(index_path.read_bytes()).hexdigest()
assert len(index['rows'])==20
for schema in ['Motion', 'Health']:
    records = []
    for rotation in range(10):
        path = Path(a.prefix + '-' + schema.lower() + '-r' + str(rotation)) / 'evidence.json'
        row=next(x for x in index['rows'] if x['schema']==schema and x['rotation']==rotation)
        if not path.exists():
            records.append({'schema':schema,'rotation':rotation,'status':row['status'],'planSHA256':index['planSHA256']});continue
        data = path.read_bytes()
        result['receiptPins'][str(path)] = hashlib.sha256(data).hexdigest()
        assert result['receiptPins'][str(path)]==row['receiptSHA256']
        record = json.loads(data)
        if row['status'] != 'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS':
            record['reportedReceiptStatus']=record['status'];record['status']=row['status']
        assert record['schema'] == schema and record['rotation'] == rotation
        records.append(record)
    assert len({r['planSHA256'] for r in records}) == 1
    complete = all(r['status'] == 'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for r in records)
    cohort = {'complete': complete, 'statuses': [r['status'] for r in records]}
    if complete:
        clocks = {role: [r['phaseMS'][role] for r in records] for role in records[0]['phaseMS']}
        medians = {role: statistics.median(values) for role, values in clocks.items()}
        cohort.update(rawMS=clocks, medianMS=medians,
                      rangesMS={role: [min(v), max(v)] for role, v in clocks.items()},
                      JSOverTS=medians['handoff-JS'] / medians['TS'],
                      NativeOverTS=medians['tune-Native'] / medians['TS'],
                      NativeSpeedupOverTS=medians['TS'] / medians['tune-Native'],
                      JSOverBaselineJS=medians['handoff-JS'] / medians['baseline-JS'],
                      NativeOverBaselineNative=medians['tune-Native'] / medians['baseline-Native'])
        if all('peakRSSKiB' in r for r in records):
            peaks = {role: [r['peakRSSKiB'][role] for r in records] for role in clocks}
            cohort.update(rawPeakRSSKiB=peaks,
                          medianPeakRSSKiB={role: statistics.median(v) for role, v in peaks.items()},
                          peakRSSRangesKiB={role: [min(v), max(v)] for role, v in peaks.items()},
                          RSSScope='Fresh Linux direct-child whole-process peak; not aggregate process-tree or active-Tx memory')
    result['cohorts'][schema] = cohort
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result['cohorts']))
