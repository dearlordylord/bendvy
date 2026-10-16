"""Independent finite component/capture owner model, before backend observation."""
from pathlib import Path
import hashlib
import gzip
import sys
from dataclasses import dataclass, field

HERE = Path(__file__).resolve().parent
SOURCE_PINS = {'/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/component-capture-v1/main.bend': 'd0c3a20afe322fbda24baf138c37a1dc301142a7432d93798580fd8979819991', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/component-capture-v1/fixture.bend': '72abe4faf896600e4e623b6a45e4d2b7b3bb2eb8478f4273e958f31148836b2c', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recoverable-component-capture.bend': 'a967ad99661aaccef608b5f9b4825a13fe69e5b99cabbf6ee1cc9bea8bd4e468', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world.bend': '4e191783000df87279190cdd5c74d419de88a1bae8d7ebaf0c3ed8600ad80d1a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/string-equality.bend': '2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/column.bend': '3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/lifecycle.bend': '6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-handoff.bend': '91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/indexed-lifecycle.bend': 'e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/system.bend': 'e1a7e54cfd862a440bb2d2277045c0d861a4806e17015f901cfe4ab3f776d113', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/registration.bend': '34a78022a38c297b49680acecbfeb675532eb9f32bfad7aceb2a854dc35d31a5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/transaction.bend': 'a27dcd99fec5de95256e810ace6c5540791969dbe1e0c99916ec38b5f7e3040b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-declaration.bend': '6912b9c2dd0d163fc7d9f73ed6d2374ddbc0fb05342a97fb4aac968c8e75ecd5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-product.bend': '5f5babe4c53da424a2ebaa8e61157b3bedd6dbbd49c93be5600a780833f1fb1f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/capabilities.bend': 'bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/component.bend': '0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recoverable-array-resource.bend': '7c5279b865e3a6ce72bbaf44a8f7d445ff0cb6d919a2db5e660a66582e6eba3b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-schema.bend': 'a694d2570202141ec906fd89fb0306d2ad8a55b2279a98b963daefe2b8f19ffc', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-data.bend': '1d1891b034450c041125027bd04f902418378787852864147b1bccb9f58b95d4', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-utf16.bend': '343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/persistence-declaration.bend': '06921c755feee8944f2a33b920dca5df00e9d693057a6842ffef4ebc5c9ddc76', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-capabilities.bend': 'a7ddbf52e79924dec4c31eaa2d6abacb015f612dce1b528f5b6e0e7812999d65', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/schema-fragments.bend': 'e161ff13196cd40b2218efc7734c2e1e661e74e09a754e6ff60cbe2b525d65ca', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode.bend': '13761fdc9607f9e1873be01858da8517badea6dbfa58a116038fbb30afdeb793', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-size.bend': 'dbab191e20936ea5508dfb5ebdcaefa96790d6f73d0e8ed70bea78abcfbe8281', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-resource-owner.bend': '1a8f02609c919dc6f76cd2d3c7f22bd75c123cca8d2230d5652caeaa7ae90108', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recovery-journal.bend': 'a512716dfb898d1f2966afd90516388f13ba18802f679d29e3be51a049e34677', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array.bend': '64569d9d091f1fd8d0a7de7778972265eebd441836fd5538ae5be9f66fa8a3c1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array-owner.bend': '1c87ad9125c3efd7662d4a366cd2cb228e4d96ecda4f3704fa7074687dc3085f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-owner.bend': '1ba07d23e4d57fa9e8c370a752f260f049bda77f005f42a63ee8f5ca698bdf0d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-component.bend': 'f31a96f591bb0b19f919e43ff281faf11a073a9ac73fca5b590e8fca3f759fa7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/component-capture-v1/scenario.bend': '8a7331bc9f422cbddac776c6984546fe1a024b7d677430da9d8b953b8571e0f7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/component-capture-v1/observe.bend': '698dcf8d9e0f05416ff13114e6158003b1f87d7e4440e1ac24f9541681399b0e', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/observe.bend': '01a418c947795200b6ff5eae92844634aa202efa5bb1686be736c65ee6ef88fb', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/fixture.bend': 'aa3159534dde4b103b2afbbf9390c9d982da3cfc7fdef10096fb837a51d503d3', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-io.bend': '1be0fcd577ecf177af89136f77e5c8e67894304a89adefaf0565591f641a63e9', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.bend': '92f7205a5d4d633289348960e139f5797354ff7dbfb0627b5d9435e17c5f48d7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.c': 'b218011c7738b7ac8ca94963b8c8cacd97006af6fa1c6ab6f4ac506c612b4521', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.js': 'f463bf328c4232fec85c67e328d93309e2191d80b7377be64355b6c1edd4f815', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/component-capture-v1/SOURCE-FREEZE.json': 'a775efca3f5b9be9bb1954fd117b2b77a4887fe6566501fb2f40f66da2b58129', '/home/node/.bend/bend2/base.bend': 'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661', '/home/node/.bend/bend2/effs/print.c': '28552d3b56aee6f6cdb66326aaa49ad0df35e4476e08c548c908efcbfafbd3e7', '/home/node/.bend/bend2/effs/print.js': '814ceba4efbaa291b7b6a9ff29aa20e3a23c06eb4fa165c69ee0bd22878adaa9'}

def pair(n): return (n,n+1)
def array(n): return (pair(n),pair(n+2))
def tree(x): return '('+','.join(map(tree,x))+')' if isinstance(x,tuple) else str(x)
def items(xs): return ''.join(x+';' for x in xs)+'[]'
def optional(x): return 'None' if x is None else 'Some:'+tree(x)
def stamp(x): return ':'.join(map(str,x))
NAME='recoverable-component-capture'

@dataclass
class World:
    ns: int
    value: int
    clock: int = 1
    cells: dict = field(init=False)
    cursor: int = 0
    capture: tuple = None
    def __post_init__(self): self.cells={1:(array(self.value),(1,1)),2:(None,(0,0))}
    def write(self, target, value):
        old=self.cells[target]
        self.clock+=1
        self.cells[target]=(value,(old[1][0] if old[0] is not None else self.clock,self.clock))
        return old
    def owner(self): return f'{self.ns}:1:{NAME}:[Payload]:cursor={self.cursor}:capture={tree(self.capture)}'
    def show(self):
        cells=''.join(('-' if self.cells.get(i,(None,(0,0)))[0] is None else tree(self.cells[i][0]))+'@'+stamp(self.cells.get(i,(None,(0,0)))[1])+';' for i in range(4))
        return f'W{{{self.ns},3,2,((False,True),(True,False)),4,2,{cells},Unit,[],pending=0,[1:{NAME}:[Payload]],2,{self.clock}}}'

def arguments(ns,target,other,seed,fail):
    return (f'target={ns}:{target}:foreign={other}:1:first={tree(array(seed))}:second={tree(array(seed+20))}'
            f':captureFirst={tree(array(seed+40))}:captureElement={tree(pair(seed+50))}'
            f':captureSecond={tree(array(seed+60))}:rejected={tree(array(seed+80))}:fail={fail}')

def component_record(ns,target,value):
    payload,ticks=value
    return f'{ns}:{target}@{stamp(ticks)}:{optional(payload)}'

def execute(w,target,seed,fail):
    initial=w.cells[target]; old_capture=w.capture; initial_clock=w.clock; prior_cursor=w.cursor
    # Each record is a saved original; operations are independently modelled as exchanges.
    first_old=w.write(target,array(seed))
    cap_first_old=w.capture; w.capture=array(seed+40)
    cap_element_old=w.capture[1]; w.capture=(w.capture[0],pair(seed+50))
    second_old=w.write(target,array(seed+20))
    cap_second_old=w.capture; w.capture=array(seed+60)
    # The foreign handle never matches this World; no clock/state/journal action.
    assert w.clock==initial_clock+2
    if fail:
        returned_cap_second=w.capture;w.capture=cap_second_old
        returned_second=w.cells[target];w.cells[target]=second_old
        returned_element=w.capture[1];w.capture=(w.capture[0],cap_element_old)
        returned_cap_first=w.capture;w.capture=cap_first_old
        returned_first=w.cells[target];w.cells[target]=first_old
        component_rows=[returned_first,returned_second]
        capture_rows=[('replaced',returned_cap_first),('swapped',returned_element),('replaced',returned_cap_second)]
        assert w.cells[target]==initial and w.capture==old_capture and w.cursor==prior_cursor
        assert [v[0] for v in component_rows]==[array(seed),array(seed+20)]
        added=initial[1][0] if initial[0] is not None else initial_clock+1
        assert [v[1] for v in component_rows]==[(added,initial_clock+1),(added,initial_clock+2)]
        assert capture_rows==[('replaced',array(seed+40)),('swapped',pair(seed+50)),('replaced',array(seed+60))]
    else:
        component_rows=[first_old,second_old]
        capture_rows=[('replaced',cap_first_old),('swapped',cap_element_old),('replaced',cap_second_old)]
        w.cursor=w.clock
        assert w.cells[target][0]==array(seed+20) and w.capture==array(seed+60)
    recovered='components='+items(component_record(w.ns,target,x) for x in component_rows)+':captures='+items(('replaced:' if k=='replaced' else 'swapped:1:')+tree(v) for k,v in capture_rows)
    output='components='+items([optional(array(seed+80))])+':arrays=[]:elements=[]:errors=MissingEntity;[]'
    return output,recovered

def scenario(ns):
    w=World(ns,10,capture=array(1000));foreign=World(ns+1,900,capture=array(9000))
    def snapshot(label): return '|'.join((label,w.show(),foreign.show(),w.owner(),foreign.owner()))+'\n'
    out=snapshot('registered')
    for label,seed,fail,target in [('commit',100,False,1),('failed',200,True,1),('retry-failed',300,True,1),('retry-success',400,False,1),('absent-failed',600,True,2)]:
        out+=f'input:{label}|{arguments(ns,target,ns+1,seed,fail)}\n'
        result,recovered=execute(w,target,seed,fail)
        expected={'commit':(3,3),'failed':(5,3),'retry-failed':(7,3),'retry-success':(9,9),'absent-failed':(11,9)}
        assert (w.clock,w.cursor)==expected[label]
        out+=snapshot(label+(' failed' if fail else ' success').replace(' ',':')+'|output='+result+'|recovery='+recovered)
    out+='input:foreign-world|'+arguments(ns,1,ns+1,500,False)+'\n'
    out+=snapshot('foreign-world:refused|args-returned='+arguments(ns,1,ns+1,500,False))
    assert w.clock==11 and w.cursor==9
    assert w.cells=={1:(array(420),(1,9)),2:(None,(0,0))}
    assert w.capture==array(460) and foreign.clock==1 and foreign.cursor==0
    return out

def derive(): return ('Workshop\n'+scenario(1)+'Garden\n'+scenario(3)+'\n').encode()

if __name__=='__main__':
    assert SOURCE_PINS, 'Final source freeze pending'
    for name,h in SOURCE_PINS.items(): assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h,name
    raw=derive()
    if '--write' in sys.argv:
        (HERE/'oracle.txt').write_bytes(raw)
        (HERE/'oracle.txt.gz').write_bytes(gzip.compress(raw,mtime=0))
    else:
        assert (HERE/'oracle.txt').read_bytes()==raw
        assert gzip.decompress((HERE/'oracle.txt.gz').read_bytes())==raw
    print(len(raw),hashlib.sha256(raw).hexdigest())
