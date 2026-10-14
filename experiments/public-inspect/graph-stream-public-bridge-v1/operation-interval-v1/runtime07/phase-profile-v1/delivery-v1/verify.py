#!/usr/bin/env python3
"""Validate the portable runtime06/07 diagnostic packet; run no tools."""
from __future__ import annotations
import gzip
import hashlib
import json
from pathlib import Path
import stat
import zipfile

HERE = Path(__file__).resolve().parent
BASE = HERE.parents[2]

def fail(message: str) -> None:
    raise SystemExit('FAIL: ' + message)

def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()

def require(ok: bool, message: str) -> None:
    if not ok:
        fail(message)

def member(zf: zipfile.ZipFile, name: str) -> bytes:
    try:
        return zf.read(name)
    except KeyError:
        fail('missing archive member: ' + name)

def obj(zf: zipfile.ZipFile, name: str):
    try:
        return json.loads(member(zf, name))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        fail(f'invalid JSON {name}: {exc}')

def check_runtime06(zf: zipfile.ZipFile, delivery: dict) -> None:
    prefix = 'evidence/runtime06/native/'
    plan_raw = member(zf, prefix + 'plan.json')
    receipt_raw = member(zf, prefix + 'receipt.json')
    observer_raw = member(zf, prefix + 'observer.json')
    observer_script = member(zf, prefix + 'observe_emit.py')
    plan, receipt, observer = [json.loads(raw) for raw in (plan_raw, receipt_raw, observer_raw)]
    expected = delivery['runtime06']
    require(sha(plan_raw) == expected['planSHA256'], 'runtime06 plan hash mismatch')
    require(sha(receipt_raw) == expected['receiptSHA256'], 'runtime06 receipt hash mismatch')
    require(sha(observer_raw) == expected['observerSHA256'], 'runtime06 observer hash mismatch')
    require(sha(observer_script) == expected['observerScriptSHA256'], 'runtime06 observer script hash mismatch')
    require(receipt.get('status') == 'INCOMPLETE' and receipt.get('acceptanceClaim', False) is False,
            'runtime06 must remain diagnostic INCOMPLETE')
    require(receipt.get('planSHA256') == sha(plan_raw), 'runtime06 receipt does not bind plan')
    commands = receipt.get('commands', [])
    require(len(commands) == 1, 'runtime06 receipt must retain only the attempted emit command')
    command = commands[0]
    require(command.get('label') == 'emit' and command.get('capSeconds') == 30
            and command.get('failure') == 'child deadline', 'runtime06 emit deadline classification changed')
    require(command.get('argv') == plan['commands'][0].get('argv'),
            'runtime06 receipt command differs from frozen plan')
    require(command.get('exit') is None, 'runtime06 deadline must not be recast as an exit code')
    for stream in ('stdout', 'stderr'):
        require(command.get(stream, {}).get('bytes') == 0, 'runtime06 raw stream is not empty as recorded')
    require(receipt.get('guardFailures') == [], 'runtime06 guard failure list changed')
    require(observer.get('generatedCAfterObserver', {}).get('exists') is False,
            'runtime06 observer records unexpected generated C')
    cg_start = observer.get('targetCgroupAtFirstObservation', {})
    cg_end = observer.get('targetCgroupAtEnd', {})
    require(cg_start.get('cpu.max', {}).get('value') == 'max 100000'
            and cg_end.get('cpu.max', {}).get('value') == 'max 100000',
            'runtime06 cgroup CPU limit context changed')
    start_stats = cg_start.get('cpu.stat', {}).get('values', {})
    end_stats = cg_end.get('cpu.stat', {}).get('values', {})
    require(start_stats.get('nr_throttled') == end_stats.get('nr_throttled'),
            'runtime06 cgroup throttling counter changed')
    bend = plan.get('tools', {}).get('bend')
    require(isinstance(bend, str) and bend in plan.get('pins', {}), 'runtime06 stock Bend binary is not pinned')
    require(plan['commands'][0].get('label') == 'emit' and plan['commands'][0].get('capSeconds') == 30,
            'runtime06 frozen command binding changed')
    ready = obj(zf, prefix + 'observer.ready.json')
    require(ready.get('planSHA256') == sha(plan_raw), 'runtime06 observer ready record does not bind plan')
    require(ready.get('observerScriptSHA256') == sha(observer_script), 'runtime06 ready record does not bind observer')
    samples = observer.get('samples', [])
    require(len(samples) == expected['sampleCount'] == 30, 'runtime06 observer sample count mismatch')
    target = observer.get('target', {})
    first, last = samples[0], samples[-1]
    require(all(s.get('pid') == target.get('pid') and s.get('startTimeTicks') == target.get('startTimeTicks')
                for s in samples), 'runtime06 samples do not retain one process identity')
    hz = ready.get('clockTicksPerSecond')
    require(isinstance(hz, int) and hz > 0, 'runtime06 clock tick rate missing')
    cpu_ticks = (last['utimeTicks'] + last['stimeTicks']) - (first['utimeTicks'] + first['stimeTicks'])
    wall_ns = int(last['elapsedMonotonicNs']) - int(first['elapsedMonotonicNs'])
    sampled_rss = max(s['vmRssKiB'] for s in samples)
    require(cpu_ticks == expected['sampledProcessCpuTicks'], 'runtime06 sampled CPU delta changed')
    require(wall_ns == expected['sampledWallNs'], 'runtime06 sampled wall interval changed')
    require(sampled_rss == expected['maxSampledRssKiB'], 'runtime06 sampled RSS maximum changed')

def check_runtime07(zf: zipfile.ZipFile, delivery: dict) -> None:
    prefix = 'evidence/runtime07/phase-profile-v1/'
    plan_raw = member(zf, prefix + 'native/plan.json')
    receipt_raw = member(zf, prefix + 'native/receipt.json')
    plan, receipt = json.loads(plan_raw), json.loads(receipt_raw)
    expected = delivery['runtime07']
    require(sha(plan_raw) == expected['planSHA256'], 'runtime07 plan hash mismatch')
    require(sha(receipt_raw) == expected['receiptSHA256'], 'runtime07 receipt hash mismatch')
    require(receipt.get('classification') == 'INCOMPLETE' and receipt.get('acceptanceClaim') is False
            and receipt.get('performanceClaim') is False, 'runtime07 diagnostic status was broadened')
    require(receipt.get('planSHA256') == sha(plan_raw), 'runtime07 receipt does not bind plan')
    command = plan.get('command', {})
    require(command.get('label') == 'native-source-emit-profile' and command.get('capSeconds') == 30
            and command.get('cpu') == 5, 'runtime07 source-profile command binding changed')
    require(command.get('argv', [])[0:3] == ['/usr/bin/taskset', '-c', '5'],
            'runtime07 CPU binding changed')
    require(plan.get('tools', {}).get('bunVersion') == '1.3.14', 'runtime07 Bun version changed')
    require(plan.get('tools', {}).get('bunSHA256') == expected['bunSHA256'], 'runtime07 Bun hash changed')
    compiler = plan.get('compilerSource', {})
    require(compiler.get('upstreamCommit') == expected['upstreamCommit'], 'runtime07 upstream compiler commit changed')
    require(compiler.get('officialTreeManifestSHA256') == expected['officialTreeManifestSHA256'],
            'runtime07 official compiler source manifest changed')
    copied, official = compiler.get('copiedFiles', {}), compiler.get('officialFiles', {})
    require(len(copied) == len(official) == 97, 'runtime07 source inventory size changed')
    require([name for name in sorted(official) if copied.get(name) != official[name]] == ['comp.ts'],
            'runtime07 copied compiler differs beyond instrumented comp.ts')
    require(compiler.get('originalInstrumentedFileSHA256') == official.get('comp.ts'),
            'runtime07 official comp.ts provenance changed')
    require(compiler.get('copiedInstrumentedFileSHA256') == copied.get('comp.ts'),
            'runtime07 instrumented comp.ts provenance changed')
    for name, expected_sha in copied.items():
        raw = member(zf, prefix + 'compiler/bend2/' + name)
        require(sha(raw) == expected_sha, 'runtime07 copied compiler source mismatch: ' + name)
    patch = member(zf, prefix + 'instrumentation.patch')
    require(sha(patch) == compiler.get('patchSHA256') == expected['instrumentationPatchSHA256'],
            'runtime07 instrumentation patch hash mismatch')
    license_raw = member(zf, prefix + 'LICENSE')
    require(sha(license_raw) == compiler.get('license', {}).get('copiedSHA256'),
            'runtime07 compiler license hash mismatch')
    profile_path = prefix + 'native/compile-book.jsonl'
    profile = member(zf, profile_path)
    profile_meta = receipt.get('raw', {}).get('phaseJSONL', {})
    require(len(profile) == profile_meta.get('bytes') == expected['profileBytes'], 'runtime07 raw profile size mismatch')
    require(sha(profile) == profile_meta.get('sha256') == expected['profileSHA256'],
            'runtime07 raw profile hash mismatch')
    rows = [json.loads(line) for line in profile.splitlines()]
    require(len(rows) == expected['profileRecords'] == 23181, 'runtime07 profile record count mismatch')
    require(rows[0].get('event') == 'compile-book-start', 'runtime07 profile start event mismatch')
    require(rows[-1].get('event') == 'start' and rows[-1].get('phase') == 'emit-body',
            'runtime07 profile final partial event mismatch')
    require(receipt.get('raw', {}).get('generatedC', {}).get('exists') is False,
            'runtime07 timed-out profile unexpectedly generated C')
    for stream in ('stdout', 'stderr'):
        require(receipt.get('raw', {}).get(stream, {}).get('bytes') == 0,
                'runtime07 raw stream is not empty as recorded')
    compression_map = json.loads(member(zf, prefix + 'SOURCE-COMPRESSION-MAP.json'))
    for row in compression_map.get('members', []):
        original = member(zf, prefix + row['logicalPath'])
        compressed = member(zf, prefix + row['archivePath'])
        require(len(original) == row['rawBytes'] and sha(original) == row['rawSHA256'],
                'runtime07 source compression raw mapping mismatch')
        require(len(compressed) == row['archiveBytes'] and sha(compressed) == row['archiveSHA256'],
                'runtime07 source compression member mismatch')
        require(gzip.decompress(compressed) == original, 'runtime07 compressed source does not reconstruct exact bytes')

def main() -> None:
    delivery = json.loads((HERE / 'DELIVERY.json').read_text(encoding='utf-8'))
    manifest_raw = (HERE / delivery['manifestPath']).read_bytes()
    archive_raw = (HERE / delivery['portablePath']).read_bytes()
    owned_raw = (HERE / delivery['ownershipPath']).read_bytes()
    require(sha(manifest_raw) == delivery['manifestSHA256'], 'manifest hash mismatch')
    require(sha(archive_raw) == delivery['portableSHA256'], 'portable archive hash mismatch')
    require(len(archive_raw) == delivery['portableBytes'], 'portable archive size mismatch')
    require(sha(owned_raw) == delivery['ownershipSHA256'], 'owned-path selection hash mismatch')
    require(sha((HERE / delivery['readmePath']).read_bytes()) == delivery['readmeSHA256'], 'README hash mismatch')
    require(sha(Path(__file__).read_bytes()) == delivery['verifierSHA256'], 'verifier hash mismatch')
    owned = json.loads(owned_raw)
    require(owned.get('format') == 'inspector55-runtime06-07-diagnostic-owned-paths-v1'
            and len(owned.get('paths', [])) == owned.get('count') == delivery['ownedPathCount'],
            'owned-path selection metadata mismatch')
    require(delivery['ownedPathCount'] == 6, 'unexpected diagnostic packet import selection size')
    expected_owned = sorted([
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/DELIVERY.json',
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/MANIFEST.json',
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/OWNED-PATHS.json',
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/PORTABLE.zip',
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/README.md',
        'experiments/public-inspect/graph-stream-public-bridge-v1/operation-interval-v1/runtime07/phase-profile-v1/delivery-v1/verify.py',
    ])
    require(owned.get('paths') == expected_owned, 'owned-path selection is not the exact diagnostic packet')
    manifest = json.loads(manifest_raw)
    require(manifest.get('format') == 'inspector55-runtime06-07-diagnostic-manifest-v1'
            and len(manifest.get('members', [])) == manifest.get('memberCount'), 'manifest metadata mismatch')
    names = [row['archivePath'] for row in manifest['members']]
    require(len(names) == len(set(names)), 'duplicate archive path in manifest')
    with zipfile.ZipFile(HERE / delivery['portablePath'], 'r') as zf:
        infos = zf.infolist()
        actual = [info.filename for info in infos]
        require(len(actual) == len(set(actual)) and sorted(actual) == sorted(names),
                'archive members differ from manifest')
        for info, row in zip(sorted(infos, key=lambda i: i.filename), sorted(manifest['members'], key=lambda r:r['archivePath'])):
            mode = (info.external_attr >> 16) & 0o170000
            require(not info.is_dir() and mode in (0, stat.S_IFREG), 'non-regular archive member')
            raw = zf.read(info.filename)
            require(len(raw) == row['bytes'] and sha(raw) == row['sha256'],
                    'archive member mismatch: ' + info.filename)
        check_runtime06(zf, delivery)
        check_runtime07(zf, delivery)
    print('PASS_RETAINED_RUNTIME06_07_DIAGNOSTICS')

if __name__ == '__main__':
    main()
