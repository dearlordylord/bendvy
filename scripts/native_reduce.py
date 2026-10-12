"""Prepare smaller existing specs-list fixtures without executing a compiler."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def reduce_specs(source, indices):
    pattern = r'(def specs\(\) -> List<&2,Spec>:\[\n)(.*?)(\n\])'
    match = re.search(pattern, source, re.S)
    if not match:
        raise ValueError('expected existing multiline specs fixture')
    rows = match[2].splitlines()
    if any(not row.strip().startswith('Spec{') or not row.rstrip().rstrip(',').endswith('}') for row in rows):
        raise ValueError('unsupported specs layout; refuse heuristic reduction')
    if not indices or len(set(indices)) != len(indices) or any(i < 0 or i >= len(rows) for i in indices):
        raise ValueError('unique in-range indices required')
    selected = ',\n'.join(rows[i].rstrip().rstrip(',') for i in indices)
    return source[:match.start(2)] + selected + source[match.end(2):]


def prepare(source_path, output, indices):
    source_path, output = Path(source_path).resolve(), Path(output)
    original = source_path.read_bytes()
    text = reduce_specs(original.decode(), indices)
    # Relocated fixtures must keep the same original dependencies.
    def absolute(match):
        target = (source_path.parent / match[1]).resolve()
        if any(c.isspace() for c in str(target)):
            raise ValueError('relocated import path contains whitespace')
        return 'import ' + str(target) + match[2]
    text = re.sub(r'^import (\.[^\s]+)(.*)$', absolute, text, flags=re.M)
    dependencies = {}
    def visit(path):
        path = path.resolve(strict=True)
        if str(path) in dependencies:
            return
        body = path.read_bytes()
        dependencies[str(path)] = hashlib.sha256(body).hexdigest()
        for name in re.findall(r'^import\s+(\S+)', body.decode(), re.M):
            if name != 'Base':
                visit(path.parent / name)
    visit(source_path)
    if any(hashlib.sha256(Path(p).read_bytes()).hexdigest() != sha for p, sha in dependencies.items()):
        raise ValueError('source changed while preparing reduction')
    output.mkdir(parents=True, exist_ok=False)
    (output / 'main.bend').write_text(text)
    manifest = {'status': 'PREPARED_NOT_EXECUTED', 'source': str(source_path),
                'sourceSHA256': hashlib.sha256(original).hexdigest(), 'indices': indices,
                'candidateSHA256': hashlib.sha256(text.encode()).hexdigest(),
                'fileImportClosure': dependencies, 'BaseAndTools': 'not yet frozen; launch review required',
                'scope': 'smaller workload, not semantic or compiler qualification',
                'next': 'review launch; check JS against independent subset oracle, then stock Native cap'}
    (output / 'REDUCTION.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest


def phase_summary(events):
    # Instrumented-copy markers are observations, not stock compiler causality.
    opened, complete = [], []
    for event in events:
        phase = event['phase']
        if event['event'] == 'start':
            opened.append(phase)
        elif event['event'] == 'end':
            if not opened or opened[-1] != phase:
                raise ValueError('unmatched/nonnested phase marker')
            opened.pop()
            complete.append(phase)
        else:
            raise ValueError('unknown phase marker')
    return {'completed': complete, 'openAtCaptureEnd': opened,
            'scope': 'provided instrumented markers only; no stock causality claim'}


def phase_log(text):
    """Summarize existing JSON-lines instrumented compiler stderr, including definitions."""
    opened, completed, last, ignored = {}, [], None, 0
    for line in text.splitlines():
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            ignored += 1
            continue
        if not isinstance(row, dict) or not isinstance(row.get('phase'), str):
            ignored += 1
            continue
        last = row
        phase = row['phase']
        for suffix, beginning in (('-enter', True), ('-start', True),
                                  ('-complete', False), ('-end', False), ('-exit', False)):
            if phase.endswith(suffix):
                key = (phase[:-len(suffix)], row.get('definition'), row.get('index'), row.get('pass'))
                if beginning:
                    if key in opened:
                        raise ValueError('duplicate open phase marker')
                    opened[key] = row
                else:
                    start = opened.pop(key, None)
                    completed.append({'end': row, 'start': start})
                break
    if last is None:
        raise ValueError('no instrumented phase markers')
    return {'lastMarker': last, 'completedMarkers': len(completed),
            'openAtCaptureEnd': list(opened.values()), 'ignoredLines': ignored,
            'scope': 'instrumented-copy observation only; no stock compiler causality or speedup'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    reduce = commands.add_parser('reduce')
    reduce.add_argument('source', type=Path)
    reduce.add_argument('output', type=Path)
    reduce.add_argument('--indices', type=int, nargs='+', required=True)
    phases = commands.add_parser('phases')
    phases.add_argument('events', type=Path)
    log = commands.add_parser('log')
    log.add_argument('stderr', type=Path)
    args = parser.parse_args()
    if args.command == 'reduce':
        result = prepare(args.source, args.output, args.indices)
    elif args.command == 'log':
        result = phase_log(args.stderr.read_text())
    else:
        result = phase_summary(json.loads(args.events.read_text()))
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
