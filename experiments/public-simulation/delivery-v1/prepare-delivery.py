"""Freeze complete relocated ordinary verification cohort; launch no children."""
import hashlib
import json
from pathlib import Path
import sys
import types
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def load(name, path):
    raw = path.read_bytes(); module = types.ModuleType(name); module.__file__ = str(path); sys.modules[name] = module
    exec(compile(raw, str(path), 'exec'), module.__dict__); return module

def prepare():
    base = ROOT / 'experiments/public-simulation/delivery-v1'
    relocation = load('prepare', base / 'prepare.py')
    stage = Path('/tmp/bendvy63-ordinary-delivery-stage-v1')
    output = Path('/tmp/bendvy63-ordinary-delivery-v4')
    if stage.is_symlink() or output.exists() or output.is_symlink(): raise ValueError('Output starts absent; stage alias refused')
    manifest, sources = relocation.expected_stage()
    if len(sources) != 106: raise ValueError('Complete106 source closure required')
    if not stage.exists(): relocation.prepare(stage)
    config = load('simulation_delivery_config', base / 'installed-config.py')
    comparator = load('simulation_delivery_compare', base / 'compare.py')
    joins = comparator.stage_joins(stage)
    if len(joins) != 32: raise ValueError('Complete constructor inventory required')
    helpers = {'runner': ROOT / 'scripts/task_runner.py', 'tools': ROOT / 'scripts/owned-tool-pins.py', 'logs': ROOT / 'scripts/receipt-logs.py', 'boundary': ROOT / 'scripts/evidence_boundary.py', 'metadata': base / 'prepare-metadata.py', 'prepare': base / 'prepare.py', 'source_evidence': ROOT / 'experiments/public-simulation/bend-v1/source_evidence.py'}
    subject = ROOT / 'experiments/public-simulation/bend-v1'
    reference = ROOT / 'experiments/public-simulation/reference-v1'
    controls = ROOT / 'experiments/public-simulation/controls-v1/finite-controls-v1'
    files = set(helpers.values()) | {HERE / 'run-delivery.py', Path(__file__), HERE / 'test-delivery-admission.py', HERE / 'test-delivery-transport.py', HERE / 'check-control-reuse.py', HERE / 'CONTROL-REUSE.json', base / 'installed-config.py', base / 'compare.py', subject / 'parse-report.py', subject / 'compare-ts.py', subject / 'independent-expected.json', subject / 'development-evidence-index.json', subject / 'development-evidence.tar.gz', subject / 'candidate-source-correction.json', reference / 'reference.mjs', reference / 'inputs.json', reference / 'expected.stdout', reference / 'expected.json', reference / 'evidence/corrected-oracle-v1/receipt.json', ROOT / '.references/sources.json', ROOT / '.references/bevy-ts/package.json', ROOT / '.references/bevy-ts/packages/core/package.json'}
    files.update(controls / name for name in ['selection.json', 'index.json', 'evidence.tar.gz', 'verify.py', 'README.md'])
    files.update(ROOT / name for name in manifest['sources'])
    files.update(path for path in (ROOT / '.references/bevy-ts/packages/core/src').rglob('*') if path.is_file())
    files.update(path for path in stage.rglob('*') if path.is_file())
    python = str(Path(sys.executable).resolve(strict=True)); files.add(Path(python))
    # Known exact installed tools from admitted v6, independent of optional session.
    v6 = load('historical_v6', HERE / 'metadata-evidence-v6/verify.py')
    old, _, _ = v6.verified()
    toolpaths = {name: str(Path(path).resolve(strict=True)) for name, path in config.TOOL_PATHS.items()}
    for path in toolpaths.values():
        if sha(Path(path).read_bytes()) != old['pins'][path]: raise ValueError('Historical tool changed')
        files.add(Path(path))
    entry = str(stage / manifest['entry'])
    def command(label, argv, cap, emits=None):
        row = {'label': label, 'argv': [toolpaths['taskset'], '-c', '5', *argv], 'capSeconds': cap}
        if emits: row['emits'] = emits
        return row
    commands = [command('source', [toolpaths['bend'], entry, '--check-only'], 5), command('TS', [toolpaths['node'], str(reference / 'reference.mjs')], 5), command('JS-emit', [toolpaths['bend'], entry, '-o', str(output / 'simulation.js')], 30, 'simulation.js'), command('JS-run', [toolpaths['node'], str(output / 'simulation.js')], 5), command('Native-emit', [toolpaths['bend'], entry, '-o', str(output / 'simulation.c')], 30, 'simulation.c'), command('Native-clang', [config.TOOL_PATHS['clangWrapper'], '-O3', str(output / 'simulation.c'), '-pthread', '-lm', '-o', str(output / 'simulation.native')], 120, 'simulation.native'), command('Native-run', [str(output / 'simulation.native'), '--threads', '1', '--gpu', 'off'], 5)]
    names = ['bend.json', 'bend.config.json', 'bunfig.toml', 'package.json', '.clang', 'clang.cfg']
    directories = {ROOT, stage, stage / 'experiments/public-simulation/bend-v1', HERE, Path(config.CLANG_ROOT) / 'usr/lib/llvm-19/bin', Path('/tmp/bendvy-clang19-diagnostic')}
    configs = {str(root / name): sha((root / name).read_bytes()) if (root / name).is_file() else None for root in directories for name in names}
    files.update(Path(name) for name, value in configs.items() if value is not None)
    literals = list(config.TOOL_PATHS.values()) + list(config.LINK_INPUTS)
    metadata = load('delivery_namespace', base / 'prepare-metadata.py')
    namespace = metadata.namespace_state(literals)
    files.update(Path(name) for name in namespace['configFiles'])
    if namespace['configPresence']['/etc/ld.so.cache']: files.add(Path('/etc/ld.so.cache'))
    controls_join = load('current_control_reuse', HERE / 'check-control-reuse.py').verify()
    if controls_join != json.loads((HERE / 'CONTROL-REUSE.json').read_bytes()): raise ValueError('Current controls join changed')
    return {'scope': 'Complete relocated106-source fixed simulation JS/Native and observed pinnedTS; ordinary snapshot/verify, no closed resolver/timing/fullparity claim', 'python': python, 'outputRoot': str(output), 'stageRoot': str(stage), 'stagePins': {str(p.relative_to(stage)): sha(p.read_bytes()) for p in stage.rglob('*') if p.is_file()}, 'pins': {str(p.resolve()): sha(p.read_bytes()) for p in files}, 'smallInputPaths': [str(p.resolve()) for p in files if str(p.resolve()) not in set(toolpaths.values())], 'helpers': {name: str(path) for name, path in helpers.items()}, 'comparator': str(base / 'compare.py'), 'parser': str(subject / 'parse-report.py'), 'tsJoiner': str(subject / 'compare-ts.py'), 'constructorJoins': joins, 'oracleSHA256': sha((subject / 'independent-expected.json').read_bytes()), 'tsExpected': str(reference / 'expected.stdout'), 'commands': commands, 'toolConfiguration': {'tools': toolpaths, 'resource_roots': list(config.RESOURCE_ROOTS), 'ldd': toolpaths['ldd'], 'taskset': toolpaths['taskset'], 'cpu': 5, 'env': config.environment(), 'skip_ldd': ['clangWrapper', 'ldd'], 'capture_mode': 'split'}, 'namespaceLiterals': list(literals), 'namespace': namespace, 'configPresence': configs, 'lock': '/tmp/bendvy-parity-heavy.lock', 'maximumProbeCommands': 140, 'controls': {'selection': str(controls / 'selection.json'), 'sourceCurrentJoin': controls_join, 'scope': 'Retained selected finite controls unchanged API bytes; recorded geometry EOF correction only; no fresh relocated control execution claim'}, 'timing': 'Deferred under CPU contention; #28 unchanged regression and equivalent-work timing/scaling remain separate', 'closedResolverQualified': False}

if __name__ == '__main__': print(json.dumps(prepare(), indent=2))
