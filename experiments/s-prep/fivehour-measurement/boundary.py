#!/usr/bin/env python3
"""Prepare/freeze concrete executable inputs; execution acceptance remains separate."""
import argparse, hashlib, json, pathlib, shutil, subprocess, sys, re
import guard
H=pathlib.Path(__file__).resolve().parent

def prepare(js_core,native_core,output):
    guard.deadline(30); protected=guard.protected(); output.mkdir(exist_ok=False)
    closures={}; drivers={}; recipes={}; tools={}
    for backend,core in [('JS',js_core),('Native',native_core)]:
        root=core.resolve().parents[1]; receipt=root/'cache-specialization.json'; info=json.loads(receipt.read_text())
        raw=info['runtimeClosure']; digest=hashlib.sha256(json.dumps(raw,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        if digest!=info['runtimeClosureSHA256']:raise ValueError('recipe closure ledger mismatch')
        for name,pin in raw.items():
            if guard.sha(root/name)!=pin:raise ValueError('recipe actual closure differs')
            closures[str((root/name).resolve())]=pin
        recipes[backend]={'runtimeClosureSHA256':digest,'rawProviderVariant':info['rawProviderVariant'],'receipt':str(receipt),'receiptSHA256':guard.sha(receipt)}
        for q in (receipt,root/'overlay.json'):closures[str(q)]=guard.sha(q)
    recipe=guard.PROJECT/'experiments/s-prep/fivehour-cache-integration'
    recipe_members=[]
    for q in sorted(recipe.rglob('*')):
        if q.is_file() and '__pycache__' not in q.parts:
            name=q.relative_to(guard.PROJECT).as_posix();blob=subprocess.check_output(['git','-C',str(guard.PROJECT),'show','HEAD:'+name])
            if blob!=q.read_bytes():raise ValueError('recipe source differs from HEAD')
            closures[str(q)]=guard.sha(q);recipe_members.append(str(q))
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
    checks=guard.PROJECT/'experiments/s-prep/fivehour-connected-gates'
    if checks.exists():
        for q in checks.rglob('*'):
            if q.is_file() and '__pycache__' not in q.parts:closures[str(q.resolve())]=guard.sha(q)
    # Conservatively protect actual project imports used by the checks, including
    # dynamically imported helpers and Bend fixtures outside the gate directory.
    for name in subprocess.check_output(['git','-C',str(guard.PROJECT),'ls-files'],text=True).splitlines():
        q=guard.PROJECT/name
        if q.suffix in ('.py','.mjs','.bend') or q.name=='bend-check':closures[str(q.resolve())]=guard.sha(q)
    for p in H.glob('*.py'):closures[str(p.resolve())]=guard.sha(p)
    python=pathlib.Path(sys.executable).resolve();closures[str(python)]=guard.sha(python);tools['python']=str(python)
    for name in ('bend','node','clang'):
        p=pathlib.Path(shutil.which(name)).resolve();closures[str(p)]=guard.sha(p);tools[name]=str(p)
    canonical=pathlib.Path('/home/node/.codex/plugins/cache/TheGreenCedar/codex-autoresearch/3.0.0')
    for folder in ('scripts','lib','dist'):
        for q in (canonical/folder).rglob('*'):
            if q.is_file() and q.suffix in ('.mjs','.js','.ts','.json'):closures[str(q.resolve())]=guard.sha(q)
    installed=pathlib.Path.home()/'.bend/bend2'
    for p in [installed/'base.bend',*(installed/'effs').glob('*')]:
        if p.is_file():closures[str(p.resolve())]=guard.sha(p)
    manifest={'protocolVersion':'fresh16-one-bracket-v1','accepted':False,'deadlineUTC':guard.DEADLINE.isoformat(),'batch':16,'ticks':64,'schemas':['Health','Motion'],'size':256,'workload':'dense','editableTypeBlocks':{name:re.findall(r'^type [^\n]+\n(?:[ \t]+[^\n]*\n)*',pathlib.Path(name).read_text(),re.M) for backend,root in {'JS':js_core,'Native':native_core}.items() for name in [str(root/n) for n in ['storage.bend','query.bend','cache.bend','cached-payload.bend','held.bend','held-adapter.bend']+(['uncached-payload.bend'] if backend=='Native' else [])] if pathlib.Path(name).exists()},'editableHeaders':{name:[line for line in pathlib.Path(name).read_text().splitlines() if line.startswith(('def ','type '))] for backend,root in {'JS':js_core,'Native':native_core}.items() for name in [str(root/n) for n in ['storage.bend','query.bend','cache.bend','cached-payload.bend','held.bend','held-adapter.bend']+(['uncached-payload.bend'] if backend=='Native' else [])] if pathlib.Path(name).exists()},'editableSignaturePins':{name:hashlib.sha256('\n'.join(line for line in pathlib.Path(name).read_text().splitlines() if line.startswith(('def ','type '))).encode()).hexdigest() for backend,root in {'JS':js_core,'Native':native_core}.items() for name in [str(root/n) for n in ['storage.bend','query.bend','cache.bend','cached-payload.bend','held.bend','held-adapter.bend']+(['uncached-payload.bend'] if backend=='Native' else [])] if pathlib.Path(name).exists()},'checkDirectory':str(checks),'checkMembers':sorted(str(q.resolve()) for q in checks.rglob('*') if q.is_file() and '__pycache__' not in q.parts) if checks.exists() else [],'canonicalCLI':str(canonical/'scripts/autoresearch.mjs'),'recipes':recipes,'recipeDirectory':str(recipe),'recipeMembers':recipe_members,'tools':tools,'drivers':drivers,'files':closures,'backendRoots':{'JS':str(js_core.resolve()),'Native':str(native_core.resolve())},'outputRoot':str(output.resolve()),'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'scope':'focused segment only; no full-product acceptance'}
    p=output/'manifest.json';p.write_text(json.dumps(manifest,indent=2)+'\n');return guard.sha(p)

def verify(path,digest,allow=()):
    guard.deadline();
    if guard.sha(path)!=digest:raise ValueError('manifest digest differs from review binding')
    m=json.loads(path.read_text());guard.protected()
    if m['protocolVersion']!='fresh16-one-bracket-v1' or m['batch']!=16 or m['ticks']!=64 or m['schemas']!=['Health','Motion']:raise ValueError('protocol differs')
    checkdir=pathlib.Path(m['checkDirectory'])
    check_members=sorted(str(q.resolve()) for q in checkdir.rglob('*') if q.is_file() and '__pycache__' not in q.parts) if checkdir.exists() else []
    if check_members!=m['checkMembers']:raise ValueError('check source directory membership changed')
    actual_members=sorted(str(q) for q in pathlib.Path(m['recipeDirectory']).rglob('*') if q.is_file() and '__pycache__' not in q.parts)
    if actual_members!=m['recipeMembers']:raise ValueError('recipe directory membership changed')
    for name,pin in m['files'].items():
        if name not in allow and guard.sha(pathlib.Path(name))!=pin:raise ValueError('source/tool closure changed: '+name)
    for schema in m['schemas']:
        for backend in ('Native','JS'):
            p=pathlib.Path(m['drivers'][schema][backend]);actual=guard.bend_closure(p,[p.parent,pathlib.Path(m['backendRoots'][backend])])
            if any(name not in allow and m['files'].get(name)!=pin for name,pin in actual.items()):raise ValueError('unbound derived import')
    return m

if __name__=='__main__':
    a=argparse.ArgumentParser();sub=a.add_subparsers(dest='mode',required=True)
    p=sub.add_parser('prepare');p.add_argument('--js-core',type=pathlib.Path,required=True);p.add_argument('--native-core',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True)
    p=sub.add_parser('verify');p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--sha256',required=True)
    args=a.parse_args()
    if args.mode=='prepare':print(prepare(args.js_core,args.native_core,args.output))
    else:verify(args.manifest,args.sha256);print('SOURCE_TOOL_IMPORT_DEADLINE_PREFLIGHT_PASS')
