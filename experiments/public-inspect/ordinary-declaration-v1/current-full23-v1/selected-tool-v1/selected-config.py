"""Explicit successor selection for existing runners; no discovery or child execution."""
from pathlib import Path
import hashlib
import json
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE_CONFIG = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
BASE = runpy.run_path(str(BASE_CONFIG))
TOOL_PATHS = {**BASE['TOOL_PATHS'], 'bend': str(HERE / 'bend'),
              'bendElf': BASE['TOOL_PATHS']['bend']}
RESOURCE_ROOTS = (*BASE['RESOURCE_ROOTS'], str(HERE / 'prepared/compiler'))
LINK_INPUTS = BASE['LINK_INPUTS']

def environment():
    return BASE['environment']()

def candidate():
    # Preserve inherited reached library/config scope; ldd must inspect ELF, not wrapper.
    result = BASE['candidate']()
    generated = HERE / 'prepared/compiler/cli.mjs'
    spec = json.loads((HERE / 'RECIPE.json').read_text())
    if hashlib.sha256(generated.read_bytes()).hexdigest() != spec['selectedCLISHA256']:
        raise ValueError('selected CLI not prepared or differs')
    inputs = [HERE / n for n in ['bend', 'RECIPE.json', 'prepare.py',
                                 'selected-config.py', 'prepared/PREPARED.json']]
    inputs += [generated, BASE_CONFIG]
    bindings = [BASE['file_binding'](str(p)) for p in inputs]
    result['tools'] = {name: str(Path(path).resolve(strict=True))
                       for name, path in TOOL_PATHS.items()}
    result['discoveryTools']['bend'] = str(Path(TOOL_PATHS['bendElf']).resolve(strict=True))
    result['discoveryTools']['bendElf'] = result['discoveryTools']['bend']
    result['toolAndReachedLinkBindings'] += bindings
    result['inputFiles'] = sorted(set(result['inputFiles']) |
                                  {binding['resolved'] for binding in bindings})
    result['resourceRoots'] = list(RESOURCE_ROOTS)
    result['scriptDiscovery'] = {'scriptNames': ['bend'],
        'underlyingELF': TOOL_PATHS['bendElf'],
        'scope': 'Existing owned-tool-pins skip_ldd for wrapper; inspect bendElf. '
                 'Pin all wrapper/CLI/recipe/resource bytes in existing guards.'}
    result['selection'] = {'scope': 'Explicit project-local successor, not system installation',
        'recipeSHA256': hashlib.sha256((HERE / 'RECIPE.json').read_bytes()).hexdigest(),
        'cliSHA256': spec['selectedCLISHA256'],
        'stockELFSHA256': spec['elfSHA256'],
        'status': 'PREPARED_NOT_SELECTED_IN_SHARED_CONFIGURATION'}
    return result
