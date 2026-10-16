#!/usr/bin/env python3
"""Independent full changed-stamp-omission countermodel. No runtime-output input."""
import copy, gzip, hashlib, json, runpy, os, re
from pathlib import Path
HERE=Path(__file__).resolve().parent
prior=runpy.run_path(str(HERE.parent/'independent-oracle-v1/prior-model.py.source'))
meta=runpy.run_path(str(HERE/'metadata-model.py.source'))
c=prior['c'];n=prior['n']

def tree(bits):
    if len(bits)==1:return c('physical.bend','LiveLeaf',c('Base','True' if bits[0] else 'False'))
    half=len(bits)//2
    return c('physical.bend','LiveNode',tree(bits[:half]),tree(bits[half:]))

def world_metadata(m):
    registrations=[c('world.bend','RegistrationMeta',i,'Simulation/'+name,meta['ACCESS'][name]) for i,name in m['registrations']]
    stamps=[c('physical.bend','StampRow',i,*[c('lifecycle.bend','Stamp',added,changed) for added,changed in row]) for i,row in m['stamps'].items()]
    return c('physical.bend','WorldMetadata',m['namespace'],m['capacity'],n(m['depth']),tree(m['live']),registrations,m['nextSystem'],stamps)

def registry(m,name):
    r=m['registries'][name]
    return c('owner-metadata.bend','RegistryMetadata',m['namespace'],r['id'],'Simulation/'+name,r['access'],r['cursor'])

def owner_metadata(m):
    optional=[c('Base','Some',registry(m,name)) if name in m['registries'] else c('Base','None') for name in ['Spawn','Move','Damage']]
    readers=[c('owner-metadata.bend','ReaderMetadata',m['namespace'],i,i,registry(m,name)) for i,name in [(1,'ReaderA'),(2,'ReaderB')]]
    return c('owner-metadata.bend','OwnerMetadata',*optional,*readers)

def report():
    schemas=[]
    for ns in [1,2]:
        phases=copy.deepcopy(prior['schema'](ns));metadata=meta['metadata'](ns)
        for phase,m in zip(phases,metadata):
            observation=phase['fields'][0];world=observation['fields'][0]['fields'][0]
            assert world['fields'][0]==m['label'] and world['fields'][6]==m['clock']
            world['fields'].append(world_metadata(m));observation['fields'].append(owner_metadata(m))
        schemas.append(phases)
    return c('main.bend','TwoSchemaReport',*schemas)

def strip_additions(report):
    result=copy.deepcopy(report)
    for phases in result['fields']:
        for phase in phases:
            observation=phase['fields'][0];observation['fields'].pop()
            observation['fields'][0]['fields'][0]['fields'].pop()
    return result

def selftest():
    value=report();assert strip_additions(value)==prior['report']
    # Distinguish registered system cursor from event-runtime reader positions.
    for ns in [1,2]:
        states=meta['metadata'](ns)
        assert states[0]['registrations']==[(2,'ReaderB'),(1,'ReaderA')]
        assert states[1]['registries']['Spawn']['cursor']==0
        assert states[-1]['nextSystem']==6
        assert all(s['registries']['ReaderA']['cursor']==s['registries']['ReaderB']['cursor']==0 for s in states)
        assert states[2]['stamps'][2]==[(4,4),(5,5),(6,6)]
        assert states[3]['stamps'][2]==[(4,4),(5,5),(6,6)]
        assert states[5]['stamps'][2]==[(0,0)]*3
    return value

def literal_report(value, entry):
    entry=Path(entry).resolve(); closure={}; todo=[entry]
    while todo:
        path=todo.pop()
        if str(path) in closure:continue
        body=path.read_bytes();closure[str(path)]=hashlib.sha256(body).hexdigest()
        for target in re.findall(r"^import ([^\s]+)",body.decode(),re.M):
            if target=='Base':dep=Path('/home/node/.bend/bend2/base.bend')
            elif target.startswith('/'):dep=Path(target)
            else:dep=(path.parent/target).resolve()
            todo.append(dep)
    labels=set()
    def collect(x):
        if isinstance(x,list):
            for v in x:collect(v)
        elif isinstance(x,dict):
            if 'constructor' in x:labels.add(x['constructor'])
            for v in x.values():collect(v)
    collect(value);mapping={}
    for label in sorted(labels):
        file,name=label.split('::')
        candidates=[Path(p) for p in closure if Path(p).name==('base.bend' if file=='Base' else file)]
        assert len(candidates)==1,(label,candidates)
        source=candidates[0];body=source.read_text();declared=set();in_type=False
        for line in body.splitlines():
            if line.startswith('type '):in_type=True;tail=line.partition(' is ')[2].partition(':')[2].strip()
            elif line and not line[0].isspace() and not line.startswith('#'):in_type=False;tail=''
            else:tail=line.strip() if in_type else ''
            found=re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*\{',tail)
            if found:declared.add(found.group(1))
        assert name in declared,(label,source)
        literal=name if file=='Base' or source==entry else os.path.relpath(source.with_suffix(''),entry.parent)+'.'+name
        mapping[label]={'literal':literal,'source':str(source),'sha256':closure[str(source)]}
    def change(x):
        if isinstance(x,list):return [change(v) for v in x]
        if isinstance(x,dict):return {k:mapping[v]['literal'] if k=='constructor' else change(v) for k,v in x.items()}
        return x
    return change(value),mapping,closure

if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument('--entry',required=True);parser.add_argument('--write',action='store_true');args=parser.parse_args()
    value=selftest();literal,mapping,closure=literal_report(value,args.entry)
    formatter=runpy.run_path(str(HERE.parent/'independent-oracle-v1/term-format.py.source'))
    raw=(formatter['render'](literal)+'\n').encode();assert formatter['parse'](raw.decode())==literal
    if args.write:
        (HERE/'expected.stdout').write_bytes(raw)
        with (HERE/'expected.stdout.gz').open('wb') as f:
            with gzip.GzipFile(fileobj=f,mode='wb',filename='',mtime=0) as z:z.write(raw)
        (HERE/'CONSTRUCTOR-JOIN.json').write_text(json.dumps(mapping,indent=2)+'\n')
        (HERE/'SOURCE-PINS.json').write_text(json.dumps(closure,indent=2)+'\n')
    else:assert raw==(HERE/'expected.stdout').read_bytes()==gzip.decompress((HERE/'expected.stdout.gz').read_bytes())
    print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'sourceCountIncludingBase':len(closure),'constructors':len(mapping),'phases':28}))
