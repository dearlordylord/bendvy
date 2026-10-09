"""Lossless archive/source-metadata verifier; no child or live dependencies."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
manifest=json.loads((HERE/'FILES.json').read_text());files={};identities={}
for row in manifest['members']:
 raw=gzip.decompress((HERE/row['object']).read_bytes())
 assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
 assert row['path'] not in files
 files[row['path']]=raw;identities[row['path']]=row['sha256']
for row in manifest['externalIdentityOnly']:
 assert row['path'] not in identities
 identities[row['path']]=row['sha256']
base='/tmp/bendvy-inspect54-layout-provenance06/'
raw_plan=files[base+'plan.json'];digest=hashlib.sha256(raw_plan).hexdigest()
assert digest=='29d84873c0877de05addec99c89a025ba8ca127b130952d71ccbd4978da512d5'
plan=json.loads(raw_plan)
assert len(plan['pins'])==172
for name,sha in plan['pins'].items():assert identities[name]==sha
receipt=json.loads(files[base+'receipt.json'])
assert receipt['planSHA256']==digest and receipt['provenanceComplete'] is True
command=receipt['commands'][0]
assert len(receipt['commands'])==1 and command['argv']==plan['argv'] and command['capSeconds']==30
assert command['exit']==1 and command['failure'] is None
for key in ('stdout','stderr'):
 row=command[key];assert identities[row['path']]==row['sha256'] and len(files[row['path']])==row['bytes']
assert b'DiagnosticAbort: cooperative profiling cutoff' in files[base+'emit.stderr']
assert base+'reference.c' not in files
assert receipt['qualifiesInstalledCompiler'] is False
labels=[]
for row in receipt['guards']:
 assert identities[row['path']]==row['sha256']
 guard=json.loads(files[row['path']]);assert guard['unchanged'] is True
 labels.append(guard['label'])
 for name,sha in guard['actualPins'].items():assert identities[name]==sha
 assert set(plan['pins'])<=set(guard['actualPins'])
assert labels==['emit-pre','emit-acquired','emit-post','final']
runner=[name for name in plan['pins'] if name.endswith('/cpu-profile-v1/diagnostic-run.py')]
assert len(runner)==1
namespace={'__file__':runner[0],'__name__':'retained_diagnostic'}
exec(compile(files[runner[0]],runner[0],'exec'),namespace)
# Source joins resolve archived bytes rather than requiring original worktrees.
class ArchivedPath:
 def __init__(self,name):self.name=str(name)
 def read_text(self):return files[self.name].decode()
namespace['Path']=ArchivedPath
namespace['sha']=lambda name:identities[str(name)]
raw=files[base+'provenance.json'];assert hashlib.sha256(raw).hexdigest()==receipt['provenanceSHA256']
data=json.loads(raw,object_pairs_hook=namespace['unique_object'])
summary=namespace['validate_provenance'](data,plan)
assert summary==receipt['provenanceSummary']
assert summary=={'calls':2425856,'definitions':2018,'unknownCalls':0,'omitted':2424545,'errors':0,'mapped':2017,'unmapped':1}
profile_raw=files[base+'recursive.cpuprofile'];assert hashlib.sha256(profile_raw).hexdigest()==receipt['profileSHA256']
profile=json.loads(profile_raw);namespace['validate_profile'](profile)
assert len(profile['samples'])==receipt['profileSamples']==18965
analysis=json.loads((HERE/'ANALYSIS.json').read_text())
assert analysis['negativeTimeDeltas']==sum(x<0 for x in profile['timeDeltas'])==1
mapping={row['definition']:row for row in data['mapping']};rows=data['observed']['rows']
expected_top=[]
for key,count in sorted(data['observed']['definitionCounts'],key=lambda row:row[1],reverse=True)[:12]:
 expected_top.append({'definition':key,'calls':count,'mapping':mapping[key],'retainedShapes':sum(row['definition']==key for row in rows)})
assert analysis['topDefinitionInvocationCounts']==expected_top
assert analysis['unmapped']==[row for row in data['mapping'] if row['status']!='mapped']
assert analysis['retainedShapes']==len(rows)==256
assert analysis['maxRetainedFromWidth']==max(row['from']['width'] for row in rows)==36
assert analysis['maxRetainedToWidth']==max(row['to']['width'] for row in rows)==36
print('PASS111 lossless members,172 identities,4 guards, complete provenance/source/Book/counters/profile; cooperative compiler failure retained')
