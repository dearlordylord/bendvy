"""Exact complete String output and current consuming import-closure guard."""
from pathlib import Path
import hashlib,re
TERM_PATH=Path(__file__).resolve()
class TERM:
 @staticmethod
 def strict_equal(actual,expected):
  if type(actual) is not str or type(expected) is not str or actual!=expected:raise ValueError('Entire literal output differs')
class Transport:
 def __init__(self,entry):self.entry=Path(entry).resolve()
 def inventory(self):
  seen={}
  def visit(p):
   p=p.resolve();key=str(p)
   if key in seen:return
   seen[key]=hashlib.sha256(p.read_bytes()).hexdigest()
   for value in re.findall(r'^import (\S+)',p.read_text(),re.M):visit(Path('/home/node/.bend/bend2/base.bend') if value=='Base' else p.parent/value)
  visit(self.entry)
  for suffix in ('c','js'):visit(Path(__file__).resolve().parents[8] / ('benchmarks/parity-features/timing.'+suffix))
  return {'entrypoint':str(self.entry),'sourceSHA256':seen}
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
