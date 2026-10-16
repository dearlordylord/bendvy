"""Independent finite owner-token model; no candidate output is an input."""
from pathlib import Path
import hashlib
import sys
import gzip

SOURCE_PINS = {'/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/main.bend': '498d741c863922a01a971dff43507727b6395cbffa9b80b65e2b7f89680720ef', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/fixture.bend': 'aa3159534dde4b103b2afbbf9390c9d982da3cfc7fdef10096fb837a51d503d3', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-recoverable-array-resource.bend': '7c5279b865e3a6ce72bbaf44a8f7d445ff0cb6d919a2db5e660a66582e6eba3b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world.bend': '4e191783000df87279190cdd5c74d419de88a1bae8d7ebaf0c3ed8600ad80d1a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/string-equality.bend': '2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/system.bend': 'e1a7e54cfd862a440bb2d2277045c0d861a4806e17015f901cfe4ab3f776d113', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/registration.bend': '34a78022a38c297b49680acecbfeb675532eb9f32bfad7aceb2a854dc35d31a5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-schema.bend': 'a694d2570202141ec906fd89fb0306d2ad8a55b2279a98b963daefe2b8f19ffc', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-data.bend': '1d1891b034450c041125027bd04f902418378787852864147b1bccb9f58b95d4', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-utf16.bend': '343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/persistence-declaration.bend': '06921c755feee8944f2a33b920dca5df00e9d693057a6842ffef4ebc5c9ddc76', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-capabilities.bend': 'a7ddbf52e79924dec4c31eaa2d6abacb015f612dce1b528f5b6e0e7812999d65', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/capabilities.bend': 'bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/component.bend': '0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/lifecycle.bend': '6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/column.bend': '3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-handoff.bend': '91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/indexed-lifecycle.bend': 'e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/transaction.bend': 'a27dcd99fec5de95256e810ace6c5540791969dbe1e0c99916ec38b5f7e3040b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/schema-fragments.bend': 'e161ff13196cd40b2218efc7734c2e1e661e74e09a754e6ff60cbe2b525d65ca', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode.bend': '13761fdc9607f9e1873be01858da8517badea6dbfa58a116038fbb30afdeb793', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/decode-size.bend': 'dbab191e20936ea5508dfb5ebdcaefa96790d6f73d0e8ed70bea78abcfbe8281', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/ordinary-declaration.bend': '6912b9c2dd0d163fc7d9f73ed6d2374ddbc0fb05342a97fb4aac968c8e75ecd5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/owner-product.bend': '5f5babe4c53da424a2ebaa8e61157b3bedd6dbbd49c93be5600a780833f1fb1f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-resource-owner.bend': '1a8f02609c919dc6f76cd2d3c7f22bd75c123cca8d2230d5652caeaa7ae90108', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recovery-journal.bend': 'a512716dfb898d1f2966afd90516388f13ba18802f679d29e3be51a049e34677', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array.bend': '64569d9d091f1fd8d0a7de7778972265eebd441836fd5538ae5be9f66fa8a3c1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-array-owner.bend': '1c87ad9125c3efd7662d4a366cd2cb228e4d96ecda4f3704fa7074687dc3085f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/recoverable-owner.bend': '1ba07d23e4d57fa9e8c370a752f260f049bda77f005f42a63ee8f5ca698bdf0d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/scenario.bend': 'ee88e1046255e1f40887052dad0b6bb6cdb53cc4a090a1e39dd28711de969a57', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/observe.bend': '01a418c947795200b6ff5eae92844634aa202efa5bb1686be736c65ee6ef88fb', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-io.bend': '1be0fcd577ecf177af89136f77e5c8e67894304a89adefaf0565591f641a63e9', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/src/ecs/world-namespace.bend': '92f7205a5d4d633289348960e139f5797354ff7dbfb0627b5d9435e17c5f48d7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-owned-operations/experiments/public-recovery/ordinary-array-v1/SOURCE-FREEZE.json': '06abb317f4124c17d7eed4b78966172e4060562a1f685df71ec17d5760c17a00', '/home/node/.bend/bend2/base.bend': 'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661', '/home/node/.bend/bend2/effs/print.c': '28552d3b56aee6f6cdb66326aaa49ad0df35e4476e08c548c908efcbfafbd3e7', '/home/node/.bend/bend2/effs/print.js': '814ceba4efbaa291b7b6a9ff29aa20e3a23c06eb4fa165c69ee0bd22878adaa9'}

def check_sources():
    for name, expected in SOURCE_PINS.items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == expected, name

HERE = Path(__file__).resolve().parent

def pair(n):
    return (n, n + 1)

def array(n):
    return (pair(n), pair(n + 2))

def tree(value):
    if isinstance(value, tuple):
        return '(' + ','.join(map(tree, value)) + ')'
    return str(value)

def items(xs):
    return ''.join(x + ';' for x in xs) + '[]'

def args(seed, fail):
    return ':'.join((tree(array(seed)), tree(pair(seed + 10)),
                     tree(array(seed + 20)), tree(pair(seed + 30)),
                     'fail=' + str(fail)))

def execute(old, seed, fail):
    # Token provenance is represented separately from numerical equality.
    first, element, second = array(seed), pair(seed + 10), array(seed + 20)
    edited = (first[0], element)
    displaced = [('replaced', old), ('swapped', first[1]), ('replaced', edited)]
    current = second
    recovered = []
    for kind, saved in reversed(displaced):
        if fail:
            if kind == 'replaced':
                current, released = saved, current
            else:
                released = current[1]
                current = (current[0], saved)
        else:
            released = saved
        recovered.insert(0, (kind, released))
    assert current == (old if fail else second)
    assert recovered == ([('replaced', first), ('swapped', element), ('replaced', second)]
                         if fail else displaced)
    return current, recovered

def records(rows):
    return items(('replaced:' if kind == 'replaced' else 'swapped:1:') + tree(value)
                 for kind, value in rows)

def registry(ns):
    return f'{ns}:1:recoverable-array:[Payload]:cursor=0'

def world(ns, value):
    return (f'ns={ns}:next=1:high=0:capacity=1:depth=0:live=False:resource={tree(value)}'
            ':events=0:pending=0:regs=[1:recoverable-array:[Payload]]:sid=2:clock=0')

def scenario(ns):
    current, foreign = array(10), array(900)
    def snapshot(label):
        return '|'.join((label, world(ns, current), world(ns + 1, foreign),
                         registry(ns), registry(ns + 1))) + '\n'
    text = snapshot('registered')
    for label, seed, fail in [('commit',100,False), ('failed',200,True),
                              ('retry-failed',300,True), ('retry-success',400,False)]:
        text += f'input:{label}|{args(seed, fail)}\n'
        before = current
        current, recovered = execute(current, seed, fail)
        if fail:
            assert current == before == array(120)
        result = 'failed' if fail else 'success'
        text += snapshot(f'{label}:{result}|returned=arrays=[]:elements='
                         + items([tree(pair(seed + 30))])
                         + '|recovered=' + records(recovered))
    text += f'input:foreign|{args(500,False)}\n'
    # Namespace mismatch returns the original Args before invoking gameplay.
    text += snapshot('foreign:refused|args-returned=' + args(500,False))
    assert current == array(420) and foreign == array(900)
    return text

def derive():
    # Both ordinary WI.create calls finish before the next schema is started.
    # Each scenario ends LF, and Base IO.print adds one additional LF.
    return ('Workshop\n' + scenario(1) + 'Garden\n' + scenario(3) + '\n').encode()

if __name__ == '__main__':
    check_sources()
    raw = derive()
    if '--write' in sys.argv:
        (HERE / 'oracle.txt').write_bytes(raw)
        (HERE / 'oracle.txt.gz').write_bytes(gzip.compress(raw, mtime=0))
    else:
        assert (HERE / 'oracle.txt').read_bytes() == raw
        assert gzip.decompress((HERE / 'oracle.txt.gz').read_bytes()) == raw
    print(f'{len(raw)} bytes SHA256 {hashlib.sha256(raw).hexdigest()}')
