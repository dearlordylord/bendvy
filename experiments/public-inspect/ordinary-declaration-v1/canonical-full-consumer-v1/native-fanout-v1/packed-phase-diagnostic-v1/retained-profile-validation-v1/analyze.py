"""Whole copied-execution self-sample counts only; runs after full validation PASS."""
import collections,hashlib,json,sys
from pathlib import Path
plan=json.loads(Path(sys.argv[1]).read_text());raw=Path(plan['capturedProfile']).read_bytes();capture=json.loads(Path(plan['profileCaptureMetadata']).read_text())
assert hashlib.sha256(raw).hexdigest()==capture['sha256'] and len(raw)==capture['bytes']
profile=json.loads(raw);nodes={n['id']:n for n in profile['nodes']}
counts=collections.Counter((nodes[i]['callFrame']['functionName'],nodes[i]['callFrame']['url'])for i in profile['samples'])
assert sum(counts.values())==len(profile['samples'])
phase=[json.loads(l[len('BENDVY_PHASE '):])for l in (Path(plan['retainedRoot'])/'source-copy-emit.stderr').read_text().splitlines()]
print(json.dumps({'scope':'Retained fully validated copied-execution profile self-sample counts; not phase-aligned timing, allocation/GC cause, stock/backend/performance/refinement evidence','profileSHA256':capture['sha256'],'samples':len(profile['samples']),'nodes':len(profile['nodes']),'topSelfSampleNames':[{'functionName':name,'url':url,'samples':n}for (name,url),n in counts.most_common(30)],'phaseEvents':phase,'limits':'Samples span startup/checking/lowering/emission. Phase logs lack an absolute alignment anchor, so no per-phase percentage attribution. Anonymous/builtin frames remain unattributed; helper instrumentation changes sampled copied execution.'},indent=2))
