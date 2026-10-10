"""Independent finite condition/lazy-reader model, using source only."""
import json
from dataclasses import dataclass, field

def ls(xs): return '[' + ', '.join(xs) + ']'
def boolean(x): return str(x).lower()
@dataclass
class Stream:
    batches: list = field(default_factory=list)
    positions: list = field(default_factory=list)
    dropped: int = 0
    frame_start: int = 0
    def frame(self,tick):
        boundary=min([self.frame_start]+[p[1] for p in self.positions])
        gone=[t for t,_ in self.batches if t<=boundary]
        if gone:self.dropped=max(self.dropped,max(gone))
        self.batches=[(t,v) for t,v in self.batches if t>boundary]
        self.frame_start=tick
    def skip(self,id,tick):
        self.positions=[(i,tick if i==id else c,r) for i,c,r in self.positions]
    def read(self,id,tick):
        old=next((p for p in self.positions if p[0]==id),None)
        cursor=old[1] if old else 0
        registered=old[2] if old else tick
        values=[v for t,v in self.batches if t>cursor]
        lagged=max(cursor,registered)<self.dropped
        if old is None:self.positions.insert(0,(id,0,tick))
        return values,lagged
    def show(self):
        return 'batches='+ls([str(t)+':'+ls([v]) for t,v in self.batches])+',positions='+ls([f'{i}:{c}:{r}' for i,c,r in self.positions])+f',dropped={self.dropped},frameStart={self.frame_start}'
@dataclass
class App:
    flow: str='Play'
    pending: str='Boot:false'
    previous: str='Boot'
    changed: bool=True
    fs: Stream=field(default_factory=lambda:Stream([(1,'Boot>Play')]))
    levels: Stream=field(default_factory=Stream)
    tick:int=1
    frame:int=0
    queued:bool=True
    deliveries:list=field(default_factory=list)
    observations:list=field(default_factory=list)
    status:str='ready'
    def run(self):
        self.fs.frame(self.tick); self.levels.frame(self.tick)
        self.frame+=1; self.changed=False
        self.observations=[]; self.status='finished'
        for id,name,allowed in [(1,'fast',self.flow=='Play'),(2,'slow',self.flow!='Play')]:
            if not allowed:
                self.fs.skip(id,self.tick);self.levels.skip(id,self.tick)
                self.observations.append('skipped:'+str(id)); continue
            fv,fl=self.fs.read(id,self.tick);lv,ll=self.levels.read(id,self.tick)
            self.tick+=1 # reader provider pulse, not component clock
            self.fs.skip(id,self.tick);self.levels.skip(id,self.tick)
            self.deliveries.append(name+':flow='+ls(fv)+'/level='+ls(lv)+'/lagged='+boolean(fl)+','+boolean(ll)+':ok')
            self.observations.append('ran:'+str(id))
    def marker(self):
        self.queued=False # leading ordinary Barrier activates/populates reserved entity
        self.tick+=1
        old=self.flow;self.flow='Boot';self.pending='none';self.previous=old;self.changed=True
        self.fs.batches.append((self.tick,old+'>'+self.flow))
    def show(self):
        stamps='[]' if self.queued else '[1:1:1]'
        cells='[none]' if self.queued else '[[10, 99]]'
        live='[false, false]' if self.queued else '[false, true]'
        physical_live='N(L(False),L(False))' if self.queued else 'N(L(False),L(True))'
        physical_cells='L(none)' if self.queued else 'L(some:N(L(10),L(99)))'
        access='[transition.Flow.read, transition.Level.read]'
        world=('ns=1;next=2;high=1;capacity=2;depth=1;live='+live+';cells='+cells+':stamps='+stamps
               +';owned=[30, 130];flow='+self.flow+'(pending='+self.pending+',previous='+self.previous+',changed='+boolean(self.changed)+')'
               +';level=0(pending=none,previous=none,changed=false);flowStream='+self.fs.show()+';levelStream='+self.levels.show()
               +f';frame={self.frame};tick={self.tick};hooks=[];queue={int(self.queued)};registrations=[2:slow:'+access+', 1:fast:'+access+']'
               +f';nextSystem=3;componentClock={int(not self.queued)};busEvents=0')
        physical='live='+physical_live+'/cells='+physical_cells+':stamps='+stamps+'/owned=N(L(30),L(130))/bus=[]'
        return world+'/physical='+physical+'/fast=1:1:fast:'+access+':cursor=0:flow=1:1:level=1:1/slow=1:2:slow:'+access+':cursor=0:flow=1:2:level=1:2/owners=N(L(43),L(59))/deliveries='+ls(self.deliveries)+'/observations='+ls(self.observations)+'/status='+self.status

def render():
    app=App(); rows=['initial:'+app.show()]
    app.run();rows.append('readers-register:'+app.show())
    app.marker();app.run();rows.append('skipped-backlog:'+app.show())
    app.run();rows.append('repeat-empty:'+app.show())
    return (json.dumps('\n'.join(rows)+'\n')+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render())
