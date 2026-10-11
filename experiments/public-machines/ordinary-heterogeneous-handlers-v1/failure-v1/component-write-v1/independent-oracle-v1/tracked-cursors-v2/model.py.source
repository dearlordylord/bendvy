"""Finite source-derived execution/serializer; no Bend runtime output input."""
import json

def ls(xs): return '[' + ', '.join(map(str,xs)) + ']'
def arr(a,b): return f'node(leaf:{a},leaf:{b})'
def slot(current,pending='None',previous='None',changed=False):
    return f'{current}:pending={pending}:previous={previous}:changed={str(changed)}'
class Model:
    def __init__(self):
        self.owned=11; self.locals=[0]*6; self.pending=1; self.applied=0
        self.first=slot('Cold'); self.second=slot('Idle')
        self.ticks=[0,0]; self.batches=[[],[]]; self.positions=[[],[]]
        self.delivered=[[],[]]; self.trace=[]; self.statuses=[]
    def barrier(self): self.applied+=self.pending; self.pending=0
    def callback(self,machine,code):
        self.owned+=machine*10+code; self.locals[(machine-1)*3+code-1]+=1
        self.trace.append(f'{machine}:{code}'); self.pending+=1
    def marker(self,machine,first=False):
        self.barrier(); i=machine-1; self.ticks[i]+=1
        if first:
            for code in (1,2,3): self.callback(machine,code)
            if machine==1:
                self.first=slot('Warm','Settled:False','Cold',True); change='Cold>Warm'
            else:
                self.second=slot('Active:7','None','Idle',True); change='Idle>Active:7'
            self.batches[i].append(f'{self.ticks[i]}:'+ls([change]))
        elif machine==1:
            self.first=slot('Settled','None','Warm',True)
            self.batches[0].append(str(self.ticks[0])+':'+ls(['Warm>Settled']))
        else: self.second=slot('Active:7','None','Idle',False)
        self.statuses.append(('first' if machine==1 else 'second')+':Completed')
    def read(self,machine):
        i=machine-1; self.positions[i]=[f'1:{self.ticks[i]}:{self.ticks[i]}']
        self.delivered[i]=['Cold>Warm' if machine==1 else 'Idle>Active:7']
        self.statuses.append(('first' if machine==1 else 'second')+'-reader:Completed')
    def stream(self,i):
        return 'batches='+ls(self.batches[i])+':positions='+ls(self.positions[i])+':dropped=0:frameStart=0'
    def bundle(self,m):
        kinds=['exit:Cold','transition:Cold>Warm','enter:Warm'] if m==1 else ['exit:Idle','transition:Idle>Active:7','enter:Active:7']
        prefix='first' if m==1 else 'second'; entries=[]
        for code,kind in enumerate(kinds,1):
            ordinal=(m-1)*3+code; name=prefix+'-'+['exit','transition','enter'][code-1]
            entries.append(f'{kind}:needs=[1, 2, 1]:entry={ordinal}:registry=1:{ordinal}:{name}:[owned:write, Local:write, deferred:write]:cursor=0')
        return '1:'+ls(entries)
    def snapshot(self,label):
        resources='owned='+arr(self.owned,12)+'|sibling='+arr(21,22)+'|first={'+self.first+'}|second={'+self.second+'}|firstStream={'+self.stream(0)+'}|secondStream={'+self.stream(1)+'}|firstReader=1:1|secondReader=1:1|locals='+ls([f'1:{i+1}:'+arr(n,i+1) for i,n in enumerate(self.locals)])+'|firstTick='+str(self.ticks[0])+'|secondTick='+str(self.ticks[1])+'|trace='+ls(self.trace)+'|firstDelivered='+ls(self.delivered[0])+'|secondDelivered='+ls(self.delivered[1])+'|applied='+str(self.applied)
        names=['first-exit','first-transition','first-enter','second-exit','second-transition','second-enter','first-reader','second-reader']
        registrations=ls([f'{i}:{names[i-1]}:'+('[owned:write, Local:write, deferred:write]' if i<7 else ('[first-stream:read]' if i==7 else '[second-stream:read]')) for i in range(8,0,-1)])
        store='first=Column{values=leaf:some('+arr(31,32)+');stamps=[]}|sibling=Column{values=leaf:some('+arr(41,42)+');stamps=[]}'
        world='ns=1|next=2|high=1|live=node(leaf:False,leaf:True)|capacity=2|depth=1|store={'+store+'}|resources={'+resources+'}|events='+ls(self.trace)+'|pending='+str(self.pending)+'|registrations='+registrations+'|nextSystem=9|clock=0'
        return label+':world={'+world+'}|firstBundle='+self.bundle(1)+'|secondBundle='+self.bundle(2)+'|firstReaderRegistry=1:7:first-reader:[first-stream:read]:cursor=0|secondReaderRegistry=1:8:second-reader:[second-stream:read]:cursor=0|statuses='+ls(self.statuses)
class FailureModel(Model):
    def __init__(self):
        super().__init__(); self.registered=[None,None]
    def failed_marker(self):
        self.barrier(); self.ticks[0]+=1
        self.callback(1,1)
        # Local touch occurs before Tx.begin; failed Tx undo owns only head/trace.
        self.locals[1]+=1
        old_head,old_trace=self.owned,self.trace[:]
        self.owned+=12; self.trace.append('1:2')
        self.owned,self.trace=old_head,old_trace
        self.first=slot('Cold','Warm:False','Cold',False)
        self.statuses.append('first:Failed:transition:transition-first-attempt')
    def read(self,machine):
        i=machine-1
        if self.registered[i] is None: self.registered[i]=self.ticks[i]
        self.positions[i]=[f'1:{self.ticks[i]}:{self.registered[i]}']
        if self.batches[i]: self.delivered[i].append('Cold>Warm' if machine==1 else 'Idle>Active:7')
        self.statuses.append(('first' if machine==1 else 'second')+'-reader:Completed')
class ComponentModel(FailureModel):
    def __init__(self):
        super().__init__(); self.cells=31; self.changed=0; self.clock=0; self.cursors=[0]*8
    def column(self):
        stamps=[] if self.clock==0 else ['1:0:'+str(self.changed)]
        return 'Column{values=leaf:some('+arr(self.cells,32)+');stamps='+ls(stamps)+'}'
    def write(self,value):
        self.clock+=1; self.cells=value; self.changed=self.clock
    def callback(self,machine,code):
        super().callback(machine,code); self.write(machine*10+code)
        self.cursors[(machine-1)*3+code-1]=self.clock
    def failed_marker(self):
        self.barrier(); self.ticks[0]+=1; self.callback(1,1)
        self.locals[1]+=1
        # Failed resource and component writes undo payload/stamp, not Local or clock.
        old_cells,old_stamp=self.cells,self.changed
        self.write(12)
        tentative='tentativeCells='+self.column()+'|clock='+str(self.clock)
        self.cells,self.changed=old_cells,old_stamp
        self.first=slot('Cold','Warm:False','Cold',False)
        self.statuses.append('first:Failed:transition:transition-first-attempt|'+tentative)
    def read(self,machine):
        super().read(machine); self.cursors[5+machine]=self.clock
    def snapshot(self,label):
        text=super().snapshot(label)
        text=text.replace('Column{values=leaf:some('+arr(31,32)+');stamps=[]}',self.column(),1)
        text=text.replace('|clock=0}', '|clock='+str(self.clock)+'}',1)
        names=['first-exit','first-transition','first-enter','second-exit','second-transition','second-enter','first-reader','second-reader']
        for i,name in enumerate(names):
            access='owned:write, Local:write, deferred:write' if i<6 else ('first-stream:read' if i==6 else 'second-stream:read')
            old=f'1:{i+1}:{name}:[{access}]:cursor=0'
            text=text.replace(old,f'1:{i+1}:{name}:[{access}]:cursor={self.cursors[i]}')
        return text
def observations():
    m=ComponentModel(); out=[m.snapshot('before')]
    m.first=slot('Cold','Warm:False'); m.second=slot('Idle','Active:7:False'); out.append(m.snapshot('queued'))
    m.failed_marker(); out.append(m.snapshot('first-failure'))
    assert (m.owned,m.applied,m.pending,m.locals)==(22,1,1,[1,1,0,0,0,0])
    assert m.trace==['1:1'] and m.batches==[[],[]]
    m.read(1); out.append(m.snapshot('first-reader-before-retry')); assert m.delivered[0]==[]
    m.marker(1,True); out.append(m.snapshot('first-retry'))
    assert (m.owned,m.applied,m.pending,m.locals[:3])==(58,2,3,[2,2,1])
    m.marker(2,True); out.append(m.snapshot('second-marker')); assert (m.owned,m.applied,m.pending)==(124,5,3)
    m.read(1); out.append(m.snapshot('first-reader')); assert m.positions[0]==['1:2:1']
    m.read(2); out.append(m.snapshot('second-reader'))
    m.marker(1); out.append(m.snapshot('later-first-marker')); assert (m.owned,m.applied,m.pending)==(124,8,0)
    m.marker(2); out.append(m.snapshot('later-second-marker')); assert m.locals==[2,2,1,1,1,1]
    out.append('Factory:2'); return out
def expected(): return (json.dumps(observations(),ensure_ascii=False)+'\n').encode()
if __name__=='__main__':
    import hashlib
    raw=expected(); print(json.dumps({'observations':len(observations()),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}))
