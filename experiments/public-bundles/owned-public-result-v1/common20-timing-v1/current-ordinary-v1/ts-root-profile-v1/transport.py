"""Current TS fixture source membership; unchanged complete timer validator below."""
from pathlib import Path
import hashlib,json
TERM_PATH=Path(__file__).resolve()
class Transport:
 def __init__(self,entry):self.entry=Path(entry).resolve(strict=True)
 def inventory(self):
  here=self.entry.parent
  root=Path('/workspace/formal-proofs/bendvy')
  core=root/'.references/bevy-ts/packages/core'
  paths=[self.entry,here/'reference.mjs',root/'benchmarks/parity-features/capture.mjs',core/'package.json',*sorted((core/'src').rglob('*'))]
  sources={str(p.resolve(strict=True)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths if p.is_file()}
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
