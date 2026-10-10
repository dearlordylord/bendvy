"""Independent frozen canonical World pipeline model; no runtime output inputs."""
from dataclasses import dataclass, field

def tree(x):
    return "L("+str(x)+")" if isinstance(x,int) else "N("+tree(x[0])+","+tree(x[1])+")"

def context(n):
    return "factory=identity=constructed-array/decl=FiniteNumber/input=FiniteNumber/tailFactory=identity=canonical-tail/decl=FiniteNumber/input=FiniteNumber/rest=N(L(N(L(70),L(71))),L(L(72)))/trail=["+", ".join(["tail"]*n)+"]"

def tail(replacement=False):
    base=51 if replacement else 21
    return tree(((base,base+1),(base+2,base+3)))+"/tag="+("False" if replacement else "True")+"/scalar="+str(61 if replacement else 32)

def raw(replacement=False):
    return "Ready("+payload(replacement)+")/tail="+tail(replacement)+"/tag-component=Tag/data-component="+str(202 if replacement else 101)

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
        world="{ns:1,next:"+str(2 if self.reserved else 1)+",high:"+str(int(self.reserved))+",cap:"+str(2 if self.reserved else 1)+",depth:"+str(int(self.reserved))+",live:"+live+",store:"+store+",resource:"+resource+",events:[],pending:"+str(self.pending)+",regs:[1:canonical-bundle:[bundle:write]],system:2,clock:"+str(self.clock)+"}"
        registry="{ns:1,id:1,name:canonical-bundle,access:[bundle:write],cursor:"+str(self.cursor)+"}"
        return "registry="+registry+"|world="+world+"|context="+context(self.trail)

def checkpoints():
    s=State();out=[("initial",s.snapshot())]
    # Supplied Rejected bypasses the canonical head factory but returns the
    # original Payload and Blocked. Eager valid tail is undone by invalid_tail.
    s.trail+=1;s.cursor=s.clock
    rejected="Rejected("+payload()+",Constructor(Blocked))/tail="+tail()+"/tag-component=Tag/data-component=101"
    out.append(("refused","[Constructor(Blocked), None, None, None]|raw="+rejected+"|"+s.snapshot()))
    # Explicit Ready repair retains Array11/12 and number7; identity inverse.
    s.stage_spawn();out.append(("spawn-queued",s.snapshot()))
    s.barrier();out.append(("installed",s.snapshot()))
    s.stage_insert();out.append(("replacement-queued",s.snapshot()))
    s.barrier(True);out.append(("replaced",s.snapshot()))
    s.unwind();out.append(("restored",s.snapshot()))
    s.unwind();out.append(("cleaned",s.snapshot()))
    return out

def report():
    # Both pinned IO.print effects write raw String bytes plus one LF; no show_val quoting.
    return ("\n".join(label+"="+view for label,view in checkpoints())+"\n").encode()

if __name__=="__main__":
    import sys
    sys.stdout.buffer.write(report())
