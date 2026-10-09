"""Derive loader search specification only from full verified actual metadata."""
import importlib.util
import json
import os
from pathlib import Path
import re
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('actual_metadata',HERE/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
def derive():
    plan,receipt,raws=v.verified();root=Path(plan['outputRoot'])
    helptext=raws[str(root/'loader-help.stdout')].decode()
    default=re.findall(r'^  (/.+?) \(system search path\)$',helptext,re.M)
    library=re.findall(r'^  (/.+?) \(LD_LIBRARY_PATH\)$',helptext,re.M)
    assert library==plan['environment']['LD_LIBRARY_PATH'].split(':')
    assert default and 'No subdirectories of glibc-hwcaps directories are searched.'in helptext
    assert all('  '+name+' 'in helptext for name in ['aarch64','tls','atomics'])
    suffixes=['tls/aarch64/atomics','tls/aarch64','tls/atomics','tls','aarch64/atomics','aarch64','atomics','']
    roles={};runpaths=[]
    for command in plan['commands']:
        if command['label']=='loader-help':continue
        text=raws[command['stdout']].decode();origin=str(Path(command['argv'][-1]).parent)
        paths=re.findall(r'\((RPATH|RUNPATH)\).*?\[(.*?)\]',text)
        expanded=[]
        for kind,value in paths:
            for path in value.split(':'):
                assert path and '$LIB'not in path and '$PLATFORM'not in path
                path=path.replace('${ORIGIN}',origin).replace('$ORIGIN',origin)
                assert '$'not in path and Path(path).is_absolute()
                expanded.append({'kind':kind,'path':os.path.normpath(path)})
        roles[command['label']]={'elf':command['argv'][-1],
          'needed':re.findall(r'\(NEEDED\).*?\[(.*?)\]',text),
          'interpreter':re.findall(r'Requesting program interpreter: (.*?)\]',text),
          'rawPaths':paths,'expandedPaths':expanded}
        runpaths.extend(x['path']for x in expanded)
    roots=list(dict.fromkeys(library+runpaths+default))
    searches=[str(Path(root)/suffix) if suffix else root for root in roots for suffix in suffixes]
    configdirs=[]
    for config in plan['namespace']['configFiles']:
        for line in raws[config].decode().splitlines():
            line=line.split('#',1)[0].strip()
            if line and not line.startswith('include '):
                assert Path(line).is_absolute();configdirs.append(line)
    return {'status':'SOURCE_CURRENT_SEARCH_SPECIFICATION_NOT_CLOSED_ADMISSION',
      'actualPlanSHA256':receipt['planSHA256'],'elfRoles':roles,
      'environmentLibraryRoots':library,'defaultRoots':default,'objectRunpathRoots':list(dict.fromkeys(runpaths)),
      'expectedLegacySuffixes':suffixes,'suffixEvidence':'Actualhelp enables aarch64/tls/atomics; retained prior source-backed combination order, not separately observed directory traversal',
      'builtinGlibcHwcaps':[],'loader_search_directories':list(dict.fromkeys(searches)),
      'cacheConfiguredDirectories':list(dict.fromkeys(configdirs)),
      'configIncludes':plan['namespace']['configIncludes'],'configPresence':plan['namespace']['configPresence'],
      'recursiveResolverInputs':sorted(set(plan['namespace']['configFiles'])|{'/etc/ld.so.conf','/etc/ld.so.conf.d','/etc/ld.so.cache','/etc/ld.so.preload'}|{value['elf']for value in roles.values()}),
      'exactExistingAliases':plan['namespace']['aliases'],
      'closednessGaps':['Current cache target paths/aliases and transitive loaded-library RPATH/RUNPATH remain unobserved',
        'Shallow all-name/all-candidate-byte inventories, absent search paths and complete alias coverage still required',
        'Actual auxiliary-vector/legacy suffix use and no additional dynamic library search source still require binding'],
      'separateLaterStages':['Native header/GCC/linker script/search compiler inputs','Generated executable ELF/runtime closure'],
      'newChildren':0,'qualifiesClosedResolver':False}
if __name__=='__main__':print(json.dumps(derive(),indent=2))
