import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import ../candidate/src/ecs/debug-metadata.bend as M
import ./definition.bend as Declaration
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
# The retained declaration accompanies the actual affine registered owner.
# C/R/Args/Output remain arbitrary Type; no runtime owner is captured or cloned.
type Bound<CT:Data,RT:Data,ET:Data,MT:Data,LT:Data,VT:Data,KT:Data,S:Data,C:Type,R:Type,E:Data,Args:Type,Error:Data,Output:Type,-runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Bound{owner:Sys.Registry<S,C,R,E,Args,Error,Output,runner>,declaration:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>}
type Registration<CT:Data,RT:Data,ET:Data,MT:Data,LT:Data,VT:Data,KT:Data,S:Data,C:Type,R:Type,E:Data,Args:Type,Error:Data,Output:Type,-runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Registered{world:W.World<S,C,R,E>,owner:Bound<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner>}
  Rejected{world:W.World<S,C,R,E>}
type Observation<S:Data> is Data:
  Observation{namespace:U32,id:U32,cursor:U32,actualName:String,actualAccess:List<&2,String>,system:M.System,valid:Bool}
def joined(~CT:Data,~RT:Data,~ET:Data,~MT:Data,~LT:Data,~VT:Data,~KT:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>,declaration:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>,result:Sys.RegistrationResult<S,C,R,E,Args,Error,Output,runner>) -> Registration<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner>:
  match result:
    case Sys.Registered{world,owner}:Registered{world,Bound{owner,declaration}}
    case Sys.RegistrationFailed{world}:Rejected{world}
def register(~CT:Data,~RT:Data,~ET:Data,~MT:Data,~LT:Data,~VT:Data,~KT:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~name:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>->String,~access:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>->List<&2,String>,world:W.World<S,C,R,E>,+declaration:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>) -> Registration<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner>:
  joined(~CT,~RT,~ET,~MT,~LT,~VT,~KT,~S,~C,~R,~E,~Args,~Error,~Output,~runner,declaration,Sys.register(~S,~C,~R,~E,~Args,~Error,~Output,~runner,world,name(declaration),access(declaration)))
def observe(~CT:Data,~RT:Data,~ET:Data,~MT:Data,~LT:Data,~VT:Data,~KT:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~name:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>->String,~access:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>->List<&2,String>,~metadata:Declaration.Definition<S,CT,RT,ET,MT,LT,VT,KT>->List<&2,String>->M.System,value:Bound<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner>,positions:List<&2,String>) -> Bound<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner> & Observation<S>:
  match value:
    case Bound{Sys.Registry{+namespace,+id,+actualName,+actualAccess,+cursor},+declaration}:(Bound{Sys.Registry{namespace,id,actualName,actualAccess,cursor},declaration},Observation{namespace,id,cursor,actualName,actualAccess,metadata(declaration,positions),Bool.and(String.eq(actualName,name(declaration)),W.access_equal(actualAccess,access(declaration)))})

# The actual registered id and the retained nominal declaration jointly supply
# the schedule entry. No display label lookup or cloned registered owner.
# Condition ids are supplied by the actual scheduler binding; this helper does
# not derive Check requirements or validate callable condition metadata.
def schedule_entry(~CT:Data,~RT:Data,~ET:Data,~MT:Data,~LT:Data,~VT:Data,~KT:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~resource:RT->Provision.Requirement<S>,~service:VT->Provision.Requirement<S>,condition:U32,value:Bound<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner>) -> Bound<CT,RT,ET,MT,LT,VT,KT,S,C,R,E,Args,Error,Output,runner> & Provision.Plan<S>:
  match value:
    case Bound{Sys.Registry{namespace,+id,name,access,cursor},+declaration}:(Bound{Sys.Registry{namespace,id,name,access,cursor},declaration},Provision.Entry{Schedule.System{id,condition},[]})
