"""Exact complete String output and current consuming import-closure guard."""
from pathlib import Path
import hashlib,re
TERM_PATH=Path(__file__).resolve()
class TERM:
 @staticmethod
 def strict_equal(actual,expected):
  if type(actual) is not dict or type(expected) is not dict or actual!=expected:raise ValueError('Entire literal output differs')
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
  return {'entrypoint':str(self.entry),'sourceSHA256':seen}
 def normalize(self,text):
  if type(text) is not str:raise ValueError('String output required')
  observed={};schema=None;world=None;instances=False
  for line in text.splitlines():
   if line.startswith('SCHEMA='):
    schema=line[7:]
    if schema not in ['A','B'] or schema in observed:raise ValueError('Unexpected/duplicate schema')
    observed[schema]={'worlds':{},'instances':[]};world=None;instances=False;continue
   if line.startswith('WORLD='):
    world=line[6:]
    if not schema or world not in ['A','B'] or world in observed[schema]['worlds']:raise ValueError('Unexpected/duplicate world')
    observed[schema]['worlds'][world]=[];instances=False;continue
   if line=='INSTANCES':
    if not schema or instances:raise ValueError('Unexpected instance frame')
    instances=True;continue
   if not schema or not line:raise ValueError('Unframed observation')
   if instances:observed[schema]['instances'].append(line);continue
   if not world:raise ValueError('Missing world')
   label,status,body=line.split('|',2);pairs=[part.split('=',1) for part in body.split(';')]
   if len(pairs)!=len({k for k,v in pairs}) or not all(k and v for k,v in pairs):raise ValueError('Duplicate/empty field')
   observed[schema]['worlds'][world].append({'label':label,'status':status,'fields':dict(pairs)})
  return observed
