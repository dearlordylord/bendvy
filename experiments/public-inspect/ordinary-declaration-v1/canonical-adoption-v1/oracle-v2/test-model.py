import copy,gzip,json
import expected as E
for name,omit in [('normal',False),('mutant',True)]:
 text=E.model(omit);raw=(text+'\n').encode()
 assert (E.HERE/(name+'-expected.stdout')).read_bytes()==raw
 assert gzip.decompress((E.HERE/(name+'-expected.stdout.gz')).read_bytes())==raw
 assert json.loads((E.HERE/(name+'-expected.json')).read_text())==text
 lines=text.split('\n');assert len(lines)==4
 assert lines[0].startswith('first.before|') and lines[2].startswith('second.before|')
 assert lines[0].split('|',1)[1]==lines[1].split('|',1)[1]==lines[2].split('|',1)[1]==lines[3].split('|',1)[1]
 assert 'store=Column{values=leaf:some(Payload{leaf:42});stamps=[1:1:1]}' in text
 assert 'Indexed' not in text and 'UNSUPPORTED' not in text
 assert text.count('pendingCount=0|pendingEmpty=True')==4
 assert text.count('undoCount=0|undoEmpty=True|commandsCount=0|commandsEmpty=True')==4
 assert raw+b'\n'!=raw and b'\n'.join(raw.split(b'\n')[:-2])+b'\n'!=raw
 d=E.p.delivery(omit);d['owner']['world']['resource']['value']=18
 assert E.observation(d)!=lines[-1].split('|',1)[1]
 assert raw.replace(b'leaf:42',b'leaf:43')!=raw
normal=E.model();mutant=E.model(True)
assert normal.replace('clauses=[Position:Read]','clauses=[]')==mutant
assert normal!=mutant
print('PASS whole four snapshots, restored plain owner, callback counts, clause-only mutant and complete literal corruptions')
