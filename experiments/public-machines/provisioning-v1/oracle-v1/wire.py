"""Pure String wire derived from pinned comp.ts C/JS show_chr/show_val/io_exit.

Prior *.stdout files are complete semantic rows plus the assumed print LF;
main String itself has NO final LF. Preserve those historical files unchanged.
"""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
COMP=Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts')
def show_chr(character):
 c=ord(character)
 special={10:'n',9:'t',13:'r',0:'0',92:'\\',34:'"'}
 if c in special:return '\\'+special[c]
 if c<32 or c==127 or 0xd800<=c<=0xdfff or c>0x10ffff:return '\\u{'+format(c,'x')+'}'
 return character
def pure_string(value):return ('"'+''.join(map(show_chr,value))+'"\n').encode('utf-8')
def expected(prefix):
 rows=(HERE/(prefix+'.stdout')).read_text()
 assert rows.endswith('\n') and not rows.endswith('\n\n')
 return pure_string(rows[:-1])
if __name__=='__main__':
 manifest={'basisCommit':'4f3ab2d9','referenceCommit':'a950fd683c0d76f09794078e6174fe98a1492876','compilerSource':{'path':str(COMP),'sha256':hashlib.sha256(COMP.read_bytes()).hexdigest()},'sourceRules':['C show_chr5726/show_val5773','JS show_chr6089/show_val6116/io_exit6136'],'correction':'pure String wraps quotes/escapes internal LF and appends one external LF; unchanged semantic row model; historical unquoted stdout files preserved','files':{}}
 for prefix in ['expected','mutant-expected','flow-only-expected']:
  value=expected(prefix);name=prefix+'-wire.stdout';(HERE/name).write_bytes(value)
  manifest['files'][name]={'bytes':len(value),'sha256':hashlib.sha256(value).hexdigest(),'semanticJSON':prefix+'.json','historicalRows':prefix+'.stdout'}
 (HERE/'WIRE-BASIS.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(json.dumps(manifest['files'],indent=2))
