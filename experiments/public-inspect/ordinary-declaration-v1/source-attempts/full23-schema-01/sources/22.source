import Base
import fixture.bend as Fixture
import runtime-owners.bend as Owners
import schema-families.bend as D
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/commands.bend as Cmd

type Family is Data:
  Stock{}
  Title{}
  Active{}
  Count{}
type Operation<S:Data> is Data:
  Operation{family:Family,target:W.Handle<S>,value:Maybe<&2,U32>}
def stock(~S:Data,target:W.Handle<S>,value:Maybe<&2,U32>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match value:
    case None{}:Fixture.stock_write(~S,world,target,None{})
    case Some{value}:Fixture.stock_write(~S,world,target,Some{D.Stock{Array.new(U32,0n,value)}})
def title(~S:Data,target:W.Handle<S>,value:Maybe<&2,U32>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match value:
    case None{}:Fixture.title_write(~S,world,target,None{})
    case Some{value}:Fixture.title_write(~S,world,target,Some{D.Title{Array.new(U32,0n,value)}})
def active(~S:Data,target:W.Handle<S>,value:Maybe<&2,U32>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match value:
    case None{}:Fixture.active_write(~S,world,target,None{})
    case Some{value}:Fixture.active_write(~S,world,target,Some{D.Active{Array.new(U32,0n,value)}})
def count(~S:Data,target:W.Handle<S>,value:Maybe<&2,U32>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match value:
    case None{}:Fixture.count_write(~S,world,target,None{})
    case Some{value}:Fixture.count_write(~S,world,target,Some{D.Count{Array.new(U32,0n,value)}})
def apply(~S:Data,operation:Operation<S>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match operation:
    case Operation{Stock{},target,value}:stock(~S,target,value,world)
    case Operation{Title{},target,value}:title(~S,target,value,world)
    case Operation{Active{},target,value}:active(~S,target,value,world)
    case Operation{Count{},target,value}:count(~S,target,value,world)
def carry(~S:Data,errors:String,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  (world,error)=observed
  (world,errors ++ error)
def applied(~S:Data,value:Operation<S>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  (world,errors)=observed
  carry(~S,errors,apply(~S,value,world))
def operations(~S:Data,values:List<&2,Operation<S>>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match values:
    case []:observed
    case value <> rest:operations(~S,rest,applied(~S,value,observed))
def target(~S:Data,targets:List<&2,W.Handle<S>>,index:Nat) -> Maybe<&2,W.Handle<S>>:
  match targets index:
    case [] _:None{}
    case value <> _ 0n:Some{value}
    case _ <> rest 1n+index:target(~S,rest,index)
def selected(~S:Data,family:Family,value:Maybe<&2,U32>,observed:Maybe<&2,W.Handle<S>>) -> List<&2,Operation<S>>:
  match observed:
    case None{}:[]
    case Some{target}:[Operation{family,target,value}]
def item(~S:Data,targets:List<&2,W.Handle<S>>,id:Nat,family:Family,value:Maybe<&2,U32>) -> List<&2,Operation<S>>:
  selected(~S,family,value,target(~S,targets,id))
def append(~S:Data,a:List<&2,Operation<S>>,b:List<&2,Operation<S>>) -> List<&2,Operation<S>>:
  List.append(&2,Operation<S>,a,b)
def independent_inputs(~S:Data,+targets:List<&2,W.Handle<S>>) -> List<&2,Operation<S>>:
  append(~S,item(~S,targets,3n,Stock{},None{}),append(~S,item(~S,targets,3n,Stock{},Some{41}),append(~S,item(~S,targets,7n,Stock{},None{}),append(~S,item(~S,targets,7n,Stock{},Some{81}),append(~S,item(~S,targets,3n,Title{},None{}),append(~S,item(~S,targets,3n,Title{},Some{42}),append(~S,item(~S,targets,11n,Title{},None{}),append(~S,item(~S,targets,11n,Title{},Some{122}),append(~S,item(~S,targets,15n,Stock{},Some{161}),append(~S,item(~S,targets,15n,Title{},Some{162}),append(~S,item(~S,targets,7n,Active{},Some{1}),append(~S,item(~S,targets,11n,Count{},Some{124}),[]))))))))))))
def ticked(~S:Data,inputs:List<&2,Operation<S>>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & U32) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  (world,_)=observed
  operations(~S,inputs,(world,""))
def independent(~S:Data,targets:List<&2,W.Handle<S>>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  ticked(~S,independent_inputs(~S,targets),W.advance_clock(~S,~D.Store<S>,~Owners.Resource<S>,~U32,world))
# Fixture cleanup disposes actual removed affine payloads; readonly callbacks do not.
def cleared(~S:Data,~Payload:Type,value:Col.SwapOutcome<S,Payload>) -> Col.Column<S,Payload>:
  match value:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def clear(~S:Data,store:D.Store<S>,handle:W.Handle<S>) -> D.Store<S>:
  match store handle:
    case D.Store{stock,title,active,count} W.Handle{_,+id}:
      D.Store{cleared(~S,~D.Stock,Col.clear(~S,~D.Stock,stock,id)),cleared(~S,~D.Title,Col.clear(~S,~D.Title,title,id)),cleared(~S,~D.Active,Col.clear(~S,~D.Active,active,id)),cleared(~S,~D.Count,Col.clear(~S,~D.Count,count,id))}
def structural_inputs(~S:Data,+targets:List<&2,W.Handle<S>>) -> List<&2,Operation<S>>:
  append(~S,item(~S,targets,3n,Stock{},None{}),append(~S,item(~S,targets,0n,Stock{},Some{1001}),append(~S,item(~S,targets,0n,Title{},Some{1002}),append(~S,item(~S,targets,7n,Active{},None{}),append(~S,item(~S,targets,11n,Count{},None{}),append(~S,item(~S,targets,7n,Stock{},None{}),append(~S,item(~S,targets,7n,Stock{},Some{81}),append(~S,item(~S,targets,11n,Title{},None{}),append(~S,item(~S,targets,11n,Title{},Some{122}),[])))))))))
def despawn_choice(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,errors:String,selected:Maybe<&2,W.Handle<S>>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  match selected:
    case None{}:(world,errors ++ "missing-structural-target;")
    case Some{handle}:(Cmd.despawn_apply_with(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~clear(~S),world,handle),errors)
def despawned(~S:Data,selected:Maybe<&2,W.Handle<S>>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  (world,errors)=observed
  despawn_choice(~S,world,errors,selected)
def structural(~S:Data,+targets:List<&2,W.Handle<S>>,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String:
  despawned(~S,target(~S,targets,15n),ticked(~S,structural_inputs(~S,targets),W.advance_clock(~S,~D.Store<S>,~Owners.Resource<S>,~U32,world)))
def main() -> Unit:
  Unit{}
