#!/usr/bin/env python3
"""Concrete source confinement and global deadline, no loop authorization."""
import datetime, hashlib, pathlib, re, subprocess
PROJECT=pathlib.Path('/workspace/formal-proofs/bendvy')
DEADLINE=datetime.datetime(2026,10,5,7,34,51,tzinfo=datetime.timezone.utc)
PINS={'experiments/s-integrate/measurement-bend-run.py': '25ab577d5234a1c30f46318708455377353ec39d4fb0b6bf1b40ad5ea5da8f84', 'experiments/t05/run.py': '3767d4b66b63f6492aa260213de17b33de9f772fbe2250a91aa579f856c85b19', 'experiments/t01/bend-check': '7c2e4afd996beae6749c650fe508f76d49633267665a96a44938af08ad0ce6a5', 'experiments/s-integrate/measurement-samples-reference.mjs': 'ecfd1b590964fb76fb69a7a28e9dffa05b631592f47a52f11921ffaec25253b6', '.references/sources.json': '5d4d89ca984a2eb21e21715344219bb9caa022b6bebca0c9f8959584cceb8b8f'}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
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

def kill_descendants(pid):
    """Kill only the launched process and observed descendants, including setsid."""
    import os,signal
    graph={}
    for p in pathlib.Path('/proc').glob('[0-9]*/stat'):
        try:
            fields=p.read_text().rsplit(')',1)[1].split();graph[int(p.parent.name)]=(int(fields[1]),fields[19])
        except (OSError,ValueError,IndexError):pass
    selected={pid}
    while True:
        nextset=selected|{child for child,(parent,start) in graph.items() if parent in selected}
        if nextset==selected:break
        selected=nextset
    for child in sorted(selected,reverse=True):
        try:
            fd=os.pidfd_open(child)
            try:
                current=(pathlib.Path('/proc')/str(child)/'stat').read_text().rsplit(')',1)[1].split()[19]
                if child in graph and current==graph[child][1]:signal.pidfd_send_signal(fd,signal.SIGKILL)
            finally:os.close(fd)
        except (ProcessLookupError,OSError):pass
