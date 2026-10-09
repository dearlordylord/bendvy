"""Full pre-output countermodel: only reached provider returns cell zero four times."""
import copy
import hashlib
import json
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARENT=HERE.parents[1]/'oracle-v1/expected.py'
AUTHOR=Path('/workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1')
SOURCE=AUTHOR/'grant-index-zero-v1/source'

def helper():
    m=types.ModuleType('independent_reached_basis');m.__file__=str(PARENT)
    exec(compile(PARENT.read_bytes(),str(PARENT),'exec'),m.__dict__)
    return m

def baseline():
    return json.loads((ROOT/'experiments/public-owned-events/declaration-read-v1/oracle-v1/registered-expected.json').read_bytes())

def countermodel():
    value=baseline()
    for role in ('standard','capacity'):
        for snapshot in value[role]['Trace']['snapshots']:
            for completion in snapshot['reads']:
                if 'ReadSucceeded' in completion:
                    view=completion['ReadSucceeded']['view']
                elif 'ReadBodyFailed' in completion:
                    view=completion['ReadBodyFailed']['error']['ReadFailed']['view']
                else:
                    continue
                for packet in view['packets']:
                    assert len(packet['cells'])==4
                    packet['cells']=[packet['cells'][0]]*4
    return value

def render(value):
    m=helper()
    p,t=m.source_load('independent_registered_transport',ROOT/'experiments/public-owned-events/declaration-read-v1/transport.py').parser('registered')
    original=AUTHOR/'source/declaration-read-v1/registered-v1'
    p.ENTRY=SOURCE/'main.bend'
    for key,(path,fields) in list(p.records.items()):
        if path=='log.bend':p.records[key]=(str(original/'log.bend'),fields)
        if path=='direct-controls.bend':p.records[key]=(str(original/'direct-controls.bend'),fields)
    for key,(path,variants) in list(p.sums.items()):
        if path=='log.bend':p.sums[key]=(str(original/'log.bend'),variants)
    # Unchanged direct controls return their ORIGINAL observation module's records.
    p.records['DirectPayloadView']=(str(original/'observation.bend'),p.records['PayloadView'][1])
    p.records['DirectRowView']=(str(original/'observation.bend'),[('key','U32'),('payload','DirectPayloadView')])
    p.records['DirectLogView']=(str(original/'observation.bend'),[('seen',['U32']),('rows',['DirectRowView'])])
    p.records['DirectView']=(str(original/'direct-controls.bend'),[('log','DirectLogView'),('value','MaybeCells'),('errors',['Refusal']),('refused',['DirectRowView'])])
    old_name=p.name
    def nominal(path,tag):
        return old_name(path,{'DirectPayloadView':'PayloadView','DirectRowView':'RowView','DirectLogView':'LogView'}.get(tag,tag))
    p.name=nominal
    raw=(p.render(t,value)+'\n').encode()
    reader=p.Parser(raw.decode());decoded=reader.read(t);reader.literal('\n')
    assert reader.i==len(reader.text) and decoded==value
    return raw,m.used

if __name__=='__main__':
    pins={str(PARENT):hashlib.sha256(PARENT.read_bytes()).hexdigest()}
    for name,value in (('baseline',baseline()),('counterfactual',countermodel())):
        raw,used=render(value);pins.update(used)
        (HERE/(name+'.json')).write_text(json.dumps(value,indent=2)+'\n')
        (HERE/(name+'.stdout')).write_bytes(raw)
    def visit(path):
        import re
        path=path.resolve();key=str(path)
        if key in pins:return
        content=path.read_bytes();pins[key]=hashlib.sha256(content).hexdigest()
        for dep in re.findall(r'^import (\S+)',content.decode(),re.M):
            visit(Path('/home/node/.bend/bend2/base.bend') if dep=='Base' else path.parent/dep)
    visit(SOURCE/'main.bend')
    pins[str(ROOT/'experiments/public-owned-events/declaration-read-v1/oracle-v1/registered-expected.json')]=hashlib.sha256((ROOT/'experiments/public-owned-events/declaration-read-v1/oracle-v1/registered-expected.json').read_bytes()).hexdigest()
    (HERE/'source-basis.json').write_text(json.dumps({'sourceCommit':'7d95ee60','entry':str(SOURCE/'main.bend'),'pins':pins,'scope':'Pre-output whole registered model; provider grant index zero only; three cloned constructor modules.'},indent=2)+'\n')
