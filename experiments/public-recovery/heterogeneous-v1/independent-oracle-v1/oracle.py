"""Independent heterogeneous value/owner model; no backend output input."""
from pathlib import Path
from dataclasses import dataclass,field
import gzip,hashlib,sys
HERE=Path(__file__).resolve().parent
SOURCE_PINS={'/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/main.bend': '4e7043c87d298f6dc1e2a9224b50b6220476823d79f19f5d6960523261bcd82a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/fixture.bend': 'd2bfc23a2d4bcbb01518939800d635cea4352634e5931908deeaf42d8821303f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/schema.bend': '87a2065a98d124888177381813985c0e93bb055a65ced66297c175c2d4832ed7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/column.bend': '3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/lifecycle.bend': '6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-handoff.bend': '91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/indexed-lifecycle.bend': 'e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-product.bend': '5f5babe4c53da424a2ebaa8e61157b3bedd6dbbd49c93be5600a780833f1fb1f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-component-binding.bend': '2cab2c6545348f0a5fb5bf237195a36e913e6d9b5a4ce9a6240bdee4a83165e1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-declaration.bend': '6912b9c2dd0d163fc7d9f73ed6d2374ddbc0fb05342a97fb4aac968c8e75ecd5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/component.bend': '0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world.bend': '4e191783000df87279190cdd5c74d419de88a1bae8d7ebaf0c3ed8600ad80d1a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/string-equality.bend': '2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/transaction.bend': 'a27dcd99fec5de95256e810ace6c5540791969dbe1e0c99916ec38b5f7e3040b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-schema.bend': 'a694d2570202141ec906fd89fb0306d2ad8a55b2279a98b963daefe2b8f19ffc', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-data.bend': '1d1891b034450c041125027bd04f902418378787852864147b1bccb9f58b95d4', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-utf16.bend': '343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/persistence-declaration.bend': '06921c755feee8944f2a33b920dca5df00e9d693057a6842ffef4ebc5c9ddc76', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-capabilities.bend': 'a7ddbf52e79924dec4c31eaa2d6abacb015f612dce1b528f5b6e0e7812999d65', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/capabilities.bend': 'bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/schema-fragments.bend': 'e161ff13196cd40b2218efc7734c2e1e661e74e09a754e6ff60cbe2b525d65ca', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode.bend': '13761fdc9607f9e1873be01858da8517badea6dbfa58a116038fbb30afdeb793', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-size.bend': 'dbab191e20936ea5508dfb5ebdcaefa96790d6f73d0e8ed70bea78abcfbe8281', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recovery-declaration.bend': '320f8c82dd0fad350d30dc5999225dd51538198d4287b6bca7ac3b1c32afc327', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recoverable-array-resource.bend': '7c5279b865e3a6ce72bbaf44a8f7d445ff0cb6d919a2db5e660a66582e6eba3b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/system.bend': 'e1a7e54cfd862a440bb2d2277045c0d861a4806e17015f901cfe4ab3f776d113', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/registration.bend': '34a78022a38c297b49680acecbfeb675532eb9f32bfad7aceb2a854dc35d31a5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-resource-owner.bend': '1a8f02609c919dc6f76cd2d3c7f22bd75c123cca8d2230d5652caeaa7ae90108', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recovery-journal.bend': 'a512716dfb898d1f2966afd90516388f13ba18802f679d29e3be51a049e34677', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array.bend': '64569d9d091f1fd8d0a7de7778972265eebd441836fd5538ae5be9f66fa8a3c1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array-owner.bend': '1c87ad9125c3efd7662d4a366cd2cb228e4d96ecda4f3704fa7074687dc3085f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-owner.bend': '1ba07d23e4d57fa9e8c370a752f260f049bda77f005f42a63ee8f5ca698bdf0d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recovery-system.bend': '936ffc328ceaa5dfaa4477c128a9a6bade122be6a68ba1f37dab347a0d5f28f7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recovery-component.bend': 'e49cef1af0b4aa28909c5f34040147c09b317c2b24e64f0f59e283ca1a55a07d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recoverable-component-capture.bend': 'a967ad99661aaccef608b5f9b4825a13fe69e5b99cabbf6ee1cc9bea8bd4e468', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-component.bend': 'f31a96f591bb0b19f919e43ff281faf11a073a9ac73fca5b590e8fca3f759fa7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-component-family.bend': '83930c57ef45f3471c565f4a2a1de17e2d479059560fd9db9cd18d08638404b3', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recovery-capture.bend': '619a93b46bb1364454f22a0d11677caeba8603657a3da874f80176b560a30dd0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/scenario.bend': '694f7c18d478792712f13260753bc03be44c8ef2ecb59b7ddc7e682fb3307e98', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/observe.bend': '8b12de4255bf687dc00b8285f1a1963cdbcaa1b4e1a67c0686e8152ad972ca13', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/observe.bend': '01a418c947795200b6ff5eae92844634aa202efa5bb1686be736c65ee6ef88fb', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/fixture.bend': 'aa3159534dde4b103b2afbbf9390c9d982da3cfc7fdef10096fb837a51d503d3', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-io.bend': '1be0fcd577ecf177af89136f77e5c8e67894304a89adefaf0565591f641a63e9', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.bend': '92f7205a5d4d633289348960e139f5797354ff7dbfb0627b5d9435e17c5f48d7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.c': 'b218011c7738b7ac8ca94963b8c8cacd97006af6fa1c6ab6f4ac506c612b4521', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.js': 'f463bf328c4232fec85c67e328d93309e2191d80b7377be64355b6c1edd4f815', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/heterogeneous-v1/SOURCE-FREEZE.json': '67b89b96143dbe04fd49dfcc9d6aa26b282ec5d5a938dcd6f573d067e9159fbc', '/home/node/.bend/bend2/base.bend': 'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661', '/home/node/.bend/bend2/effs/print.c': '28552d3b56aee6f6cdb66326aaa49ad0df35e4476e08c548c908efcbfafbd3e7', '/home/node/.bend/bend2/effs/print.js': '814ceba4efbaa291b7b6a9ff29aa20e3a23c06eb4fa165c69ee0bd22878adaa9'}
def pair(n):return (n,n+1)
def array(n):return (pair(n),pair(n+2))
def tree(v):return '('+','.join(map(tree,v))+')' if isinstance(v,tuple) else str(v)
def items(xs):return ''.join(x+';' for x in xs)+'[]'
def ticks(v):return ':'.join(map(str,v))
def optional(v):return 'None' if v is None else 'Some:'+tree(v)
NAME='recoverable-heterogeneous'
ACCESS='[Payload, Flags]'
@dataclass
class World:
    ns:int
    seed:int
    capture:tuple
    clock:int=2
    cursor:int=0
    cells:dict=field(init=False)
    def __post_init__(self):
        self.cells={'Payload':{1:(array(self.seed),(1,1)),2:(None,(0,0))},'Flags':{1:(pair(self.seed+5),(2,2)),2:(None,(0,0))}}
    def write(self,family,target,value):
        old=self.cells[family][target];self.clock+=1
        self.cells[family][target]=(value,(old[1][0] if old[0] is not None else self.clock,self.clock))
        return old
    def owner(self):return f'{self.ns}:1:{NAME}:{ACCESS}:cursor={self.cursor}:capture={tree(self.capture)}'
    def show(self):
        columns=[]
        for f in ('Payload','Flags'):
            rows=[self.cells[f].get(i,(None,(0,0))) for i in range(4)]
            columns.append(f+'='+''.join(('-' if v is None else tree(v))+'@'+ticks(t)+';' for v,t in rows))
        return (f'W{{{self.ns},3,2,((False,True),(True,False)),4,2,'+':'.join(columns)
                +f',Unit,events=0,pending=0,[1:{NAME}:{ACCESS}],2,{self.clock}}}')
def args(ns,target,seed,fail):
    return (f'target={ns}:{target}:a={tree(array(seed))}:b={tree(pair(seed+10))}'
            f':a2={tree(array(seed+20))}:b2={tree(pair(seed+30))}:capture={tree(array(seed+40))}'
            f':element={tree(pair(seed+50))}:fail={fail}')
def record(ns,target,row):
    value,stamp=row
    return f'{ns}:{target}@{ticks(stamp)}:{optional(value)}'
def execute(w,target,seed,fail):
    original={f:w.cells[f][target] for f in ('Payload','Flags')};old_capture=w.capture;clock=w.clock;cursor=w.cursor
    journal=[]
    def write(f,v):journal.append((f,w.write(f,target,v)))
    write('Payload',array(seed));write('Flags',pair(seed+10))
    journal.append(('replace',w.capture));w.capture=array(seed+40)
    write('Payload',array(seed+20));write('Flags',pair(seed+30))
    journal.append(('swap',w.capture[1]));w.capture=(w.capture[0],pair(seed+50))
    assert w.clock==clock+4
    recovered={'Payload':[],'Flags':[],'captures':[]}
    for kind,saved in reversed(journal):
        released=saved
        if fail:
            if kind in ('Payload','Flags'):
                released=w.cells[kind][target];w.cells[kind][target]=saved
            elif kind=='replace':released=w.capture;w.capture=saved
            else:released=w.capture[1];w.capture=(w.capture[0],saved)
        if kind in ('Payload','Flags'):recovered[kind].insert(0,released)
        else:recovered['captures'].insert(0,(kind,released))
    if fail:
        assert all(w.cells[f][target]==original[f] for f in original)
        assert w.capture==old_capture and w.cursor==cursor
        assert recovered['captures']==[('replace',array(seed+40)),('swap',pair(seed+50))]
        for f,offsets,values in [('Payload',(1,3),(array(seed),array(seed+20))),('Flags',(2,4),(pair(seed+10),pair(seed+30)))]:
            added=original[f][1][0] if original[f][0] is not None else clock+offsets[0]
            assert recovered[f]==[(values[i],(added,clock+offsets[i])) for i in range(2)]
    else:
        w.cursor=w.clock
        assert w.cells['Payload'][target][0]==array(seed+20) and w.cells['Flags'][target][0]==pair(seed+30)
        assert w.capture==(pair(seed+40),pair(seed+50))
    recovery=':'.join(f+'='+items(record(w.ns,target,v) for v in recovered[f]) for f in ('Payload','Flags'))
    recovery+=':captures='+items(('replaced:' if k=='replace' else 'swapped:1:')+tree(v) for k,v in recovered['captures'])
    return 'Payload=[]:Flags=[]:arrays=[]:elements=[]:errors=[]',recovery

def scenario(ns):
    w=World(ns,10,array(1000));foreign=World(ns+1,900,array(9000))
    def snapshot(label):return '|'.join((label,w.show(),foreign.show(),w.owner(),foreign.owner()))+'\n'
    result=snapshot('registered')
    for label,seed,fail,target,checkpoint in [('commit',100,False,1,(6,6)),('failed',200,True,1,(10,6)),('retry-failed',300,True,1,(14,6)),('retry-success',400,False,1,(18,18)),('absent-failed',600,True,2,(22,18))]:
        result+='input:'+label+'|'+args(ns,target,seed,fail)+'\n'
        output,recovery=execute(w,target,seed,fail)
        assert (w.clock,w.cursor)==checkpoint
        result+=snapshot(label+(':failed' if fail else ':success')+'|output='+output+'|recovery='+recovery)
    result+='input:foreign-world|'+args(ns,1,500,False)+'\n'
    result+=snapshot('foreign-world:refused|args-returned='+args(ns,1,500,False))
    assert w.cells['Payload']=={1:(array(420),(1,17)),2:(None,(0,0))}
    assert w.cells['Flags']=={1:(pair(430),(2,18)),2:(None,(0,0))}
    assert w.capture==(pair(440),pair(450)) and foreign.clock==2 and foreign.cursor==0
    return result

def derive():return ('Workshop\n'+scenario(1)+'Garden\n'+scenario(3)+'\n').encode()
if __name__=='__main__':
    assert SOURCE_PINS,'Final source freeze pending'
    for name,h in SOURCE_PINS.items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h,name
    raw=derive()
    if '--write' in sys.argv:
        (HERE/'oracle.txt').write_bytes(raw);(HERE/'oracle.txt.gz').write_bytes(gzip.compress(raw,mtime=0))
    else:
        assert (HERE/'oracle.txt').read_bytes()==raw
        assert gzip.decompress((HERE/'oracle.txt.gz').read_bytes())==raw
    print(len(raw),hashlib.sha256(raw).hexdigest())
