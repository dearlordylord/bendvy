"""Independent finite reader-query model, never reads backend/golden output."""
from pathlib import Path
from copy import deepcopy
import hashlib,json,gzip
HERE=Path(__file__).resolve().parent

def show(xs,f=str):return '['+', '.join(f(x) for x in xs)+']'
def items(xs,f=str):return ''.join(f(x)+';' for x in xs)+'[]'
def tree(xs):
    if len(xs)==1:return 'L('+str(xs[0])+')'
    n=len(xs)//2
    return 'N('+tree(xs[:n])+','+tree(xs[n:])+')'
def tup(xs):return '('+','.join(map(str,xs))+')'
def obs(o):return f'observation(projection=({o[0]},[90, 91]),entered={tree([o[1],100])})'
def publication(p):
    family,key=p
    inner=lambda a,b:f'Pub(first={show(a)},second={show(b)})'
    return inner([key],[]) if family==0 else f'Pub(first=[],second=[{inner([key],[]) if family==1 else inner([],[key])}])'
def batch(b,f=str):return f'({b[0]},{show(b[1],f)})'

class Model:
    def __init__(self,ns,foreign):
        self.ns=ns;self.foreign=foreign;self.tick=0;self.clock=2;self.values=[10,20];self.stamps=[[1,1],[2,2]]
        self.user=[100,101];self.logs=[[],[],[]];self.events=[];self.batches=[[],[],[]];self.journal=[]
        self.position=None;self.registry=0;self.scratch=[1,2];self.fail=0;self.observations=[];self.traces=[]
    def access(self):return ['Cargo:read','Value','Counter']
    def pub_access(self):return ['Cargo:write','Alerts:write','Crates:write']
    def column(self,foreign=False):
        values=[] if foreign else self.values
        return ''.join(f'row{i}='+('Some('+str(values[i-1])+')' if i<=len(values) else 'None')+'@'+tup([0,0] if foreign or i>2 else self.stamps[i-1])+';' for i in range(1,5))
    def world(self,foreign=False):
        ns=self.foreign if foreign else self.ns
        logs=[[],[],[]] if foreign else self.logs
        texts=[]
        for family,rows in enumerate(logs):
            render=lambda r:str(r[0])+':'+(f'N(L({tree(r[1][0])}),L({tree(r[1][1])}))' if family==2 else tree(r[1]))
            texts.append(f'{["Cargo","Alerts","Crates"][family]}=log(next={len(rows)+1},rows={items(rows,render)})')
        user=[100,101] if foreign else self.user
        regs=[] if foreign else [(2,'read-cargo-with-query',self.access()),(1,'empty-world-publisher',self.pub_access())]
        meta=lambda r:f'({r[0]},{r[1]},{show(r[2])})'
        return f'world(ns={ns},next={1 if foreign else 4},high={0 if foreign else 3},live={"L(False)" if foreign else "N(N(L(False),L(True)),N(L(True),L(True)))"},capacity={1 if foreign else 4},depth={0 if foreign else 2},column={{{self.column(foreign)}}},user={tree(user)},{",".join(texts)},events={show([] if foreign else self.events,publication)},pending=0,regs={show(regs,meta)},sid={1 if foreign else 3},clock={0 if foreign else self.clock})'
    def stream(self,family,foreign=False):
        batches=[] if foreign else self.batches[family];p=None if foreign or family else self.position
        positions=[] if p is None else [p]
        unread=0 if p is None else sum(len(ids) for t,ids in batches if t>p[1])
        statuses=[] if p is None else [p+[unread,'False']]
        return f'stream(domain={["Cargo","Alerts","Crates"][family]},batches={show(batches,batch)},positions={show(positions,tup)},statuses={show(statuses,tup)},next={2 if family==0 and not foreign else 1},frameStart=0,boundary=0,capacity=2,dropped=0)'
    def runtime(self,foreign=False):
        return f'runtime(tick={0 if foreign else self.tick},{self.world(foreign)},state('+','.join(f'{name}={self.stream(i,foreign)}' for i,name in enumerate(['Cargo','Alerts','Crates']))+f',owners=Unit,journal={show([] if foreign else self.journal,lambda b:batch(b,publication))},journalSize={0 if foreign else len(self.events)},frameStart=0))'
    def snapshot(self,label):
        self.traces.append(dict(label=label,tick=self.tick,clock=self.clock,values=self.values[:],stamps=deepcopy(self.stamps),user=self.user[:],position=deepcopy(self.position),registry=self.registry,scratch=self.scratch[:],fail=self.fail,observations=deepcopy(self.observations),logCounts=list(map(len,self.logs))))
        return label+'|'+self.runtime()+'|foreign='+self.runtime(True)+f'|publisher=publisher(ns={self.ns},id=1,name=empty-world-publisher,access={show(self.pub_access())},cursor=0)|reader=({self.ns},1,2)|registry(ns={self.ns},id=2,name=read-cargo-with-query,access={show(self.access())},cursor={self.registry})|args(delta=1,failValue={self.fail},scratch={tree(self.scratch)})|observations='+items(self.observations,obs)
    def publish(self):
        self.tick+=1;published=[]
        for family,payload in [(0,[900,7]),(1,[1000,7]),(0,[901,7]),(2,[[900,7],[902,7]])]:
            key=len(self.logs[family])+1;self.logs[family].append((key,payload));published.append((family,key))
        self.events.extend(published);self.journal.append((self.tick,published))
        for family in range(3):self.batches[family].append((self.tick,[k for f,k in published if f==family]))
        return 'published:7:recovery(Cargo=[],Alerts=[],Crates=[])\n'
    def read(self,fail=0,foreign=False):
        if foreign:return f'rejected:{self.registry}\n'
        self.fail=fail;old_tick=self.tick;self.tick+=1
        if self.position is None:self.position=[1,0,old_tick]
        keys=[k for t,ids in self.batches[0] if t>self.position[1] for k in ids]
        before=deepcopy((self.values,self.stamps,self.user));newobs=[];out=[];failed=False
        for key in keys:
            projection=self.logs[0][key-1][1][0];entered=0
            for i in range(2):
                old=self.values[i];counter=self.user[0];self.clock+=1;self.values[i]=old+1;self.stamps[i][1]=self.clock;self.user=[counter+1,counter+2]
                entered+=1;self.scratch[0]+=1;out.append(old)
                if old==fail:failed=True;break
            newobs.append([projection,entered])
            if failed:break
        self.observations.extend(newobs)
        if failed:self.values,self.stamps,self.user=before;out=[]
        else:self.position[1]=self.tick;self.registry=self.clock
        return ('query-failed-at='+str(fail) if failed else 'success')+':lag=False:values='+show(out)+'\n'

def derive():
    output=[];traces=[]
    for name,ns,foreign in [('Workshop',1,2),('Garden',3,4)]:
        m=Model(ns,foreign);output.append(name+'\n');output.append(m.snapshot('registered'))
        for label,operation in [('empty',lambda:m.read()),('publish1',m.publish),('committed',lambda:m.read()),('publish2',m.publish),('latefailed',lambda:m.read(23)),('retry',lambda:m.read()),('nochange',lambda:m.read()),('foreign',lambda:m.read(foreign=True))]:
            output.extend([operation(),m.snapshot(label)])
        output.append('returned-observations:'+items(m.observations,obs)+'\n');traces.append(m.traces)
    return (''.join(output)+'\n').encode(),traces
if __name__=='__main__':
    raw,states=derive();(HERE/'expected.stdout').write_bytes(raw);z=gzip.compress(raw,mtime=0);(HERE/'expected.stdout.gz').write_bytes(z);(HERE/'states.json').write_text(json.dumps(states,indent=2)+'\n');print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'gzip_bytes':len(z),'gzip_sha256':hashlib.sha256(z).hexdigest()}))
