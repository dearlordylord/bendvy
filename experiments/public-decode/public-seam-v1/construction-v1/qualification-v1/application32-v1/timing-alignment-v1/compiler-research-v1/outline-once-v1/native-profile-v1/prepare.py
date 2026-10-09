"""Metadata-only preparation; no nm, ptrace or target child."""
from pathlib import Path
import hashlib
import json
import struct

HERE=Path(__file__).resolve().parent
ACTUAL=Path('/tmp/bendvy-inspect54-outline-native-o001')
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def needed(path):
    raw=Path(path).read_bytes()
    offset=struct.unpack_from('<Q',raw,40)[0]
    width,count=struct.unpack_from('<HH',raw,58)
    sections=[struct.unpack_from('<IIQQQQIIQQ',raw,offset+i*width)for i in range(count)]
    result=[]
    for section in sections:
        if section[1]==6:
            strings=sections[section[6]]
            names=raw[strings[4]:strings[4]+strings[5]]
            for position in range(section[4],section[4]+section[5],16):
                kind,value=struct.unpack_from('<qQ',raw,position)
                if kind==1:result.append(names[value:names.find(b'\0',value)].decode('ascii'))
    return result

def main():
    old=json.loads((ACTUAL/'plan.json').read_text())
    receipt=json.loads((ACTUAL/'receipt.json').read_text())
    assert receipt['commands'][0]['exit']==0 and receipt['status']=='INCOMPLETE'
    assert receipt['commands'][1]['failure']=='child deadline'
    assert sha(old['native'])==receipt['buildArtifactSHA256']=='3a3a7028a3c0a09fd6f543a3460f5b8f785a3083f20516bf8bdc79d8de966156'
    pins=dict(old['pins']);assert {name:sha(name)for name in pins}==pins
    for path in ACTUAL.iterdir():
        if path.is_file():pins[str(path)]=sha(path)
    headers=['/usr/include/aarch64-linux-gnu/asm/ptrace.h','/usr/include/linux/ptrace.h','/usr/include/linux/elf.h','/proc/sys/kernel/yama/ptrace_scope']
    for name in headers:pins[name]=sha(name)
    assert Path(headers[-1]).read_text().strip()=='0'
    nm=str(Path('/usr/bin/nm').resolve())
    queue=[nm];libraries={}
    while queue:
        path=queue.pop()
        if path in libraries:continue
        dependencies=needed(path);libraries[path]=dependencies;pins[path]=sha(path)
        for name in dependencies:
            resolved=str((Path('/usr/lib/aarch64-linux-gnu')/name).resolve(strict=True))
            queue.append(resolved)
    for path in HERE.iterdir():
        if path.is_file() and path.name not in ('plan.json','PREPARED.json'):
            pins[str(path)]=sha(path)
    out=Path('/tmp/bendvy-inspect54-outline-profile01');out.mkdir()
    plan=dict(old)
    plan.update(scope='Bounded PC diagnostic of exact existing O0 Inspector; no semantic/performance/adoption claim',pins=pins,cwd=str(HERE),
                targetSeconds=5,sampleIntervalSeconds=.01,nmRaw=str(out/'symbols.stdout'),symbolToolLibraries=libraries,
                commands=[{'label':'symbols','argv':[old['tools']['taskset'],'-c','5',nm,'-n','-S','--defined-only',old['native']],'capSeconds':5},
                          {'label':'profile','argv':[old['tools']['taskset'],'-c','5',old['tools']['python'],str(HERE/'sampler.py'),str(out/'plan.json')],'capSeconds':10}],
                postConsumer='Raw PC/maps/symbol/stream capture only; target5 vs supervisor10; no whole-oracle credit')
    path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');(HERE/'plan.json').write_bytes(path.read_bytes())
    index={'status':'FROZEN_UNADMITTED_NO_TARGET_CHILD','plan':str(path),'sha256':sha(path),
           'launchArgv':[old['tools']['python'],str(HERE/'development.py'),str(path),sha(path)],
           'profileActualArgvRecipe':'Append the externally verified admitted plan SHA to the profile command argv; it is recorded as actualArgv.',
           'targetSeconds':5,'outerSamplerSeconds':10,'binarySHA256':sha(old['native']),'sourcePins':len(pins)}
    (HERE/'PREPARED.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(index,indent=2))

if __name__=='__main__':main()
