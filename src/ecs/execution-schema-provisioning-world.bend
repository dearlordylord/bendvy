import Base
import ./execution-schema-provisioning.bend as Provision
import ./execution-composer-layout.bend as Layout
import ./execution-lifetime-scope-coverage.bend as Coverage
import ./execution-relation-context.bend as Context
import ./world.bend as W

def checked(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},valid:Bool,restore:R -> W.World<S,C,R,E>,result:Layout.resources(~S,resources) & Bool) -> W.World<S,C,R,E> & Bool:
  match result:
    case (owners,storedValid):(restore(Layout.checked_owner(Layout.resources(~S,resources),R,Equal.sym(Type,R,Layout.resources(~S,resources),same),owners)),Bool.and(valid,storedValid))
def preflight(~S:Data,~C:Type,~R:Type,~E:Data,~resources:Layout.Layout,~same:{R == Layout.resources(~S,resources) : Type},~Seed:Type,~blueprint:Provision.Blueprint<S,resources,Seed>,context:Context.Context<S,R,resources,same>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Bool:
  match context world:
    case Context.Context{+expected} W.World{+namespace,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle}:checked(~S,~C,~R,~E,~resources,~same,Bool.and(U32.is_eq(expected,namespace),Coverage.provisioned_layout(resources,Layout.AtLeaf{},Provision.graphs(~S,~resources,~Seed,blueprint),Provision.scopes(~S,~resources,~Seed,blueprint))),owners => W.World{namespace,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle},Provision.preflight(~S,~resources,~Seed,blueprint)(expected,Layout.checked_owner(R,Layout.resources(~S,resources),same,owners)))
