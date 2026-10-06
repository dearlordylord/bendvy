#!/usr/bin/env python3
"""Read-only decoded archive integrity review; no task's semantic execution inherited."""
import pathlib,json,hashlib,tarfile,argparse
p=argparse.ArgumentParser();p.add_argument('--root',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda b:hashlib.sha256(b).hexdigest();r=[]
for rel,archive,manifest in [('source-slot-host-controls','original-host.tar.gz','original-host-manifest.json'),('source-slot-host-controls','host12-mutants.tar.gz','host12-mutants-manifest.json'),('source-slot-host-controls','e11-original-access.tar.gz','e11-original-access-manifest.json'),('source-slot-host-tx-controls','evidence.tar.gz','evidence.tar.gz.manifest.json')]:
 base=a.root/'experiments/s-prep'/rel;ap=base/archive;mp=base/manifest;data=json.loads(mp.read_text());assert sha(ap.read_bytes())==data['archiveSHA256'];count=0
 with tarfile.open(ap) as tar:
  if 'members' in data:
   for name,digest in data['members'].items():assert sha(tar.extractfile(name).read())==digest,name;count+=1
  else:
   verified={}
   for name,item in data['files'].items():
    digest=item['SHA256']
    if digest not in verified:verified[digest]=tar.extractfile('blobs/'+digest).read()
    assert sha(verified[digest])==digest and len(verified[digest])==item['bytes'];count+=1
 r.append({'archive':str(ap.relative_to(a.root)),'archiveSHA256':data['archiveSHA256'],'manifestSHA256':sha(mp.read_bytes()),'decodedMembersOrLogicalFilesVerified':count})
a.output.write_text(json.dumps({'status':'READ_ONLY_FOUR_ARCHIVES_DECODED_SHA_PASS','archives':r},indent=2)+'\n')
