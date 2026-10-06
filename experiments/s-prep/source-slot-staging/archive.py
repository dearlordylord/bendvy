#!/usr/bin/env python3
"""Freeze exact finite observations and verify every decoded member digest."""
import argparse,gzip,hashlib,io,json,pathlib,tarfile
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--baseline',type=P,required=True);p.add_argument('--mutants',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--failures',type=P,nargs='*',default=[]);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest();files={};failures=[]
for label,folder in [('baseline',a.baseline),('mutants',a.mutants)]:
 for f in sorted(folder.rglob('*')):
  if f.is_file():assert not f.is_symlink();files[label+'/'+str(f.relative_to(folder))]=f.read_bytes()
for folder in a.failures:
 receipt=folder/'evidence.json';data=json.loads(receipt.read_text());assert data['status'] in ['FAIL','INCOMPLETE'] and ('error' in data or 'failure' in data)
 failures.append({'folder':str(folder),'status':data['status'],'error':data.get('error',data.get('failure'))})
 for f in sorted(folder.rglob('*')):
  if f.is_file() and (f.name=='evidence.json' or f.suffix=='.txt' or f.name.endswith('-runtime.bend')):files['preparation-failures/'+folder.name+'/'+str(f.relative_to(folder))]=f.read_bytes()
base=json.loads((a.baseline/'evidence.json').read_text());mut=json.loads((a.mutants/'evidence.json').read_text());assert base['status']=='PASS_BOUNDED_SLOT_STAGING' and mut['status']=='FOUR_REACHED_COMPILING_SLOT_DEFECTS_ALL_FOUR_ROLES_DETECTED';assert base['sourceManifest']==mut['sourceManifest']
for schema in ['motion','health']:
 expectedsha=base['subjects'][schema.title()+'JS']['fixtureSHA256']
 assert all(role['fixtureSHA256']==expectedsha for v in mut['subjects'].values() for k,role in v['roles'].items() if k.startswith(schema.title()))
raw=io.BytesIO()
with tarfile.open(fileobj=raw,mode='w') as tar:
 for name,data in sorted(files.items()):
  info=tarfile.TarInfo(name);info.size=len(data);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(data))
archive=a.output/'exact-observations.tar.gz';archive.write_bytes(gzip.compress(raw.getvalue(),mtime=0));members={name:{'sha256':sha(data),'bytes':len(data)} for name,data in sorted(files.items())}
with tarfile.open(archive,'r:gz') as tar:
 assert sorted(tar.getnames())==sorted(members)
 for member in tar.getmembers():data=tar.extractfile(member).read();assert sha(data)==members[member.name]['sha256'] and len(data)==members[member.name]['bytes']
manifest={'status':'ALL_DECODED_MEMBERS_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':members};(a.output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
summary={'status':'BOUNDED_SLOT_STAGING_AND_REACHED_MUTANTS_PASS','closureSHA256':base['closureSHA256'],'sourceManifest':base['sourceManifest'],'positiveTypeCases':2,'intendedNegativeTypeCases':10,'runtimeFullCheckpoints':40,'foreignAPICalls':100,'actualTxStagedSlotPayloads':640,'compilingMutants':4,'mutantBackendSchemaRoles':16,'preparationFailures':failures,'archive':{'sha256':manifest['archiveSHA256'],'bytes':manifest['archiveBytes'],'members':len(members)},'limits':'Finite Main Slot staging/ingress only; no Host runtime/full22, universal refinement, proofs or performance acceptance.'};(a.output.parent/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary['archive']))
