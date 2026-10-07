import Base
import ../bend-candidate/consumer.bend as A
import ../bend-candidate/full-v2/optional-resource.bend as Slot
import condition.bend as Check
import ../../../src/ecs/world.bend as W

# Closed diagnostic driver state. These fields are not grants to Check consumers.
type Diagnostic is Data:
  Diagnostic{snapshot:String,before:String,after:String,same:Bool,allowed:Bool,ran:U32,checks:U32}
type Resources is Type:
  Resources{score:Slot.Slot<A.Resource>,diagnostic:Diagnostic}
def fresh() -> Diagnostic:
  Diagnostic{"","","",False{},False{},0,0}
def score_done(diagnostic:Diagnostic,result:Slot.Slot<A.Resource> & Maybe<&2,List<&2,U32>>) -> Resources & List<&2,U32>:
  match result:
    case (slot,None{}):(Resources{slot,diagnostic},[])
    case (slot,Some{value}):(Resources{slot,diagnostic},value)
def project_score(resources:Resources) -> Resources & List<&2,U32>:
  match resources:
    case Resources{slot,diagnostic}:score_done(diagnostic,Slot.observe(~A.Resource,~List<&2,U32>,~A.project_resource,slot))
def available_done(diagnostic:Diagnostic,result:Slot.Slot<A.Resource> & Bool) -> Resources & Bool:
  (slot,value)=result
  (Resources{slot,diagnostic},value)
def available(resources:Resources) -> Resources & Bool:
  match resources:
    case Resources{slot,diagnostic}:available_done(diagnostic,Slot.presence(~A.Resource,slot))
def names(result:W.World<A.Schema,A.Store,Resources,U32> & Bool) -> W.World<A.Schema,A.Store,Resources,U32> & List<&2,String>:
  match result:
    case (world,True{}):(world,[])
    case (world,False{}):(world,["Workshop/CheckScore"])
def required(world:W.World<A.Schema,A.Store,Resources,U32>) -> W.World<A.Schema,A.Store,Resources,U32> & List<&2,String>:
  names(W.observe_resource(~A.Schema,~A.Store,~Resources,~U32,~Bool,~available,world))
# Preload and clear diagnostics outside the read-only Check.run boundary.
def preload(snapshot:String,resources:Resources) -> Resources & Unit:
  match resources:
    case Resources{score,Diagnostic{_,_,_,_,_,ran,checks}}:(Resources{score,Diagnostic{snapshot,"","",False{},False{},ran,(checks + 1 : U32)}},Unit{})
def record(before:String,after:String,same:Bool,allowed:Bool,resources:Resources) -> Resources & Unit:
  match resources:
    case Resources{score,Diagnostic{snapshot,_,_,_,_,ran,checks}}:(Resources{score,Diagnostic{snapshot,before,after,same,allowed,ran,checks}},Unit{})
def increment(resources:Resources) -> Resources & Unit:
  match resources:
    case Resources{score,Diagnostic{snapshot,before,after,same,allowed,ran,checks}}:(Resources{score,Diagnostic{snapshot,before,after,same,allowed,(ran + 1 : U32),checks}},Unit{})
def updated(diagnostic:Diagnostic,result:A.Resource & Unit) -> Resources & Unit:
  (resource,value)=result
  (Resources{Slot.Present{resource},diagnostic},value)
def update_cells(resource:A.Resource) -> A.Resource & Unit:
  match resource:
    case A.Resource{cells}:(A.Resource{Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,cells,0,31),1,31),2,31),3,34)},Unit{})
def update(resources:Resources) -> Resources & Unit:
  match resources:
    case Resources{Slot.Absent{},diagnostic}:(Resources{Slot.Absent{},diagnostic},Unit{})
    case Resources{Slot.Present{resource},diagnostic}:updated(diagnostic,update_cells(resource))
def diagnostic(resources:Resources) -> Resources & Diagnostic:
  match resources:
    case Resources{score,+diagnostic}:(Resources{score,diagnostic},diagnostic)
