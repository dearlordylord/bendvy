#!/usr/bin/env python3
"""Archive exact source, receipts and observations; verify every decoded digest."""
import argparse,lzma,hashlib,io,json,pathlib,tarfile
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--prepared',type=P,nargs='+',required=True);p.add_argument('--runs',type=P,nargs='+',required=True);p.add_argument('--output',type=P,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);sha=lambda b:hashlib.sha256(b).hexdigest();files={};generated={};recipes=P(__file__).parent
for folder in a.prepared:
 manifest=json.loads((folder/'adaptation.json').read_text());assert manifest['status']=='PREPARED_TRANSPORT_ONLY';core=folder/'core';assert all(sha((core/P(n).name).read_bytes())==v for n,v in manifest['sourcePins'].items());assert all(sha((core/n).read_bytes())==v for n,v in manifest['extraPins'].items())
 for f in sorted(folder.rglob('*')):
  if f.is_file() and f.suffix in ['.bend','.json']:files['prepared/'+folder.name+'/'+str(f.relative_to(folder))]=f.read_bytes()
for folder in a.runs:
 receipt=json.loads((folder/'evidence.json').read_text());assert receipt['status']!='INCOMPLETE'
 for command in receipt.get('commands',[]):
  blob=(folder/command['log']).read_bytes()
  if 'sha256' in command:assert sha(blob)==command['sha256']
 for f in sorted(folder.iterdir()):
  if not f.is_file():continue
  assert not f.is_symlink()
  if f.suffix in ['.txt','.json','.mjs','.py']:files['runs/'+folder.name+'/'+f.name]=f.read_bytes()
  else:generated[folder.name+'/'+f.name]={'sha256':sha(f.read_bytes()),'bytes':f.stat().st_size}
# Preserve the exact old executable diagnostic recipe, which used a broader status string.
old=(recipes/'run.py').read_text().replace('LISTED_DIAGNOSTIC_FIVE_FAMILY_SIZES_FULL_FIELDS_PASS','LISTED_FIVE_FAMILY_SIZES_FULL_FIELDS_PASS').encode();expected=json.loads((a.runs[0]/'evidence.json').read_text())['recipes']['run.py'];assert sha(old)==expected;files['recipes/run-executed-small-large.py']=old
files['generated-artifacts.json']=(json.dumps(generated,indent=2)+'\n').encode()
archive=a.output/'exact-observations.tar.xz';members={}
with archive.open('wb') as raw:
 with lzma.LZMAFile(raw,mode='wb',preset=1) as gz:
  with tarfile.open(fileobj=gz,mode='w|') as tar:
   for name,data in sorted(files.items()):
    info=tarfile.TarInfo(name);info.size=len(data);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(data));members[name]={'sha256':sha(data),'bytes':len(data)}
with tarfile.open(archive,'r:xz') as tar:
 assert sorted(tar.getnames())==sorted(members)
 for member in tar:
  data=tar.extractfile(member).read();assert sha(data)==members[member.name]['sha256'] and len(data)==members[member.name]['bytes']
manifest={'status':'ALL_DECODED_MEMBERS_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':members};(a.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'archiveBytes':manifest['archiveBytes'],'members':len(members)}))
