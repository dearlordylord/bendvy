#!/usr/bin/env python3
"""Concrete source confinement and global deadline, no loop authorization."""
import datetime, hashlib, pathlib, re, subprocess
PROJECT=pathlib.Path('/workspace/formal-proofs/bendvy')
DEADLINE=datetime.datetime(2026,10,5,7,34,51,tzinfo=datetime.timezone.utc)
PINS={'experiments/s-integrate/measurement-bend-run.py': '25ab577d5234a1c30f46318708455377353ec39d4fb0b6bf1b40ad5ea5da8f84', 'experiments/t05/run.py': '3767d4b66b63f6492aa260213de17b33de9f772fbe2250a91aa579f856c85b19', 'experiments/t01/bend-check': '7c2e4afd996beae6749c650fe508f76d49633267665a96a44938af08ad0ce6a5', 'experiments/s-integrate/measurement-samples-reference.mjs': 'ecfd1b590964fb76fb69a7a28e9dffa05b631592f47a52f11921ffaec25253b6', '.references/sources.json': '5d4d89ca984a2eb21e21715344219bb9caa022b6bebca0c9f8959584cceb8b8f'}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def tool_environment(tools):
    directories=[]
    for name in ('node','clang','bend','python'):
        parent=str(pathlib.Path(tools[name]).parent)
        if parent not in directories:directories.append(parent)
    for parent in ('/usr/bin','/bin'):
        if parent not in directories:directories.append(parent)
    return {'HOME':'/home/node','PATH':':'.join(directories),'LANG':'C.UTF-8','LC_ALL':'C.UTF-8'}

def clang_inputs(wrapper):
    wrapper=pathlib.Path(wrapper).resolve();root=pathlib.Path('/home/node/.local/opt/dnd-clang14/usr')
    binary=root/'lib/llvm-14/bin/clang'
    if 'exec "$CLANG_ROOT/lib/llvm-14/bin/clang" "$@"' not in wrapper.read_text():raise ValueError('unreviewed clang wrapper')
    files={}
    for p in root.rglob('*'):
        if p.is_file():files[str(p)]=sha(p);files[str(p.resolve())]=sha(p.resolve())
    environment=tool_environment({'node':'/usr/bin/node','clang':str(wrapper),'bend':'/home/node/.bend/bin/bend','python':'/usr/local/bin/python3'})
    environment['LD_LIBRARY_PATH']=str(root/'lib/aarch64-linux-gnu')+':'+str(root/'lib/llvm-14/lib')
    deadline(5);dynamic=subprocess.check_output(['/usr/bin/ldd',str(binary)],env=environment,text=True,timeout=5)
    if 'not found' in dynamic:raise ValueError('clang shared dependency unresolved')
    for name in re.findall(r'(?:=>\s+)?(/[^\s()]+)',dynamic):
        p=pathlib.Path(name);files[str(p)]=sha(p);files[str(p.resolve())]=sha(p.resolve())
    deadline(5);linker=pathlib.Path(subprocess.check_output([str(wrapper),'-print-prog-name=ld'],env=tool_environment({'node':'/usr/bin/node','clang':str(wrapper),'bend':'/home/node/.bend/bin/bend','python':'/usr/local/bin/python3'}),text=True,timeout=5).strip()).resolve()
    files[str(linker)]=sha(linker)
    deadline(5);linker_dynamic=subprocess.check_output(['/usr/bin/ldd',str(linker)],env=environment,text=True,timeout=5)
    if 'not found' in linker_dynamic:raise ValueError('linker shared dependency unresolved')
    for name in re.findall(r'(?:=>\s+)?(/[^\s()]+)',linker_dynamic):
        p=pathlib.Path(name);files[str(p)]=sha(p);files[str(p.resolve())]=sha(p.resolve())
    return {'wrapper':str(wrapper),'binary':str(binary.resolve()),'binarySHA256':sha(binary.resolve()),'root':str(root),'members':sorted(str(p) for p in root.rglob('*') if p.is_file()),'files':files,'linker':str(linker)}
def deadline(limit=0, now=None):
    now=now or datetime.datetime.now(datetime.timezone.utc)
    if (DEADLINE-now).total_seconds() <= limit: raise ValueError('global deadline cannot fit child')
def protected():
    for name,digest in PINS.items():
        p=PROJECT/name
        if sha(p)!=digest: raise ValueError('protected source changed: '+name)
        tracked=subprocess.check_output(['git','-C',str(PROJECT),'show','HEAD:'+name])
        if hashlib.sha256(tracked).hexdigest()!=digest: raise ValueError('protected HEAD differs: '+name)
    reference=PROJECT/'.references/bevy-ts'
    if subprocess.check_output(['git','-C',str(reference),'rev-parse','HEAD'],text=True).strip()!='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334': raise ValueError('TS HEAD changed')
    files={}
    for name in subprocess.check_output(['git','-C',str(reference),'ls-files','packages/core/src'],text=True).splitlines():
        p=reference/name
        if p.suffix!='.ts': continue
        blob=subprocess.check_output(['git','-C',str(reference),'show','HEAD:'+name])
        if p.read_bytes()!=blob: raise ValueError('TS import closure changed: '+name)
        files[str(p)]=sha(p)
    return files

def bend_closure(entry, roots):
    roots=[p.resolve() for p in roots]; found={}
    def visit(p):
        p=p.resolve()
        if not any(p.is_relative_to(r) for r in roots): raise ValueError('Bend import escapes declared roots: '+str(p))
        if str(p) in found: return
        found[str(p)]=sha(p)
        for imp in re.findall(r'^import (\S+)',p.read_text(),re.M):
            if imp=='Base': continue
            if not imp.endswith('.bend'): raise ValueError('unsupported import '+imp)
            visit(p.parent/imp)
    visit(entry);return found

def child_pids(pid):
    result=set();tasks=pathlib.Path('/proc')/str(pid)/'task'
    if tasks.exists():
        for task in tasks.iterdir():
            try:result.update(int(x) for x in (task/'children').read_text().split())
            except FileNotFoundError:pass
    return result

def enable_subreaper():
    import ctypes
    if ctypes.CDLL(None,use_errno=True).prctl(36,1,0,0,0)!=0:raise OSError('cannot establish owned child subreaper')

def kill_descendants(pid):
    """Stop each parent before enumerating children; pin process identities."""
    import os,signal,time
    pending=[pid];owned=[];seen=set();end=time.monotonic()+1
    while pending and time.monotonic()<end:
        current=pending.pop()
        if current in seen:continue
        seen.add(current)
        try:
            descriptor=os.pidfd_open(current);signal.pidfd_send_signal(descriptor,signal.SIGSTOP)
        except ProcessLookupError:continue
        owned.append(descriptor)
        # Confirm the parent stopped before reading its child set.
        while time.monotonic()<end:
            try:state=(pathlib.Path('/proc')/str(current)/'stat').read_text().rsplit(')',1)[1].split()[0]
            except FileNotFoundError:break
            if state in ('T','t','Z','X'):break
            time.sleep(.001)
        pending.extend(child_pids(current))
    for descriptor in reversed(owned):
        try:signal.pidfd_send_signal(descriptor,signal.SIGKILL)
        except ProcessLookupError:pass
        finally:os.close(descriptor)

def cleanup_owned(pid,prior=()):
    """Subreaper-owned orphans are included; unrelated prior children spared."""
    import os,time
    if pid in child_pids(os.getpid())-set(prior):kill_descendants(pid)
    end=time.monotonic()+1
    while time.monotonic()<end:
        owned=child_pids(os.getpid())-set(prior)
        if not owned:return
        for child in owned:kill_descendants(child)
        for child in owned:
            try:os.waitpid(child,os.WNOHANG)
            except ChildProcessError:pass
        time.sleep(.001)
    if child_pids(os.getpid())-set(prior):raise TimeoutError('owned descendants did not terminate within finite cleanup')
