"""Independent frozen canonical World pipeline model; no runtime output inputs."""
from dataclasses import dataclass, field

def tree(x):
    return "L("+str(x)+")" if isinstance(x,int) else "N("+tree(x[0])+","+tree(x[1])+")"

def context(n):
    return "factory=identity=constructed-array/decl=FiniteNumber/input=FiniteNumber/rest=N(L(N(L(70),L(71))),L(L(72)))/trail=["+", ".join(["tail"]*n)+"]"

def tail(replacement=False):
    base=51 if replacement else 21
    return tree(((base,base+1),(base+2,base+3)))+"/tag="+("False" if replacement else "True")+"/scalar="+str(61 if replacement else 31)

def raw(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/wire=Number("+str(17 if replacement else 7)+")/fail=False/tail="+tail(replacement)+"/tag-component=Tag/data-component="+str(202 if replacement else 101)

def payload(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/number="+str(17 if replacement else 7)

@dataclass
class State:
    reserved: bool=False
    active: bool=False
    heads: str="null"
    tails: str="null"
    head_stamp: tuple|None=None
    tail_stamp: tuple|None=None
    tags: str="null"
    data: str="null"
    tag_stamp: tuple|None=None
    data_stamp: tuple|None=None
    pending: int=0
    saved: list=field(default_factory=list)
    returned: list=field(default_factory=list)
    clock: int=0
    cursor: int=0
    trail: int=0

    def stage_spawn(self):
        # Construction succeeds before reservation; reserve grows live, stage activation then delivery.
        self.trail+=1;self.reserved=True;self.pending=2;self.cursor=self.clock

    def stage_insert(self):
        self.trail+=1;self.pending=1;self.cursor=self.clock

    def barrier(self,replacement=False):
        self.pending=0;self.active=True
        self.saved.insert(0,(self.heads,self.tails,self.head_stamp or (0,0),self.tail_stamp or (0,0),self.tags,self.data,self.tag_stamp or (0,0),self.data_stamp or (0,0),replacement))
        for which,value in (("head",payload(replacement)),("tail",tail(replacement)),("tag","Tag"),("data",str(202 if replacement else 101))):
            old=getattr(self,which+"_stamp")
            self.clock+=1
            setattr(self,which+"_stamp",((old[0] if old else self.clock),self.clock))
            setattr(self,{"head":"heads","tail":"tails","tag":"tags","data":"data"}[which],value)

    def unwind(self):
        # Recursive install inverse restores tail then head; original stamps, actual displaced owners.
        h,t,hs,ts,g,d,gs,ds,replacement=self.saved.pop(0)
        self.heads=h;self.tails=t;self.head_stamp=hs;self.tail_stamp=ts
        self.tags=g;self.data=d;self.tag_stamp=gs;self.data_stamp=ds
        self.returned.insert(0,raw(replacement))

    def snapshot(self):
        def col(value,stamp):
            stamps="[]" if stamp is None else "[1:"+str(stamp[0])+":"+str(stamp[1])+"]"
            return "{values:"+value+",stamps:"+stamps+"}"
        resource="{returned:"+"".join(x+";" for x in self.returned)+"end,saved:"+str(len(self.saved))+",quarantine:0,errors:0,spare:N(L(70),L(71))}"
        store="{heads:"+col(self.heads,self.head_stamp)+",tails:"+col(self.tails,self.tail_stamp)+",tags:"+col(self.tags,self.tag_stamp)+",data:"+col(self.data,self.data_stamp)+"}"
        live="[False,"+("True" if self.active else "False")+"]" if self.reserved else "False"
        world="{ns:1,next:"+str(2 if self.reserved else 1)+",high:"+str(int(self.reserved))+",cap:"+str(2 if self.reserved else 1)+",depth:"+str(int(self.reserved))+",live:"+live+",store:"+store+",resource:"+resource+",events:[],pending:"+str(self.pending)+",regs:[2:canonical-bundle:[bundle:write], 1:duplicate-bundle:[bundle:write]],system:3,clock:"+str(self.clock)+"}"
        registry="{ns:1,id:2,name:canonical-bundle,access:[bundle:write],cursor:"+str(self.cursor)+"}"
        return "registry="+registry+"|world="+world+"|context="+context(self.trail)

def checkpoints():
    s=State();out=[("initial",s.snapshot())]
    # Invalid finite-number head retains raw; tail constructor still runs and retains all context.
    refused="[Validation($,finite number,Text(bad)), None, None, None]|raw="+tree((11,12))+"/wire=Number(7)/fail=False/tail="+tail()+"/tag-component=Tag/data-component=101|"+s.snapshot()
    s.stage_spawn();out.append(("spawn-queued",s.snapshot()))
    s.barrier();out.append(("installed",s.snapshot()))
    s.stage_insert();out.append(("replacement-queued",s.snapshot()))
    s.barrier(True);out.append(("replaced",s.snapshot()))
    s.unwind();out.append(("restored",s.snapshot()))
    s.unwind();out.append(("cleaned",s.snapshot()))
    return out

def report():
    # Both pinned IO.print effects write raw String bytes plus one LF; no show_val quoting.
    return ("\n".join(label+"="+view for label,view in all_valid_checkpoints())+"\n").encode()


def duplicate_world():
    # Before normal registration, the actual first registry is duplicate-bundle id1.
    world=State().snapshot().split("|world=",1)[1].split("|context=",1)[0]
    return world.replace("regs:[2:canonical-bundle:[bundle:write], 1:duplicate-bundle:[bundle:write]],system:3", "regs:[1:duplicate-bundle:[bundle:write]],system:2")

def duplicate_report():
    extra=tree((91,92))+"/wire=Number(8)/fail=False"
    remaining=tree((11,12))+"/wire=Number(7)/fail=False/tail="+tail()+"/tag-component=Tag/data-component=101"
    initial="duplicate-initial="+duplicate_world()
    refused="duplicate-refused=constructed-array|prepared=[]|raw=duplicate-head="+extra+"/remaining="+remaining+"|context="+context(0)+"|world="+duplicate_world()
    # Validation precedes construction/reservation/queue; the returned Context has no trail.
    normal="\n".join(label+"="+view for label,view in all_valid_checkpoints())
    final="duplicate-owner-final="+extra+"|registry={ns=1,id=1,name=duplicate-bundle,access=[bundle:write],cursor=0}"
    return (initial+"\n"+refused+"\n"+normal+"\n"+final+"\n").encode()


def world_text(s):
    return s.snapshot().split("|world=",1)[1].split("|context=",1)[0]
def duplicate_only_world(s):
    return world_text(s).replace("regs:[2:canonical-bundle:[bundle:write], 1:duplicate-bundle:[bundle:write]],system:3", "regs:[1:duplicate-bundle:[bundle:write]],system:2")
def bypass_report():
    s=State();initial="duplicate-initial="+duplicate_only_world(s)
    # Batch.spawn reserves then stages only activation; duplicate runner never calls BT.finish.
    s.reserved=True;s.pending=1;s.trail=1
    before=duplicate_only_world(s)
    s.active=True;s.pending=0;after=duplicate_only_world(s)
    extra=tree((91,92))+"/wire=Number(8)/fail=False"
    original="duplicate-head="+extra+"/remaining="+raw()
    prepared="[entry{ns=1,id=1,position=1,raw="+original+"};[reservation{ns=1,id=1};[]]]"
    return (initial+"\nbypassed-accepted={ns=1,id=1,spawned=True}|world="+before+"\nbypassed-after-barrier="+after+"|registry={ns=1,id=1,name=duplicate-bundle,access=[bundle:write],cursor=0}|context="+context(1)+"|prepared="+prepared+"\n").encode()

all_valid_checkpoints=checkpoints

"""Independent frozen canonical World pipeline model; no runtime output inputs."""
from dataclasses import dataclass, field

def tree(x):
    return "L("+str(x)+")" if isinstance(x,int) else "N("+tree(x[0])+","+tree(x[1])+")"

def context(n):
    return "factory=identity=constructed-array/decl=FiniteNumber/input=FiniteNumber/rest=N(L(N(L(70),L(71))),L(L(72)))/trail=["+", ".join(["tail"]*n)+"]"

def tail(replacement=False):
    base=51 if replacement else 21
    return tree(((base,base+1),(base+2,base+3)))+"/tag="+("False" if replacement else "True")+"/scalar="+str(61 if replacement else 31)

def raw(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/wire=Number("+str(17 if replacement else 7)+")/fail=False/tail="+tail(replacement)+"/tag-component=Tag/data-component="+str(202 if replacement else 101)

def payload(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/number="+str(17 if replacement else 7)

@dataclass
class EntityState:
    reserved: bool=False
    active: bool=False
    heads: str="null"
    tails: str="null"
    head_stamp: tuple|None=None
    tail_stamp: tuple|None=None
    tags: str="null"
    data: str="null"
    tag_stamp: tuple|None=None
    data_stamp: tuple|None=None
    pending: int=0
    saved: list=field(default_factory=list)
    returned: list=field(default_factory=list)
    clock: int=0
    cursor: int=0
    trail: int=0

    def stage_spawn(self):
        # Construction succeeds before reservation; reserve grows live, stage activation then delivery.
        self.trail+=1;self.reserved=True;self.pending=2;self.cursor=self.clock

    def stage_insert(self):
        self.trail+=1;self.pending=1;self.cursor=self.clock

    def barrier(self,replacement=False):
        self.pending=0;self.active=True
        self.saved.insert(0,(self.heads,self.tails,self.head_stamp or (0,0),self.tail_stamp or (0,0),self.tags,self.data,self.tag_stamp or (0,0),self.data_stamp or (0,0),replacement))
        for which,value in (("head",payload(replacement)),("tail",tail(replacement)),("tag","Tag"),("data",str(202 if replacement else 101))):
            old=getattr(self,which+"_stamp")
            self.clock+=1
            setattr(self,which+"_stamp",((old[0] if old else self.clock),self.clock))
            setattr(self,{"head":"heads","tail":"tails","tag":"tags","data":"data"}[which],value)

    def unwind(self):
        # Recursive install inverse restores tail then head; original stamps, actual displaced owners.
        h,t,hs,ts,g,d,gs,ds,replacement=self.saved.pop(0)
        self.heads=h;self.tails=t;self.head_stamp=hs;self.tail_stamp=ts
        self.tags=g;self.data=d;self.tag_stamp=gs;self.data_stamp=ds
        self.returned.insert(0,raw(replacement))

    def snapshot(self):
        def col(value,stamp):
            stamps="[]" if stamp is None else "[1:"+str(stamp[0])+":"+str(stamp[1])+"]"
            return "{values:"+value+",stamps:"+stamps+"}"
        resource="{returned:"+"".join(x+";" for x in self.returned)+"end,saved:"+str(len(self.saved))+",quarantine:0,errors:0,spare:N(L(70),L(71))}"
        store="{heads:"+col(self.heads,self.head_stamp)+",tails:"+col(self.tails,self.tail_stamp)+",tags:"+col(self.tags,self.tag_stamp)+",data:"+col(self.data,self.data_stamp)+"}"
        live="[False,"+("True" if self.active else "False")+"]" if self.reserved else "False"
        world="{ns:1,next:"+str(2 if self.reserved else 1)+",high:"+str(int(self.reserved))+",cap:"+str(2 if self.reserved else 1)+",depth:"+str(int(self.reserved))+",live:"+live+",store:"+store+",resource:"+resource+",events:[],pending:"+str(self.pending)+",regs:[1:canonical-bundle:[bundle:write]],system:2,clock:"+str(self.clock)+"}"
        registry="{ns:1,id:1,name:canonical-bundle,access:[bundle:write],cursor:"+str(self.cursor)+"}"
        return "registry="+registry+"|world="+world+"|context="+context(self.trail)

def checkpoints():
    s=EntityState();out=[("initial",s.snapshot())]
    # Invalid finite-number head retains raw; tail constructor still runs and retains all context.
    s.trail+=1;s.cursor=s.clock
    refused="[Validation($,finite number,Text(bad)), None, None, None]|raw="+tree((11,12))+"/wire=Text(bad)/fail=False/tail="+tail()+"/tag-component=Tag/data-component=101|"+s.snapshot()
    out.append(("refused",refused))
    s.stage_spawn();out.append(("spawn-queued",s.snapshot()))
    s.barrier();out.append(("installed",s.snapshot()))
    s.stage_insert();out.append(("replacement-queued",s.snapshot()))
    s.barrier(True);out.append(("replaced",s.snapshot()))
    s.unwind();out.append(("restored",s.snapshot()))
    s.unwind();out.append(("cleaned",s.snapshot()))
    return out

def report():
    # Both pinned IO.print effects write raw String bytes plus one LF; no show_val quoting.
    return ("\n".join(label+"="+view for label,view in all_valid_checkpoints())+"\n").encode()



def entity_world(s):return s.snapshot().split("|world=",1)[1].split("|context=",1)[0]
def missing_report():
    s=EntityState();s.reserved=True
    lines=["initial="+s.snapshot()]
    # Canonical construction runs before missing entity validation; each retry appends tail once.
    s.trail=1;lines.append("missing=MissingEntity|raw="+raw()+"|"+s.snapshot())
    s.active=True;s.trail=2;s.pending=1;lines.append("retry-queued="+s.snapshot())
    s.barrier();lines.append("installed="+s.snapshot());s.unwind();lines.append("cleaned="+s.snapshot())
    return ("\n".join(lines)+"\n").encode()
def foreign_report():
    home=EntityState();peer=EntityState();peer.reserved=True;peer.active=True
    peer_text=entity_world(peer).replace("{ns:1,","{ns:2,",1).replace("regs:[1:canonical-bundle:[bundle:write]],system:2","regs:[],system:1").replace("spare:N(L(70),L(71))","spare:N(L(80),L(81))")
    lines=["peer-before="+peer_text,"initial="+home.snapshot()]
    home.trail=1;lines.append("foreign=MissingEntity|raw="+raw()+"|"+home.snapshot())
    home.trail=2;lines.append("foreign-again=MissingEntity|raw="+raw()+"|"+home.snapshot());lines.append("peer-after="+peer_text)
    return ("\n".join(lines)+"\n").encode()
