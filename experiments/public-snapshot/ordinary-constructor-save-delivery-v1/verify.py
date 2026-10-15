#!/usr/bin/env python3
"""Offline retained-byte, command, guard, source-delta and full-oracle joins."""
import copy
import gzip
import hashlib
import importlib.util
import json
import tempfile
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
NORMAL = 'c381bdeab1e75d6ecbe893baabc2e901ee162499c2e59d838f7cdaa0a9a201dc'


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
        need(len(baseline) == plan['normalOracleBytes'] == 9605 and sha(baseline) == plan['normalOracleSHA256'] == NORMAL and actual != baseline, 'normal baseline not rejected')
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
        need(set(manifest['roles']) == {'normal-js', 'normal-native', 'admission-bypass-js', 'included-transient-retained-js'}, 'exact role set')
        controls = 0
        for name, role in manifest['roles'].items():
            plan = json.loads(read(role['planPath'], role['planSHA256']))
            receipt = json.loads(read(role['receiptPath'], role['receiptSHA256']))
            check_role(plan, receipt, role, read)
            if name == 'normal-native':
                mutations = [lambda r:r['commands'].pop(), lambda r:r['commands'].reverse(), lambda r:r['commands'][0].update(capSeconds=31), lambda r:r['commands'][0]['argv'].append('--wrong'), lambda r:r['commands'][0]['stdout'].update(bytes=1), lambda r:r['commands'][0]['stderr'].update(path='/tmp/wrong'), lambda r:r['commands'][0]['stdout'].update(published=False), lambda r:r['guards'].pop(), lambda r:r['guards'].reverse(), lambda r:r.update(status='INCOMPLETE')]
                for mutate in mutations:
                    bad = copy.deepcopy(receipt); mutate(bad)
                    try:
                        check_role(plan, bad, role, read)
                    except (ValueError, KeyError):
                        controls += 1
                    else:
                        raise ValueError('malformed receipt accepted')
        need(len(manifest['sourceDeltas']) == 2, 'exact mutation count')
        root_map = json.loads(read(manifest['rootSourceMap']['path'], manifest['rootSourceMap']['sha256']))
        need(len(root_map['rows']) == 16, 'root source count')
        for row in root_map['rows']:
            root = read(row['rootPath'], row['rootSHA256']).decode().splitlines(keepends=True)
            for change in row['importOnlyRewrites']:
                i = change['line'] - 1
                need(root[i] == change['to'], 'root import replacement')
                root[i] = change['from']
            need(''.join(root).encode() == read(row['qualifiedPath'], row['qualifiedSHA256']), 'root import inverse')
        for item in manifest['sourceDeltas']:
            delta = json.loads(read(item['path'], item['sha256']))
            changed = []
            for row in delta['sources']:
                normal = read(row['normalPath'], row['normalSHA256'])
                mutant = read(row['mutantPath'], row['mutantSHA256'])
                if normal != mutant:
                    changed.append((normal, mutant))
            need(len(changed) == 1, 'mutation changed other source bodies')
            normal, mutant = changed[0]
            anchor, replacement = delta['anchor'].encode(), delta['replacement'].encode()
            need(normal.count(anchor) == 1, 'mutation anchor')
            if 'offset' in delta:
                pos = delta['offset']
                need(mutant[pos:pos+len(replacement)] == replacement and mutant[:pos]+anchor+mutant[pos+len(replacement):] == normal, 'admission inverse')
            else:
                need(mutant.replace(delta['helpers'].encode(), b'', 1).replace(replacement, anchor, 1) == normal, 'transient inverse')
        # Restore only independent model source files, preserving their relative
        # imports. Calling compact_bytes does not run a backend or write output.
        with tempfile.TemporaryDirectory(prefix='snapshot58-oracle-') as tmp:
            for item in manifest['oracleFiles']:
                target = Path(tmp)/item['relativePath']; target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(read(item['path'], item['sha256']))
            for item in manifest['oracleModels']:
                target = Path(tmp)/item['relativePath']
                spec = importlib.util.spec_from_file_location('snapshot_oracle_'+str(controls), target)
                module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
                value = getattr(module, item['function'])()
                need(value == read(item['expectedPath'], item['expectedSHA256']), 'independent model reproduction')
                controls += 1
        ts = manifest['tsReuse']
        tp = json.loads(read(ts['plan']['path'], ts['plan']['sha256']))
        tr = json.loads(read(ts['receipt']['path'], ts['receipt']['sha256']))
        need(tr['status'] == 'DEVELOPMENT_PASS' and tr['planSHA256'] == ts['plan']['sha256'], 'historical TS receipt')
        need(len(tr['commands']) == 1, 'TS command count')
        command = tr['commands'][0]
        need(command['argv'] == tp['command']['argv'] == ['/usr/bin/taskset', '-c', '5', ts['nodePath'], ts['referencePath']], 'TS argv')
        need(command['exit'] == 0 and command['failure'] is None and command['capSeconds'] == tp['command']['capSeconds'] == 5, 'TS child')
        tsraw = read(ts['stdout']['path'], ts['stdout']['sha256'])
        need(command['streams']['stdout']['sha256'] == sha(tsraw) and command['streams']['stdout']['bytes'] == len(tsraw) == 1768, 'TS raw')
        need(command['streams']['stderr']['bytes'] == 0 and command['streams']['stderr']['sha256'] == sha(b''), 'TS stderr')
        need(tsraw == read(ts['expected']['path'], ts['expected']['sha256']), 'TS complete independent oracle')
        need(tp['pins'][ts['nodePath']] == ts['nodeSHA256'] and tp['pins'][ts['referencePath']] == ts['referenceSHA256'], 'TS source/tool selection')
        need(sha(read(ts['referencePath'], ts['referenceSHA256'])) == ts['referenceSHA256'], 'TS reference bytes')
        need(len(ts['currentSourcePins']) == 33, 'TS dependency scope')
        for path, digest in ts['currentSourcePins'].items():
            need(tp['pins'][path] == sha(read(path, digest)), 'TS source applicability')
        current_role = manifest['roles']['normal-js']
        current_receipt = json.loads(read(current_role['receiptPath'], current_role['receiptSHA256']))
        current_stdout = current_receipt['commands'][-1]['stdout']
        current = json.loads(read(current_stdout['path'], current_stdout['sha256']))
        prior = json.loads(tsraw)
        for schema in ['Workshop', 'Garden']:
            for old_key, new_key in ts['sharedSnapshotPairs']:
                need(prior[schema][old_key] == current['scenario'][schema][new_key], 'TS shared snapshot')
            need(prior[schema]['retainedAliasFirst'] == prior[schema]['after'], 'TS alias observation')
            need(current['scenario'][schema]['first'] != current['scenario'][schema]['after'], 'Bend detached save observation')
        need(controls == 14, 'control/model count')
    print('PASS_RETAINED_BASIC_SNAPSHOT',len(manifest['archiveMembers']),'members; 4 roles; 10 malformed controls; 4 source models; transient posthoc NOT_FRESH_RUN')

if __name__ == '__main__':
    main()
