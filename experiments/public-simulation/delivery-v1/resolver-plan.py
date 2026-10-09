"""Deterministic resolver preparation only; no namespace scan or discovery."""
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def declaration(candidate,tools,links,environment,resources):
    if candidate['status']!='UNADMITTED_CANDIDATE_NOT_CLOSED' or candidate['fullByteInventoryExecuted'] is not False:
        raise ValueError('Unadmitted metadata cannot assert resolver qualification')
    directories=list(candidate['loaderSearchDirectories'])
    files=list(candidate['resolverInputs'])
    if len(directories)!=len(set(directories)) or len(files)!=len(set(files)):
        raise ValueError('Duplicate namespace declarations')
    if '/lib' in files or '/usr/lib' in files:
        raise ValueError('Broad recursive loader roots are not admitted')
    if not all(Path(p).is_absolute() for p in directories+files):
        raise ValueError('Absolute resolver paths required')
    # Preserve literal aliases and reached inputs; current preserved Bend replaces
    # the upgraded historical alias as a tool, without qualifying its namespace.
    files=sorted(set(files)|set(tools.values())|set(links))
    payload={'status':'PREPARED_UNADMITTED_RESOLVER_DECLARATION',
      'helper':'scripts/owned-tool-pins.py:PinnedTools',
      'resolver_inputs':files,'loader_search_directories':directories,
      'resource_roots':list(resources),'tools':dict(tools),
      'environment':dict(environment),'fullByteInventoryExecuted':False,
      'qualifiesClosedResolver':False,'qualifiesCompilerInputs':False,
      'metadataLimitations':list(candidate['remaining']),
      'stillRequired':['Current loader alias/file/search membership bytes and config/cache/preload absence guards',
        'Consumed headers/header candidates, GCC selection and linker default/script/search closure',
        'Generated Native ELF/runtime closure and full output/oracle delivery gates']}
    return payload

def prepare():
    spec=importlib.util.spec_from_file_location('simulation_config',HERE/'installed-config.py')
    config=importlib.util.module_from_spec(spec);spec.loader.exec_module(config)
    raw=(HERE/'resolver-candidate-input.json').read_bytes()
    result=declaration(json.loads(raw),config.TOOL_PATHS,config.LINK_INPUTS,
      config.environment(),config.RESOURCE_ROOTS)
    result['metadataSHA256']=hashlib.sha256(raw).hexdigest()
    result['configurationSHA256']=hashlib.sha256((HERE/'installed-config.py').read_bytes()).hexdigest()
    result['environmentSHA256']=hashlib.sha256(json.dumps(result['environment'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
    return result
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
