"""Derive exact observed loader targets; candidate search roots remain unadmitted."""
import json
from pathlib import Path
import re
HERE = Path(__file__).resolve().parent
namespace = {'__file__': str(HERE / 'verify.py'), '__name__': 'archive_verify'}
exec(compile((HERE / 'verify.py').read_bytes(), str(HERE / 'verify.py'), 'exec'), namespace)

def derive():
    plan, receipt, raws = namespace['verified']()
    root = Path(plan['outputRoot'])
    text = lambda label: raws[str(root / (label + '.stdout'))].decode()
    prior = json.loads(raws[next(p for p in raws if p.endswith('metadata-evidence-v4/LOADER-SEARCH.json'))])
    diagnostics = text('loader-auxv')
    values = dict(re.findall(r'^([a-z_][a-z_0-9.]*)=(.*)$', diagnostics, re.M))
    assert values['dl_platform'] == '"aarch64"'
    assert values['dl_hwcap_important'] == '0x100'
    assert values['dl_hwcaps_subdirs'] == '""' and values['dl_hwcaps_subdirs_active'] == '0x0'
    system = re.findall(r'^path.system_dirs\[0x[0-9a-f]+\]="([^"]+)"$', diagnostics, re.M)
    assert [p.rstrip('/') for p in system] == prior['defaultRoots']
    cache = []
    for name, flags, path in re.findall(r'^\s+(\S+) \(([^)]+)\) => (/.+)$', text('ldconfig-cache'), re.M):
        cache.append({'soname': name, 'flags': flags, 'path': path})
    assert cache
    roles = {}
    for command in plan['commands']:
        if not command['label'].endswith('-loader-list'):
            continue
        loaded = []
        for name, path in re.findall(r'^\s*(\S+) => (/[^(]+?) \(0x[0-9a-f]+\)$', text(command['label']), re.M):
            loaded.append({'soname': name, 'path': path})
        assert loaded and 'not found' not in text(command['label'])
        roles[command['label']] = {'subject': command['argv'][-1], 'actualLoaded': loaded}
    targets = sorted({entry['path'] for role in roles.values() for entry in role['actualLoaded']})
    return {
        'status': 'ACTUAL_TARGETS_AND_CACHE_CAPTURED_NOT_RESOLVER_ADMISSION',
        'actualPlanSHA256': receipt['planSHA256'],
        'priorPlanSHA256': plan['actualPriorPlanSHA256'],
        'actualLoader': {k: values[k] for k in ['dl_platform', 'dl_hwcap', 'dl_hwcap_important', 'dl_hwcap2', 'dl_hwcaps_subdirs', 'dl_hwcaps_subdirs_active', 'version.version']},
        'actualDefaultRoots': system,
        'actualLoadedBySubject': roles,
        'actualLoadedTargetPaths': targets,
        'cacheEntries': cache,
        'searchCandidate': prior['loader_search_directories'],
        'expectedLegacySuffixes': prior['expectedLegacySuffixes'],
        'legacyBoundary': 'Actual platform aarch64 and important HWCAP atomics bit 0x100 present; diagnostics do not independently prove legacy combination traversal/order. Expected eight suffixes remain a source-backed candidate, not observed full search.',
        'cacheTargetBoundary': 'Cache output captures every advertised soname/path, not target file bytes/alias chains or loader-selected cache applicability.',
        'nextExactELFSubjects': targets,
        'remainingGaps': ['DT_NEEDED/RPATH/RUNPATH and interpreter of each actual loaded target; transitive search roots may enlarge candidate', 'Shallow all names/types/candidate bytes/absence for final search directories plus actual alias chains', 'Cache target namespace and legacy suffix ordering authority; preload/config include absence retained from v4'],
        'separateLaterStages': prior['separateLaterStages'],
        'qualifiesClosedResolver': False,
        'newChildren': 0,
    }

if __name__ == '__main__':
    print(json.dumps(derive(), indent=2))
