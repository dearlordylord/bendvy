"""Complete literal machine observations; no field projection."""
from pathlib import Path
import hashlib,re
def decode_string(text):
 if type(text) is not str or not text.startswith('"') or not text.endswith('"\n'):
  raise ValueError('Exactly one printed Bend String with final LF required')
 body=text[1:-2];result=[];at=0
 escapes={'n':'\n','t':'\t','r':'\r','0':'\0','\\':'\\','"':'"'}
 while at<len(body):
  char=body[at];at+=1
  if char=='\\':
   if at==len(body):raise ValueError('Incomplete String escape')
   char=body[at];at+=1
   if char in escapes:result.append(escapes[char]);continue
   if char!='u' or at==len(body) or body[at]!='{':raise ValueError('Unknown String escape')
   end=body.find('}',at+1)
   if end<0:raise ValueError('Incomplete codepoint escape')
   digits=body[at+1:end]
   if not digits or any(c not in '0123456789abcdef' for c in digits):raise ValueError('Malformed codepoint escape')
   value=int(digits,16)
   if value>0x10ffff:raise ValueError('Codepoint outside fixture String domain')
   if digits!=format(value,'x') or not (value<32 or value==127 or 0xd800<=value<=0xdfff) or value in (0,9,10,13):raise ValueError('Noncanonical printer escape')
   result.append(chr(value));at=end+1
  else:
   if char=='"' or ord(char)<32 or ord(char)==127 or 0xd800<=ord(char)<=0xdfff:raise ValueError('Unescaped String character')
   result.append(char)
 return ''.join(result)

class TERM:
 @staticmethod
 def strict_equal(actual,expected):
  if type(actual) is not dict or type(expected) is not dict or actual!=expected:raise ValueError('Entire literal output differs')
class Transport:
 def __init__(self,entry):self.entry=Path(entry).resolve(strict=True)
 def inventory(self):
  seen={}
  def visit(p):
   p=p.resolve(strict=True);key=str(p)
   if key in seen:return
   seen[key]=hashlib.sha256(p.read_bytes()).hexdigest()
   for value in re.findall(r'^import (\S+)',p.read_text(),re.M):visit(Path('/home/node/.bend/bend2/base.bend') if value=='Base' else p.parent/value)
  visit(self.entry)
  return {'entrypoint':str(self.entry),'sourceSHA256':seen}
 def normalize(self,text):
  text=decode_string(text)
  observed={};schema=None
  for line in text.splitlines():
   if line.startswith('SCHEMA='):
    schema=line[7:]
    if schema not in ('A','B') or schema in observed:raise ValueError('Unexpected/duplicate schema')
    observed[schema]=[];continue
   if schema is None or not line:raise ValueError('Unframed observation')
   label,status,body=line.split('|',2)
   pairs=[part.split('=',1) for part in body.split(';')]
   if any(len(pair)!=2 for pair in pairs):raise ValueError('Malformed full field')
   if len(pairs)!=len({k for k,v in pairs}) or not all(k and v for k,v in pairs):raise ValueError('Duplicate/empty field')
   if any(row['label']==label for row in observed[schema]):raise ValueError('Duplicate checkpoint')
   observed[schema].append({'label':label,'status':status,'fields':dict(pairs)})
  if tuple(observed)!=('A','B'):raise ValueError('Missing/reordered schema')
  count=5 if self.entry.name=='flow-only.bend' else 17
  if any(len(rows)!=count for rows in observed.values()):raise ValueError('Missing/extra checkpoint')
  return observed
