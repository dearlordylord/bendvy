#!/usr/bin/env python3
"""Source-only public TS actual-operation model; no Node/backend invocation."""
import copy
import gzip
import hashlib
import json
import re
from pathlib import Path
import sys
HERE=Path(__file__).resolve().parent
j=lambda v:json.dumps(v,separators=(',',':'))
SCOPE='Public actual-operation shared scenario; backend-specific complete debug retained, no affine/clock equality claim'

def failures():
    return [{'operation':'relate','relation':'Parent','source':1,'target':target,'error':({'_tag':'SelfRelationNotAllowed','entityId':1,'relation':'Parent'} if target==1 else {'_tag':'MissingTargetEntity','entityId':1,'targetId':3,'relation':'Parent'})} for target in [1,3]]

class Model:
    def __init__(self,root):
        self.root=root;self.tick=0;self.frame=0;self.frame_start=0;self.boundary=0
        self.entities={};self.marks={};self.readers={};self.removed=[];self.logs={'Ping':[],'Parent':[]}
        self.dropped={'Ping':0,'Parent':0};self.edge=False;self.pending=[];self.timeline=[]
    def advance(self):self.tick+=1;return self.tick
    def start_frame(self):
        self.frame+=1
        if self.frame_start>0:self.boundary=self.frame_start
        self.frame_start=self.tick
        for key in self.logs:
            hold=min([self.boundary]+[r['streamLastRun'] for r in self.readers.values()])
            while self.logs[key] and self.logs[key][0][0]<=hold:
                tick,_=self.logs[key].pop(0);self.dropped[key]=max(self.dropped[key],tick)
        hold=min([self.boundary]+[r['lastRun'] for r in self.readers.values()])
        self.removed=[(tick,id) for tick,id in self.removed if tick>hold]
    def run_writer(self,kind):
        self.advance()
        commands={'seed':['spawn','spawn'],'remove-target':['remove'],'reinsert-target':['insert'],'successful-link':['relate'],'spawn-doomed':['spawn'],'despawn-doomed':['despawn'],'writer-queued':['relate','relate']}[kind]
        self.pending=[{'tag':tag,'system':'writer' if kind=='writer-queued' else kind} for tag in commands]
        if kind=='writer-queued':self.logs['Ping'].append((self.advance(),[31,32]))
    def flush(self,kind):
        self.advance()
        if kind=='seed':self.entities={1:42,2:43};self.marks={1:(self.tick,self.tick),2:(self.tick,self.tick)}
        elif kind=='remove-target':self.entities[2]=None;self.removed.append((self.tick,2))
        elif kind=='reinsert-target':self.entities[2]=44;self.marks[2]=(self.tick,self.tick)
        elif kind=='successful-link':self.edge=True
        elif kind=='spawn-doomed':self.entities[3]=None
        elif kind=='despawn-doomed':del self.entities[3]
        elif kind=='writer-published':
            for f in failures():self.logs['Parent'].append((self.tick,[f]))
        else:raise AssertionError(kind)
        self.pending=[]
    def values(self,key,since):return [copy.deepcopy(v) for tick,values in self.logs[key] if tick>since for v in values]
    def read(self,name,phase,fail=False,skip=False):
        if skip:
            assert name in self.readers
            self.readers[name]['streamLastRun']=self.tick
            return None
        if name not in self.readers:self.readers[name]={'lastRun':0,'streamLastRun':0,'registeredAt':self.tick}
        reader=self.readers[name];since=reader['lastRun'];stream_since=reader['streamLastRun'];this_run=self.advance()
        present=[id for id,value in sorted(self.entities.items()) if value is not None]
        result={'phase':phase,'reader':name,'rows':[{'id':id,'payload':self.entities[id]} for id in present],
                'added':[id for id in present if self.marks[id][0]>since], 'changed':[id for id in present if self.marks[id][1]>since],
                'removed':[id for tick,id in self.removed if tick>since], 'events':self.values('Ping',stream_since),
                'eventLag':self.dropped['Ping']>max(stream_since,reader['registeredAt']), 'failures':self.values('Parent',stream_since),
                'relationLag':self.dropped['Parent']>max(stream_since,reader['registeredAt'])}
        if not fail:reader['lastRun']=reader['streamLastRun']=this_run
        # attempted999 is buffered then erased by rollback; it never appends a batch or advances publish tick.
        return result
    def streams(self):
        if not self.readers and not any(self.logs.values()):return []
        result=[]
        for key,kind in [('Ping','event'),('Parent','relationFailure')]:
            log=self.logs[key];readers=[]
            for name,reader in self.readers.items():
                readers.append({'system':name,'unread':len(self.values(key,reader['streamLastRun'])),'lagged':self.dropped[key]>max(reader['streamLastRun'],reader['registeredAt'])})
            entry={'kind':kind,'stream':key,'size':sum(len(values) for _,values in log),'capacity':65536,'readers':readers}
            if log:
                name,holder=min(self.readers.items(),key=lambda pair:pair[1]['streamLastRun'])
                if log[0][0]<=self.boundary and holder['streamLastRun']<log[0][0]:entry['heldBy']=name
            result.append(entry)
        return result
    def world(self):
        return {'version':1,'frame':self.frame,'tick':self.tick,'entityCount':len(self.entities),
                'entities':[{'id':id,'components':{} if value is None else {'Stock':value},'relations':{'Parent':2} if id==1 and self.edge else {}} for id,value in sorted(self.entities.items())],
                'resources':{},'machines':{},'pendingCommands':copy.deepcopy(self.pending)}
    def capture(self,phase,deliveries,ok=True):
        self.timeline.append({'phase':phase,'tick':self.tick,'frame':self.frame,'boundary':self.boundary,'frameStart':self.frame_start,'readerCursors':copy.deepcopy(self.readers)})
        return {'root':self.root,'phase':phase,'operation':phase,'ok':ok,'deliveries':deliveries,'world':self.world(),'streams':self.streams()}
    def run(self):
        output=[]
        writer_phases=['seed','remove-target','reinsert-target','successful-link','spawn-doomed','despawn-doomed','writer-queued']
        phases=['seed','warm-readers','remove-target','read-removed','reinsert-target','read-reinserted','successful-link','spawn-doomed','despawn-doomed','writer-queued','writer-published','fast-active-skip','slow-failed','slow-retry','fast-success','fast-repeat','slow-repeat']
        for phase in phases:
            self.start_frame();deliveries=[]
            if phase in writer_phases:
                self.run_writer(phase)
                if phase!='writer-queued':self.flush(phase)
            elif phase=='writer-published':self.flush(phase)
            elif phase in ['warm-readers','read-removed','read-reinserted']:
                deliveries=[self.read(name,phase) for name in ['fast','slow']]
            elif phase=='fast-active-skip':assert self.read('fast',phase,skip=True) is None
            else:
                name='slow' if phase in ['slow-failed','slow-retry','slow-repeat'] else 'fast'
                deliveries=[self.read(name,phase,fail=phase=='slow-failed')]
            output.append(self.capture(phase,deliveries,phase!='slow-failed'))
        assert self.tick==26 and self.frame==17
        assert output[1]['deliveries'][0]['added']==output[1]['deliveries'][1]['added']==[1,2]
        assert output[3]['deliveries'][0]['removed']==output[3]['deliveries'][1]['removed']==[2]
        assert output[5]['deliveries'][0]['added']==output[5]['deliveries'][1]['changed']==[2]
        assert output[12]['deliveries'][0]['events']==output[13]['deliveries'][0]['events']==[31,32]
        assert output[12]['deliveries'][0]['failures']==output[13]['deliveries'][0]['failures']==failures()
        assert output[14]['deliveries'][0]['events']==output[14]['deliveries'][0]['failures']==[]
        assert all(x['world']['entities'][0]['relations']=={'Parent':2} for x in output[6:])
        assert not any(999 in d['events'] for x in output for d in x['deliveries'])
        assert output[-1]['streams'][0]['size']==output[-1]['streams'][1]['size']==0
        return output

def derive():
    output=[];timelines=[]
    for root in ['ReadersAlpha','ReadersBeta']:
        model=Model(root);output.extend(model.run());timelines.append({'root':root,'timeline':model.timeline})
    result={'scope':SCOPE,'observations':output}
    return (j(result)+'\n').encode(),timelines
if __name__=='__main__':
    pins=json.loads((HERE/'ts-source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    source=Path('/tmp/bendvy43-scheduled-matched-ts-oracle-source02/adapter.mjs').read_text()
    assert re.findall(r"^  (?:enabled=false;|failSlow=true;|failSlow=false;|enabled=true;)?step\('([^']+)'",source,re.M)==['seed','warm-readers','remove-target','read-removed','reinsert-target','read-reinserted','successful-link','spawn-doomed','despawn-doomed','writer-queued','writer-published','fast-active-skip','slow-failed','slow-retry','fast-success','fast-repeat','slow-repeat']
    assert "commands.relate(source,Parent,target)" in source
    assert "ctx.events.attempted.emit(999);return Fx.fail(77)" in source
    assert "for (const root of ['ReadersAlpha','ReadersBeta'])" in source
    assert source.endswith('console.log(JSON.stringify({scope:'+repr(SCOPE)+',observations}));\n')
    wire,timelines=derive()
    if '--write' in sys.argv:
        (HERE/'ts.expected.stdout').write_bytes(wire);(HERE/'ts.expected.stdout.gz').write_bytes(gzip.compress(wire,mtime=0))
        (HERE/'ts.timeline.json').write_text(json.dumps(timelines,indent=2)+'\n')
    else:
        assert (HERE/'ts.expected.stdout').read_bytes()==wire
        assert gzip.decompress((HERE/'ts.expected.stdout.gz').read_bytes())==wire
        assert json.loads((HERE/'ts.timeline.json').read_text())==timelines
    print(j({'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'sourcePins':len(pins),'observations':34,'invariants':'passed'}))
