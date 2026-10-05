#!/usr/bin/env python3
"""Proposed exact candidate allowlist snapshot; no benchmark or acceptance."""
import hashlib,json,pathlib,shutil,subprocess,sys,re
import boundary,guard
H=pathlib.Path(__file__).resolve().parent
EDITABLE={'storage.bend','query.bend','cache.bend','cached-payload.bend','held.bend','held-adapter.bend'}

def editable(m):
    return {str(pathlib.Path(root)/name) for backend,root in m['backendRoots'].items() for name in EDITABLE|({'uncached-payload.bend'} if backend=='Native' else set()) if (pathlib.Path(root)/name).exists()}

def capture(path,digest,output):
    # Verify immutable ledger digest before deriving the exact editable paths.
    if guard.sha(path)!=digest:raise ValueError('reviewed manifest digest changed')
    original=json.loads(path.read_text());allow=editable(original)
    for name in allow:
        lines='\n'.join(line for line in pathlib.Path(name).read_text().splitlines() if line.startswith(('def ','type ')))
        text=pathlib.Path(name).read_text()
        code='\n'.join(line.split('#',1)[0] for line in text.splitlines())
        if re.search(r'\bunsafe\b|\bforeign\s+(?:def|type)\b',code):raise ValueError('unsafe/foreign source forbidden')
        for block in original['editableTypeBlocks'][name]:
            if text.count(block)!=1:raise ValueError('nominal type constructors changed')
        actual=lines.splitlines()
        for header in original['editableHeaders'][name]:
            if actual.count(header)!=1:raise ValueError('existing definition/type signature changed')
    boundary.verify(path,digest,allow=allow);output.mkdir(exist_ok=False)
    m=dict(original);m['drivers']={};m['files']={};m['backendRoots']={};current={}
    for backend,oldroot in original['backendRoots'].items():
        root=pathlib.Path(oldroot);dest=output/backend/'experiments/s-integrate';dest.mkdir(parents=True)
        # Copy only fully bound Bend core inputs; deny hidden imported additions.
        names={pathlib.Path(name) for name in original['files'] if pathlib.Path(name).is_relative_to(root) and name.endswith('.bend')}
        for old in sorted(names):
            relative=old.relative_to(root);target=dest/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(old.read_bytes());current[str(old)]=guard.sha(old)
        m['backendRoots'][backend]=str(dest.resolve())
        source_root=root.parents[1];overlay=json.loads((source_root/'overlay.json').read_text());cache=json.loads((source_root/'cache-specialization.json').read_text());runtime=guard.bend_closure(dest/'measurement-bend.bend',[dest]);relative={str(pathlib.Path(name).relative_to((output/backend).resolve())):pin for name,pin in runtime.items()}
        cache['initialRecipeReceiptSHA256']=guard.sha(source_root/'cache-specialization.json')
        for key,filename in [('cacheSourceSHA256','cache.bend'),('cachedPayloadSHA256','cached-payload.bend'),('rawProviderSHA256','uncached-payload.bend')]:
            cache[key]=guard.sha(dest/filename)
        cache['runtimeClosure']=relative;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(relative,sort_keys=True,separators=(',',':')).encode()).hexdigest();cache['capturedParentManifestSHA256']=digest
        overlay['sources']=relative;overlay['cacheSpecialization']=cache
        (output/backend/'overlay.json').write_text(json.dumps(overlay,indent=2)+'\n');(output/backend/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
        for schema in original['schemas']:
            folder=output/'drivers'/backend/schema
            subprocess.run([sys.executable,H/'prepare-bend.py','--core',dest,'--output',folder,'--schema',schema,'--batch','16'],check=True,timeout=5)
            m['drivers'].setdefault(schema,{})[backend]=str((folder/'batch.bend').resolve());m['files'].update(guard.bend_closure(folder/'batch.bend',[folder,dest]))
    for schema in original['schemas']:
        old=pathlib.Path(original['drivers'][schema]['TS']);dest=output/(schema+'-reference.mjs');dest.write_bytes(old.read_bytes());m['drivers'][schema]['TS']=str(dest.resolve());m['files'][str(dest.resolve())]=guard.sha(dest)
    # All external immutable method/tool/reference/recipe inputs stay bound.
    roots=[pathlib.Path(x) for x in original['backendRoots'].values()]
    olddrivers=[pathlib.Path(x).parent for v in original['drivers'].values() for k,x in v.items() if k!='TS']
    for name,pin in original['files'].items():
        p=pathlib.Path(name)
        if not any(p.is_relative_to(r) for r in roots+olddrivers) and name not in [v['TS'] for v in original['drivers'].values()]:m['files'][name]=pin
    boundary.verify(path,digest,allow=allow)
    if any(guard.sha(pathlib.Path(name))!=pin for name,pin in current.items()):raise ValueError('candidate changed during snapshot')
    m['outputRoot']=str(output.resolve());m['capturedCandidateBytes']=current;m['acceptedParentManifestSHA256']=digest;m['snapshotOnly']=True
    target=output/'manifest.json';target.write_text(json.dumps(m,indent=2)+'\n');return target,guard.sha(target)

if __name__=='__main__':
    import argparse
    a=argparse.ArgumentParser();a.add_argument('--manifest',type=pathlib.Path,required=True);a.add_argument('--sha256',required=True);a.add_argument('--output',type=pathlib.Path,required=True);x=a.parse_args();print(capture(x.manifest,x.sha256,x.output))
