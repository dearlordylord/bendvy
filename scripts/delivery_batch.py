"""Run an explicit ready batch sequentially; collectors retain their own locks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import time
import task_runner
from evidence_boundary import ReceiptBoundary
from delivery_preflight import validate


def run_batch(manifest_path, output):
    manifest_path, output = Path(manifest_path), Path(output)
    frozen = manifest_path.read_bytes()
    manifest = json.loads(frozen)
    jobs = manifest['jobs']
    ids = [j['id'] for j in jobs]
    if not jobs or len(set(ids)) != len(ids):
        raise ValueError('nonempty unique jobs required')
    for job in jobs:
        if not job['id'] or Path(job['id']).name != job['id'] or job['id'] in ('.', '..'):
            raise ValueError('job id must be a filename')
        if job.get('kind') != 'ordinary':
            raise ValueError('performance/resource admission remains with coordinator')
        if not job['argv'] or not 0 < job['capSeconds']:
            raise ValueError('explicit command and wrapper cap required')
        plan_bytes = Path(job['plan']).read_bytes()
        if hashlib.sha256(plan_bytes).hexdigest() != job['planSHA256']:
            raise ValueError('job plan digest mismatch')
        validate(json.loads(plan_bytes), plan_path=Path(job['plan']))
    # This is not an outer heavy lock: frozen collectors acquire theirs themselves.
    # The shared command owner handles cancellation, descendants and deadlines.
    output.mkdir(parents=True, exist_ok=False)
    receipt = {'status': 'INCOMPLETE', 'manifestSHA256': hashlib.sha256(frozen).hexdigest(),
               'commands': [], 'pending': ids[:], 'scope': 'wrapper execution only'}
    def guard():
        if manifest_path.read_bytes() != frozen:
            raise ValueError('batch manifest changed')
        for job in jobs:
            if hashlib.sha256(Path(job['plan']).read_bytes()).hexdigest() != job['planSHA256']:
                raise ValueError('batch job plan changed')
        for row in receipt['commands']:
            for stream in ('stdout', 'stderr'):
                captured = row.get(stream, {})
                if captured.get('published'):
                    path = Path(captured['path'])
                    if path.is_symlink() or hashlib.sha256(path.read_bytes()).hexdigest() != captured['sha256']:
                        raise ValueError('captured stream changed')
    with ReceiptBoundary(receipt, output / 'receipt.json', [('batch inputs', guard)]):
        for job in jobs:
            guard()
            started = time.monotonic()
            result = task_runner.execute_result(job['argv'], job['capSeconds'],
                                                cwd=job['cwd'], capture='split')
            row = {'id': job['id'], 'exit': result['exit'], 'failure': result['failure'],
                   'seconds': time.monotonic() - started}
            # Retain the terminal result even if raw publication subsequently fails.
            receipt['commands'].append(row)
            receipt['pending'].remove(job['id'])
            for stream in ('stdout', 'stderr'):
                raw = result[stream]
                row[stream] = {'path': str(output / (job['id'] + '.' + stream)),
                               'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(),
                               'published': False, 'unpublishedHex': raw.hex()}
            for stream in ('stdout', 'stderr'):
                raw = result[stream]
                target = output / (job['id'] + '.' + stream)
                fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
                with os.fdopen(fd, 'wb') as file:
                    file.write(raw)
                row[stream]['published'] = True
                del row[stream]['unpublishedHex']
            if result['failure'] or result['exit'] != 0:
                raise RuntimeError('job failed: ' + job['id'])
        receipt['status'] = 'WRAPPERS_PASS'
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    run_batch(args.manifest, args.output)


if __name__ == '__main__':
    main()
