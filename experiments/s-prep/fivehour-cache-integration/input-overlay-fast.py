"""Equivalent frozen baseline extraction in one git blob batch; no compiler changes."""
import pathlib,subprocess,hashlib,json,re
BASELINE='a976667'
def materialize(root,destination,candidate):
 destination=pathlib.Path(destination).resolve();candidate=pathlib.Path(candidate).resolve();assert not destination.exists()
 names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASELINE,'experiments'],cwd=root,timeout=5).decode().splitlines();names=[n for n in names if n.endswith('.bend')]
 data=subprocess.check_output(['git','cat-file','--batch'],input=''.join(BASELINE+':'+n+'\n' for n in names).encode(),cwd=root,timeout=5);cursor=0;sources={};overrides={}
 for name in names:
  end=data.index(b'\n',cursor);header=data[cursor:end].decode().split();assert len(header)==3 and header[1]=='blob';size=int(header[2]);cursor=end+1;blob=data[cursor:cursor+size];cursor+=size;assert data[cursor:cursor+1]==b'\n';cursor+=1
  replacement=candidate/pathlib.Path(name).name
  if pathlib.Path(name).parent==pathlib.Path('experiments/s-integrate') and replacement.is_file():blob=replacement.read_bytes();overrides[name]=str(replacement)
  target=destination/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(blob);sources[name]=hashlib.sha256(blob).hexdigest()
 assert cursor==len(data)
 for replacement in sorted(candidate.glob('*.bend')):
  if replacement.name.startswith('owned-storage-'):continue
  name='experiments/s-integrate/'+replacement.name
  if name in sources:continue
  target=destination/name;target.parent.mkdir(parents=True,exist_ok=True);blob=replacement.read_bytes();target.write_bytes(blob);sources[name]=hashlib.sha256(blob).hexdigest();overrides[name]=str(replacement)
 for name in sources:
  path=destination/name
  for imported in re.findall(r'^import\s+(\S+)',path.read_text(),re.M):
   if imported.startswith('.'):
    target=(path.parent/imported).resolve();assert target.is_relative_to(destination) and target.is_file()
 manifest={'baseline':BASELINE,'overrides':overrides,'sources':sources};(destination/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n');return manifest
