"""Source-only model of present component removal, rollback and commit."""
from pathlib import Path
from copy import deepcopy
import gzip,hashlib,sys
HERE=Path(__file__).resolve().parent
SOURCE_PINS={'/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/heterogeneous-v1/schema.bend': '87a2065a98d124888177381813985c0e93bb055a65ced66297c175c2d4832ed7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/independent-app-v1/successor-v2/application.bend': 'd73c7494ceb1f1731dfc04dc3e56f2233d5491004a2a2aa8534aa25223a5926b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/independent-app-v1/successor-v2/main.bend': '744705f0b1792f2345029e94e7526088a01988b9edec55c125ded2634e2d33a4', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/independent-app-v1/successor-v2/observe.bend': '709fdb0a7f0db090fc834e2f0b236db96123c94a8729822dc1150ece859c1d70', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/independent-app-v1/successor-v2/scenario.bend': 'b009b8c3d2674fcbb1ef9f50bf6e71ff7c9ecc2bc601317db67000e0641fe875', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/capabilities.bend': 'bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/column.bend': '3fec368b85fd1d43e53de3838ec32486c5d74b628a7069a82a83e60922b29f2a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/component.bend': '0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/decode-capabilities.bend': 'a7ddbf52e79924dec4c31eaa2d6abacb015f612dce1b528f5b6e0e7812999d65', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/decode-data.bend': '1d1891b034450c041125027bd04f902418378787852864147b1bccb9f58b95d4', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/decode-size.bend': 'dbab191e20936ea5508dfb5ebdcaefa96790d6f73d0e8ed70bea78abcfbe8281', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/decode-utf16.bend': '343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/decode.bend': '13761fdc9607f9e1873be01858da8517badea6dbfa58a116038fbb30afdeb793', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/indexed-lifecycle.bend': 'e997f3b089149a54afb6485fcb2167d1fd0e86979bfa16329473d3a235e8b8d5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/lifecycle.bend': '6585d64ff88a3985a663d42c5b9a82ff3d5067e6ad451f506fad146c4fbd09b0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-component-binding.bend': '2cab2c6545348f0a5fb5bf237195a36e913e6d9b5a4ce9a6240bdee4a83165e1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-declaration.bend': '6912b9c2dd0d163fc7d9f73ed6d2374ddbc0fb05342a97fb4aac968c8e75ecd5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recoverable-array-resource.bend': '7c5279b865e3a6ce72bbaf44a8f7d445ff0cb6d919a2db5e660a66582e6eba3b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recoverable-component-capture.bend': 'a967ad99661aaccef608b5f9b4825a13fe69e5b99cabbf6ee1cc9bea8bd4e468', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recovery-capture.bend': '619a93b46bb1364454f22a0d11677caeba8603657a3da874f80176b560a30dd0', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recovery-component.bend': 'e49cef1af0b4aa28909c5f34040147c09b317c2b24e64f0f59e283ca1a55a07d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recovery-declaration.bend': '320f8c82dd0fad350d30dc5999225dd51538198d4287b6bca7ac3b1c32afc327', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recovery-resource.bend': 'ab18690189cfb902b8e303c32ba9fdc05eff04d7784b01bb95a3ecfdf07e0c1a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-recovery-system.bend': '936ffc328ceaa5dfaa4477c128a9a6bade122be6a68ba1f37dab347a0d5f28f7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/ordinary-schema.bend': 'a694d2570202141ec906fd89fb0306d2ad8a55b2279a98b963daefe2b8f19ffc', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/owner-handoff.bend': '91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/owner-product.bend': '5f5babe4c53da424a2ebaa8e61157b3bedd6dbbd49c93be5600a780833f1fb1f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/persistence-declaration.bend': '06921c755feee8944f2a33b920dca5df00e9d693057a6842ffef4ebc5c9ddc76', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recoverable-array-owner.bend': '1c87ad9125c3efd7662d4a366cd2cb228e4d96ecda4f3704fa7074687dc3085f', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recoverable-array.bend': '64569d9d091f1fd8d0a7de7778972265eebd441836fd5538ae5be9f66fa8a3c1', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recoverable-component-family.bend': '83930c57ef45f3471c565f4a2a1de17e2d479059560fd9db9cd18d08638404b3', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recoverable-component.bend': 'f31a96f591bb0b19f919e43ff281faf11a073a9ac73fca5b590e8fca3f759fa7', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recoverable-owner.bend': '1ba07d23e4d57fa9e8c370a752f260f049bda77f005f42a63ee8f5ca698bdf0d', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/recovery-journal.bend': 'a512716dfb898d1f2966afd90516388f13ba18802f679d29e3be51a049e34677', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/registration.bend': '34a78022a38c297b49680acecbfeb675532eb9f32bfad7aceb2a854dc35d31a5', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/schema-fragments.bend': 'e161ff13196cd40b2218efc7734c2e1e661e74e09a754e6ff60cbe2b525d65ca', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/string-equality.bend': '2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/system.bend': 'e1a7e54cfd862a440bb2d2277045c0d861a4806e17015f901cfe4ab3f776d113', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/transaction.bend': 'a27dcd99fec5de95256e810ace6c5540791969dbe1e0c99916ec38b5f7e3040b', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/world-resource-owner.bend': '1a8f02609c919dc6f76cd2d3c7f22bd75c123cca8d2230d5652caeaa7ae90108', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/src/ecs/world.bend': '4e191783000df87279190cdd5c74d419de88a1bae8d7ebaf0c3ed8600ad80d1a', '/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application/experiments/public-recovery/independent-app-v1/successor-v2/SOURCE-FREEZE.json': '808fc8ef7f431f4d164185e95180bb80a78d5cd16d1b8baf89e38b58096898ad', '/home/node/.bend/bend2/base.bend': 'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661', '/home/node/.bend/bend2/effs/print.c': '28552d3b56aee6f6cdb66326aaa49ad0df35e4476e08c548c908efcbfafbd3e7', '/home/node/.bend/bend2/effs/print.js': '814ceba4efbaa291b7b6a9ff29aa20e3a23c06eb4fa165c69ee0bd22878adaa9'}
def L(v):return ('L',v)
def N(a,b):return ('N',a,b)
def two(a,b):return N(L(a),L(b))
def render(v):
    if isinstance(v,tuple):return v[0]+'('+','.join(render(x) for x in v[1:])+')'
    return str(v)
def option(v):return 'None' if v is None else 'Some('+render(v)+')'
def stamp(v):return '('+','.join(map(str,v))+')'
ORIGINAL=N(L(two(41,97)),L(L(203)))
SIBLING=L(N(two(5,8),two(13,21)))
RESOURCE=N(L(L(77)),L(two(88,99)))
CAPTURE=L(N(two(102,103),two(104,105)))
ATTEMPT_RESOURCE=L(N(two(301,302),two(303,304)))
ATTEMPT_CAPTURE=N(L(two(401,402)),L(L(403)))
COMMIT_RESOURCE=N(L(L(501)),L(two(502,503)))
COMMIT_CAPTURE=L(two(601,602))
ACCESS='[Payload][Flags][Resource][]'
NAME='present-removal'
def logical_column(physical,metadata):
    # Column positive entity ids index the value Array at id-1; Life keys are ids.
    return {entity:(physical[entity-1],metadata.get(entity,(0,0))) for entity in range(1,5)}
def seed():
    first=logical_column([ORIGINAL,SIBLING,None,None],{1:(3,8),2:(4,9)})
    second=logical_column([two(17,19),L(23),None,None],{1:(2,5),2:(6,10)})
    # World liveness is indexed by id directly, independently from Column storage.
    live=[False,True,True,False]
    assert live[1] and live[2] and first[1][0] is not None
    assert first[2][0]==SIBLING and second[1][0]==two(17,19)
    return dict(first=first,second=second,resource=RESOURCE,capture=CAPTURE,clock=11,cursor=0)
def column(c):return ''.join(f'row{i}={option(c.get(i,(None,(0,0)))[0])}@{stamp(c.get(i,(None,(0,0)))[1])};' for i in range(1,5))
def world(s):
    live=N(two('False','True'),two('True','False'))
    return (f'world(ns=7,next=3,high=2,live={render(live)},capacity=4,depth=2,first{{{column(s["first"])}}}'
            f'second{{{column(s["second"])}}},resource={render(s["resource"])},events=[],pending=0,'
            f'registrations=(1,{NAME},{ACCESS})[],nextSystem=2,clock={s["clock"]})')
def owner(s):return f'owner(ns=7,id=1,name={NAME},access={ACCESS},cursor={s["cursor"]},capture={render(s["capture"])})'
def record(old):
    payload,ticks=old
    return f'record((7,1),{stamp(ticks)},{option(payload)});[]'
def recovery(component,capture,resource):
    return f'recovery(first={record(component)},second=[],capture=Replaced({render(capture)});[],resource=Replaced({render(resource)});[])'
def call(s,new_resource,new_capture,abort):
    before=deepcopy(s)
    old_component=s['first'][1];s['clock']+=1
    # An accepted None clears presence AND both lifecycle ticks, while clock advances.
    s['first'][1]=(None,(0,0))
    old_resource=s['resource'];s['resource']=new_resource
    old_capture=s['capture'];s['capture']=new_capture
    if abort:
        # Reverse global order: capture, resource, component. Each displaced owner returns.
        released_capture=s['capture'];s['capture']=old_capture
        released_resource=s['resource'];s['resource']=old_resource
        released_component=s['first'][1];s['first'][1]=old_component
        expected=deepcopy(before);expected['clock']+=1
        assert s==expected
        assert released_component==(None,(0,0))
        recovered=recovery(released_component,released_capture,released_resource)
        outcome='Failure(PolicyDeclined)'
    else:
        s['cursor']=s['clock']
        assert s['first'][1]==(None,(0,0))
        recovered=recovery(old_component,old_capture,old_resource)
        outcome='Success'
    assert s['first'][2]==before['first'][2] and s['second']==before['second']
    return f'outcome={outcome};output(removed=True,refused=None);{world(s)};{owner(s)};{recovered}'
def derive():
    s=seed();initial='initial:'+world(s)+';'+owner(s)
    rollback=call(s,ATTEMPT_RESOURCE,ATTEMPT_CAPTURE,True)
    assert (s['clock'],s['cursor'])==(12,0) and s['first'][1]==(ORIGINAL,(3,8))
    committed=call(s,COMMIT_RESOURCE,COMMIT_CAPTURE,False)
    assert (s['clock'],s['cursor'])==(13,13)
    assert s['resource']==COMMIT_RESOURCE and s['capture']==COMMIT_CAPTURE
    assert s['first'][2]==(SIBLING,(4,9))
    # scenario string has no terminal LF; IO.print supplies exactly one.
    return (initial+'\nrollback:'+rollback+'\ncommit:'+committed+'\n').encode()
if __name__=='__main__':
    assert SOURCE_PINS
    for name,h in SOURCE_PINS.items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h,name
    raw=derive()
    if '--write' in sys.argv:
        (HERE/'oracle.txt').write_bytes(raw);(HERE/'oracle.txt.gz').write_bytes(gzip.compress(raw,mtime=0))
    else:
        assert (HERE/'oracle.txt').read_bytes()==raw
        assert gzip.decompress((HERE/'oracle.txt.gz').read_bytes())==raw
    print(len(raw),hashlib.sha256(raw).hexdigest())
