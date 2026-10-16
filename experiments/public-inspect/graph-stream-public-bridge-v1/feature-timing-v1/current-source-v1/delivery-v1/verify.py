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

def verify_role(plan, receipt, plan_path, plan_sha, raw, failed=False):
    role = plan['role']
    labels = ['consumer'] if role == 'ts' else ['emit', 'consumer'] if role == 'js' else ['emit', 'build', 'consumer']
    caps = [5] if role == 'ts' else [30, 5] if role == 'js' else [30, 120, 5]
    need([c['label'] for c in plan['commands']] == labels, 'plan command order')
    actual_labels = labels
    need([c['label'] for c in receipt['commands']] == actual_labels, 'receipt command order/count')
    need(receipt['planSHA256'] == plan_sha, 'receipt plan hash')
    need(receipt['status'] == ('INCOMPLETE' if failed else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'), 'status')
    need((plan['oracleBytes'],plan['oracleSHA256']) == ((237711,'e5c0f46f05fdaff62676c09dd89376e9a7ee67e58ef1e3a8159ad2edd9b0c1ee') if failed else (271299,ORACLE)), 'oracle binding')
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
                need(len(data) == 271299 and sha(data) == ORACLE, 'full physical output')
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
    if failed:
        need(receipt.get('error') == 'ValueError: Complete consumer byte output differs from whole independent oracle', 'historical mismatch reason')
        need(sha(gzip.decompress(raw(plan['oracle'],plan['pins'][plan['oracle']]))) != ORACLE, 'failed original golden retained')
    if not failed:
        need(receipt['wholeOracleSHA256'] == ORACLE, 'receipt oracle')
        need(gzip.decompress(raw(plan['oracle'], plan['pins'][plan['oracle']])) == raw(receipt['commands'][-1]['stdout']['path'], ORACLE), 'independent gzip oracle')

def main():
    import importlib.util
    import tempfile
    delivery=json.loads((HERE/'DELIVERY.json').read_text())
    need(set(delivery['artifacts']) == {'README.md','RESULT.json','EVIDENCE.zip','MANIFEST.json','verify.py'}, 'delivery artifact set')
    for name,row in delivery['artifacts'].items():
        data=(HERE/name).read_bytes()
        need(sha(data)==row['sha256'] and len(data)==row['bytes'], 'delivery artifact')
    manifest=json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as z:
        names=z.namelist()
        need(len(names)==len(set(names)) and set(names)==set(manifest['archiveMembers']), 'archive membership')
        for name,row in manifest['archiveMembers'].items():
            data=z.read(name)
            need(sha(data)==row['sha256'] and len(data)==row['bytes'], 'archive body')
        def raw(path,digest):
            key=path+'@'+digest
            need(key in manifest['pathHashToMember'], 'missing path/hash: '+key)
            return z.read(manifest['pathHashToMember'][key])
        def keyed(key): return raw(*split_key(key))
        fixture=json.loads(keyed(manifest['fixtureFreezeKey']))
        need(len(fixture['sourceInventory'])==92,'fixture closure count')
        fixture_root=Path(split_key(manifest['fixtureFreezeKey'])[0])
        for _ in range(6): fixture_root=fixture_root.parent
        # Absolute source roots remain recorded identities; archive reads use exact path/hash.
        source_prefix=split_key(manifest['fixtureFreezeKey'])[0].split('/experiments/')[0]
        for rel,digest in fixture['sourceInventory'].items():need(sha(raw(source_prefix+'/'+rel,digest))==digest,'fixture body')
        join=json.loads(keyed(manifest['fixtureJoinKey']))
        need(len(join['files'])==15 and sum(r['importOnly'] for r in join['files'])==13,'fixture scope')
        for row in join['files']:
            new=raw(source_prefix+'/'+row['path'],row['newSHA256'])
            # Historical original bodies are retained under their root absolute paths.
            old_path='/workspace/formal-proofs/bendvy/'+row['oldPath']
            old=raw(old_path,row['oldSHA256'])
            if row['importOnly']:
                need(new.replace(b'../../../../../src/ecs/',b'../../../../src/ecs/')==old,'import inverse')
        controls=0
        for name,role in manifest['roles'].items():
            planpath,plansha=split_key(role['planKey'])
            plan=json.loads(raw(planpath,plansha));receipt=json.loads(keyed(role['receiptKey']))
            verify_role(plan,receipt,planpath,plansha,raw,failed=name=='historical-js')
            # Tool and resource identity bindings remain exact explicit archive or external rows.
            identity=dict(plan['pins'])
            for root,entries in plan['resourceRoots'].items():
                identity.update({str(Path(root)/p):h for p,h in entries.items()})
            for p,h in identity.items():need(p+'@'+h in manifest['pathHashToMember'] or p+'@'+h in manifest['externalIdentityOnly'],'identity binding')
            if name=='native':
                mutations=[lambda r:r['commands'].pop(),lambda r:r['commands'].reverse(),lambda r:r['commands'][0].update(capSeconds=31),lambda r:r['commands'][0]['argv'].append('--other'),lambda r:r['commands'][0]['stdout'].update(bytes=1),lambda r:r['commands'][0]['stdout'].update(sha256='0'*64),lambda r:r['commands'][0]['stdout'].update(path='/tmp/wrong'),lambda r:r['guards'].pop(),lambda r:r['guards'].reverse(),lambda r:r.update(wholeOracleSHA256='0'*64)]
                for mutate in mutations:
                    bad=copy.deepcopy(receipt);mutate(bad)
                    try:verify_role(plan,bad,planpath,plansha,raw)
                    except (ValueError,KeyError,TypeError):controls+=1
                    else:raise ValueError('malformed receipt accepted')
        need(controls==10,'malformed controls')
        with tempfile.TemporaryDirectory(prefix='verify55-model-') as directory:
            p=Path(directory)/'derive.py';p.write_bytes(keyed(manifest['oracleModelKey']))
            spec=importlib.util.spec_from_file_location('physical55_retained',p)
            model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
            logical=Path(directory)/'logical.stdout';logical.write_bytes(keyed(manifest['logicalKey']))
            logical_raw,records=model.logical_records(logical)
            output=model.output_bytes(logical_raw,records)
            model.check_selftest(output,records)
            need(len(output)==271299 and sha(output)==ORACLE,'independent full model reproduction')
    print('PASS_CURRENT_PHYSICAL_PAIR',len(manifest['archiveMembers']),'objects; 92 Bend bodies; JS/Native271299; failed-v1 preserved; 10 malformed controls; zero backend executions')

if __name__=='__main__':main()
