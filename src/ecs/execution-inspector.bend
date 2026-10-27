import Base
import ./inspector.bend as Inspector
import ./check.bend as Check
import ./capabilities.bend as Cap
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as Access
import ./resource-field.bend as Field
import ./execution-declaration.bend as Declaration

type Resource<-H:Type,-V:Data> is Type:
  Resource{read:Cap.ValueRead<H,V>,uses:List<&2,Declaration.Access>}
def resource(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Resource<Inspector.Frame<S,C,R,E>,Layout.view(layout,route)>:
  Resource{Inspector.read_resource(~S,~C,~R,~E,~Layout.view(layout,route),~Field.project(~R,~Access.resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~Layout.view(layout,route),~Access.resource_lens(~S,~R,~layout,~route,~same),~Access.resource_view(~S,~layout,~route))),[Declaration.Access{Layout.key(layout,route),Declaration.ResourceAccess{},Declaration.Exclusive{},Declaration.ReadOnly{}}]}
def check_resource(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Resource<Check.Frame<S,C,R,E>,Layout.view(layout,route)>:
  Resource{Check.resource_grant(~S,~C,~R,~E,~Layout.view(layout,route),~Field.project(~R,~Access.resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~Layout.view(layout,route),~Access.resource_lens(~S,~R,~layout,~route,~same),~Access.resource_view(~S,~layout,~route))),[Declaration.Access{Layout.key(layout,route),Declaration.ResourceAccess{},Declaration.Exclusive{},Declaration.ReadOnly{}}]}
def resource_grant(~H:Type,~V:Data,value:Resource<H,V>) -> Cap.ValueRead<H,V>:
  match value:
    case Resource{read,_}:read
def resource_uses(~H:Type,~V:Data,value:Resource<H,V>) -> List<&2,Declaration.Access>:
  match value:
    case Resource{_,uses}:uses
