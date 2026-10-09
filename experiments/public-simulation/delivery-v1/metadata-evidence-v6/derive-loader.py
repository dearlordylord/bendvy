"""Reconcile actual transitive ELF data with historical loader resolutions."""
import json
import os
from pathlib import Path
import re
HERE = Path(__file__).resolve().parent
namespace = {'__file__': str(HERE / 'verify.py'), '__name__': 'archive_verify'}
exec(compile((HERE / 'verify.py').read_bytes(), str(HERE / 'verify.py'), 'exec'), namespace)

def derive():
    plan, receipt, raws = namespace['verified']()
    prior_path = next(p for p in raws if p.endswith('metadata-evidence-v5/LOADER-TARGETS.json'))
    prior = json.loads(raws[prior_path])
    root = Path(plan['outputRoot'])
    roles = []
    extra_roots = []
    loaded_names = {entry['soname']: entry['path'] for role in prior['actualLoadedBySubject'].values() for entry in role['actualLoaded']}
    # Loader reports its interpreter using an absolute alias rather than bare SONAME.
    for name, path in list(loaded_names.items()):
        if Path(name).name == 'ld-linux-aarch64.so.1':
            loaded_names['ld-linux-aarch64.so.1'] = path
    for command in plan['commands']:
        text = raws[command['stdout']].decode()
        source = command['argv'][-1]
        origin = str(Path(source).parent)
        paths = re.findall(r'\((RPATH|RUNPATH)\).*?\[(.*?)\]', text)
        expanded = []
        for kind, value in paths:
            for path in value.split(':'):
                if not path:
                    expanded.append({'kind': kind, 'raw': path, 'unresolved': 'Empty path searches working directory'})
                    continue
                path = path.replace('${ORIGIN}', origin).replace('$ORIGIN', origin)
                if '$' in path or not Path(path).is_absolute():
                    expanded.append({'kind': kind, 'raw': path, 'unresolved': 'Dynamic token or relative path needs loader-context interpretation'})
                else:
                    path = os.path.normpath(path)
                    expanded.append({'kind': kind, 'path': path}); extra_roots.append(path)
        needed = re.findall(r'\(NEEDED\).*?\[(.*?)\]', text)
        roles.append({'label': command['label'], 'actualELF': source, 'soname': re.findall(r'\(SONAME\).*?\[(.*?)\]', text), 'needed': needed, 'interpreter': re.findall(r'Requesting program interpreter: (.*?)\]', text), 'rawPaths': paths, 'expandedPaths': expanded, 'neededAbsentFromObservedNames': sorted(set(needed) - set(loaded_names))})
    assert len(roles) == 25
    unresolved = [entry for role in roles for entry in role['expandedPaths'] if 'unresolved' in entry]
    return {'status': 'ACTUAL_TRANSITIVE_ELF_METADATA_NOT_RESOLVER_ADMISSION', 'actualPlanSHA256': receipt['planSHA256'], 'priorPlanSHA256': plan['actualPriorPlanSHA256'], 'elfRoles': roles, 'actualLoadedBySubject': prior['actualLoadedBySubject'], 'transitivePathRoots': sorted(set(extra_roots)), 'uninterpretedSearchPaths': unresolved, 'neededNotObserved': sorted({name for role in roles for name in role['neededAbsentFromObservedNames']}), 'candidateSearchDirectories': list(dict.fromkeys(prior['searchCandidate'] + [str(Path(root) / suffix) if suffix else root for root in sorted(set(extra_roots)) for suffix in prior['expectedLegacySuffixes']])), 'expectedLegacySuffixes': prior['expectedLegacySuffixes'], 'closureBoundary': 'Observed selected files and their DT_NEEDED are accounted for; this does not pin names/bytes/absence of alternate loader search candidates, cache targets or actual symlink chains.', 'remainingGaps': ['Final shallow candidate directory membership/types/all candidate bytes/absence and symlink target coverage', 'Legacy HWCAP combination order needs loader-source authority; diagnostics prove flags/platform, not traversal', 'Cache namespace (425 advertised entries) and selected applicability/aliases; configuration include and preload presence must remain guarded'], 'separateLaterStages': ['Compiler header/GCC/linker script/search namespace', 'Generated executable ELF/runtime namespace'], 'qualifiesClosedResolver': False, 'newChildren': 0}

if __name__ == '__main__':
    print(json.dumps(derive(), indent=2))
