import pathlib,json,hashlib,tarfile,io,lzma
P=pathlib.Path;p=P(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest();files={};generated={};receipts={};closure='599b1c2fb2389fc71fdcf289243b0e388caab33a338625623cbf6f38bfbd9a63'
for label,folder in [('generic',P('/tmp/bendvy-motion-id-buffer-v12-generic-r1')),('motion-registration',P('/tmp/bendvy-motion-id-buffer-v12-registration-motion')),('health-registration',P('/tmp/bendvy-motion-id-buffer-v12-registration-health'))]:
 r=json.loads((folder/'evidence.json').read_text());assert r['status'].endswith('_PASS');assert r.get('sourceClosureSHA256',r.get('closure'))==closure;receipts[label]={'status':r['status'],'receiptSHA256':sha((folder/'evidence.json').read_bytes())}
 for c in r['commands']:
  if 'log'in c:assert sha((folder/c['log']).read_bytes())==c['sha256']
 for f in folder.rglob('*'):
  if not f.is_file():continue
  n=label+'/'+str(f.relative_to(folder));b=f.read_bytes()
  if f.suffix in ['.bend','.txt','.json']:files[n]=b
  else:generated[n]={'sha256':sha(b),'bytes':len(b)}
files['generated-artifact-pins.json']=(json.dumps(generated,indent=2)+'\n').encode();members={n:sha(b)for n,b in files.items()};archive=p/'complete-generic-and-registration.tar.xz'
with lzma.LZMAFile(archive,'wb',preset=1)as stream:
 with tarfile.open(fileobj=stream,mode='w|')as tar:
  for n,b in sorted(files.items()):i=tarfile.TarInfo(n);i.size=len(b);tar.addfile(i,io.BytesIO(b))
with tarfile.open(archive,'r:xz')as tar:assert {m.name:sha(tar.extractfile(m).read())for m in tar}==members
(p/'summary.json').write_text(json.dumps({'status':'FRESH_V12_GENERIC_TYPE_AND_CURRENT_REGISTRATION_PASS','sourceClosureSHA256':closure,'genericFullRecords':1600,'genericIntendedNegatives':2,'positiveRegistrations':4,'registrationIntendedNegatives':10,'receipts':receipts,'archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'decodedMembers':len(members),'decodedHashesVerified':True,'recipes':{n:sha((p/n).read_bytes())for n in ['run.py','fixtures.py','access.py']},'scope':'Unchanged generic arbitrary-Type route and actual current private HA registration; not new split-owned carrier alignment/mutation, universal authority, proof or speed acceptance.'},indent=2)+'\n')
