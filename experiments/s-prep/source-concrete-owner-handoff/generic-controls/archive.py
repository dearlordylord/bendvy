#!/usr/bin/env python3
"""Freeze finite query fields and failure history; verify every decoded member."""
import argparse,hashlib,io,json,lzma,pathlib,tarfile
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--baseline',type=P,required=True);p.add_argument('--mutants',type=P,required=True);p.add_argument('--history',type=P,nargs='*',default=[]);p.add_argument('--output',type=P,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);sha=lambda b:hashlib.sha256(b).hexdigest();files={};generated={}
base=json.loads((a.baseline/'evidence.json').read_text());mut=json.loads((a.mutants/'evidence.json').read_text());assert base['status']=='GENERIC_AFFINE_HANDOFF_FINITE_FIELDS_AND_INTENDED_NEGATIVES_PASS';assert mut['status']=='THREE_REACHED_COMPILING_QUERY_DEFECTS_ALL_EIGHT_ROLES_DETECTED';assert base['sourceManifest']==mut['sourceManifest'];assert base['sourceClosureSHA256']=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55'
for label,folder in [('baseline',a.baseline),('mutants',a.mutants),*[("history/"+f.name,f)for f in a.history]]:
 receipt=json.loads((folder/'evidence.json').read_text());assert receipt['status']!='INCOMPLETE'
 for cmd in receipt['commands']:
  if 'sha256' in cmd:assert sha((folder/cmd['log']).read_bytes())==cmd['sha256']
 for f in sorted(folder.rglob('*')):
  if not f.is_file():continue
  assert not f.is_symlink();name=label+'/'+str(f.relative_to(folder));blob=f.read_bytes()
  if f.suffix in ['.bend','.txt','.json']:files[name]=blob
  else:generated[name]={'sha256':sha(blob),'bytes':len(blob)}
for subject,data in base['subjects'].items():
 assert all(v['status']=='FULL_FIELDS_PASS' and v['records']==200 for v in data['backends'].values());assert len(data['backends'])==2;assert sha((a.baseline/'core'/ (subject+'.bend')).read_bytes())==data['fixtureSHA256']
 for m in mut['subjects'].values():
  for role,v in m['roles'].items():
   if role.startswith(subject+'-'):assert v['fixtureSHA256']==data['fixtureSHA256'] and v['oracleSHA256']==data['oracleSHA256']
for n,h in base['sourceManifest'].items():assert sha((a.baseline/'core'/P(n).name).read_bytes())==h
files['generated-artifact-pins.json']=(json.dumps(generated,indent=2)+'\n').encode();archive=a.output/'exact-observations.tar.xz';members={}
with lzma.LZMAFile(archive,'wb',preset=1) as stream:
 with tarfile.open(fileobj=stream,mode='w|') as tar:
  for name,data in sorted(files.items()):
   info=tarfile.TarInfo(name);info.size=len(data);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(data));members[name]={'sha256':sha(data),'bytes':len(data)}
with tarfile.open(archive,'r:xz') as tar:
 assert sorted(tar.getnames())==sorted(members)
 for m in tar:
  data=tar.extractfile(m).read();assert sha(data)==members[m.name]['sha256'] and len(data)==members[m.name]['bytes']
manifest={'status':'ALL_DECODED_MEMBERS_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':members};(a.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
summary={'status':'BOUNDED_GENERIC_AFFINE_QUERY_HANDOFF_PASS','sourceClosureSHA256':base['sourceClosureSHA256'],'sourceManifest':base['sourceManifest'],'subjects':4,'schemaPayloadBackendRoles':8,'fullExecutableRecords':1600,'intendedTypeNegatives':2,'compilingQueryMutants':3,'detectedMutantRoles':24,'history':[{ 'folder':f.name,'status':json.loads((f/'evidence.json').read_text())['status']}for f in a.history],'scope':'Balanced supported Array constructors and capacity <= physical size; high-water bounds tested. Exported Batch hole-world observation is accepted. No production confinement, new HA packed consumer, Tx, foreign malformed-array refinement, proof or performance acceptance.','archive':{'sha256':manifest['archiveSHA256'],'bytes':manifest['archiveBytes'],'members':len(members)}};(a.output.parent/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary['archive']))
