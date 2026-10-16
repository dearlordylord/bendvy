"""Independent sequential owner-handoff model; no backend output inputs."""
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
        return '|target=1:1|runtime='+self.runtime()+'|schedule='+self.owners()+'|recovery=recovery{'+ident(4,'ArrayRecovery','array')+f';cursor={self.recovery_cursor};capture=Unit}}|publisher=publisher{{'+ident(5,'PublishRecoveredCargo','RecoveredCargo:write')+';cursor=0}|reader=reader{namespace=1;id=1;registryId=6}|registry=readerRegistry{'+ident(6,'ReadRecoveredCargo','RecoveredCargo:read, scalar')+f';cursor={5 if self.read_done else 0}}}|scratch='+tree(*self.scratch)+'|records='+self.records+'|output=none|returned=[]|loose='+self.loose+'|history='+listing(self.history)+'|readings='+('[16]' if self.read_done else '[]')+'|values='+('[11]' if self.read_done else '[]')+'|lagged=False|status='+self.status
    def inspect_status(self):return 'inspector:cursor=0;arrays=Found([70, 90]):added=True:changed=True;scalar=Found('+str(self.scalar)+'):added=True:changed=True;counter=[21, 22]'
def render():
    s=State();lines=[]
    def world(label):lines.append(label+'|world='+s.world()+'\n')
    def snap(label):lines.append(label+s.host()+'\n')
    world('created');s.reserved=True;world('bundle-committed-before-flush');s.seed();world('explicit-flush');s.registered=True;s.handoff=True;snap('handoff-registered')
    s.tick+=1;s.clock+=1;s.records='cons({handle=1:1;stamp=1:3;payload=some('+tree(70,90)+')},[])';s.loose='none';s.status='Failure';snap('recovery-failed-after')
    s.records='[]';s.loose='some('+tree(70,90)+')';s.history.append('1:1:1:3');snap('replacement-withdrawn')
    s.tick+=1;s.clock+=1;s.array=(70,90);s.array_changed=s.clock;s.recovery_cursor=s.clock;s.records='cons({handle=1:1;stamp=1:1;payload=some('+tree(7,9)+')},[])';s.loose='none';s.status='Success';snap('recovery-retry-after')
    s.records='[]';s.loose='some('+tree(7,9)+')';s.history.append('1:1:1:1');snap('original-withdrawn')
    s.tick+=1;s.published=True;s.loose='none';s.status='publication:Success';snap('publication-after');snap('reader-before')
    s.tick+=1;s.clock+=1;s.scalar+=16;s.changed=s.clock;s.read_done=True;s.scratch=(17,18);s.status='reader:Success';snap('reader-after')
    for label,allowed in [('first',True),('second',False),('third',True)]:
        s.allow=allowed;snap(label+'-before');s.tick+=1;s.run();s.status='Finished:'+listing(['ran:3','phase:AuditCapturedPipeline','ran:1' if allowed else 'skipped:1','barrier','ran:2','barrier']);snap(label+'-after')
        for suffix in ['-inspect','-repeated-inspect']:
            s.tick+=1;s.status=s.inspect_status();snap(label+suffix)
    return (''.join(lines)+'\n').encode()
def selftest():
    raw=render();assert raw.endswith(b'\n\n');assert raw.count(b'\n')==24
    assert b'calls=leaf:2;values=node(leaf:88,leaf:98)' in raw
    assert b'clock=7' in raw and b'tick=13' in raw
if __name__=='__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:sys.stdout.buffer.write(render())
