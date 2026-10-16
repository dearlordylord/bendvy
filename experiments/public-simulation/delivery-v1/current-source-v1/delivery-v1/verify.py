#!/usr/bin/env python3
"""Offline verification of the retained matched lifecycle packet."""
import copy
import gzip
import hashlib
import json
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ORACLE = '83c78b0e9a8944516ca101b604468cee3af05a9509af0b64bc37bed8ac982b8a'
FULL_SOURCE_COMMIT = '0a7f3efbb57302f63e6d92d4d4b4d4c92bbf937d'
PHASE_COMMIT = '79df8d9c40722ee9507a1e253f283b51025f9d6c'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def need(ok, message):
    if not ok:
        raise ValueError(message)

def split_key(key):
    return key.rsplit('@', 1)

def verify_role(plan, receipt, plan_path, plan_sha, raw, mutant=False):
    oracle = plan["oracleSHA256"]
    size = plan["oracleBytes"]
    role = plan['role']
    labels = ['consumer'] if role == 'ts' else ['emit', 'consumer'] if role == 'js' else ['emit', 'build', 'consumer']
    caps = [5] if role == 'ts' else [30, 5] if role == 'js' else [30, 120, 5]
    need([c['label'] for c in plan['commands']] == labels, 'plan command order')
    actual_labels = labels
    need([c['label'] for c in receipt['commands']] == actual_labels, 'receipt command order/count')
    need(receipt['planSHA256'] == plan_sha, 'receipt plan hash')
    need(receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS', 'status')
    need((size,oracle) == ((96998,'8d6d24730b36879a948c76747519407643f958881c7670938f20872a3cb821bc') if mutant else (97054,'3ac945ce62c346d7725c2e03c52c359014ba75fd427b7f48fd56dffd396f969f')), 'oracle binding')
    need(set(plan['importClosure']) == set(plan['sourceInventory']), 'source closure')
    for path, digest in plan['sourceInventory'].items():
        need(sha(raw(path, digest)) == digest, 'source bytes')
    runner = [h for p, h in plan['pins'].items() if p.endswith('/scripts/task_runner.py')]
    need(len(runner) == 1, 'runner pin')
    pins = dict(plan['pins'])
    pins[plan_path] = plan_sha
    expected_guards = []
    for p, actual, cap in zip(plan['commands'], receipt['commands'], caps):
        label = actual['label']
        need(actual['argv'] == p['argv'] and actual['capSeconds'] == p['capSeconds'] == cap, 'argv/cap')
        need(actual['capture'] == 'split' and actual['runnerSHA256'] == runner[0], 'capture/runner')
        need(actual['exit'] == 0 and actual['failure'] is None, 'child failure')
        for phase in ['pre', 'acquired']:
            expected_guards.append((label+'-'+phase, dict(pins)))
        for stream in ['stdout', 'stderr']:
            info = actual[stream]
            need(info['published'] is True, 'stream publication')
            need(info['path'] == str(Path(plan_path).parent / (label+'.'+stream)), 'stream path')
            data = raw(info['path'], info['sha256'])
            need(len(data) == info['bytes'] and sha(data) == info['sha256'], 'stream bytes/hash')
            need(stream != 'stderr' or data == b'', 'unexpected stderr')
            pins[info['path']] = info['sha256']
            if label == 'consumer' and stream == 'stdout':
                need(len(data) == size and sha(data) == oracle, 'full physical output')
        if label in ['emit', 'build']:
            key = 'generated' if label == 'emit' else 'native'
            digest = receipt[label+'ArtifactSHA256']
            need(sha(raw(plan[key], digest)) == digest, 'artifact')
            need(plan[key] in p['argv'], 'artifact argv')
            pins[plan[key]] = digest
        expected_guards.append((label+'-post', dict(pins)))
    expected_guards.append(('final', dict(pins)))
    need(len(receipt['guards']) == len(expected_guards), 'guard count')
    for info, (label, expected) in zip(receipt['guards'], expected_guards):
        need(info['path'] == str(Path(plan_path).parent / (label+'.guard.json')), 'guard path/order')
        guard = json.loads(raw(info['path'], info['sha256']))
        need(guard['label'] == label and guard['unchanged'] is True and guard['actualPins'] == expected, 'guard progression')
    need(receipt['wholeOracleSHA256'] == oracle, 'receipt oracle')
    need(gzip.decompress(raw(plan['oracle'], plan['pins'][plan['oracle']])) == raw(receipt['commands'][-1]['stdout']['path'], oracle), 'full independent gzip oracle')
    if mutant:
        normal=gzip.decompress(raw(plan['normalOracle'],plan['pins'][plan['normalOracle']]))
        need(sha(normal) != oracle and receipt['completeNormalBaselineRejected'] is True,'normal baseline rejected')

def main():
    import tempfile,runpy
    delivery=json.loads((HERE/'DELIVERY.json').read_text())
    for name,row in delivery['artifacts'].items():
        data=(HERE/name).read_bytes();need(sha(data)==row['sha256'] and len(data)==row['bytes'],'delivery artifact')
    m=json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as z:
        need(len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(m['archiveMembers']),'membership')
        for name,row in m['archiveMembers'].items():
            b=z.read(name);need(sha(b)==row['sha256'] and len(b)==row['bytes'],'archive body')
        def raw(path,digest):return z.read(m['pathHashToMember'][path+'@'+digest])
        def keyed(k):return raw(*split_key(k))
        controls=0
        for name,role in m['roles'].items():
            path,h=split_key(role['planKey']);p=json.loads(raw(path,h));r=json.loads(keyed(role['receiptKey']))
            verify_role(p,r,path,h,raw,mutant=name=='stamp-mutant-js')
            identity=dict(p['pins'])
            for root,rows in p['resourceRoots'].items():identity.update({str(Path(root)/n):v for n,v in rows.items()})
            for k,v in identity.items():need(k+'@'+v in m['pathHashToMember'] or k+'@'+v in m['externalIdentityOnly'],'tool/resource identity')
            if name=='native':
                mutations=[lambda r:r['commands'].pop(),lambda r:r['commands'].reverse(),lambda r:r['commands'][0].update(capSeconds=31),lambda r:r['commands'][0]['argv'].append('--other'),lambda r:r['commands'][0]['stdout'].update(bytes=1),lambda r:r['commands'][0]['stdout'].update(sha256='0'*64),lambda r:r['commands'][0]['stdout'].update(path='/tmp/wrong'),lambda r:r['guards'].pop(),lambda r:r['guards'].reverse(),lambda r:r.update(wholeOracleSHA256='0'*64)]
                for mutate in mutations:
                    bad=copy.deepcopy(r);mutate(bad)
                    try:verify_role(p,bad,path,h,raw)
                    except (ValueError,KeyError,TypeError):controls+=1
                    else:raise ValueError('malformed receipt accepted')
        need(controls==10,'malformed controls')
        f=json.loads(keyed(m['fixtureFreezeKey']));need(len(f['sourceInventory'])==53,'closure count')
        prefix=split_key(m['fixtureFreezeKey'])[0].split('/experiments/')[0]
        for rel,h in f['sourceInventory'].items():need(sha(raw(prefix+'/'+rel,h))==h,'source body')
        join=json.loads(keyed(m['fixtureJoinKey']));need(len(join['files'])==38,'fixture count')
        counts={}
        for row in join['files']:
            kind=row['classification'];counts[kind]=counts.get(kind,0)+1
            new=raw(prefix+'/experiments/public-simulation/delivery-v1/current-source-v1/'+row['path'],row['sha256'])
            if kind=='import-only':
                old=raw(prefix+'/'+row['priorPath'],row['priorSha256'])
                need(old.replace(b'/workspace/formal-proofs/bendvy/src/ecs/',b'../../../../../src/ecs/')==new,'import inverse')
        need(counts=={'import-only':34,'additive-observer':2,'new-owner-preserving-observer':2},'fixture delta scope')
        mf=json.loads(keyed(m['mutantFreezeKey']));mutation=mf['mutation'];changes=[]
        for rel,h in mf['sourceInventory'].items():
            body=raw(mf['snapshotRoot']+'/'+rel,h)
            if h!=f['sourceInventory'][rel]:changes.append(rel)
        need(changes==['src/ecs/lifecycle.bend'],'single mutant module')
        body=raw(mf['snapshotRoot']+'/'+changes[0],mutation['mutantSha256'])
        need(body.count(mutation['after'].encode())==1 and sha(body.replace(mutation['after'].encode(),mutation['before'].encode()))==mutation['normalSha256'],'exact expression inverse')
        with tempfile.TemporaryDirectory(prefix='verify63-model-') as directory:
            root=Path(directory)
            for version,files in m['models'].items():
                d=root/version;d.mkdir()
                for name,key in files.items():(d/name).write_bytes(keyed(key))
            for version in m['models']:
                model=runpy.run_path(str(root/version/'derive.py'));value=model['selftest']()
                mapping=json.loads((root/version/'CONSTRUCTOR-JOIN.json').read_text())
                def change(x):
                    if isinstance(x,list):return [change(v) for v in x]
                    if isinstance(x,dict):return {k:mapping[v]['literal'] if k=='constructor' else change(v) for k,v in x.items()}
                    return x
                formatter=runpy.run_path(str(root/'independent-oracle-v1/term-format.py.source'))
                b=(formatter['render'](change(value))+'\n').encode()
                need(b==(root/version/'expected.stdout').read_bytes()==gzip.decompress((root/version/'expected.stdout.gz').read_bytes()),'complete source-model reproduction')
    print('PASS_COMPLETE_SIMULATION_PACKET',len(m['archiveMembers']),'objects; JS+Native97054; reached stamp counter96998;53 sources;2 full models;10 malformed controls;zero backends')
if __name__=='__main__':main()
