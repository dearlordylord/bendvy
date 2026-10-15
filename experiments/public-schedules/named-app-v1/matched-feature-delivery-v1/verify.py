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
    labels = {'ts':['consumer'],'js':['emit','consumer'],'native':['emit','build','consumer']}[plan['role']]
    caps = {'ts':[5],'js':[30,5],'native':[30,120,5]}[plan['role']]
    prefix = ['/usr/bin/taskset', '-c', '5']
    if plan['role'] == 'ts':
        need(plan['commands'][0]['argv'] == prefix+[plan['tools']['node'],plan['entrypoint']], 'TS entry argv')
    else:
        need(plan['commands'][0]['argv'] == prefix+[plan['tools']['bend'], plan['entrypoint'], '-o', plan['generated']], 'emitter source/artifact argv')
    if plan['role'] == 'native':
        need(plan['commands'][1]['argv'] == prefix+[plan['tools']['clangWrapper'], '-O3', plan['generated'], '-o', plan['native'], '-pthread', '-lm'], 'ordinary O3 build argv')
        need(plan['commands'][-1]['argv'] == prefix+[plan['native'], '--threads', '1', '--gpu', 'off'], 'Native consumer argv')
    elif plan['role'] == 'js':
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

def check_batch(manifest, read):
    row=manifest['batch']; batch=json.loads(read(row['manifest']['path'],row['manifest']['sha256'])); receipt=json.loads(read(row['receipt']['path'],row['receipt']['sha256']))
    need(receipt['status']=='WRAPPERS_PASS' and receipt['pending']==[] and receipt['manifestSHA256']==row['manifest']['sha256'],'batch terminal')
    need([x['id'] for x in batch['jobs']]==[x['id'] for x in receipt['commands']]==['matched-ts01','matched-js01','matched-native01'],'batch exact jobs')
    for name,job,actual,cap in zip(['ts','js','native'],batch['jobs'],receipt['commands'],[30,60,180]):
        role=manifest['roles'][name]; plan=json.loads(read(role['planPath'],role['planSHA256'])); binding=plan['collectorBinding']
        argv=[binding['interpreter']['path'],binding['collector']['path'],'run',role['planPath'],role['planSHA256']]
        need(job['kind']=='ordinary' and job['plan']==role['planPath'] and job['planSHA256']==role['planSHA256'],'batch plan')
        need(job['argv']==actual['argv']==argv and job['cwd']==actual['cwd']==plan['cwd'] and job['capSeconds']==actual['capSeconds']==cap,'batch launch')
        need(actual['exit']==0 and actual['failure'] is None,'batch child')
        for key in ['interpreter','collector']:
            need(plan['pins'][binding[key]['path']]==binding[key]['sha256'],'collector binding')
        for stream in ['stdout','stderr']:
            value=actual[stream]; need(value['path']==str(Path(row['outputRoot'])/(job['id']+'.'+stream)) and value['published'] is True,'batch stream path')
            raw=read(value['path'],value['sha256']); need(raw==b'' and value['bytes']==0,'batch stream')


def main():
    delivery=json.loads((HERE/'DELIVERY.json').read_text())
    for name,row in delivery['artifacts'].items():
        raw=(HERE/name).read_bytes();need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'delivery '+name)
    manifest=json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as z:
        need(len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(manifest['archiveMembers']),'members')
        for name,row in manifest['archiveMembers'].items():
            raw=z.read(name);need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'archive bytes')
        def read(path,digest):
            row=manifest['pathHashToMember'][path+'@'+digest]
            need(row['sourcePath']==path and row['sha256']==digest,'full sourcePath identity')
            raw=z.read(row['member']);need(sha(raw)==digest,'path hash');return raw
        need(set(manifest['roles'])=={'ts','js','native'},'roles')
        for name,role in manifest['roles'].items():
            plan=json.loads(read(role['planPath'],role['planSHA256']));receipt=json.loads(read(role['receiptPath'],role['receiptSHA256']))
            check_role(plan,receipt,role,read)
            for path,digest in plan['pins'].items():
                if path in manifest['externalPins']:need(manifest['externalPins'][path]==digest,'external metadata')
                else:read(path,digest)
            reached=set()
            if name=='ts':
                guard=next(p for p in plan['pins'] if p.endswith('/development-plan-guard-v1/plan_guard.py'))
                module=type(sys)('archived_guard');exec(compile(read(guard,plan['pins'][guard]),guard,'exec'),module.__dict__)
                edges=module._ts_specifiers
            def visit(path):
                need(path in plan['sourceInventory'],'closure escape')
                if path in reached:return
                reached.add(path);text=read(path,plan['sourceInventory'][path]).decode()
                targets=edges(text) if name=='ts' else re.findall(r'^import\s+(\S+)',text,re.MULTILINE)
                for target in targets:
                    if target!='Base':visit(os.path.normpath(str(Path(path).parent/target)))
            visit(plan['entrypoint']);need(reached==set(plan['sourceInventory']),'consuming closure')
        check_batch(manifest,read)
        controls=0
        role=manifest['roles']['native'];plan=json.loads(read(role['planPath'],role['planSHA256']));receipt=json.loads(read(role['receiptPath'],role['receiptSHA256']))
        edits=[lambda x:x['commands'].pop(),lambda x:x['commands'].append(copy.deepcopy(x['commands'][0])),lambda x:x['commands'].reverse(),lambda x:x['commands'][0].__setitem__('label','other'),lambda x:x['commands'][0].__setitem__('capSeconds',31),lambda x:x['commands'][0]['argv'].__setitem__(4,str(Path(plan['entrypoint']).parent.parent/'wrong-parent'/Path(plan['entrypoint']).name)),lambda x:x['commands'][-1]['stdout'].__setitem__('path',str(Path(x['commands'][-1]['stdout']['path']).parent.parent/'wrong-parent'/'consumer.stdout')),lambda x:x['commands'][-1]['stdout'].__setitem__('bytes',1),lambda x:x['guards'].pop(),lambda x:x['guards'].append(copy.deepcopy(x['guards'][0])),lambda x:x['guards'].reverse()]
        for edit in edits:
            bad=copy.deepcopy(receipt);edit(bad)
            try:check_role(plan,bad,role,read)
            except (ValueError,KeyError,IndexError):controls+=1
            else:raise ValueError('malformed receipt accepted')
        path=receipt['commands'][-1]['stdout']['path'];digest=receipt['commands'][-1]['stdout']['sha256'];row=manifest['pathHashToMember'][path+'@'+digest];original=row['sourcePath'];row['sourcePath']=str(Path(path).parent.parent/'wrong-parent'/Path(path).name)
        try:check_role(plan,receipt,role,read)
        except ValueError:controls+=1
        else:raise ValueError('wrong manifest parent accepted')
        finally:row['sourcePath']=original
        model=manifest['model'];module=type(sys)('independent_named_model');sys.modules[module.__name__]=module;exec(compile(read(model['path'],model['sha256']),model['path'],'exec'),module.__dict__)
        for row in model['outputs']:
            expected=read(row['path'],row['sha256']);need(module.generate(row['scale'])==expected and len(expected)==row['bytes'],'full independent model');need(gzip.decompress(read(row['gzipPath'],row['gzipSHA256']))==expected,'model gzip')
        ownership=json.loads((HERE/'OWNERSHIP.json').read_text());repo=HERE.parents[3]
        for path in ownership['paths']:
            relative=Path(path);need(not relative.is_absolute() and '..' not in relative.parts,'owned relative path');need((repo/relative).is_file(),'owned file absent')
        for row in manifest['rootSources']:
            need((repo/row['repoPath']).read_bytes()==read(row['producerPath'],row['sha256']),'checkout source drift')
    print('PASS_RETAINED_MATCHED_NAMED_APP',len(manifest['archiveMembers']),'members;3roles;104records;actualbatch;',controls,'malformedcontrols')

if __name__=='__main__':main()
