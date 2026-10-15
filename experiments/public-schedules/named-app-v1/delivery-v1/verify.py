#!/usr/bin/env python3
"""Offline retained-byte, command, guard, source-delta and full-oracle joins."""
import copy
import gzip
import hashlib
import importlib.util
import json
import tempfile
import zipfile
import sys
import re
import os
import importlib.machinery
from pathlib import Path

HERE = Path(__file__).resolve().parent
NORMAL = '1aabfd5785de4e3d9bb1be6204f86850961a62b5403eb7a642fe5cbd32ee4796'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def need(value, message):
    if not value:
        raise ValueError(message)


def check_role(plan, receipt, role, read):
    labels = ['emit', 'build', 'consumer'] if plan['role'] == 'native' else ['emit', 'consumer']
    caps = [30, 120, 5] if plan['role'] == 'native' else [30, 5]
    prefix = ['/usr/bin/taskset', '-c', '5']
    need(plan['commands'][0]['argv'] == prefix+[plan['tools']['bend'], plan['entrypoint'], '-o', plan['generated']], 'emitter source/artifact argv')
    if plan['role'] == 'native':
        need(plan['commands'][1]['argv'] == prefix+[plan['tools']['clangWrapper'], '-O3', plan['generated'], '-o', plan['native'], '-pthread', '-lm'], 'ordinary O3 build argv')
        need(plan['commands'][-1]['argv'] == prefix+[plan['native'], '--threads', '1', '--gpu', 'off'], 'Native consumer argv')
    else:
        need(plan['commands'][-1]['argv'] == prefix+[plan['tools']['node'], plan['generated']], 'JS consumer argv')
    need([c['label'] for c in plan['commands']] == labels, 'planned command order')
    need([c['label'] for c in receipt['commands']] == labels, 'actual command order/count')
    need(receipt['planSHA256'] == role['planSHA256'], 'plan/receipt binding')
    need(receipt['status'] == role['originalStatus'], 'original status changed')
    need(receipt.get('guardFailures', []) == [], 'guard failures')
    need(role['originalStatus'] == ('INCOMPLETE' if role['posthoc'] else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'), 'role scope')
    need(set(plan['sourceInventory']) == set(plan['importClosure']), 'closure membership')
    for path, digest in plan['sourceInventory'].items():
        need(sha(read(path, digest)) == digest, 'source bytes')
    runner = [h for p, h in plan['pins'].items() if p.endswith('/scripts/task_runner.py')]
    need(len(runner) == 1, 'runner identity')
    pins = dict(plan['pins']); pins[role['planPath']] = role['planSHA256']
    guards = []
    for frozen, actual, cap in zip(plan['commands'], receipt['commands'], caps):
        label = actual['label']
        need(actual['argv'] == frozen['argv'], 'argv mismatch')
        need(actual['capSeconds'] == frozen['capSeconds'] == cap, 'cap mismatch')
        need(actual['exit'] == 0 and actual['failure'] is None, 'child failure')
        need(actual['capture'] == 'split' and actual['runnerSHA256'] == runner[0], 'capture/runner')
        for phase in ['pre', 'acquired']:
            guards.append((label+'-'+phase, dict(pins)))
        for stream in ['stdout', 'stderr']:
            row = actual[stream]
            need(row['published'] is True, 'unpublished stream')
            need(row['path'] == str(Path(role['planPath']).parent/(label+'.'+stream)), 'stream path')
            raw = read(row['path'], row['sha256'])
            need(sha(raw) == row['sha256'] and len(raw) == row['bytes'], 'stream hash/size')
            need(stream != 'stderr' or raw == b'', 'stderr not empty')
            pins[row['path']] = row['sha256']
        if label in ['emit', 'build']:
            key = 'generated' if label == 'emit' else 'native'
            digest = receipt[label+'ArtifactSHA256']
            need(plan[key] in actual['argv'] and sha(read(plan[key], digest)) == digest, 'generated artifact join')
            pins[plan[key]] = digest
        guards.append((label+'-post', dict(pins)))
    guards.append(('final', dict(pins)))
    need(len(receipt['guards']) == len(guards), 'guard count')
    for row, (label, expected) in zip(receipt['guards'], guards):
        need(row['path'] == str(Path(role['planPath']).parent/(label+'.guard.json')), 'guard order/path')
        g = json.loads(read(row['path'], row['sha256']))
        need(g['label'] == label and g['unchanged'] is True and g['actualPins'] == expected, 'guard state progression')
    stdout = receipt['commands'][-1]['stdout']
    actual = read(stdout['path'], stdout['sha256'])
    expected = read(role['expectedPath'], role['expectedSHA256'])
    need(actual == expected and len(actual) == role['expectedBytes'], 'complete independent oracle')
    need(gzip.decompress(read(role['expectedGzipPath'], role['expectedGzipSHA256'])) == expected, 'gzip oracle')
    old = gzip.decompress(read(plan['oracle'], plan['pins'][plan['oracle']]))
    need(len(old) == plan['oracleBytes'] and sha(old) == plan['oracleSHA256'], 'frozen oracle')
    if role['posthoc']:
        need(actual != old and 'wholeOracleSHA256' not in receipt, 'historical mismatch erased')
        need(role['freshExecutionForCorrectedOracle'] is False, 'posthoc fresh claim')
    else:
        need(old == actual and receipt['wholeOracleSHA256'] == role['expectedSHA256'], 'receipt oracle')
    if plan['subject'] == 'mutant':
        baseline = gzip.decompress(read(plan['normalOracle'], plan['pins'][plan['normalOracle']]))
        need(len(baseline) == plan['normalOracleBytes'] == 42359 and sha(baseline) == plan['normalOracleSHA256'] == NORMAL and actual != baseline, 'normal baseline not rejected')
        if not role['posthoc']:
            need(receipt['completeNormalBaselineRejected'] is True, 'baseline rejection missing')


def main():
    delivery = json.loads((HERE/'DELIVERY.json').read_text())
    for path, row in delivery['artifacts'].items():
        raw = (HERE/path).read_bytes()
        need(sha(raw) == row['sha256'] and len(raw) == row['bytes'], 'delivery '+path)
    manifest = json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as z:
        need(len(z.namelist()) == len(set(z.namelist())) and set(z.namelist()) == set(manifest['archiveMembers']), 'archive membership')
        for name, row in manifest['archiveMembers'].items():
            raw = z.read(name)
            need(sha(raw) == row['sha256'] and len(raw) == row['bytes'], 'archive bytes')
        def read(path, digest):
            raw = z.read(manifest['pathHashToMember'][path+'@'+digest])
            need(sha(raw) == digest, 'path/hash object')
            return raw
        need(set(manifest['roles']) == {'normal-retained-js','normal-native','foreign-js','foreign-native','placement-mutant-js'}, 'exact role set')
        for name, role in manifest['roles'].items():
            plan = json.loads(read(role['planPath'],role['planSHA256']))
            receipt = json.loads(read(role['receiptPath'],role['receiptSHA256']))
            check_role(plan,receipt,role,read)
            for path, digest in plan['pins'].items():
                if path in manifest['externalPins']:need(manifest['externalPins'][path] == digest, 'external tool hash')
                else:read(path,digest)
            reached = set()
            def visit(path):
                need(path in plan['sourceInventory'], 'import escapes inventory')
                if path in reached:return
                reached.add(path)
                raw = read(path,plan['sourceInventory'][path]).decode()
                for target in re.findall(r'^import\s+(\S+)',raw,re.MULTILINE):
                    if target != 'Base':visit(os.path.normpath(str(Path(path).parent/target)))
            visit(plan['entrypoint'])
            need(reached == set(plan['sourceInventory']), 'exact consuming closure')
        role=manifest['roles']['normal-native']
        plan=json.loads(read(role['planPath'],role['planSHA256']))
        receipt=json.loads(read(role['receiptPath'],role['receiptSHA256']))
        cases=[]
        def changed(edit):
            bad=copy.deepcopy(receipt);edit(bad);cases.append(bad)
        changed(lambda x:x['commands'].pop())
        changed(lambda x:x['commands'].append(copy.deepcopy(x['commands'][0])))
        changed(lambda x:x['commands'].reverse())
        changed(lambda x:x['commands'][0].__setitem__('label','other'))
        changed(lambda x:x['commands'][-1]['argv'].__setitem__(-1,'on'))
        changed(lambda x:x['commands'][0].__setitem__('capSeconds',31))
        changed(lambda x:x['commands'][0]['argv'].__setitem__(4,str(Path(plan['entrypoint']).parent.parent/'wrong-parent'/Path(plan['entrypoint']).name)))
        changed(lambda x:x['commands'][-1]['stdout'].__setitem__('path',str(Path(x['commands'][-1]['stdout']['path']).parent.parent/'wrong-parent'/'consumer.stdout')))
        changed(lambda x:x['commands'][-1]['stdout'].__setitem__('bytes',x['commands'][-1]['stdout']['bytes']+1))
        changed(lambda x:x['guards'].pop())
        changed(lambda x:x['guards'].append(copy.deepcopy(x['guards'][0])))
        changed(lambda x:x['guards'].reverse())
        controls=0
        for bad in cases:
            try:check_role(plan,bad,role,read)
            except (ValueError,KeyError,IndexError):controls+=1
            else:raise ValueError('malformed receipt accepted')
        role=manifest['roles']['placement-mutant-js'];plan=json.loads(read(role['planPath'],role['planSHA256']));receipt=json.loads(read(role['receiptPath'],role['receiptSHA256']))
        bad=copy.deepcopy(receipt);bad['completeNormalBaselineRejected']=False
        try:check_role(plan,bad,role,read)
        except (ValueError,KeyError):controls+=1
        else:raise ValueError('missing normal-rejection accepted')
        need(controls==13,'malformed control count')
        for row in manifest['rootSources']:
            raw=read(row['producerPath'],row['sha256'])
            target=HERE.parents[3]/row['repoPath']
            if target.exists():need(sha(target.read_bytes())==sha(raw),'root source bytes')
        delta=json.loads(read(manifest['sourceDelta']['path'],manifest['sourceDelta']['sha256']))
        mutation=delta['sourceMutation'];changed=0
        for row in delta['sourceMap']:
            normal=read(row['inputPath'],row['inputSHA256']);mutant=read(row['outputPath'],row['outputSHA256']).decode()
            mapping={item['to']:item['from'] for item in row['imports']}
            restored=re.sub(r'^import\s+(\S+)',lambda m:'import '+mapping.get(m.group(1),m.group(1)),mutant,flags=re.MULTILINE).encode()
            if row['inputPath']==mutation['path']:
                changed+=1;pos=mutation['offset'];anchor=mutation['old'].encode();replacement=mutation['new'].encode()
                need(normal.count(anchor)==1 and sha(restored)==mutation['bodyMutationSHA256'],'one-anchor mutation')
                need(restored[pos:pos+len(replacement)]==replacement and restored[:pos]+anchor+restored[pos+len(replacement):]==normal,'exact mutation inverse')
            else:need(restored==normal,'import-only inverse')
        need(changed==1,'exact one changed source')
        # Pure independent generate() functions perform no runtime execution.
        for i, row in enumerate(manifest['models']):
            module=type(sys)('named56_model_'+str(i));sys.modules[module.__name__]=module
            exec(compile(read(row['path'],row['sha256']),row['path'],'exec'),module.__dict__)
            need(module.generate()==read(row['expectedPath'],row['expectedSHA256']),'independent full model')
        control=json.loads(read(manifest['authority']['path'],manifest['authority']['sha256']))
        need(len(control['controls'])==9,'authority count')
        for path,digest in control['selectedToolInputs'].items():
            need(plan['pins'][path] == digest, 'authority tool scope')
        for row in control['controls']:
            receipt=json.loads(read(row['receipt']['path'],row['receipt']['sha256']))
            need(receipt['argv'] == ['/usr/bin/taskset','-c','3','/workspace/formal-proofs/bendvy/scripts/bend-check',receipt['sourcePath']], 'authority exact argv')
            need(receipt['stdoutSHA256']==row['stdout']['sha256'] and receipt['stderrSHA256']==row['stderr']['sha256'], 'authority stream binding')
            need(receipt['exitCode']==row['expectedExit'] and receipt['sourceSHA256']==row['sourceInventory'][receipt['sourcePath']],'authority source/exit')
            raw=read(row['stdout']['path'],row['stdout']['sha256'])+read(row['stderr']['path'],row['stderr']['sha256'])
            need(all(fragment.encode() in raw for fragment in row['diagnosticFragments']),'intended authority reason')
            for path,digest in row['sourceInventory'].items():read(path,digest)
    print('PASS_RETAINED_NAMED_APP',len(manifest['archiveMembers']),'members;5roles;13malformedcontrols;4models;9sourcecontrols;JSposthocNOT_FRESH_RUN')

if __name__=='__main__':
    main()
