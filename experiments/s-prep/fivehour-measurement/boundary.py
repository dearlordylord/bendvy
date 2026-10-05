#!/usr/bin/env python3
"""Prepare/freeze concrete executable inputs; execution acceptance remains separate."""
import argparse, hashlib, json, pathlib, shutil, subprocess, sys
import guard
H=pathlib.Path(__file__).resolve().parent

def prepare(js_core,native_core,output):
    guard.deadline(30); protected=guard.protected(); output.mkdir(exist_ok=False)
    closures={}; drivers={}
    for schema in ('Health','Motion'):
        drivers[schema]={}
        for backend,core in [('JS',js_core),('Native',native_core)]:
            folder=output/(schema+'-'+backend)
            subprocess.run([sys.executable,str(H/'prepare-bend.py'),'--core',str(core),'--output',str(folder),'--schema',schema,'--batch','16'],check=True,timeout=5)
            entry=folder/'batch.bend';closures.update(guard.bend_closure(entry,[folder,core]))
            drivers[schema][backend]=str(entry.resolve())
        reference=output/(schema+'-reference.mjs')
        subprocess.run([sys.executable,str(H/'prepare-ts.py'),'--source',str(guard.PROJECT/'experiments/s-integrate/measurement-samples-reference.mjs'),'--output',str(reference),'--schema',schema,'--batch','16'],check=True,timeout=5)
        closures[str(reference.resolve())]=guard.sha(reference);drivers[schema]['TS']=str(reference.resolve())
    closures.update(protected)
    for name in guard.PINS:closures[str(guard.PROJECT/name)]=guard.PINS[name]
    for p in H.glob('*.py'):closures[str(p.resolve())]=guard.sha(p)
    for name in ('bend','node','clang'):
        p=pathlib.Path(shutil.which(name)).resolve();closures[str(p)]=guard.sha(p)
    installed=pathlib.Path.home()/'.bend/bend2'
    for p in [installed/'base.bend',*(installed/'effs').glob('*')]:
        if p.is_file():closures[str(p.resolve())]=guard.sha(p)
    manifest={'protocolVersion':'fresh16-one-bracket-v1','accepted':False,'deadlineUTC':guard.DEADLINE.isoformat(),'batch':16,'ticks':64,'schemas':['Health','Motion'],'size':256,'workload':'dense','drivers':drivers,'files':closures,'backendRoots':{'JS':str(js_core.resolve()),'Native':str(native_core.resolve())},'outputRoot':str(output.resolve()),'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'scope':'focused segment only; no full-product acceptance'}
    p=output/'manifest.json';p.write_text(json.dumps(manifest,indent=2)+'\n');return guard.sha(p)

def verify(path,digest):
    guard.deadline();
    if guard.sha(path)!=digest:raise ValueError('manifest digest differs from review binding')
    m=json.loads(path.read_text());guard.protected()
    if m['protocolVersion']!='fresh16-one-bracket-v1' or m['batch']!=16 or m['ticks']!=64 or m['schemas']!=['Health','Motion']:raise ValueError('protocol differs')
    for name,pin in m['files'].items():
        if guard.sha(pathlib.Path(name))!=pin:raise ValueError('source/tool closure changed: '+name)
    for schema in m['schemas']:
        for backend in ('Native','JS'):
            p=pathlib.Path(m['drivers'][schema][backend]);actual=guard.bend_closure(p,[p.parent,pathlib.Path(m['backendRoots'][backend])])
            if any(m['files'].get(name)!=pin for name,pin in actual.items()):raise ValueError('unbound derived import')
    return m

if __name__=='__main__':
    a=argparse.ArgumentParser();sub=a.add_subparsers(dest='mode',required=True)
    p=sub.add_parser('prepare');p.add_argument('--js-core',type=pathlib.Path,required=True);p.add_argument('--native-core',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True)
    p=sub.add_parser('verify');p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--sha256',required=True)
    args=a.parse_args()
    if args.mode=='prepare':print(prepare(args.js_core,args.native_core,args.output))
    else:verify(args.manifest,args.sha256);print('SOURCE_TOOL_IMPORT_DEADLINE_PREFLIGHT_PASS')
