"""Validate the existing emit/build/consumer/source delivery-plan dialect."""
import argparse
import json
from pathlib import Path


def validate(plan):
    commands = plan.get('commands', [])
    labels = [c.get('label') for c in commands]
    if not commands or any(not isinstance(x, str) or not x for x in labels):
        raise ValueError('nonempty command labels required')
    if len(set(labels)) != len(labels):
        raise ValueError('duplicate command label')
    source = all('--check-only' in c.get('argv', []) for c in commands)
    if source:
        if any(not x.startswith('source-') or x == 'source-' for x in labels):
            raise ValueError('check-only commands require source- labels for collector dispatch')
        return 'source'
    if any('--check-only' in c.get('argv', []) for c in commands):
        raise ValueError('mixed source/runtime plan is unsupported')
    native = 'build' in labels
    expected = ['emit', 'build', 'consumer'] if native else ['emit', 'consumer']
    if labels != expected:
        raise ValueError('runtime command order must be ' + repr(expected))
    generated = plan.get('generated')
    suffix = '.c' if native else '.js'
    if not isinstance(generated, str) or Path(generated).suffix != suffix:
        raise ValueError('generated artifact must end in ' + suffix)
    def output(command):
        argv = command.get('argv', [])
        if argv.count('-o') != 1 or argv.index('-o') + 1 >= len(argv):
            raise ValueError('one explicit -o output required')
        return argv[argv.index('-o') + 1]
    if output(commands[0]) != generated:
        raise ValueError('emit output differs from generated artifact')
    if native:
        executable = plan.get('native')
        if not isinstance(executable, str) or executable == generated:
            raise ValueError('distinct Native executable required')
        if generated not in commands[1]['argv'] or output(commands[1]) != executable:
            raise ValueError('build input/output differs from planned artifacts')
        if executable not in commands[2]['argv']:
            raise ValueError('consumer does not invoke planned Native executable')
    elif generated not in commands[1]['argv']:
        raise ValueError('consumer does not invoke generated JS')
    return 'native' if native else 'js'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('plan', type=Path, nargs='?')
    parser.add_argument('--manifest', type=Path)
    args = parser.parse_args()
    if bool(args.plan) == bool(args.manifest):
        parser.error('select one plan or --manifest')
    plans = [args.plan] if args.plan else [Path(p) for p in json.loads(args.manifest.read_text())['plans']]
    if not plans:
        raise ValueError('nonempty candidate plan selection required')
    for path in plans:
        print(str(path) + ': ' + validate(json.loads(path.read_text())))


if __name__ == '__main__':
    main()
