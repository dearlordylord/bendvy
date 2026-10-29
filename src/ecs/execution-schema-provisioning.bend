import Base
import ./execution-composer-layout.bend as Layout
import ./execution-command-permission.bend as Permission
import ./execution-relation-provider.bend as GraphProvider
import ./execution-lifetime-scope-provider.bend as ScopeProvider
import ./execution-relation-store.bend as GraphStore
import ./execution-lifetime-scope-store.bend as ScopeStore
import ./execution-relation-failure-retention.bend as Retention
import ./execution-resource-policy.bend as Policy
import ./relation-types.bend as T
import ./execution-relation-context.bend as Context

# A provisioning declaration constructs its owner and framework maintenance
# evidence together. It grants no capability to an executing gameplay body.
type Blueprint<-S:Data,-resources:Layout.Layout,-Seed:Type> is Type:
  Blueprint{build:U32 -> Seed -> Layout.resources(~S,resources),graphs:List<&2,Layout.Route>,scopes:List<&2,Layout.Route>,selection:Permission.Selection<S,resources>,retention:Retention.Program(~S,~resources),preflight:U32 -> Layout.resources(~S,resources) -> Layout.resources(~S,resources) & Bool}
type Bound<-S:Data,-WR:Type,-resources:Layout.Layout,-same:{WR == Layout.resources(~S,resources) : Type},-Seed:Type,-blueprint:Blueprint<S,resources,Seed>,-Application:Type> is Type:
  Bound{bound:Context.Bound<S,WR,resources,same,Application>}
def reported(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~Seed:Type,~blueprint:Blueprint<S,resources,Seed>,-Application:Type,-Report:Data,result:Context.Bound<S,WR,resources,same,Application> & Report) -> Bound<S,WR,resources,same,Seed,blueprint,Application> & Report:
  match result:
    case (bound,report):(Bound{bound},report)
def unchecked(~S:Data,~resources:Layout.Layout,_:U32,owners:Layout.resources(~S,resources)) -> Layout.resources(~S,resources) & Bool:
  (owners,True{})
def graph_preflight(~S:Data,~descriptor:T.Descriptor<S>,~key:String,expected:U32,owners:Layout.resources(~S,GraphProvider.layout(~S,~descriptor,key))) -> Layout.resources(~S,GraphProvider.layout(~S,~descriptor,key)) & Bool:
  match owners:
    case Layout.ResourceSlot{Layout.Viewed{GraphStore.Store{+namespace,graph,failures,sequence,nextReader},cache},stamp}:(Layout.ResourceSlot{Layout.Viewed{GraphStore.Store{namespace,graph,failures,sequence,nextReader},cache},stamp},U32.is_eq(expected,namespace))
def scope_preflight(~S:Data,~key:String,expected:U32,owners:Layout.resources(~S,ScopeProvider.layout(~S,key))) -> Layout.resources(~S,ScopeProvider.layout(~S,key)) & Bool:
  match owners:
    case Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{+namespace,members},cache},stamp}:(Layout.ResourceSlot{Layout.Viewed{ScopeStore.Store{namespace,members},cache},stamp},U32.is_eq(expected,namespace))

def ordinary_layout(~P:Type,~V:Data,~refresh:P -> P & V,key:String) -> Layout.Layout:
  Layout.LayoutLeaf{P,V,refresh,key,Policy.Ordinary{}}
def ordinary_owner(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,~key:String,_:U32,owner:P) -> Layout.resources(~S,ordinary_layout(~P,~V,~refresh,key)):
  Layout.ResourceSlot{Layout.initialize(ordinary_layout(~P,~V,~refresh,key),Layout.AtLeaf{},owner),Layout.unknown_stamp()}
def ordinary(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,~key:String) -> Blueprint<S,ordinary_layout(~P,~V,~refresh,key),P>:
  Blueprint{ordinary_owner(~S,~P,~V,~refresh,~key),[],[],Permission.no_selection(~S,~ordinary_layout(~P,~V,~refresh,key)),Retention.empty(~S,~ordinary_layout(~P,~V,~refresh,key)),unchecked(~S,~ordinary_layout(~P,~V,~refresh,key))}
def graph_owner(~S:Data,~descriptor:T.Descriptor<S>,~key:String,namespace:U32,_:Unit) -> Layout.resources(~S,GraphProvider.layout(~S,~descriptor,key)):
  Layout.ResourceSlot{Layout.initialize(GraphProvider.layout(~S,~descriptor,key),Layout.AtLeaf{},GraphStore.fresh(~S,~descriptor,namespace)),Layout.unknown_stamp()}
def graph(~S:Data,~descriptor:T.Descriptor<S>,~key:String) -> Blueprint<S,GraphProvider.layout(~S,~descriptor,key),Unit>:
  Blueprint{graph_owner(~S,~descriptor,~key),[Layout.AtLeaf{}],[],Permission.extend_selection(~S,~GraphProvider.layout(~S,~descriptor,key),~Layout.AtLeaf{},~{==},~descriptor,~{==},~{==},~{==},Permission.no_selection(~S,~GraphProvider.layout(~S,~descriptor,key))),Retention.extend(~S,~GraphProvider.layout(~S,~descriptor,key),~Layout.AtLeaf{},~{==},~descriptor,~{==},~{==},~{==},Retention.empty(~S,~GraphProvider.layout(~S,~descriptor,key))),graph_preflight(~S,~descriptor,~key)}
def scope_owner(~S:Data,~key:String,namespace:U32,_:Unit) -> Layout.resources(~S,ScopeProvider.layout(~S,key)):
  Layout.ResourceSlot{Layout.initialize(ScopeProvider.layout(~S,key),Layout.AtLeaf{},ScopeStore.fresh(~S,namespace)),Layout.unknown_stamp()}
def scope(~S:Data,~key:String) -> Blueprint<S,ScopeProvider.layout(~S,key),Unit>:
  Blueprint{scope_owner(~S,~key),[],[Layout.AtLeaf{}],Permission.extend_scope_selection(~S,~ScopeProvider.layout(~S,key),~Layout.AtLeaf{},~{==},~{==},~{==},~{==},Permission.no_selection(~S,~ScopeProvider.layout(~S,key))),Retention.empty(~S,~ScopeProvider.layout(~S,key)),scope_preflight(~S,~key)}
def builder(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> U32 -> Seed -> Layout.resources(~S,resources):
  match value:
    case Blueprint{build,_,_,_,_,_}: build
def graphs(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> List<&2,Layout.Route>:
  match value:
    case Blueprint{_,graphs,_,_,_,_}: graphs
def scopes(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> List<&2,Layout.Route>:
  match value:
    case Blueprint{_,_,scopes,_,_,_}: scopes
def selection(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> Permission.Selection<S,resources>:
  match value:
    case Blueprint{_,_,_,selection,_,_}: selection
def retention(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> Retention.Program(~S,~resources):
  match value:
    case Blueprint{_,_,_,_,retention,_}: retention
def cleanup(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> Permission.CleanupSelection<S,resources>:
  match value:
    case Blueprint{_,graphs,scopeRoutes,Permission.Selection{program,snapshot,scopes,_},_,_}: Permission.Provisioned{program,snapshot,scopes,graphs,scopeRoutes}
def preflight(~S:Data,~resources:Layout.Layout,~Seed:Type,value:Blueprint<S,resources,Seed>) -> U32 -> Layout.resources(~S,resources) -> Layout.resources(~S,resources) & Bool:
  match value:
    case Blueprint{_,_,_,_,_,preflight}:preflight
