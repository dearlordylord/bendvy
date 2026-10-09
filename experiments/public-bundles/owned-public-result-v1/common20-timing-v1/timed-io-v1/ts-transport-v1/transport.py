"""Full pinned TS source-stage identity plus exact whole literal String gate."""
from pathlib import Path
import hashlib,json
TERM_PATH=Path(__file__).resolve()
class TERM:
 @staticmethod
 def strict_equal(actual,expected):
  if type(actual) is not str or type(expected) is not str or actual!=expected:raise ValueError('Entire literal output differs')
class Transport:
 def __init__(self,entry):self.entry=Path(entry).resolve();self.here=self.entry.parent.parent/'ts-semantic-v1'
 def inventory(self):
  binding=json.loads((self.here/'SOURCE-BINDING.json').read_bytes());stage=self.here/'stage-v1';core=Path(binding['core'])
  def files(root):return {str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(root.rglob('*')) if f.is_file()}
  original=files(core/'src');copied=files(stage/'core/src')
  if original!=binding['coreSourceMembership'] or copied!=binding['stageCoreMembership'] or copied!=original:raise ValueError('Full original/staged core membership or bytes changed')
  def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
  if digest(core/'package.json')!=binding['packageSHA256'] or digest(stage/'core/package.json')!=binding['packageSHA256']:raise ValueError('Core package source-stage join changed')
  raw=Path(binding['originalCallable']).read_bytes();staged=(stage/'reference.mjs').read_bytes()
  if digest(Path(binding['originalReference']))!=binding['originalReferenceSHA256']:raise ValueError('Original qualified reference changed')
  if digest(Path(binding['originalCallable']))!=binding['originalCallableSHA256'] or staged!=raw.replace(b'../../../../.references/bevy-ts/packages/core/src/',b'./core/src/'):raise ValueError('Only exact fixture import rewrite allowed')
  if digest(stage/'main.mjs')!=binding['mainSHA256'] or digest(stage/'reference.mjs')!=binding['stagedReferenceSHA256']:raise ValueError('Exact whole callable entry changed')
  paths=[self.here/'SOURCE-BINDING.json',Path(binding['originalCallable']),Path(binding['originalReference']),core/'package.json',stage/'core/package.json',stage/'reference.mjs',stage/'main.mjs',*sorted((core/'src').rglob('*')),*sorted((stage/'core/src').rglob('*'))]
  sources={str(f.resolve()):digest(f) for f in paths if f.is_file()}
  sources[str(self.entry)]=digest(self.entry)
  capture=self.entry.parents[5]/'benchmarks/parity-features/capture.mjs'
  sources[str(capture)]=digest(capture)
  return {'entrypoint':str(self.entry),'sourceSHA256':sources}
 def normalize(self,text):
  if type(text) is not str:raise ValueError('String output required')
  return text

import json

def digest(data):
 value=2166136261
 for byte in data:value=((value^byte)*16777619)&0xffffffff
 return value

def metric(stderr,stdout,allow_tail=False):
 first,sep,tail=stderr.partition(b"\n")
 if not sep or (tail and not allow_tail):raise ValueError('Exactly one timer metadata line required')
 def unique(pairs):
  value={}
  for key,item in pairs:
   if key in value:raise ValueError('Duplicate timer metadata field')
   value[key]=item
  return value
 value=json.loads(first,object_pairs_hook=unique)
 if type(value) is not dict or set(value)!={'elapsedNs','bytes','digest'}:raise ValueError('Timer metadata fields differ')
 if type(value['elapsedNs']) is not str or not value['elapsedNs'].isascii() or not value['elapsedNs'].isdigit():raise ValueError('Timer elapsed decimal String required')
 if type(value['bytes']) is not int or type(value['digest']) is not int or value['bytes']!=len(stdout) or value['digest']!=digest(stdout):raise ValueError('Timer complete UTF8 bytes/digest differs')
 return value,tail

def validate_result(result,expected,control):
 wanted=expected.encode('utf8')
 if control:
  prefix=b''.join(wanted.splitlines(keepends=True)[:9])
  if result['failure'] is not None or result['exit'] not in (1,2) or result['stdout']!=prefix:raise ValueError('Early-end control must finish with exact nine-line prefix and actual refusal')
  value,tail=metric(result['stderr'],prefix,True)
  if not (b'capture outside feature timer' in tail or tail==b'feature timer protocol failure\n'):raise ValueError('Actual late capture refusal missing')
  if result['stdout']==wanted:raise ValueError('Positive whole gate unexpectedly accepted early-end')
  return {'scope':'reached early-end refusal; not timing acceptance','timer':value,'wholePositiveRejected':True}
 if result['failure'] is not None or result['exit']!=0:raise ValueError('Timer consumer failed')
 if result['stdout']!=wanted:raise ValueError('Entire literal output differs')
 value,_=metric(result['stderr'],wanted)
 return {'scope':'IO timer semantic protocol qualification only; no comparative timing credit','timer':value,'wholeOutputEqual':True}
