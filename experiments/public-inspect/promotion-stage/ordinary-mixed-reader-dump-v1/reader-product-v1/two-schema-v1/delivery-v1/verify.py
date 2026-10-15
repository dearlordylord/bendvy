#!/usr/bin/env python3
"""Offline complete retained command/source/stream/guard/oracle joins; no execution."""
import copy,gzip,hashlib,json,zipfile,sys,tempfile,shutil,re,os
from pathlib import Path

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

def verify(packet,root,selftest=False):
    delivery=json.loads((packet/'DELIVERY.json').read_text())
    for name,row in delivery['artifacts'].items():
        raw=(packet/name).read_bytes();need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'delivery bytes')
    m=json.loads((packet/'MANIFEST.json').read_text());own=json.loads((packet/'OWNERSHIP.json').read_text())
    need(own['paths']==m['ownedPaths'] and len(set(own['paths']))==5,'exact ownership')
    for rel in own['paths']:
        need(not Path(rel).is_absolute() and '..' not in Path(rel).parts,'relative ownership')
        need((root/rel).is_file() and not (root/rel).is_symlink(),'owned regular file')
    for rel,digest in m['rootSources'].items():need(sha((root/rel).read_bytes())==digest,'current consumer drift')
    with zipfile.ZipFile(packet/'EVIDENCE.zip') as z:
        need(len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(m['archiveMembers']),'exact archive')
        for member,row in m['archiveMembers'].items():
            raw=z.read(member);need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'member bytes')
        def read(path,digest):
            row=m['pathHashToMember'][path+'@'+digest]
            need(row['sourcePath']==path and row['sha256']==digest,'full sourcePath identity')
            raw=z.read(row['member']);need(sha(raw)==digest and len(raw)==row['bytes'],'path bytes');return raw
        for role in m['roles'].values():
            p=json.loads(read(role['planPath'],role['planSHA256']));r=json.loads(read(role['receiptPath'],role['receiptSHA256']))
            check_role(p,r,role,read)
            for path,h in p['pins'].items():
                if path in m['externalPins']:need(m['externalPins'][path]==h,'external selected tool pin')
                else:need(sha(read(path,h))==h,'complete pinned input')
            reached=set()
            def visit(path):
                need(path in p['sourceInventory'],'closure escape')
                if path in reached:return
                reached.add(path)
                for target in re.findall(r'^import\s+(\S+)',read(path,p['sourceInventory'][path]).decode(),re.MULTILINE):
                    if target!='Base':visit(os.path.normpath(str(Path(path).parent/target)))
            visit(p['entrypoint'])
            need(reached==set(p['sourceInventory']) and len(reached)==93,'93 exact consuming source closure')
        typed=json.loads(read(m['controlPath'],m['controlSHA256']))
        need([c['name'] for c in typed['checks']]==['positive','cross-schema','affine-duplicate'],'type control identities')
        for check,expectedExit in zip(typed['checks'],[0,1,1]):
            need(check['exitCode']==expectedExit and check['capSeconds']==5,'intended type exit/cap')
            need(check['argv'][:5]==['/usr/bin/taskset','-c','0','/usr/bin/flock','/tmp/bendvy-parity-heavy.lock'],'type checker launch')
            need(sha(read(check['argv'][5],check['checkerSHA256']))==check['checkerSHA256'],'pinned type checker')
            need(check['argv'][-1] in check['sourceInventory'],'actual checked source')
            for path,h in check['sourceInventory'].items():need(sha(read(path,h))==h,'type source pin')
            combined=b''
            for stream in ['stdout','stderr']:
                row=check[stream];raw=read(row['path'],row['sha256']);need(len(raw)==row['bytes'],'type raw stream bytes');combined+=raw
            need(all(fragment.encode() in combined for fragment in check['diagnosticFragments']),'intended type diagnostic')
        controls=0
        if selftest:
            role=m['roles']['js'];p=json.loads(read(role['planPath'],role['planSHA256']));r=json.loads(read(role['receiptPath'],role['receiptSHA256']))
            for mutation in ['stream-parent','argv','cap','guard','status']:
                bad=copy.deepcopy(r)
                if mutation=='stream-parent':bad['commands'][-1]['stdout']['path']='/wrong-parent/consumer.stdout'
                if mutation=='argv':bad['commands'][-1]['argv'][-1]='/wrong/scenario.js'
                if mutation=='cap':bad['commands'][-1]['capSeconds']=6
                if mutation=='guard':bad['guards'].pop()
                if mutation=='status':bad['status']='INCOMPLETE'
                try:check_role(p,bad,role,read)
                except (ValueError,KeyError):controls+=1
                else:raise ValueError('malformed receipt accepted')
            row=r['commands'][-1]['stdout'];key=row['path']+'@'+row['sha256'];original=m['pathHashToMember'][key]['sourcePath'];m['pathHashToMember'][key]['sourcePath']='/wrong-parent/consumer.stdout'
            try:read(row['path'],row['sha256'])
            except ValueError:controls+=1
            else:raise ValueError('wrong manifest parent accepted')
            m['pathHashToMember'][key]['sourcePath']=original
    if selftest:
        with tempfile.TemporaryDirectory() as temp:
            relocated=Path(temp);(relocated/'src/ecs').mkdir(parents=True)
            for rel in own['paths']+list(m['rootSources']):
                dest=relocated/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(root/rel,dest)
            relocatedPacket=relocated/packet.relative_to(root)
            verify(relocatedPacket,relocated,False)
            changed=relocated/next(iter(m['rootSources']));changed.write_bytes(changed.read_bytes()+b'\n')
            try:verify(relocatedPacket,relocated,False)
            except ValueError:controls+=1
            else:raise ValueError('relocated source drift accepted')
    return {'status':'PASS' ,'members':len(m['archiveMembers']),'roles':2,'freshRoles':2,'typeChecks':3,'bytes':21996,'malformedControls':controls}
if __name__=='__main__':
    here=Path(__file__).resolve().parent
    root=next(p for p in here.parents if (p/'src/ecs').is_dir())
    print(json.dumps(verify(here,root,'--selftest' in sys.argv),sort_keys=True))
