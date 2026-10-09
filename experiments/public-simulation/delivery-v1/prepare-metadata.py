"""Freeze a narrow loader/ELF metadata recipe; execute no child or search scan."""
import glob
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()

def configurations(root):
    pending=[Path(root)];seen=set();files=[];patterns={}
    while pending:
        path=pending.pop(0)
        if str(path) in seen:continue
        seen.add(str(path));files.append(str(path))
        for line in path.read_text().splitlines():
            line=line.split('#',1)[0].strip()
            if not line:continue
            words=line.split()
            if words[0]=='include':
                for pattern in words[1:]:
                    if not Path(pattern).is_absolute():pattern=str(path.parent/pattern)
                    matched=sorted(glob.glob(pattern));patterns[pattern]=matched
                    pending.extend(Path(p)for p in matched)
    return files,patterns

def prepare():
    spec=importlib.util.spec_from_file_location('config',HERE/'installed-config.py');config=importlib.util.module_from_spec(spec);spec.loader.exec_module(config)
    out=Path('/tmp/bendvy63-loader-metadata-v1')
    if out.exists():raise ValueError('metadata output root must start absent')
    tools={'readelf':'/usr/bin/readelf','taskset':config.TOOL_PATHS['taskset'],
      'python':'/usr/bin/python3.11','loader':'/lib/ld-linux-aarch64.so.1'}
    subjects={k:config.TOOL_PATHS[k]for k in ['bend','node','clang','shell','bash','env','taskset','linker']}
    subjects['loader']=tools['loader']
    configs,includes=configurations('/etc/ld.so.conf')
    absence={p:Path(p).exists() for p in ['/etc/ld.so.cache','/etc/ld.so.preload']}
    files=set(configs)|{p for p,present in absence.items()if present}|set(tools.values())|set(subjects.values())
    files|=set(config.TOOL_PATHS.values())
    files|={str(ROOT/'scripts/task_runner.py'),str(ROOT/'scripts/evidence_boundary.py'),str(ROOT/'scripts/owned-tool-pins.py'),str(HERE/'installed-config.py'),str(HERE/'prepare-metadata.py'),str(HERE/'resolver-candidate-input.json')}
    pins={str(Path(p).resolve(strict=True)):sha(Path(p).resolve(strict=True))for p in sorted(files)}
    aliases={p:{'resolved':str(Path(p).resolve(strict=True)),'links':[{'path':str(x),'target':str(x.readlink())}for x in list(reversed(Path(p).parents))+[Path(p)]if x.is_symlink()]}for p in sorted(files)}
    commands=[{'label':name,'argv':[tools['taskset'],'-c','5',tools['readelf'],'-l','-d',str(Path(path).resolve(strict=True))],'capSeconds':5,'stdout':str(out/(name+'.stdout')),'stderr':str(out/(name+'.stderr'))}for name,path in subjects.items()]
    commands.append({'label':'loader-help','argv':[tools['taskset'],'-c','5',str(Path(tools['loader']).resolve(strict=True)),'--help'],'capSeconds':5,'stdout':str(out/'loader-help.stdout'),'stderr':str(out/'loader-help.stderr')})
    return {'scope':'Read-only current ELF/loader metadata only; no target workload/discovery/closed-resolver admission',
      'status':'PREPARED_NOT_EXECUTED','outputRoot':str(out),'commands':commands,'pins':pins,'aliases':aliases,
      'configIncludes':includes,'configFiles':configs,'configPresence':absence,'environment':config.environment(),
      'lock':'/tmp/bendvy-parity-heavy.lock','executor':'scripts/task_runner.py:execute_result',
      'guards':'Exact pins, aliases, include membership, config presence and raw outputs pre/acquired/post/final; receipt unconditionally on failure',
      'remainingStage':'Use actual loader help/ELF data to review shallow search roots and legacy suffixes; header/linker closure separate, generated ELF runtime later'}
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
