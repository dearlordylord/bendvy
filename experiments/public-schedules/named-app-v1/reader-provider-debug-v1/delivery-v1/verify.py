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

def archive_read(z, manifest, path, digest):
    row=manifest['pathHashToMember'][path+'@'+digest]
    need(row['sourcePath']==path and row['sha256']==digest,'full sourcePath identity')
    raw=z.read(row['member']);need(sha(raw)==digest,'path hash');return raw

def check_source_copy(row, old, selected):
    need(row['transform']=='trim-extra-blank-EOF-lines-only','source-copy transform')
    need(sha(old)==row['producerSHA256'] and sha(selected)==row['selectedSHA256'],'source-copy full hashes')
    need(old.rstrip(b'\n')+b'\n'==selected,'exact EOF-only selected source join')

def verify(packet, root):
    delivery=json.loads((packet/'DELIVERY.json').read_text())
    for name,row in delivery['artifacts'].items():
        raw=(packet/name).read_bytes();need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'delivery '+name)
    m=json.loads((packet/'MANIFEST.json').read_text())
    own=json.loads((packet/'OWNERSHIP.json').read_text())
    need(set(own['paths'])==set(m['ownedPaths']) and len(own['paths'])==len(set(own['paths'])),'exact ownership')
    for rel in own['paths']:
        need(not Path(rel).is_absolute() and '..' not in Path(rel).parts,'relative ownership')
        p=root/rel;need(p.is_file() and not p.is_symlink(),'owned regular file')
    for rel,digest in m['rootSources'].items():need(sha((root/rel).read_bytes())==digest,'current owned source drift')
    with zipfile.ZipFile(packet/'EVIDENCE.zip') as z:
        need(len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(m['archiveMembers']),'exact archive members')
        for member,row in m['archiveMembers'].items():
            raw=z.read(member);need(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'archive bytes')
        read=lambda path,digest:archive_read(z,m,path,digest)
        need(set(m['roles'])=={'js','native'},'two ordinary roles')
        for role in m['roles'].values():
            plan=json.loads(read(role['planPath'],role['planSHA256']));receipt=json.loads(read(role['receiptPath'],role['receiptSHA256']))
            check_role(plan,receipt,role,read)
            need(role['expectedBytes']==19681 and role['expectedSHA256']=='bcfed87603c04100f7382056baf62eed92c82f4990e5bc80472b71fe68fc3da7','scope oracle')
            binding=plan['collectorBinding']
            for key in ['interpreter','collector']:need(plan['pins'][binding[key]['path']]==binding[key]['sha256'],'launch collector binding')
            for path,digest in plan['pins'].items():
                if path in m['externalPins']:need(m['externalPins'][path]==digest,'selected external pin metadata')
                else:need(sha(read(path,digest))==digest,'archived plan input')
            reached=set()
            def visit(path):
                need(path in plan['sourceInventory'],'closure escape')
                if path in reached:return
                reached.add(path)
                for target in re.findall(r'^import\s+(\S+)',read(path,plan['sourceInventory'][path]).decode(),re.MULTILINE):
                    if target!='Base':visit(os.path.normpath(str(Path(path).parent/target)))
            visit(plan['entrypoint']);need(reached==set(plan['sourceInventory']) and len(reached)==78,'exact consuming closure')
        first=m['roles']['js'];executed=json.loads(read(first['planPath'],first['planSHA256']))['sourceInventory']
        changed=set()
        for rel,digest in m['rootSources'].items():
            path=str(Path(m['producerRoot'])/rel);selected=(root/rel).read_bytes()
            need(read(path,digest)==selected,'selected source archive join')
            if executed[path]!=digest:
                changed.add(rel);row=m['sourceCopyMap'][rel]
                need(row['sourcePath']==path and row['selectedSHA256']==digest and row['producerSHA256']==executed[path],'full source-copy origin')
                check_source_copy(row,read(path,row['producerSHA256']),selected)
                for role in m['roles'].values():
                    original=json.loads(read(role['planPath'],role['planSHA256']))
                    need(original['sourceInventory'][path]==row['producerSHA256'],'executed source-copy origin')
        need(changed==set(m.get('sourceCopyMap',{})),'complete selected-copy change set')
        pins=json.loads(read(m['oracleSourcePins']['path'],m['oracleSourcePins']['sha256']))
        for path,digest in pins.items():need(sha(read(path,digest))==digest,'independent model source binding')
        for row in m['sourceCheckHistory']:
            for item in row['files']:need(sha(read(item['path'],item['sha256']))==item['sha256'],'retained source check history')
    return m

def selftest(packet,root,m):
    with zipfile.ZipFile(packet/'EVIDENCE.zip') as z:
        read=lambda path,digest:archive_read(z,m,path,digest)
        role=m['roles']['native'];p=json.loads(read(role['planPath'],role['planSHA256']));r=json.loads(read(role['receiptPath'],role['receiptSHA256']))
        bad=[]
        def probe(label, mutate):
            q=copy.deepcopy(p);s=copy.deepcopy(r);mutate(q,s)
            try:check_role(q,s,role,read)
            except (ValueError,KeyError,IndexError):bad.append(label);return
            raise ValueError('malformed control accepted '+label)
        probe('missing-consumer',lambda p,r:r['commands'].pop())
        probe('duplicate-command',lambda p,r:r['commands'].__setitem__(1,copy.deepcopy(r['commands'][0])))
        probe('wrong-argv',lambda p,r:r['commands'][0]['argv'].__setitem__(4,'/wrong/main.bend'))
        probe('wrong-cap',lambda p,r:r['commands'][0].__setitem__('capSeconds',31))
        probe('missing-guard',lambda p,r:r['guards'].pop())
        probe('reordered-guard',lambda p,r:r['guards'].reverse())
        probe('same-basename-wrong-parent-stream',lambda p,r:r['commands'][-1]['stdout'].__setitem__('path','/wrong/parent/consumer.stdout'))
        probe('wrong-plan-binding',lambda p,r:r.__setitem__('planSHA256','0'*64))
        probe('wrong-original-status',lambda p,r:r.__setitem__('status','INCOMPLETE'))
        probe('wrong-artifact',lambda p,r:r.__setitem__('buildArtifactSHA256','0'*64))
        other=copy.deepcopy(m);item=next(iter(other['pathHashToMember']));other['pathHashToMember'][item]['sourcePath']='/wrong-parent/'+Path(other['pathHashToMember'][item]['sourcePath']).name
        try:archive_read(z,other,*item.rsplit('@',1))
        except ValueError:bad.append('same-basename-wrong-parent-manifest')
        else:raise ValueError('wrong manifest sourcePath accepted')
        row=next(iter(m['sourceCopyMap'].values()));old=read(row['sourcePath'],row['producerSHA256']);selected=read(row['sourcePath'],row['selectedSHA256'])
        altered=b' '+selected;wrong=copy.deepcopy(row);wrong['selectedSHA256']=sha(altered)
        try:check_source_copy(wrong,old,altered)
        except ValueError:bad.append('non-EOF-body-indent-mutation')
        else:raise ValueError('body/indentation change accepted')
        wrong=copy.deepcopy(row);wrong['producerSHA256']='0'*64
        try:check_source_copy(wrong,old,selected)
        except ValueError:bad.append('old-new-source-hash-mismatch')
        else:raise ValueError('wrong source hashes accepted')
    with tempfile.TemporaryDirectory() as temp:
        moved=Path(temp)
        for rel in m['ownedPaths']:
            dst=moved/rel;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes((root/rel).read_bytes())
        movedPacket=moved/m['packetRelativePath'];verify(movedPacket,moved)
        rel=next(iter(m['rootSources']));(moved/rel).write_bytes((moved/rel).read_bytes()+b'\n')
        try:verify(movedPacket,moved)
        except ValueError:bad.append('relocated-local-source-drift')
        else:raise ValueError('relocated drift accepted')
    need(len(bad)==14,'malformed control count')
    return bad

def main():
    packet=HERE;root=HERE.parents[4];m=verify(packet,root)
    controls=selftest(packet,root,m) if '--selftest' in sys.argv else []
    print(json.dumps({'status':'PASS_RETAINED_ORDINARY_READER_DEBUG_SCOPED','members':len(m['archiveMembers']),'roles':2,'fullBytes':19681,'records':7,'callbackResults':2,'negativeControls':len(controls),'runtimeScope':'one schema, trusted factory, no disposal execution, historical runtime62 helpers + fa74 provider; not final cross-frame behavior authority or timing'}))
if __name__=='__main__':main()
