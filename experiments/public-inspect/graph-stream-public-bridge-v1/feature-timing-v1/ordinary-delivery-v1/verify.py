#!/usr/bin/env python3
"""Offline verification of the retained matched lifecycle packet."""
import copy
import gzip
import hashlib
import json
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ORACLE = '21111a66fe196fc3c9615eadc8a39648c3583a695b233fd3d78eda355693cd60'
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
    actual_labels = ['emit'] if failed else labels
    need([c['label'] for c in receipt['commands']] == actual_labels, 'receipt command order/count')
    need(receipt['planSHA256'] == plan_sha, 'receipt plan hash')
    need(receipt['status'] == ('INCOMPLETE' if failed else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'), 'status')
    need(plan['oracleBytes'] == 24298 and plan['oracleSHA256'] == ORACLE, 'oracle binding')
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
        if failed:
            need(actual['exit'] != 0 or actual['failure'] is not None, 'deadline failure erased')
        else:
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
                need(len(data) == 24298 and sha(data) == ORACLE, 'full logical output')
        if label in ['emit', 'build'] and not failed:
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
    if not failed:
        need(receipt['wholeOracleSHA256'] == ORACLE, 'receipt oracle')
        need(gzip.decompress(raw(plan['oracle'], plan['pins'][plan['oracle']])) == raw(receipt['commands'][-1]['stdout']['path'], ORACLE), 'independent gzip oracle')

def verify_root_source(manifest, raw, map_override=None):
    meta = manifest['rootSource']
    selection_path, selection_sha = split_key(meta['selectionKey'])
    selection = json.loads(raw(selection_path, selection_sha))
    need(selection['commit'].startswith(meta['commit']) and meta['commitFull'] == FULL_SOURCE_COMMIT, 'source commit')
    need(selection['commit'] == meta['commitFull'][:len(selection['commit'])], 'selection commit binding')
    need(len(selection['paths']) == meta['selectionRows'], 'source selection count')
    selection_hashes = {row['path']: row['sha256'] for row in selection['paths']}
    for path, digest in selection_hashes.items():
        need(sha(raw(path, digest)) == digest, 'selected source row')

    map_path, map_sha = split_key(meta['mapKey'])
    source_map = map_override if map_override is not None else json.loads(raw(map_path, map_sha))
    if map_override is None:
        need(sha(raw(map_path, map_sha)) == map_sha, 'source map bytes')
    need(source_map['canonicalCoreSHA256'] == meta['canonicalCoreSHA256'], 'canonical core pin')
    need(len(source_map['rows']) == meta['sourceRows'] == 15, 'root source row count')
    for row in source_map['rows']:
        rel = row['rootRelativePath']
        digest = row['rootSHA256']
        need(selection_hashes.get(rel) == digest, 'map/selection root join')
        root_bytes = raw(rel, digest)
        qualified_path = row['qualifiedInput']
        qualified_bytes = raw(qualified_path, row['qualifiedSHA256'])
        lines = root_bytes.splitlines(keepends=True)
        seen = set()
        for edit in row['importOnlyRewrites']:
            index = edit['line'] - 1
            need(index >= 0 and index < len(lines) and index not in seen, 'import map line')
            seen.add(index)
            need(lines[index] == edit['to'].encode(), 'root import target')
            lines[index] = edit['from'].encode()
        need(b''.join(lines) == qualified_bytes, 'inverse Bend source map')
        need(sha(qualified_bytes) == row['qualifiedSHA256'], 'qualified Bend source hash')

    ts_map = source_map['typescriptImportOnly']
    ts_root = meta['typescriptRootPath']
    need(selection_hashes.get(ts_root) == ts_map['rootSHA256'], 'TS root selection join')
    ts_root_bytes = raw(ts_root, ts_map['rootSHA256'])
    ts_qualified_bytes = raw(meta['typescriptQualifiedPath'], ts_map['qualifiedSHA256'])
    old = ts_map['from'].encode()
    new = ts_map['to'].encode()
    need(ts_map['inverseRestoresQualifiedBytes'] is True and new in ts_root_bytes, 'TS import relocation')
    restored = ts_root_bytes.replace(new, old)
    need(restored == ts_qualified_bytes and sha(restored) == ts_map['qualifiedSHA256'], 'inverse TS source map')

    core_path = meta['canonicalCorePath']
    core_bytes = raw(core_path, meta['canonicalCoreSHA256'])
    need(sha(core_bytes) == meta['canonicalCoreSHA256'], 'canonical core bytes')
    source_check = source_map['sourceCheck']
    check_path = source_check['path']
    check_sha = source_check['sha256']
    need(meta['sourceCheckReceiptKey'] == check_path+'@'+check_sha or meta['sourceCheckReceiptKey'].endswith('/'+check_path+'@'+check_sha), 'source check receipt key')
    check = json.loads(raw(check_path, check_sha))
    need(check['exit'] == 0 and check['failure'] is None and check['capSeconds'] == 5 and check['capture'] == 'split', 'source check classification')
    need(source_check['exit'] == 0 and source_check['capSeconds'] == 5 and source_check['proofClaim'] is False, 'source check scope')
    parent = str(Path(check_path).parent)
    for stream in ['stdout', 'stderr']:
        data = raw(parent+'/'+stream, check[stream+'SHA256'])
        need(sha(data) == check[stream+'SHA256'], 'source check stream')
        need(stream != 'stderr' or data == b'', 'source check stderr')
    return source_map

def verify_phase(meta, raw):
    plan_path, plan_sha = split_key(meta['planKey'])
    receipt_path, receipt_sha = split_key(meta['receiptKey'])
    profile_path, profile_sha = split_key(meta['profileKey'])
    scenario_path, scenario_sha = split_key(meta['scenarioKey'])
    plan = json.loads(raw(plan_path, plan_sha))
    receipt = json.loads(raw(receipt_path, receipt_sha))
    profile = raw(profile_path, profile_sha)
    scenario = raw(scenario_path, scenario_sha)
    need(meta['acceptanceClaim'] is False and meta['performanceClaim'] is False, 'diagnostic-only metadata')
    need(plan['status'] == 'PREPARED_NOT_EXECUTED', 'frozen plan status')
    need(plan['format'] == 'bend-compiler-phase-profile-v1', 'profile plan format')
    need(plan['upstream']['version'] == '2.0.35' and plan['compilerSource']['upstreamCommit'] == PHASE_COMMIT, 'instrumented compiler provenance')
    need(plan['upstream']['commit'] == meta['upstreamCommit'] == PHASE_COMMIT, 'official compiler commit')
    need(plan['command']['label'] == 'native-source-emit-profile' and plan['command']['capture'] == 'split', 'profile command')
    need(plan['command']['cpu'] == meta['cpu'] == 5 and plan['command']['capSeconds'] == meta['capSeconds'] == 30, 'profile cap/CPU')
    need(receipt['format'] == 'bend-compiler-phase-profile-receipt-v1', 'profile receipt format')
    need(receipt['planSHA256'] == plan_sha and receipt['command']['exit'] == 0 and receipt['command']['failure'] is None, 'profile receipt binding')
    need(receipt['acceptanceClaim'] is False and receipt['performanceClaim'] is False and receipt['pinnedInputsUnchanged'] is True, 'profile receipt limits')
    need(receipt['command']['argv'] == plan['command']['argv'] and receipt['command']['capSeconds'] == 30 and receipt['command']['runnerSHA256'] == plan['taskRunner']['sha256'], 'profile argv/runner')
    need(receipt['raw']['phaseJSONL']['path'] == profile_path and receipt['raw']['phaseJSONL']['bytes'] == len(profile) and receipt['raw']['phaseJSONL']['sha256'] == profile_sha, 'phase profile raw join')
    need(receipt['raw']['generatedC']['path'] == scenario_path and receipt['raw']['generatedC']['bytes'] == len(scenario) and receipt['raw']['generatedC']['sha256'] == scenario_sha, 'diagnostic C raw join')
    need(len(scenario) == 21907288 and sha(scenario) == scenario_sha, 'profile generated C')
    rows = [json.loads(line) for line in profile.splitlines()]
    need(len(rows) == meta['profileRecords'] == 59891, 'profile record count')
    need(rows[0]['event'] == 'compile-book-start' and rows[-1]['event'] == 'compile-book-complete', 'profile completeness')
    need(rows[-1]['elapsedNs'] == meta['elapsedNs'] == '18043299845' and rows[-1]['outputChars'] == len(scenario), 'profile terminal record')
    for side in ['pre', 'post']:
        guard_path = plan['guards'][side]
        digest = receipt['guards'][side+'SHA256']
        guard = raw(guard_path, digest)
        need(sha(guard) == digest, 'phase guard bytes')
    need(plan['taskRunner']['path'] == receipt['command']['runnerPath'] if 'runnerPath' in receipt['command'] else plan['taskRunner']['sha256'] == receipt['command']['runnerSHA256'], 'profile runner binding')
    need(sha(raw(plan['taskRunner']['path'], plan['taskRunner']['sha256'])) == plan['taskRunner']['sha256'], 'profile runner bytes')
    # The retained patch path/hash binds the only local compiler change.
    patch_path = plan['compilerSource']['patchPath']
    patch_sha = plan['compilerSource']['patchSHA256']
    need(plan['pins'].get(patch_path) == patch_sha, 'instrumentation patch plan pin')
    need(sha(raw(patch_path, patch_sha)) == patch_sha, 'instrumentation patch bytes')
    for stream in ['stdout', 'stderr']:
        info = receipt['raw'][stream]
        data = raw(info['path'], info['sha256'])
        need(info['exists'] is True and info['regular'] is True and info['bytes'] == len(data) and sha(data) == info['sha256'], 'profile '+stream+' raw join')
        need(stream != 'stderr' or data == b'', 'profile stderr')

def main():
    delivery = json.loads((HERE/'DELIVERY.json').read_text())
    expected_artifacts = {'README.md', 'RESULT.json', 'EVIDENCE.zip', 'MANIFEST.json', 'verify.py'}
    need(set(delivery['artifacts']) == expected_artifacts, 'delivery artifact set')
    for path, row in delivery['artifacts'].items():
        data = (HERE/path).read_bytes()
        need(sha(data) == row['sha256'] and len(data) == row['bytes'], 'delivery '+path)
    manifest = json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as z:
        names = z.namelist()
        need(len(names) == len(set(names)) and set(names) == set(manifest['archiveMembers']), 'archive membership')
        for name, row in manifest['archiveMembers'].items():
            data = z.read(name)
            need(sha(data) == row['sha256'] and len(data) == row['bytes'], 'archive bytes')
        def raw(path, digest):
            key = path+'@'+digest
            need(key in manifest['pathHashToMember'], 'missing path/hash binding: '+key)
            return z.read(manifest['pathHashToMember'][key])
        source_map = verify_root_source(manifest, raw)
        verify_phase(manifest['phaseDiagnostic'], raw)
        tests = 0
        for name, role in manifest['roles'].items():
            plan_path, plan_sha = split_key(role['planKey'])
            receipt_path, receipt_sha = split_key(role['receiptKey'])
            plan = json.loads(raw(plan_path, plan_sha))
            receipt = json.loads(raw(receipt_path, receipt_sha))
            failed = name == 'native-failed'
            verify_role(plan, receipt, plan_path, plan_sha, raw, failed)
            if name == 'native':
                receipt_mutations = [
                    lambda r:r['commands'].pop(),
                    lambda r:r['commands'].reverse(),
                    lambda r:r['commands'][0].update(capSeconds=31),
                    lambda r:r['commands'][0]['argv'].append('--other'),
                    lambda r:r['commands'][0]['stdout'].update(bytes=1),
                    lambda r:r['commands'][0]['stdout'].update(sha256='0'*64),
                    lambda r:r['commands'][0]['stdout'].update(path='/tmp/wrong'),
                    lambda r:r['guards'].pop(),
                    lambda r:r['guards'].reverse(),
                    lambda r:r.update(wholeOracleSHA256='0'*64),
                ]
                for mutate in receipt_mutations:
                    bad = copy.deepcopy(receipt); mutate(bad)
                    try: verify_role(plan, bad, plan_path, plan_sha, raw)
                    except (ValueError, KeyError, TypeError): tests += 1
                    else: raise ValueError('malformed role receipt accepted')
        root_meta = manifest['rootSource']
        map_path, map_sha = split_key(root_meta['mapKey'])
        frozen_map = json.loads(raw(map_path, map_sha))
        map_mutations = []
        bad = copy.deepcopy(frozen_map); bad['rows'][0]['rootSHA256'] = '0'*64; map_mutations.append(bad)
        bad = copy.deepcopy(frozen_map); bad['rows'][0]['importOnlyRewrites'][0]['to'] = 'import wrong target\n'; map_mutations.append(bad)
        bad = copy.deepcopy(frozen_map); bad['typescriptImportOnly']['to'] = 'wrong/'; map_mutations.append(bad)
        for badmap in map_mutations:
            try: verify_root_source(manifest, raw, badmap)
            except (ValueError, KeyError, TypeError): tests += 1
            else: raise ValueError('malformed source map accepted')
        bad_phase = copy.deepcopy(manifest['phaseDiagnostic']); bad_phase['performanceClaim'] = True
        try: verify_phase(bad_phase, raw)
        except (ValueError, KeyError, TypeError): tests += 1
        else: raise ValueError('diagnostic performance claim accepted')
        need(tests == 14, 'negative control count')
    print('PASS_MATCHED_LIFECYCLE_SCALE1',len(manifest['archiveMembers']),'members; TS/JS/Native 24298 bytes; 14 malformed controls; source maps and profile diagnostic verified; no timing')

if __name__ == '__main__':
    main()
