"""Metadata-only shallow closure/cost preparation; no hash sweep or child."""
import hashlib
import json
from pathlib import Path
import stat
HERE = Path(__file__).resolve().parent
BASE = HERE.parent
ROOT = Path('/workspace/formal-proofs/bendvy')

def load_source(path):
    namespace = {'__file__': str(path), '__name__': 'preparation_dependency'}
    exec(compile(path.read_bytes(), str(path), 'exec'), namespace)
    return namespace

def shallow_rows(directories):
    rows = {}; files = {}
    for name in directories:
        root = Path(name)
        if not root.exists() and not root.is_symlink():
            rows[name] = {'kind': 'absent', 'resolved': str(root.resolve()), 'children': []}
            continue
        if not root.is_dir():
            raise ValueError('Search path must be a directory or absent: ' + name)
        children = []
        for child in sorted(root.iterdir()):
            info = child.lstat(); target = child.resolve(strict=True)
            entry = {'name': child.name, 'literal': str(child), 'symlink': str(child.readlink()) if child.is_symlink() else None, 'resolved': str(target)}
            if target.is_file():
                size = target.stat().st_size
                entry.update(kind='file', bytes=size); files[str(target)] = size
            elif target.is_dir():
                entry.update(kind='directory')
            else:
                raise ValueError('Existing helper refuses unsupported shallow member: ' + str(child))
            children.append(entry)
        rows[name] = {'kind': 'directory', 'resolved': str(root.resolve()), 'identity': [root.stat().st_dev, root.stat().st_ino], 'children': children}
    return rows, files

def prepare():
    transitive = load_source(BASE / 'metadata-evidence-v6/derive-loader.py')['derive']()
    prior = json.loads((BASE / 'metadata-evidence-v5/LOADER-TARGETS.json').read_bytes())
    helper = ROOT / 'experiments/public-simulation/delivery-v1/prepare-metadata.py'
    aliases = load_source(helper)['aliases']
    directories = list(transitive['candidateSearchDirectories'])
    # Root aliases require explicitly searched resolved directory identities.
    directories = list(dict.fromkeys(directories + [str(Path(p).resolve()) for p in directories]))
    rows, shallow_files = shallow_rows(directories)
    cache_paths = sorted({entry['path'] for entry in prior['cacheEntries']})
    literal_files = sorted(set(cache_paths) | set(prior['actualLoadedTargetPaths']) | {str(child['literal']) for root in rows.values() for child in root['children'] if child['kind'] == 'file'})
    alias_rows = {}; alias_errors = []
    for path in literal_files + directories:
        try: alias_rows[path] = aliases(path)
        except ValueError as error: alias_errors.append({'literal': path, 'error': str(error)})
    explicit_files = sorted({row['resolved'] for row in alias_rows.values() if Path(row['resolved']).is_file()})
    missing_cache = [p for p in cache_paths if not Path(p).exists()]
    configuration = load_source(helper)
    config_files, includes = configuration['configurations']('/etc/ld.so.conf')
    namespace = {'configFiles': config_files, 'configIncludes': includes, 'configPresence': {p: Path(p).exists() for p in ['/etc/ld.so.cache', '/etc/ld.so.preload']}, 'aliases': alias_rows}
    config_inputs = namespace['configFiles'] + ['/etc/ld.so.cache', '/etc/ld.so.preload']
    inputs = sorted(set(explicit_files + config_inputs))
    cost_files = dict(shallow_files)
    for file in explicit_files:
        cost_files[file] = Path(file).stat().st_size
    uncovered_directory_alias_targets = []
    covered_dirs = {str(Path(p).resolve()) for p in directories}
    for name, row in alias_rows.items():
        for link in row['links']:
            target = Path(link['target'])
            if not target.is_absolute(): target = Path(link['path']).parent / target
            resolved = target.resolve()
            if resolved.is_dir() and str(resolved) not in covered_dirs:
                uncovered_directory_alias_targets.append({'literal': name, 'link': link, 'target': str(resolved)})
    return {'status': 'SHALLOW_INPUT_SPECIFICATION_NOT_RESOLVER_ADMISSION', 'loader_search_directories': directories, 'resolver_inputs': inputs, 'aliases': alias_rows, 'configNamespace': namespace, 'shallowMetadata': rows, 'cacheTargetsMissing': missing_cache, 'aliasInventoryErrors': alias_errors, 'directoryAliasCoverageGaps': uncovered_directory_alias_targets, 'cost': {'uniqueRegularFiles': len(cost_files), 'uniqueRegularBytes': sum(cost_files.values()), 'shallowRegularVisits': sum(child['kind'] == 'file' for root in rows.values() for child in root['children']), 'shallowBytesIncludingAliasRepeats': sum(child.get('bytes', 0) for root in rows.values() for child in root['children']), 'largestFiles': sorted(cost_files.items(), key=lambda row: (-row[1], row[0]))[:20], 'fileBytesReadForCost': 0}, 'existingHelper': {'path': str(ROOT / 'scripts/owned-tool-pins.py'), 'sha256': hashlib.sha256((ROOT / 'scripts/owned-tool-pins.py').read_bytes()).hexdigest(), 'api': 'PinnedTools(resolver_inputs=..., loader_search_directories=..., existingconfiguration)', 'invoked': False}, 'closedResolverQualified': False, 'remaining': ['Review primary glibc2.36 legacy suffix order against actual diagnostics', 'Review cache target applicability and namespace completeness, including missing targets', 'Actual existing-helper shallow hashes and guards not yet acquired; cost is stat metadata only', 'Compiler header/linker and generated ELF stages remain separate'], 'newChildren': 0}

if __name__ == '__main__':
    print(json.dumps(prepare(), indent=2))
