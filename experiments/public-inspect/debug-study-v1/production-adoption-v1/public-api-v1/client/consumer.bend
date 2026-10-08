import Base
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/schedule-provision.bend as Provision
import ../candidate/src/ecs/debug-metadata.bend as M
import ../candidate/src/ecs/debug-description.bend as D
import ../candidate/src/ecs/debug-registered.bend as Registered
import ./multi-registered.bend as Application
import ./scheduled-view.bend as View
import ./render.bend as Render
import ./registered-owner-snapshot.bend as OwnerSnapshot
import ./render-fixture.bend as R
import ./owner-observation.bend as Owner
import ./resource-read.bend as Observe
import ./namespace-world-snapshot.bend as Snapshot
type ObservationResult is Type:
  Complete{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,output:String}
def output(name:String,description:D.Description) -> String:
  "{\"name\":"++R.quote(name)++",\"description\":"++Render.description(description)++"}"
def cursor_strings(values:List<&2,U32>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:U32.show(head)<>cursor_strings(tail)
def after(main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,text:String,+before:String,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> ObservationResult:
  match result:
    case (world,+after):Complete{world,main,again,text++"\nownerBefore="++before++"\nownerAfter="++after++"\nownerPreserved="++Render.boolean(String.eq(before,after))}
def described(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,before:String,+mainView:View.View,+againView:View.View,+renamedView:View.View,+present:Bool) -> ObservationResult:
  match mainView againView renamedView:
    case View.View{+ms,+mr,mss,_,mns,mc,+mv} View.View{+gs,+gr,gss,_,+gns,gc,+gv} View.View{+rs,+rr,rss,_,rns,rc,+rv}:after(main,again,output("duplicateLabels",D.describe([],[M.Resource{"plain",M.Plain{},present}],[],[],[],[],[ms,gs],List.append(&2,M.System,mss,gss),[mr,gr]))++"\n"++output("replacement",D.describe([],[M.Resource{"plain",M.Plain{},present}],[],[],[],[],[rs],rss,[rr]))++"\nviewsValid="++Render.boolean(Bool.and(mv,Bool.and(gv,rv)))++"\nnamespacePreserved="++Render.boolean(Bool.and(U32.is_eq(mns,gns),U32.is_eq(gns,rns)))++"\nmainCursors="++R.array(cursor_strings(mc))++"\ncursorsBefore="++R.array(cursor_strings(gc))++"\ncursorsAfter="++R.array(cursor_strings(rc)),before,Snapshot.project(world))
def projected(main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,before:String,mainView:View.View,againView:View.View,renamedView:View.View,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation) -> ObservationResult:
  match result:
    case (world,Owner.Observation{plain,_,_,_,_,_}):described(world,main,again,before,mainView,againView,renamedView,plain)
def snap(main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,mainView:View.View,againView:View.View,renamedView:View.View,result:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & String) -> ObservationResult:
  match result:
    case (world,before):projected(main,again,before,mainView,againView,renamedView,Observe.read(world))
def renamed(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,mainView:View.View,againView:View.View,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & View.View) -> ObservationResult:
  match result:
    case (again,renamedView):snap(main,again,mainView,againView,renamedView,Snapshot.project(world))
def again_observed(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,mainView:View.View,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & View.View) -> ObservationResult:
  match result:
    case (again,againView):renamed(world,main,mainView,againView,View.again_view(again,"renamed"))
def main_observed(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & View.View) -> ObservationResult:
  match result:
    case (main,mainView):again_observed(world,main,mainView,View.again_view(again,"again"))
def observe(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>) -> ObservationResult:
  main_observed(world,again,View.main_view(main))

# Both complete affine schedule/registry owners bracket the entire description
# operation, not merely one Reader cursor. Args are not passed or invoked here.
def owners_after_again(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,text:String,+mbefore:String,+gbefore:String,+mafter:String,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & String) -> ObservationResult:
  match result:
    case (again,+gafter):Complete{world,main,again,text++"\nmainBefore="++mbefore++"\nmainAfter="++mafter++"\nagainBefore="++gbefore++"\nagainAfter="++gafter++"\nregisteredOwnersPreserved="++Render.boolean(Bool.and(String.eq(mbefore,mafter),String.eq(gbefore,gafter)))}
def owners_after_main(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,text:String,mbefore:String,gbefore:String,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & String) -> ObservationResult:
  match result:
    case (main,mafter):owners_after_again(world,main,text,mbefore,gbefore,mafter,OwnerSnapshot.again(again))
def owners_observed(mbefore:String,gbefore:String,result:ObservationResult) -> ObservationResult:
  match result:
    case Complete{world,main,again,text}:owners_after_main(world,again,text,mbefore,gbefore,OwnerSnapshot.main(main))
def owners_before_again(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,mbefore:String,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & String) -> ObservationResult:
  match result:
    case (again,gbefore):owners_observed(mbefore,gbefore,observe(world,main,again))
def owners_before_main(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,result:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & String) -> ObservationResult:
  match result:
    case (main,mbefore):owners_before_again(world,main,mbefore,OwnerSnapshot.again(again))
def observe_complete(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>) -> ObservationResult:
  owners_before_main(world,again,OwnerSnapshot.main(main))
