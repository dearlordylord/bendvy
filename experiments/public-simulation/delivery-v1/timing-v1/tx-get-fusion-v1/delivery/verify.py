"""Verify retained bytes only; no compiler, consumer or benchmark execution."""
from pathlib import Path
import hashlib,json,re,zipfile
H=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
m=json.loads((H/'MANIFEST.json').read_bytes())
with zipfile.ZipFile(H/'EVIDENCE.zip') as z:
    assert len(z.namelist())==len(set(z.namelist()))==len(m['members'])
    assert set(z.namelist())=={e['member'] for e in m['members']}
    data={}
    for e in m['members']:
        raw=z.read(e['member']);assert len(raw)==e['bytes'] and sha(raw)==e['sha256'];assert e['source'] not in data;data[e['source']]=raw
base=next(k[:-len('/RESULT.json')] for k in data if k.endswith('/tx-get-fusion-v1/RESULT.json'))
v=base+'/binding-repair-v2';a=v+'/actual02';read=lambda k:data[k];js=lambda k:json.loads(read(k))
p=js(v+'/plan.json');r=js(a+'/receipt.json');f=js(v+'/FREEZE.json');l=js(v+'/LAUNCH.json');result=js(base+'/RESULT.json')
assert sha(read(v+'/plan.json'))==f['planSHA256']==l['planSHA256']==r['planSHA256']==result['planSHA256']
assert sha(read(v+'/FREEZE.json'))==l['freezeSHA256'] and l['argv'][-2:]==[v+'/plan.json',r['planSHA256']]
for k,h in p['pins'].items():
    if k in data:assert sha(read(k))==h
    else:assert m['externalPins'][k]==h
assert set(m['externalPins'])==set(p['pins'])-set(data)
labels=['source','TS','JS-emit','JS-run','Native-emit','Native-clang','Native-run']
assert [c['label'] for c in p['commands']]==[c['label'] for c in r['commands']]==labels
assert [c['capSeconds'] for c in p['commands']]==[5,5,30,5,30,120,5]
for c,want in zip(r['commands'],p['commands']):
    assert c['argv']==want['argv'] and c['capSeconds']==want['capSeconds'] and c['exit']==0 and c['failure'] is None
    for stream in ['stdout','stderr']:
        raw=read(a+'/'+c['label']+'.'+stream);meta=c[stream];assert bytes.fromhex(meta['rawHex'])==raw and sha(raw)==meta['sha256'] and len(raw)==meta['bytes']
    assert read(a+'/'+c['label']+'.stderr')==b''
for c in r['probes']:
    assert c['exit']==0 and c['failure'] is None and c['capSeconds']==5
    for stream in ['stdout','stderr']:
        raw=read(a+'/'+c['label']+'.'+stream);assert raw==bytes.fromhex(c[stream]['rawHex'])
expectedguards=['initial-pre','initial-acquired']+[lab+'-'+phase for lab in labels for phase in ['pre','acquired','post']]+['final']
assert len(r['guards'])==24
pinstate=dict(p['pins']);pinstate[v+'/plan.json']=r['planSHA256'];previous_raw={};previous_generated={}
for row,label in zip(r['guards'],expectedguards):
    assert row['path']==a+'/'+label+'.guard.json' and sha(read(row['path']))==row['sha256']
    g=js(row['path']);assert g['label']==label and g['unchanged'] is True and g['actualPins']==pinstate and g['stagePins']==p['stagePins'] and g['namespace']==p['namespace']
    assert previous_raw.items()<=g['rawPins'].items() and previous_generated.items()<=g['generated'].items()
    for name,h in g['rawPins'].items():assert sha(read(a+'/'+name))==h
    for name,h in g['generated'].items():assert sha(read(a+'/'+name))==h and h==r['generated'][name]
    if label.endswith('-post') and label[:-5] in labels:
        lab=label[:-5];assert all(lab+'.'+stream in g['rawPins'] for stream in ['stdout','stderr'])
    previous_raw=g['rawPins'];previous_generated=g['generated']
assert previous_generated==r['generated']
assert set(previous_raw)=={c['label']+'.'+stream for c in r['commands']+r['probes'] for stream in ['stdout','stderr']}
for rel,h in p['stagePins'].items():assert sha(read(p['stageRoot']+'/'+rel))==h
assert r['status']=='RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY'
assert read(a+'/JS-run.stdout')==read(a+'/Native-run.stdout') and sha(read(a+'/JS-run.stdout'))=='4473bc5dbab2005bc4ae7d9cdce86ead92f498f488cfc728840e6f7e786af1ca'
assert read(a+'/TS.stdout')==read(p['tsExpected'])
ns={'__name__':'retained_simulation_parser'};exec(compile(read(p['parser']),p['parser'],'exec'),ns)
parsed=ns['parse'](read(a+'/JS-run.stdout').decode());assert ns['render'](parsed)==read(a+'/JS-run.stdout').decode().strip()
def neutral(x):
    if isinstance(x,list):return [neutral(y) for y in x]
    if isinstance(x,dict):return {k:p['constructorJoins'][val] if k=='constructor' else neutral(val) for k,val in x.items()}
    return x
oracle='/workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/independent-expected.json';assert sha(read(oracle))==p['oracleSHA256'];assert neutral(parsed)==js(oracle)
t=js(base+'/GENERATED-TOPOLOGY.json');new=read(t['candidateJS']);old=read(t['baselineJS']);assert sha(new)==t['candidateSHA256'] and sha(old)==t['baselineSHA256']
assert len(re.findall(rb'^function [^\n]*component\$058tx_get_join\$',old,re.M))==6 and b'component$058tx_get_join$' not in new
for term in ['tx_get','tx_get_world','tx_get_live_owned','tx_get_store_finish']:assert len(re.findall(rb'^function [^\n]*component\$058'+term.encode()+rb'\$',new,re.M))==6
assert sha(read(a+'/receipt.json'))==result['receiptSHA256'] and result['generated']==r['generated']
assert js(base+'/PREFLIGHT-FAILURE.json')['commandsRun']==0 and read(base+'/actual01/receipt.json')==b''
candidate=read(f['candidate']).decode();before=read(base+'/component.before.bend').decode()
assert sha(candidate.encode())==result['candidateSHA256']==f['candidateSHA256']
inverse=candidate[:candidate.index('def tx_get_store_finish(')]+candidate[candidate.index('def tx_get_join('):]
start=inverse.index('def tx_get(');end=inverse.index('def tx_written(',start)
oldstart=before.index('def tx_get(');oldend=before.index('def tx_written(',oldstart)
inverse=inverse[:start]+before[oldstart:oldend]+inverse[end:]
assert inverse==before, 'exact candidate source reversal failed'
assert result['status']=='EXPERIMENTAL_TX_GET_FUSION_SEMANTIC_PASS_NOT_PERFORMANCE_OR_ADOPTION'
print(json.dumps({'status':'PASS_RETAINED_TX_GET_FUSION_SEMANTICS','members':len(data),'commands':7,'guards':24,'JSNativeBytes':len(read(a+'/JS-run.stdout')),'performanceClaim':False}))
