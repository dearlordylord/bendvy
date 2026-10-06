import pathlib,subprocess,json,hashlib
P=pathlib.Path;out=P('/tmp/bendvy-concrete-owner-layout-v3');out.mkdir();r={'status':'INCOMPLETE','commands':[],'builds':{}};sha=lambda b:hashlib.sha256(b).hexdigest();save=lambda:(out/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for schema in ['motion','health']:
 base=P('/tmp/bendvy-handoff-v8-'+schema+'-dense1024-build-r2');d=out/schema;d.mkdir()
 for n in ['batch.bend','measurement-bend.bend']:
  raw=(base/n).read_text();new=raw.replace('/tmp/bendvy-slot-host-handoff-v8-coherent','/tmp/bendvy-slot-host-concrete-owner-v3');(d/n).write_text(new);r['builds'].setdefault(schema,{})[n]={'originalSHA256':sha(raw.encode()),'outputSHA256':sha(new.encode()),'pathOnlyRewrite':True}
 cmd=['timeout','30s','taskset','-c','6','bend',str(d/'batch.bend'),'-o',str(d/'batch.c')];p=subprocess.run(cmd,capture_output=True,text=True);(d/'emit.txt').write_text(p.stdout+p.stderr);r['commands'].append({'argv':cmd,'exit':p.returncode});save();print(schema,p.returncode,(p.stdout+p.stderr)[-800:]);assert p.returncode==0;r['builds'][schema]['cSHA256']=sha((d/'batch.c').read_bytes());save()
r['status']='BOTH_ACTUAL_DENSE1024_C_EMISSION_PASS';save()
