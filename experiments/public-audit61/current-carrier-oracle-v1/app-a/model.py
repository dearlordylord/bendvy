"""Independent current-carrier sequential owner-handoff model; source-only, no backend output inputs."""
from base_model import State as Prior,tree,listing
class State(Prior):
    def __init__(self):
        super().__init__();self.handoff=False;self.array=(7,9);self.array_changed=1;self.tick=0;self.published=False;self.read_done=False;self.recovery_cursor=0;self.records='[]';self.loose='some('+tree(70,90)+')';self.history=[];self.scratch=(1,2);self.status='registered'
    def world(self):
        result=super().world()
        if self.seeded:result=result.replace('some('+tree(7,9)+')','some('+tree(*self.array)+')').replace('stamps=[1:1:1]','stamps=[1:1:'+str(self.array_changed)+']')
        start=result.index('|resources=')+len('|resources=');end=result.index('|events=');user=result[start:end]
        result=result[:start]+'User={'+user+'};Cargo={next='+str(2 if self.published else 1)+';rows='+('[1:'+tree(7,9)+']' if self.published else '[]')+'}'+result[end:]
        if self.published:result=result.replace('|events=[]','|events=[1]')
        if self.handoff:
            result=result.replace('|registrations=[','|registrations=[6:ReadRecoveredCargo:[RecoveredCargo:read, scalar], 5:PublishRecoveredCargo:[RecoveredCargo:write], 4:ArrayRecovery:[array], ').replace('|nextSystem=4','|nextSystem=7')
        return result
    def runtime(self):
        batches='[(3,[1])]' if self.published else '[]'
        positions='[(1,4,3)]' if self.read_done else '[]'
        statuses='[(1,4,3,0,False)]' if self.read_done else '[]'
        return f'runtime{{tick={self.tick}|'+self.world()+'|state{stream{domain=RecoveredCargo;batches='+batches+';positions='+positions+';statuses='+statuses+';nextReader=2;frameStart=0;boundary=0;capacity=2;dropped=0};owners=Unit;journal='+batches+';journalSize='+str(int(self.published))+';frameStart=0}}'
    def host(self):
        ident=lambda id,name,access:f'namespace=1;id={id};name={name};access=[{access}]'
        return '|target=1:1:0|runtime='+self.runtime()+'|schedule='+self.owners()+'|recovery=recovery{'+ident(4,'ArrayRecovery','array')+f';cursor={self.recovery_cursor};capture=Unit}}|publisher=publisher{{'+ident(5,'PublishRecoveredCargo','RecoveredCargo:write')+';cursor=0}|reader=reader{namespace=1;id=1;registryId=6}|registry=readerRegistry{'+ident(6,'ReadRecoveredCargo','RecoveredCargo:read, scalar')+f';cursor={5 if self.read_done else 0}}}|scratch='+tree(*self.scratch)+'|records='+self.records+'|output=none|returned=[]|loose='+self.loose+'|history='+listing(self.history)+'|readings='+('[16]' if self.read_done else '[]')+'|values='+('[11]' if self.read_done else '[]')+'|lagged=False|status='+self.status
    def inspect_status(self):return 'inspector:cursor=0;arrays=Found([70, 90]):added=True:changed=True;scalar=Found('+str(self.scalar)+'):added=True:changed=True;counter=[21, 22]'
def values():
    s=State();lines=[];snapshots=[]
    def world(label):
        import copy
        snapshots.append((label,copy.deepcopy(s)))
        lines.append(label+'|world='+s.world()+'\n')
    def snap(label):
        import copy
        snapshots.append((label,copy.deepcopy(s)))
        lines.append(label+s.host()+'\n')
    world('created');s.reserved=True;world('bundle-committed-before-flush');s.seed();world('explicit-flush');s.registered=True;s.handoff=True;snap('handoff-registered')
    s.tick+=1;s.clock+=1;s.records='cons({handle=1:1:0;stamp=1:3;payload=some('+tree(70,90)+')},[])';s.loose='none';s.status='Failure';snap('recovery-failed-after')
    s.records='[]';s.loose='some('+tree(70,90)+')';s.history.append('1:1:0:1:3');snap('replacement-withdrawn')
    s.tick+=1;s.clock+=1;s.array=(70,90);s.array_changed=s.clock;s.recovery_cursor=s.clock;s.records='cons({handle=1:1:0;stamp=1:1;payload=some('+tree(7,9)+')},[])';s.loose='none';s.status='Success';snap('recovery-retry-after')
    s.records='[]';s.loose='some('+tree(7,9)+')';s.history.append('1:1:0:1:1');snap('original-withdrawn')
    s.tick+=1;s.published=True;s.loose='none';s.status='publication:Success';snap('publication-after');snap('reader-before')
    s.tick+=1;s.clock+=1;s.scalar+=16;s.changed=s.clock;s.read_done=True;s.scratch=(17,18);s.status='reader:Success';snap('reader-after')
    for label,allowed in [('first',True),('second',False),('third',True)]:
        s.allow=allowed;snap(label+'-before');s.tick+=1;s.run();s.status='Finished:'+listing(['ran:3','phase:AuditCapturedPipeline','ran:1' if allowed else 'skipped:1','barrier','ran:2','barrier']);snap(label+'-after')
        for suffix in ['-inspect','-repeated-inspect']:
            s.tick+=1;s.status=s.inspect_status();snap(label+suffix)
    return snapshots,(''.join(lines)+'\n').encode()
def render():
    return values()[1]


def selftest():
    snapshots,raw=values()
    rows=dict(snapshots)
    assert len(snapshots)==23
    assert 'pending=2|pendingKinds=Raw;Raw;end|' in rows['bundle-committed-before-flush'].world()
    assert 'pending=0|pendingKinds=end|' in rows['third-repeated-inspect'].world()
    assert raw.endswith(b'\n\n') and raw.count(b'\n')==24
    assert rows['created'].clock==0 and not rows['created'].reserved
    assert 'slots=leaf:0:Consumed;free=[];order=[]' in rows['created'].world()
    assert 'slots=node(leaf:0:Consumed,leaf:0:Pending);free=[];order=[1:0]' in rows['bundle-committed-before-flush'].world()
    assert 'slots=node(leaf:0:Consumed,leaf:0:Live);free=[];order=[1:0]' in rows['explicit-flush'].world()
    failed=rows['recovery-failed-after']
    assert failed.clock==3 and failed.tick==1 and failed.array==(7,9) and failed.array_changed==1
    assert failed.recovery_cursor==0 and failed.records=='cons({handle=1:1:0;stamp=1:3;payload=some('+tree(70,90)+')},[])'
    withdrawn=rows['replacement-withdrawn']
    assert withdrawn.loose=='some('+tree(70,90)+')' and withdrawn.history==['1:1:0:1:3']
    retried=rows['recovery-retry-after']
    assert retried.clock==4 and retried.array==(70,90) and retried.array_changed==4
    assert retried.recovery_cursor==4 and retried.records=='cons({handle=1:1:0;stamp=1:1;payload=some('+tree(7,9)+')},[])'
    assert rows['original-withdrawn'].loose=='some('+tree(7,9)+')'
    assert rows['publication-after'].published and rows['publication-after'].loose=='none'
    read=rows['reader-after']
    assert read.scalar==27 and read.changed==5 and read.scratch==(17,18) and read.tick==4
    assert read.read_done and read.published
    assert (rows['first-after'].scalar,rows['first-after'].clock,rows['first-after'].calls)==(31,6,1)
    assert (rows['second-after'].scalar,rows['second-after'].clock,rows['second-after'].calls)==(31,6,1)
    final=rows['third-repeated-inspect']
    assert (final.scalar,final.clock,final.tick,final.calls)==(35,7,13,2)
    assert final.accumulated==(88,98) and final.resource==(232,332) and final.counter==(21,22)
    assert final.query_cursor==7 and final.field_cursor==6 and final.recovery_cursor==4
    assert final.history==['1:1:0:1:3','1:1:0:1:1'] and final.records=='[]'
    assert 'positions=[(1,4,3)];statuses=[(1,4,3,0,False)]' in final.runtime()
    assert 'Cargo={next=2;rows=[1:'+tree(7,9)+']}' in final.world()
    assert raw.count(b'|target=1:1:0|')==20
    assert sum(label.endswith('inspect') and state.status.startswith('inspector:') for label,state in snapshots)==6
    assert raw.count(b'|status=Finished:')==3
    assert b'calls=leaf:2;values=node(leaf:88,leaf:98)' in raw


if __name__=='__main__':
    import sys
    selftest()
    if '--self-test' not in sys.argv and '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
