"""Independent frozen stuck HeadPending countermodel model; no runtime output inputs."""
from dataclasses import dataclass, field

def tree(x):
    return "L("+str(x)+")" if isinstance(x,int) else "N("+tree(x[0])+","+tree(x[1])+")"

def context(n):
    return "factory=identity=constructed-array/decl=FiniteNumber/input=FiniteNumber/rest=N(L(N(L(70),L(71))),L(L(72)))/trail=["+", ".join(["tail"]*n)+"]"

def tail(replacement=False):
    base=51 if replacement else 21
    return tree(((base,base+1),(base+2,base+3)))+"/tag="+("False" if replacement else "True")+"/scalar="+str(61 if replacement else 31)

def raw(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/wire=Number("+str(17 if replacement else 9)+")/fail=False/tail="+tail(replacement)

def payload(replacement=False):
    return tree((41,42) if replacement else (11,12))+"/number="+str(17 if replacement else 9)

@dataclass
class State:
    reserved: bool=False
    active: bool=False
    heads: str="null"
    tails: str="null"
    head_stamp: tuple|None=None
    tail_stamp: tuple|None=None
    pending: int=0
    saved: list=field(default_factory=list)
    returned: list=field(default_factory=list)
    clock: int=0
    cursor: int=0
    trail: int=0
    quarantine: tuple|None=None
    errors: int=0

    def stage_spawn(self):
        # Construction succeeds before reservation; reserve grows live, stage activation then delivery.
        self.trail+=1;self.reserved=True;self.pending=2;self.cursor=self.clock

    def stage_insert(self):
        self.trail+=1;self.pending=1;self.cursor=self.clock

    def barrier(self,replacement=False):
        self.pending=0;self.active=True
        self.saved.insert(0,(self.heads,self.tails,self.head_stamp or (0,0),self.tail_stamp or (0,0),replacement))
        for which,value in (("head",payload(replacement)),("tail",tail(replacement))):
            old=getattr(self,which+"_stamp")
            self.clock+=1
            setattr(self,which+"_stamp",((old[0] if old else self.clock),self.clock))
            setattr(self,"heads" if which=="head" else "tails",value)

    def unwind(self):
        # Recursive install inverse restores tail then head; original stamps, actual displaced owners.
        h,t,hs,ts,replacement=self.saved.pop(0)
        self.heads=h;self.tails=t;self.head_stamp=hs;self.tail_stamp=ts
        self.returned.insert(0,tree((41,42))+"/wire=Number(17)/fail=False/tail="+tail(False))

    def pending_inverse(self):
        # Actual inverse pops the saved replacement and reaches tail first. Inactive handle
        # leaves both replacement columns unchanged and retains tail recovery + undoHead.
        self.active=False
        self.quarantine=self.saved.pop(0)
        h,t,hs,ts,replacement=self.quarantine
        self.tails=t;self.tail_stamp=ts
        self.errors+=1

    def resume(self):
        # Reached mutant refuses every outer HeadPending without calling the head
        # callback, even after actual activation. Recovery owners remain untouched.
        self.errors+=1

    def quarantine_view(self):
        if self.quarantine is None:return "end"
        h,t,hs,ts,replacement=self.quarantine
        receipt="{previous:{handle:1:1,owner:"+h+"},stamp:"+str(hs[0])+":"+str(hs[1])+"}"
        restored_tail="{handle:1:2,owner:"+tail(replacement)+"}"
        return "recovery:head-pending:"+receipt+"/tail="+restored_tail+"/error=MissingEntity/rawUndo=retained-for-execution;end"

    def snapshot(self):
        def col(value,stamp,id=1):
            stamps="[]" if stamp is None else "["+str(id)+":"+str(stamp[0])+":"+str(stamp[1])+"]"
            value=("[null,"+value+"]") if id==2 and stamp is not None else value
            return "{values:"+value+",stamps:"+stamps+"}"
        resource="{returned:"+"".join(x+";" for x in self.returned)+"end,saved:"+str(len(self.saved))+",quarantine:"+self.quarantine_view()+",errors:["+", ".join(["MissingEntity"]*self.errors)+"],spare:N(L(70),L(71))}"
        store="{heads:"+col(self.heads,self.head_stamp)+",tails:"+col(self.tails,self.tail_stamp,2)+"}"
        live="[[False,"+("True" if self.active else "False")+"],[True,False]]"
        world="{ns:1,next:3,high:2,cap:4,depth:2,live:"+live+",store:"+store+",resource:"+resource+",events:[],pending:0,regs:[1:generic-two-target-inverse:[bundle:write]],system:2,clock:"+str(self.clock)+"}"
        registry="{ns:1,id:1,name:generic-two-target-inverse,access:[bundle:write],cursor:"+str(self.cursor)+"}"
        return "registry="+registry+"|world="+world+"|context="+context(self.trail)

def checkpoints():
    # Two genuine same-world targets reserved/activated without clock advancement.
    s=State(reserved=True,active=True);out=[("initial",s.snapshot())]
    s.trail+=1;s.barrier();out.append(("installed",s.snapshot()))
    s.trail+=1;s.barrier(True);out.append(("replaced",s.snapshot()))
    s.pending_inverse();out.append(("pending",s.snapshot()))
    s.resume();out.append(("pending-again",s.snapshot()))
    s.active=True;s.resume();out.append(("restored",s.snapshot()))
    s.unwind();out.append(("cleaned",s.snapshot()))
    return out

def report():
    # Both pinned IO.print effects write raw String bytes plus one LF; no show_val quoting.
    return ("\n".join(label+"="+view for label,view in checkpoints())+"\n").encode()

if __name__=="__main__":
    import sys
    sys.stdout.buffer.write(report())
