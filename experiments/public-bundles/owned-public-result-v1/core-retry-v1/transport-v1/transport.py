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
  return {'entrypoint':str(self.entry),'sourceSHA256':seen}
 def normalize(self,text):
  if type(text) is not str:raise ValueError('String output required')
  return text
