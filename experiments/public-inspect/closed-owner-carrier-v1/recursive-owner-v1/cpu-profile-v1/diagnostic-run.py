#!/usr/bin/env python3
"""One admitted reference emit diagnostic; no installed/backend qualification."""
import fcntl,hashlib,json,os,stat,sys,types
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent

def sha(path):
    path=Path(path)
    if path.is_symlink() or not path.is_file(): raise ValueError('regular non-symlink input required')
    fd=os.open(path,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
    with os.fdopen(fd,'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular descriptor required')
        return hashlib.sha256(stream.read()).hexdigest()

VERIFIED_SOURCES={}
def load(name,path):
    path=Path(path).resolve(strict=True)
    raw=VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    m=types.ModuleType(name);m.__file__=str(path);m.__dict__['VERIFIED_SOURCES']=VERIFIED_SOURCES
    exec(compile(raw,str(path),'exec'),m.__dict__);return m

def capture(path,raw):
    if path.exists() or path.is_symlink(): raise ValueError('raw starts absent')
    fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
    with os.fdopen(fd,'wb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular raw descriptor required')
        stream.write(raw)

def validate_profile(data):
    if not isinstance(data,dict) or not isinstance(data.get('nodes'),list) or not data['nodes']:
        raise ValueError('profile nodes missing')
    ids={node['id']for node in data['nodes']}
    if len(ids)!=len(data['nodes']):raise ValueError('duplicate profile node')
    samples=data.get('samples');deltas=data.get('timeDeltas')
    if not isinstance(samples,list)or not isinstance(deltas,list)or len(samples)!=len(deltas)or not samples:
        raise ValueError('sample/delta mismatch or empty capture')
    if any(sample not in ids for sample in samples):raise ValueError('unknown sampled node')
    if any(type(delta) is not int for delta in deltas):raise ValueError('invalid sample delta')
    if data.get('endTime',-1)<data.get('startTime',0):raise ValueError('invalid profile interval')


def validate_provenance(data,plan):
    def natural(value):
        if type(value) is not int or value<0:raise ValueError('invalid provenance counter')
        return value
    if not isinstance(data,dict) or set(data)!={'observed','mapping','loaded','bookDefinitions','templateInstances'}:raise ValueError('provenance top-level fields')
    observed=data['observed']
    if set(observed)!={'scope','calls','omitted','errors','unknownCalls','definitionCounts','rows'}:raise ValueError('observed fields')
    for key in ('calls','omitted','errors','unknownCalls'):natural(observed[key])
    definitions={}
    for row in data['bookDefinitions']:
        if set(row)!={'key','tag','namespace'} or not isinstance(row['key'],str) or row['key'] in definitions:raise ValueError('Book identity rows')
        if not isinstance(row['tag'],str) or not (row['namespace'] is None or isinstance(row['namespace'],str)):raise ValueError('Book metadata')
        definitions[row['key']]=row
    templates={}
    for row in data['templateInstances']:
        if set(row)!={'template','instances'} or not isinstance(row['template'],str) or row['template'] in templates or not isinstance(row['instances'],list):raise ValueError('template registry fields')
        if any(not isinstance(key,str) for key in row['instances']) or len(set(row['instances']))!=len(row['instances']):raise ValueError('template registry instance identity')
        templates[row['template']]=row['instances']
    counts={}
    for key,count in observed['definitionCounts']:
        if not isinstance(key,str) or key in counts or key not in definitions or natural(count)==0:raise ValueError('definition count membership')
        counts[key]=count
    if sum(counts.values())+observed['unknownCalls']!=observed['calls']:raise ValueError('aggregate counter conservation')
    rows=observed['rows']
    if not isinstance(rows,list) or len(rows)>256:raise ValueError('shape bound')
    signatures=set()
    for row in rows:
        if set(row)!={'definition','displayedDefinition','from','to','calls'} or not isinstance(row['definition'],str):raise ValueError('shape row')
        if row['displayedDefinition']!=row['definition'].replace(':','.',1) or natural(row['calls'])==0:raise ValueError('shape spelling/count')
        for key in ('from','to'):
            layout=row[key]
            if set(layout)!={'width','kinds','arms'} or not isinstance(layout['kinds'],list) or natural(layout['width'])!=len(layout['kinds']):raise ValueError('layout width')
            if layout['arms'] is not None:
                names=set()
                for arm in layout['arms']:
                    if set(arm)!={'name','fields'} or not isinstance(arm['name'],str) or arm['name'] in names:raise ValueError('ordered arm identity')
                    names.add(arm['name'])
                    for width in arm['fields']:natural(width)
        signature=json.dumps({key:value for key,value in row.items() if key!='calls'},sort_keys=True)
        if signature in signatures:raise ValueError('duplicate shape')
        signatures.add(signature)
    if sum(row['calls']for row in rows)+observed['omitted']+observed['errors']!=observed['calls']:raise ValueError('shape counter conservation')
    loaded={}
    for source,namespace in data['loaded']:
        if source in loaded or not isinstance(namespace,str):raise ValueError('loaded namespace identity')
        loaded[source]=namespace
        if sha(source)!=plan['pins'][source]:raise ValueError('loaded source changed')
    if set(loaded)!=set(plan['expectedLoadedSources']):raise ValueError('complete loaded source membership')
    import re
    lexical={}
    for source in loaded:
        lexical[source]=[(match.group(1),index) for index,line in enumerate(Path(source).read_text().splitlines(),1) if (match:=re.match(r'^def ([A-Za-z_][A-Za-z_0-9]*)',line))]
    needed=set(counts)|{row['definition']for row in rows};mapped=set()
    for row in data['mapping']:
        key=row['definition']
        if key in mapped or key not in needed:raise ValueError('mapping membership')
        mapped.add(key)
        tld=definitions.get(key)
        expected={'definition':key,'status':'not-declared'}
        if tld and tld['tag']=='Def':
            origin={};source_key=key
            if not isinstance(tld['namespace'],str):
                origins=[template for template,instances in templates.items() if key in instances]
                if len(origins)>1:
                    expected={'definition':key,'status':'ambiguous-template','originTemplates':origins}
                    if row!=expected:raise ValueError('exact ambiguous template mapping differs')
                    continue
                if origins:
                    source_key=origins[0];origin={'originTemplate':source_key};tld=definitions.get(source_key)
            if not tld or tld['tag']!='Def':expected={'definition':key,'status':'missing-template-definition',**origin}
            else:
                ns=tld['namespace']
                if not isinstance(ns,str):expected={'definition':key,'status':'missing-namespace',**origin}
                elif ns and not source_key.startswith(ns+':'):expected={'definition':key,'status':'namespace-mismatch','namespace':ns,**origin}
                else:
                    local=source_key if ns=='' else source_key[len(ns)+1:]
                    sources=[source for source,namespace in loaded.items() if namespace==ns]
                    declarations=[]
                    for source in sources:
                        declarations.extend((source,index) for name,index in lexical[source] if name==local)
                    if len(declarations)!=1:expected={'definition':key,'status':'ambiguous-source' if declarations else 'no-lexical-source','namespace':ns,'files':sources,**origin}
                    else:
                        source,index=declarations[0]
                        expected={'definition':key,'status':'mapped','namespace':ns,'localName':local,'source':source,'line':index,'sourceSHA256':plan['pins'][source],**origin}
        if row!=expected:raise ValueError('exact Book/source mapping differs')
    if mapped!=needed:raise ValueError('missing mappings')
    return {'calls':observed['calls'],'definitions':len(counts),'unknownCalls':observed['unknownCalls'],'omitted':observed['omitted'],'errors':observed['errors'],'mapped':sum(row['status']=='mapped'for row in data['mapping']),'unmapped':sum(row['status']!='mapped'for row in data['mapping'])}

def unique_object(pairs):
    result={}
    for key,value in pairs:
        if key in result:raise ValueError('duplicate JSON field')
        result[key]=value
    return result


def run(plan_path,admitted):
    plan_path=Path(plan_path).resolve(strict=True)
    if sha(plan_path)!=admitted: raise ValueError('plan admission mismatch')
    plan=json.loads(plan_path.read_text());pins=dict(plan['pins']);pins[str(plan_path)]=admitted
    actual=Path(sys.executable).resolve(strict=True)
    if str(actual)!=plan['pythonInterpreter'] or sha(actual)!=pins[str(actual)]:raise ValueError('actual interpreter differs before helpers')
    if {path:sha(path) for path in pins}!=pins: raise ValueError('inputs changed')
    global VERIFIED_SOURCES
    VERIFIED_SOURCES={name:Path(name).read_bytes() for name in pins if name.endswith('.py')}
    if any(hashlib.sha256(raw).hexdigest()!=pins[name] for name,raw in VERIFIED_SOURCES.items()):raise ValueError('captured source drift')
    runner=load('reference_runner',ROOT/'scripts/task_runner.py');boundary=load('reference_boundary',ROOT/'scripts/evidence_boundary.py')
    out=plan_path.parent;artifact=Path(plan['output']);profile=Path(plan['profile']);provenance=Path(plan['provenance']) if 'provenance' in plan else None;record={'scope':plan['scope'],'planSHA256':admitted,'commands':[],'guards':[]}
    def guard(label):
        actual={path:sha(path)for path in pins};unchanged=actual==pins
        target=out/(label+'.guard.json');capture(target,(json.dumps({'label':label,'unchanged':unchanged,'actualPins':actual},indent=2)+'\n').encode());record['guards'].append({'path':str(target),'sha256':sha(target)})
        if not unchanged: raise ValueError('boundary drift')
    with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
        guard('emit-pre')
        with boundary.GuardBoundary([('post boundary',lambda:guard('emit-post'))]):
            with open('/tmp/bendvy-parity-heavy.lock','a')as lock:
                fcntl.flock(lock,fcntl.LOCK_EX)
                try:
                    guard('emit-acquired')
                    if any(p.exists() or p.is_symlink() for p in ([artifact,profile]+([provenance] if provenance else []))): raise ValueError('artifacts start absent')
                    result=runner.execute_result(plan['argv'],30,plan['environment'],str(HERE),'split')
                finally:fcntl.flock(lock,fcntl.LOCK_UN)
            row={'label':'reference-emit','argv':plan['argv'],'capSeconds':30}
            for key,value in result.items():
                if isinstance(value,bytes):
                    target=out/('emit.'+key);capture(target,value);digest=sha(target);row[key]={'path':str(target),'bytes':len(value),'sha256':digest};pins[str(target)]=digest
                else:row[key]=value
            record['commands'].append(row)
            if artifact.exists()or artifact.is_symlink():pins[str(artifact)]=sha(artifact);record['artifactSHA256']=pins[str(artifact)]
            if profile.exists()or profile.is_symlink():
                pins[str(profile)]=sha(profile);record['profileSHA256']=pins[str(profile)]
                data=json.loads(profile.read_text());validate_profile(data);record['profileSamples']=len(data['samples'])
                record['profileCaptured']=True
            if provenance is not None:
                if provenance.exists()or provenance.is_symlink():
                    pins[str(provenance)]=sha(provenance);record['provenanceSHA256']=pins[str(provenance)]
                    try:
                        data=json.loads(provenance.read_text(),object_pairs_hook=unique_object)
                        record['provenanceSummary']=validate_provenance(data,plan);record['provenanceComplete']=True
                    except (ValueError,KeyError,TypeError,IndexError)as error:
                        record['provenanceValidationError']=str(error)
                else:record['provenanceValidationError']='provenance artifact absent'
            record['status']='REFERENCE_CPU_PROFILE_CAPTURED' if record.get('profileCaptured') and result['failure']is None else 'INCOMPLETE'
            if provenance is not None and not record.get('provenanceComplete'):record['status']='INCOMPLETE'
            record['qualifiesInstalledCompiler']=False
if __name__=='__main__':run(sys.argv[1],sys.argv[2])
