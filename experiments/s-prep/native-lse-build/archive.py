import pathlib,json,hashlib,tarfile,io,lzma
P=pathlib.Path;p=P(__file__).parent;out=P('/tmp/bendvy-native-lse-build-v1');sha=lambda b:hashlib.sha256(b).hexdigest();r=json.loads((out/'evidence.json').read_text());assert r['status']=='BOTH_UNCHANGED_C_LSE_BUILD_AND_ELF_INSPECTION_PASS';assert r['recipeSHA256']==sha((p/'run.py').read_bytes());inspect=json.loads((out/'fresh-elf-inspection.json').read_text());assert inspect['status'].endswith('_PASS');assert inspect['recipeSHA256']==sha((p/'inspect.py').read_bytes());files={};blobs={};binaries={};receipts={}
def add(n,b):h=sha(b);files[n]={'sha256':h,'bytes':len(b)};blobs[h]=b
for f in out.iterdir():
 if f.is_file():
  if f.name in ['motion-native','health-native']:binaries[f.name]={'sha256':sha(f.read_bytes()),'bytes':f.stat().st_size}
  else:add('build/'+f.name,f.read_bytes())
for schema,b in r['subjects'].items():
 add('inputs/'+schema+'/batch.c',P(b['inputC']).read_bytes());add('inputs/'+schema+'/original-build.json',P(b['inputC']).with_name('build.json').read_bytes())
 for n in ['overlay.json','cache-specialization.json']:add('inputs/'+schema+'/'+n,(P(b['sourceRoot'])/n).read_bytes())
 folder=P('/tmp/bendvy-native-lse-'+schema.lower()+'-full65-v1');v=json.loads((folder/'evidence.json').read_text());assert v['status']=='PASS_FULL65' and v['programSHA256']==b['nativeSHA256'];assert v['prospectiveExecutionBytesStableBeforeAfter'];receipts[schema]={'receiptSHA256':sha((folder/'evidence.json').read_bytes()),'worlds':65,'nativeSHA256':v['programSHA256']}
 for f in folder.iterdir():
  if f.is_file():add('validation/'+schema+'/'+f.name,f.read_bytes())
add('binary-pins.json',(json.dumps(binaries,indent=2)+'\n').encode());mapping=(json.dumps(files,indent=2)+'\n').encode();archive=p/'complete-lse-evidence.tar.xz'
with lzma.LZMAFile(archive,'wb',preset=1)as stream:
 with tarfile.open(fileobj=stream,mode='w|')as tar:
  for n,b in [('files.json',mapping),*[('blobs/'+h,b)for h,b in sorted(blobs.items())]]:i=tarfile.TarInfo(n);i.size=len(b);tar.addfile(i,io.BytesIO(b))
with tarfile.open(archive,'r:xz')as tar:
 assert tar.extractfile('files.json').read()==mapping
 for n,v in files.items():b=tar.extractfile('blobs/'+v['sha256']).read();assert sha(b)==v['sha256']and len(b)==v['bytes']
(p/'summary.json').write_text(json.dumps({'status':'LSE_UNCHANGED_C_BUILD_ELF_AND_FRESH65_PASS','AT_HWCAP':r['hostBefore']['AT_HWCAP'],'HWCAP_ATOMICS':True,'soleAddedFlag':'-march=armv8-a+lse','receipts':receipts,'ELF':inspect['subjects'],'archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'logicalFiles':len(files),'uniqueBlobs':len(blobs),'allDecodedHashesVerified':True,'scope':'Verified LSE-capable Linux aarch64 host only. No source change, timing, non-LSE portability or product adoption claim.'},indent=2)+'\n')
