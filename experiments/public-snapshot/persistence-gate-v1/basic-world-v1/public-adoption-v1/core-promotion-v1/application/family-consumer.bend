import Base
import ./game.bend as Game
import ./legacy-fixture.bend as F
import ./setup.bend as Setup
import ./format.bend as Format
import ../library/persistence-declaration.bend as Decl
import ../library/owner-product.bend as Product
import ../library/declared-family.bend as Family
import ../library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./world-owner.bend as Owner
import ./physical-column.bend as Physical
import ./consumer.bend as Consumer
import ./supplement.bend as Supplement
def get(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,handle:W.Handle<S>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Cmp.Access<D.Raw>:
  Cmp.get(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>) & Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>,~F.Payload,~D.Raw,~S,~Family.take_column(~S,~F.Payload,~Game.Store(~S),~Game.Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~Game.take_saved(~S)),~Family.put_column(~S,~F.Payload,~Game.Store(~S),~Game.Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~Game.put_saved(~S)),~F.project,Game.saved_family(~S),world,handle)
def remove(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,handle:W.Handle<S>) -> Cmp.Replacement<W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload>:
  Cmp.replace(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~(Game.Scratch(~S) & Product.Owner<Unit,Unit>) & Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>,~F.Payload,~D.Raw,~S,~Family.take_column(~S,~F.Payload,~Game.Store(~S),~Game.Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~Game.take_saved(~S)),~Family.put_column(~S,~F.Payload,~Game.Store(~S),~Game.Scratch(~S) & Product.Owner<Unit,Unit>,~F.declaration(~S),~F.project,~Game.put_saved(~S)),~F.project,Game.saved_family(~S),world,handle,None{})
def physical_done(~S:Data,owner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  match observed:
    case (world,physical):(world,"{\"owner\":" ++ Format.owner(~S,owner) ++ ",\"physical\":" ++ physical ++ "}")
def owner_done(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Owner.Observed<S>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  match observed:
    case (world,owner):physical_done(~S,owner,W.with_store(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~String,Physical.store(~S),world))
def observe(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  owner_done(~S,Owner.observe(~S,world))
def access(value:Cmp.Access<D.Raw>) -> String:
  match value:
    case Cmp.Found{value}:"{\"Found\":" ++ Format.raw(value) ++ "}"
    case Cmp.ComponentAbsent{}:"\"ComponentAbsent\""
    case Cmp.MissingEntity{}:"\"MissingEntity\""
def checked_get(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Cmp.Access<D.Raw>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  match observed:
    case (world,value):(world,access(value))
def removed_owner(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,observed:F.Payload & D.Raw) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  match observed:
    case (_,value):(world,Format.raw(value))
def checked_remove(~S:Data,result:Cmp.Replacement<W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,F.Payload>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String:
  match result:
    case Cmp.Replaced{world,Some{owner}}:removed_owner(~S,world,F.project(owner))
    case Cmp.Replaced{world,None{}}:(world,"null")
    case Cmp.ReplaceRejected{world,_,_}:(world,"\"ReplaceRejected\"")
type Trace<-S:Data> is Type:
  Trace{a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,first:W.Handle<S>,second:W.Handle<S>,foreign:W.Handle<S>,parts:List<&2,String>}
def observed_b(~S:Data,parts:List<&2,String>,aAfter:String,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (_,bAfter):"{\"steps\":[" ++ String.join(parts,",") ++ "],\"afterA\":" ++ aAfter ++ ",\"afterB\":" ++ bAfter ++ "}"
def observed_a(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (_,aAfter):observed_b(~S,parts,aAfter,observe(~S,b))
def final_b(~S:Data,a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (b,value):observed_a(~S,b,List.append(&2,String,parts,[value]),observe(~S,a))
def foreign_done(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,foreign:W.Handle<S>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (a,value):final_b(~S,a,List.append(&2,String,parts,[value]),checked_get(~S,get(~S,b,foreign)))
def absent_done(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,+foreign:W.Handle<S>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (a,value):foreign_done(~S,b,foreign,List.append(&2,String,parts,[value]),checked_get(~S,get(~S,a,foreign)))
def removed(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,second:W.Handle<S>,foreign:W.Handle<S>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (a,value):absent_done(~S,b,foreign,List.append(&2,String,parts,[value]),checked_get(~S,get(~S,a,second)))
def found(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,+second:W.Handle<S>,foreign:W.Handle<S>,parts:List<&2,String>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (a,value):removed(~S,b,second,foreign,List.append(&2,String,parts,[value]),checked_remove(~S,remove(~S,a,second)))
def before_b(~S:Data,a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,first:W.Handle<S>,second:W.Handle<S>,foreign:W.Handle<S>,aBefore:String,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (b,bBefore):"{\"beforeA\":" ++ aBefore ++ ",\"beforeB\":" ++ bBefore ++ ",\"trace\":" ++ found(~S,b,second,foreign,[],checked_get(~S,get(~S,a,first))) ++ "}"
def before_a(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,first:W.Handle<S>,second:W.Handle<S>,foreign:W.Handle<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & String) -> String:
  match observed:
    case (a,aBefore):before_b(~S,a,first,second,foreign,aBefore,observe(~S,b))
def handles_b(~S:Data,a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,first:W.Handle<S>,second:W.Handle<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & List<&2,W.Handle<S>>) -> String:
  match observed:
    case (b,foreign <> _):before_a(~S,b,first,second,foreign,observe(~S,a))
    case (_,[]):"HandleRefused"
def handles_a(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & List<&2,W.Handle<S>>) -> String:
  match observed:
    case (a,first <> second <> _):handles_b(~S,a,first,second,W.handles(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,b))
    case _ :"HandleRefused"
def mutated(~S:Data,b:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Unit) -> String:
  match observed:
    case (a,_):handles_a(~S,b,W.handles(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,a))
def setup_b(~S:Data,a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,result:Setup.Setup<S>) -> String:
  match result:
    case Setup.Ready{b}:mutated(~S,b,W.with_store(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Unit,Consumer.mutate_store(~S),a))
    case Setup.Refused{_,_}:"SetupRefused"
def created_b(~S:Data,a:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,result:W.Creation<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> String:
  match result:
    case W.Created{_,b}:setup_b(~S,a,Setup.setup(~S,b))
    case W.CreateRejected{_,_}:"CreationRefused"
def setup_a(~S:Data,factory:W.Factory,result:Setup.Setup<S>) -> String:
  match result:
    case Setup.Ready{a}:created_b(~S,a,W.create(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Game.empty(~S),factory,Game.initial_resources(~S)))
    case Setup.Refused{_,_}:"SetupRefused"
def created_a(~S:Data,result:W.Creation<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> String:
  match result:
    case W.Created{factory,a}:setup_a(~S,factory,Setup.setup(~S,a))
    case W.CreateRejected{_,_}:"CreationRefused"
def run(~S:Data) -> String:
  created_a(~S,W.create(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Game.empty(~S),W.factory(),Game.initial_resources(~S)))
def main() -> IO(Unit):
  IO.print("{\"inventory\":" ++ Format.raw(Supplement.inventory()) ++ ",\"Workshop\":" ++ run(~F.Workshop) ++ ",\"Garden\":" ++ run(~F.Garden) ++ "}")
