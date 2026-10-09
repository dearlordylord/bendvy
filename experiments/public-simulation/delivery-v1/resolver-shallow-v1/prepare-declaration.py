"""Freeze existing PinnedTools invocation inputs; do not invoke it or a child."""
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def load(path):
    raw = path.read_bytes()
    namespace = {'__file__': str(path), '__name__': 'source_current_preparation'}
    exec(compile(raw, str(path), 'exec'), namespace)
    return namespace, sha(raw)

def prepare():
    inventory_module, inventory_sha = load(HERE / 'prepare.py')
    inventory = inventory_module['prepare']()
    if inventory['aliasInventoryErrors'] or inventory['directoryAliasCoverageGaps'] or inventory['cacheTargetsMissing']:
        raise ValueError('Unresolved alias/cache boundary; cannot prepare acquisition')
    configpath = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    config, config_sha = load(configpath)
    namespacepath = ROOT / 'experiments/public-simulation/delivery-v1/prepare-metadata.py'
    namespace, namespace_sha = load(namespacepath)
    prior = json.loads((HERE.parent / 'metadata-evidence-v5/LOADER-TARGETS.json').read_bytes())
    # Shallow children are already guarded by the existing helper. Explicit cache
    # literal spellings and every resolved target remain included separately.
    literals = set(inventory['resolver_inputs']) | {entry['path'] for entry in prior['cacheEntries']} | set(config['TOOL_PATHS'].values())
    literals.update(['/usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1', '/lib/ld-linux-aarch64.so.1', '/etc/ld.so.conf.d'])
    # Directory alias roots are shallow only; config includes alone may recurse.
    literal_files = sorted(p for p in literals if not Path(p).is_dir())
    inputs = sorted(set(literal_files) | {str(Path(p).resolve()) for p in literal_files} | {'/etc/ld.so.conf.d'})
    tools = {name: str(Path(path).resolve(strict=True)) for name, path in config['TOOL_PATHS'].items()}
    skip = ['clangWrapper', 'ldd']
    probes = [{'name': name, 'argv': [tools['taskset'], '-c', '5', tools['ldd'], path], 'capSeconds': 5} for name, path in tools.items() if name not in skip]
    helper = ROOT / 'scripts/owned-tool-pins.py'
    files = [helper, ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py', configpath, namespacepath, HERE / 'prepare.py', Path(__file__), HERE / 'test-preparation.py', HERE.parent / 'metadata-evidence-v6/MANIFEST.json', HERE.parent / 'metadata-evidence-v6/TRANSITIVE-ELF.json']
    pins = {str(p.resolve()): sha(p.read_bytes()) for p in files}
    cost = dict(inventory['cost'])
    cost['explicitResolverFileVisits'] = sum(Path(p).is_file() for p in inputs)
    cost['explicitResolverFileBytesIncludingAliases'] = sum(Path(p).stat().st_size for p in inputs if Path(p).is_file())
    cost['resolverLowerBoundBytesPerPassExcludingConfigDirectoryAndResources'] = cost['explicitResolverFileBytesIncludingAliases'] + cost['shallowBytesIncludingAliasRepeats']
    return {'status': 'PREPARED_EXISTING_HELPER_ACQUISITION_NOT_EXECUTED_OR_ADMITTED', 'api': 'scripts/owned-tool-pins.py:PinnedTools', 'resolver_inputs': inputs, 'loader_search_directories': inventory['loader_search_directories'], 'configuration': {'tools': tools, 'resource_roots': list(config['RESOURCE_ROOTS']), 'ldd': tools['ldd'], 'taskset': tools['taskset'], 'cpu': 5, 'env': config['environment'](), 'skip_ldd': skip, 'capture_mode': 'split', 'execute': 'Existing task_runner.execute_result adapter only; retain completed process results before raw publication and unconditional final receipt'}, 'discoveryCommands': probes, 'helperSourcePins': pins, 'namespace': namespace['namespace_state'](inputs + inventory['loader_search_directories']), 'cost': cost, 'guardRecipe': ['Acquire existing /tmp/bendvy-parity-heavy.lock before any hash or probe', 'Verify exact source/tool/config/environment pins before exact-byte helper imports', 'Freeze resolver file bytes/config include membership/absence and every shallow candidate name/type/byte/alias via existing PinnedTools; no directory recursion except explicit ld.so.conf.d and approved resource roots', 'One discovery stage: resource/tool prereqs hashed before all eight ldd probes; preserve both raw streams and returned status', 'Initial PinnedTools.check rehashes resolver/resources; each ordinary later check remains probe-free and catches drift; final boundary repeats actual discovery only if existing stage requires it', 'Before workload, guard relocated source/oracle/output namespace separately; generated Native ELF needs its own later resolver stage'], 'qualification': {'closedResolverQualified': False, 'hashSweepExecuted': False, 'newChildren': 0, 'compilerHeaderLinkerClosure': False, 'generatedNativeRuntimeClosure': False}, 'remaining': ['Independent exact declaration and upstream2.36 suffix authority review before acquisition', 'Actual helper hashing/alias acceptance/raw discovery under reviewed caller needed; no static inventory is an executed pin', 'Hash wall time is unmeasured: existing policy hashes all files, including unrelated archives and alias repeats; no policy waiver', 'Compiler input and generated runtime namespaces require separate stages']}

if __name__ == '__main__':
    print(json.dumps(prepare(), indent=2))
