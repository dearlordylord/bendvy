import pathlib,json,hashlib,tarfile,io,lzma
P=pathlib.Path;p=P(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest();files={};generated={};receipts=[]
for schema in ['motion','health']:
 folder=P('/tmp/bendvy-concrete-owner-'+schema+'-dense1024-build');b=json.loads((folder/'build.json').read_text());assert b['status']=='BUILD_PASS' and b['toolBytesStableBeforeAfter'] and b['cIncludeBytesStableBeforeAfter'];assert b['sourceClosure']=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55';assert b['recipeSHA256']==sha((p/'build.py').read_bytes())
 for name,h in b['artifacts'].items():assert sha((folder/name).read_bytes())==h
 for name,h in b['sourcePins'].items():assert sha((P(b['sourceRoot'])/name).read_bytes())==h
 for f in folder.rglob('*'):
  if f.is_file():
   name='build/'+schema+'/'+str(f.relative_to(folder));blob=f.read_bytes()
   if f.name=='batch-native':generated[name]={'sha256':sha(blob),'bytes':len(blob)}
   else:files[name]=blob
 for kind in ['native','js']:
  folder=P('/tmp/bendvy-concrete-owner-'+schema+'-'+kind+'-full65');r=json.loads((folder/'evidence.json').read_text());assert r['status']=='PASS_FULL65' and r['worlds']==65;receipts.append({'schema':schema,'kind':kind,'receiptSHA256':sha((folder/'evidence.json').read_bytes()),'programSHA256':r['programSHA256']})
  for c in r['commands']:assert sha((folder/(('prepare.txt' if 'prepare-ts1024.py' in ' '.join(c['argv']) else 'ts.txt' if c['argv'][0]=='node' and c['argv'][1].endswith('reference.mjs') else 'candidate.txt'))).read_bytes())==c['outputSHA256']
  for f in folder.rglob('*'):
   if f.is_file():files['validation/'+schema+'/'+kind+'/'+str(f.relative_to(folder))]=f.read_bytes()
files['generated-artifact-pins.json']=(json.dumps(generated,indent=2)+'\n').encode();members={n:sha(b)for n,b in files.items()};archive=p/'complete-build-and-full65.tar.xz'
with lzma.LZMAFile(archive,'wb',preset=1)as stream:
 with tarfile.open(fileobj=stream,mode='w|')as tar:
  for n,b in sorted(files.items()):i=tarfile.TarInfo(n);i.size=len(b);tar.addfile(i,io.BytesIO(b))
with tarfile.open(archive,'r:xz')as tar:assert {m.name:sha(tar.extractfile(m).read())for m in tar}==members
(p/'build-full65-summary.json').write_text(json.dumps({'status':'BOTH_SCHEMAS_NATIVE_JS_DENSE1024_FULL65_PASS','sourceClosureSHA256':'a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55','receipts':receipts,'archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'decodedMembers':len(members),'allDecodedHashesVerified':True,'sourceRecipeSHA256':sha((p/'prepare.py').read_bytes()),'buildRecipeSHA256':sha((p/'build.py').read_bytes()),'validatorSHA256':sha((p/'validate-full65.py').read_bytes()),'tsPreparationSHA256':sha((p/'prepare-ts1024.py').read_bytes()),'scope':'Fresh exact authored Dense1024 workload full fields versus actual TS. Clocks diagnostic only, not comparative timing or full acceptance.'},indent=2)+'\n')
