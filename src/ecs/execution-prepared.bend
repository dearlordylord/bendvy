import Base
import ./owner-product.bend as Product
import ./change-tick.bend as Tick

# A permit is a preparation record, not standalone invocation authority.
type Permit<-S:Data,-WC:Type> is Data:
  Permit{namespace:U32,id:U32,allowed:Bool,tick:Tick.Tick}
type Provenance<P:Data> is Data:
  Unprepared{}
  Leaf{namespace:U32,permits:List<&2,P>}
  Pair{left:Provenance<P>,right:Provenance<P>}
type Prepared<-World:Type,-Owner:Type,P:Data> is Type:
  Prepared{namespace:U32,owner:Owner,permits:List<&2,P>,provenance:Provenance<P>}
# Failure inventories have no conversion to qualified Prepared.
type Inventory<-World:Type,-Owners:Type,P:Data> is Type:
  Inventory{owners:Owners,provenance:Provenance<P>}
type Preparation<-World:Type,-Owners:Type,P:Data> is Type:
  PreparationReady{world:World,prepared:Prepared<World,Owners,P>}
  PreparationRefused{world:World,inventory:Inventory<World,Owners,P>}
# This constructor adapter belongs to the trusted preparation boundary.
def trusted_leaf(~World:Type,~Owner:Type,~P:Data,+namespace:U32,owner:Owner,+permits:List<&2,P>) -> Prepared<World,Owner,P>:
  Prepared{namespace,owner,permits,Leaf{namespace,permits}}
type Joining<-World:Type,-L:Type,-R:Type,P:Data> is Type:
  Joined{prepared:Prepared<World,Product.Owner<L,R>,P>}
  JoinRefused{left:Prepared<World,L,P>,right:Prepared<World,R,P>}
type Admission<-H:Type,-World:Type,-Owner:Type,P:Data> is Type:
  Admitted{scope:H,prepared:Prepared<World,Owner,P>}
  AdmissionRefused{scope:H,prepared:Prepared<World,Owner,P>}
type Invocation<-H:Type,-World:Type,-Owner:Type,P:Data,Status:Data> is Type:
  Invoked{scope:H,prepared:Prepared<World,Owner,P>,status:Status}
  InvocationRefused{scope:H,prepared:Prepared<World,Owner,P>,status:Status}
  InvocationInventoryRefused{scope:H,inventory:Inventory<World,Owner,P>,status:Status}
def joined(~World:Type,~L:Type,~R:Type,~P:Data,same:Bool,left:Prepared<World,L,P>,right:Prepared<World,R,P>) -> Joining<World,L,R,P>:
  match same left right:
    case False{} left right:JoinRefused{left,right}
    case True{} Prepared{namespace,left,leftPermits,lp} Prepared{_,right,rightPermits,rp}:Joined{Prepared{namespace,Product.Owner{left,right},List.append(&2,P,leftPermits,rightPermits),Pair{lp,rp}}}
def join(~World:Type,~L:Type,~R:Type,~P:Data,left:Prepared<World,L,P>,right:Prepared<World,R,P>) -> Joining<World,L,R,P>:
  match left right:
    case Prepared{+a,left,lp,lt} Prepared{+b,right,rp,rt}:joined(~World,~L,~R,~P,U32.is_eq(a,b),Prepared{a,left,lp,lt},Prepared{b,right,rp,rt})
def admitted(~H:Type,~World:Type,~Owner:Type,~P:Data,same:Bool,scope:H,prepared:Prepared<World,Owner,P>) -> Admission<H,World,Owner,P>:
  match same:
    case False{}:AdmissionRefused{scope,prepared}
    case True{}:Admitted{scope,prepared}
def admit(~H:Type,~World:Type,~Owner:Type,~P:Data,namespace:U32,scope:H,prepared:Prepared<World,Owner,P>) -> Admission<H,World,Owner,P>:
  match prepared:
    case Prepared{+actual,owner,permits,provenance}:admitted(~H,~World,~Owner,~P,U32.is_eq(namespace,actual),scope,Prepared{actual,owner,permits,provenance})

def permits(~P:Data,tree:Provenance<P>) -> List<&2,P>:
  match tree:
    case Unprepared{}:[]
    case Leaf{_,permits}:permits
    case Pair{left,right}:List.append(&2,P,permits(~P,left),permits(~P,right))
