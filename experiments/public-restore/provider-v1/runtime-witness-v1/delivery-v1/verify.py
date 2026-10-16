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

def verify_role(plan, receipt, plan_path, plan_sha, raw, mutant=False, historical=False):
    oracle = plan["oracleSHA256"]
    size = plan["oracleBytes"]
    role = plan['role']
    labels = ['consumer'] if role == 'ts' else ['emit', 'consumer'] if role == 'js' else ['emit', 'build', 'consumer']
    caps = [5] if role == 'ts' else [30, 5] if role == 'js' else [30, 120, 5]
    need([c['label'] for c in plan['commands']] == labels, 'plan command order')
    actual_labels = labels
    need([c['label'] for c in receipt['commands']] == actual_labels, 'receipt command order/count')
    need(receipt['planSHA256'] == plan_sha, 'receipt plan hash')
    need(receipt['status'] == ('INCOMPLETE' if historical else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'), 'status')
    expected = 'd40cc4bef22f6738fa3db81c2914757e59c047efb696a1a14e6e9429c9408d1d' if historical else '80c93f947abe647ac203d165a383459a73285c4fd92e98c22aa3193bc181196d' if mutant else '8e1f41339552dfeb3da0a24a9f688ddc3952ebf724bd3fd8e8ce16e5d8a7389f'
    need((size,oracle)==(513,expected),'whole oracle binding')
    actual_oracle = '8e1f41339552dfeb3da0a24a9f688ddc3952ebf724bd3fd8e8ce16e5d8a7389f' if historical else oracle
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
                need(len(data) == size and sha(data) == actual_oracle, 'full physical output')
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
    if historical:
        need(receipt['error']=='ValueError: Complete consumer byte output differs from whole independent oracle','historical failure retained')
        need(sha(gzip.decompress(raw(plan['oracle'],plan['pins'][plan['oracle']])))==oracle,'original wrong oracle retained')
    else:
        need(receipt['wholeOracleSHA256']==oracle,'receipt oracle')
        need(gzip.decompress(raw(plan['oracle'],plan['pins'][plan['oracle']]))==raw(receipt['commands'][-1]['stdout']['path'],oracle),'full gzip oracle')
    if mutant:
        need(receipt['completeNormalBaselineRejected'] is True,'whole normal baseline rejected')
        need(sha(gzip.decompress(raw(plan['normalOracle'],plan['pins'][plan['normalOracle']])))=='8e1f41339552dfeb3da0a24a9f688ddc3952ebf724bd3fd8e8ce16e5d8a7389f','matched complete normal')

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
        need(set(m['roles'])=={'historical-js','js','native','mutant-js','mutant-native'},'five roles')
        controls=0
        for name,role in m['roles'].items():
            path,h=split_key(role['planKey']);p=json.loads(raw(path,h));r=json.loads(keyed(role['receiptKey']))
            verify_role(p,r,path,h,raw,mutant=name.startswith('mutant'),historical=name=='historical-js')
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
        f=json.loads(keyed(m['fixtureFreezeKey']));mf=json.loads(keyed(m['mutantFreezeKey']))
        for freeze in [f,mf]:
            need(len(freeze['sourceInventory'])==21,'closure count')
            for path,h in freeze['sourceInventory'].items():need(sha(raw(path,h))==h,'source body')
        prefix=str(Path(f['entrypoint']).parent);join=json.loads(keyed(m['fixtureJoinKey']))
        for row in join['files']:need(raw(prefix+'/'+row['path'],row['sha256'])==raw(row['original'],row['sha256']),'byte-identical prototype')
        mj=json.loads(keyed(m['mutantJoinKey']));normal=raw(prefix+'/witness.bend',mj['normalWitnessSha256']);mutant=raw(prefix+'/witness-mutant.bend',mj['mutantWitnessSha256'])
        need(mutant.replace(mj['helper'].encode(),b'').replace(mj['after'].encode(),mj['before'].encode())==normal,'exact reached context mutation inverse')
        normalmain=raw(f['entrypoint'],f['sourceInventory'][f['entrypoint']]);mutantmain=raw(mf['entrypoint'],mf['sourceInventory'][mf['entrypoint']])
        need(normalmain.replace(b'./witness.bend',b'./witness-mutant.bend')==mutantmain,'observer import-only')
        negative=json.loads(keyed(m['negativeCheckKey']));need(negative['exitCode']==1 and negative['expected']=='owner (consumed more than once)','intended negative')
        np=str(Path(split_key(m['negativeCheckKey'])[0]).parent)
        captures=[(k,v) for k,v in m['pathHashToMember'].items() if k.startswith(np+'/') and k.split('@')[0].endswith(('/stdout','/stderr'))]
        need(len(captures)==2 and b'owner (consumed more than once)' in b''.join(z.read(v) for k,v in captures),'exact affine diagnostic')
        for path,h in negative['sourceInventory'].items():need(sha(raw(path,h))==h,'negative source')
        with tempfile.TemporaryDirectory(prefix='verify59-model-') as directory:
            root=Path(directory)
            for version,files in m['models'].items():
                d=root/version;d.mkdir()
                for name,key in files.items():(d/name).write_bytes(keyed(key))
                model=runpy.run_path(str(d/'model.py'));b=model['derive']()
                need(b==(d/'expected.stdout').read_bytes()==gzip.decompress((d/'expected.stdout.gz').read_bytes()),'complete source model reproduction')
    print('PASS_DETACHED_CONSTRUCTOR_PACKET',len(m['archiveMembers']),'objects;normal+mutant stock pairs513;v1 failure preserved;21 sources;affine negative;3 models;10 malformed controls;zero backends')
if __name__=='__main__':main()
