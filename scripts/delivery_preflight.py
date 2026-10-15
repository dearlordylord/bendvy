"""Validate the existing emit/build/consumer/source delivery-plan dialect."""
import argparse
import json
from pathlib import Path


_ARTIFACT_PARENT_GUARD = 'Existing collector guards both generated and native parents before/acquired/post/final.'
_CURRENT_COMPILER_PROVENANCE_FIELDS = {
    'currentC', 'currentCSHA256', 'currentCompilerSHA256',
}


def _is_sha256(value):
    return (isinstance(value, str) and len(value) == 64 and
            all(character in '0123456789abcdef' for character in value))


def _validate_import_closure(plan):
    # This optional field belongs to the current source-consuming collector
    # dialect.  sourceInventory remains a mapping in its authored order; the
    # collector's separate importClosure value is the sorted path list.
    if 'importClosure' not in plan:
        return
    closure = plan['importClosure']
    inventory = plan.get('sourceInventory')
    if not isinstance(closure, list) or any(not isinstance(path, str) for path in closure):
        raise ValueError('importClosure must be a list of source paths')
    if not isinstance(inventory, dict) or any(not isinstance(path, str) for path in inventory):
        raise ValueError('importClosure requires a sourceInventory mapping')
    if closure != sorted(inventory):
        raise ValueError('importClosure must be the sorted exact sourceInventory path list')


def _validate_current_compiler_provenance(plan):
    provenance = plan.get('provenance')
    if not isinstance(provenance, dict):
        return

    # Generic provenance summaries are used by ordinary plans too.  Opt in
    # only when a plan declares the exact current-C/compiler provenance shape.
    declared = _CURRENT_COMPILER_PROVENANCE_FIELDS.intersection(provenance)
    if not declared:
        return
    if not _CURRENT_COMPILER_PROVENANCE_FIELDS.issubset(provenance):
        raise ValueError('current compiler provenance fields must be declared together')

    current_c = provenance['currentC']
    generated = plan.get('generated')
    pins = plan.get('pins')
    tools = plan.get('tools')
    if not isinstance(current_c, str) or current_c != generated:
        raise ValueError('currentC must identify the planned generated C artifact')
    if not isinstance(pins, dict) or not isinstance(tools, dict):
        raise ValueError('current compiler provenance requires plan pins and tools')
    current_c_sha = provenance['currentCSHA256']
    if (not _is_sha256(current_c_sha) or pins.get(current_c) != current_c_sha):
        raise ValueError('currentC digest must match its exact plan pin')

    compiler = tools.get('bend')
    compiler_sha = provenance['currentCompilerSHA256']
    if (not isinstance(compiler, str) or not _is_sha256(compiler_sha) or
            pins.get(compiler) != compiler_sha):
        raise ValueError('current compiler digest must match the planned Bend tool pin')

    receipt_path = provenance.get('currentEmitReceipt')
    receipt_sha = provenance.get('currentEmitReceiptSHA256')
    if receipt_path is not None or receipt_sha is not None:
        if (not isinstance(receipt_path, str) or not _is_sha256(receipt_sha) or
                pins.get(receipt_path) != receipt_sha):
            raise ValueError('current emit receipt digest must match its exact plan pin')


def _validate_artifact_parent_guard(plan, plan_path):
    if 'artifactParentGuard' not in plan:
        return
    if plan['artifactParentGuard'] != _ARTIFACT_PARENT_GUARD:
        raise ValueError('unsupported artifact parent guard dialect')
    if plan_path is None:
        raise ValueError('artifact parent guard requires the plan path')

    plan_parent = Path(plan_path).resolve(strict=True).parent
    declared_root = plan.get('artifactOutputRoot')
    if not isinstance(declared_root, str):
        raise ValueError('artifact parent guard requires artifactOutputRoot')
    root_path = Path(declared_root)
    if root_path.resolve(strict=True) != plan_parent:
        raise ValueError('artifactOutputRoot must be the captured plan output directory')

    for key in ('generated', 'native'):
        artifact_path = plan.get(key)
        if not isinstance(artifact_path, str):
            raise ValueError('artifact parent guard requires planned ' + key + ' artifact')
        parent = Path(artifact_path).parent
        if parent.is_symlink() or parent.resolve(strict=True) != plan_parent:
            raise ValueError('planned artifact parent escaped captured plan output root')


def validate_bindings(plan, plan_path=None):
    """Validate opt-in bindings without admitting a command-role dialect.

    Callers may use this for metadata-only inspection of a saved plan. The
    ordinary ``validate`` entry point still performs role and command-shape
    admission separately.
    """
    _validate_import_closure(plan)
    _validate_current_compiler_provenance(plan)
    _validate_artifact_parent_guard(plan, plan_path)


def _validate_ts_consumer(plan, labels, commands):
    """Admit the existing consumer-only TypeScript plan role.

    TS plans do not emit a local JS artifact. They run the pinned Node tool on
    the explicitly inventoried entrypoint, through the same transparent
    taskset prefix as the development-plan guard.
    """
    if labels != ['consumer']:
        raise ValueError('TS role requires exactly one consumer command')

    tools = plan.get('tools')
    entrypoint = plan.get('entrypoint')
    if not isinstance(tools, dict):
        raise ValueError('TS role requires declared Node and taskset tools')
    node, taskset = tools.get('node'), tools.get('taskset')
    if not isinstance(node, str) or not node or not isinstance(taskset, str) or not taskset:
        raise ValueError('TS role requires declared Node and taskset tools')

    def canonical_absolute(value):
        if not isinstance(value, str) or not value:
            return False
        path = Path(value)
        return (path.is_absolute() and str(path) == value and
                '..' not in path.parts)

    if not all(canonical_absolute(value) for value in (node, taskset, entrypoint)):
        raise ValueError('TS role requires canonical absolute Node, taskset, and entrypoint paths')

    command = commands[0]
    if type(command.get('capSeconds')) is not int or command['capSeconds'] != 5:
        raise ValueError('TS consumer cap must be 5 seconds')
    argv = command.get('argv')
    if (not isinstance(argv, list) or len(argv) != 5 or
            argv[:2] != [taskset, '-c'] or
            not isinstance(argv[2], str) or not argv[2] or
            any(character < '0' or character > '9' for character in argv[2]) or
            argv[3:] != [node, entrypoint]):
        raise ValueError('TS consumer must bind the declared Node tool and entrypoint')
    return 'ts'


def validate(plan, plan_path=None):
    # Run the exact optional metadata dialect guards before dispatch. This
    # catches stale bindings even when the command-role shape is unsupported;
    # passing them does not make an unsupported role executable.
    validate_bindings(plan, plan_path)
    commands = plan.get('commands', [])
    labels = [c.get('label') for c in commands]
    if not commands or any(not isinstance(x, str) or not x for x in labels):
        raise ValueError('nonempty command labels required')
    if len(set(labels)) != len(labels):
        raise ValueError('duplicate command label')
    if plan.get('role') == 'ts':
        return _validate_ts_consumer(plan, labels, commands)
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
        print(str(path) + ': ' + validate(json.loads(path.read_text()), plan_path=path))


if __name__ == '__main__':
    main()
