import Base
import health-access.bend as Access
import ../../../../dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-family.bend as Family
import health-local.bend as L
import health-reader.bend as Reader
import health-publications.bend as Publications
import health-audit.bend as Audit
import ../../../../../../../src/ecs/local.bend as Local
import ../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../src/ecs/event-family-routing.bend as Route

type Owners is Type:
  Owners{a:L.Instance(),b:L.Instance(),publications:Publications.Provider(),meta:L.Meta(),tick:Nat}
type Registration is Type:
  Ready{world:F.World(),owners:Owners}
  Stopped{context:Family.Context(),stage:U32,a:Maybe<&1,L.Instance()>,reader:Maybe<&1,Reader.Provider()>,publications:Maybe<&1,Publications.Provider()>,local:Maybe<&1,L.State>}
def access() -> List<&2,String>:Access.access()
def b_registered(meta:L.Meta(),tick:Nat,a:L.Instance(),publications:Publications.Provider(),result:Local.Registered<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),L.State,L.Args,Empty,L.Returned,L.runner>) -> Registration:
  match result:
    case Local.Registered{world,b}:Ready{world,Owners{a,b,publications,meta,tick}}
    case Local.RegistrationRejected{world,local}:Stopped{Route.Runtime{world,meta,tick},4,Some{a},None{},Some{publications},Some{local}}
def a_registered(meta:L.Meta(),tick:Nat,reader:Reader.Provider(),publications:Publications.Provider(),result:Local.Registered<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),L.State,L.Args,Empty,L.Returned,L.runner>) -> Registration:
  match result:
    case Local.Registered{world,a}:b_registered(meta,tick,a,publications,Local.register(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,world,"FailedTxn/B",access(),L.B{ANode{ALeaf{0},ALeaf{102}},reader}))
    case Local.RegistrationRejected{world,local}:Stopped{Route.Runtime{world,meta,tick},3,None{},Some{reader},Some{publications},Some{local}}
def context_ready(reader:Reader.Provider(),publications:Publications.Provider(),context:Family.Context()) -> Registration:
  match context:
    case Route.Runtime{world,meta,tick}:a_registered(meta,tick,reader,publications,Local.register(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,world,"FailedTxn/A",access(),L.A{ANode{ALeaf{0},ALeaf{101}}}))
def publications_defined(reader:Reader.Provider(),result:Publications.Definition()) -> Registration:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:context_ready(reader,provider,context)
    case Ordinary.DefinitionRejected{context,_,_}:Stopped{context,2,None{},Some{reader},None{},None{}}
    case Ordinary.DefinitionDisposalRejected{context,provider,_}:Stopped{context,2,None{},Some{reader},Some{provider},None{}}
def reader_defined(result:Reader.Definition()) -> Registration:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:publications_defined(provider,Publications.define(context,"FailedTxn/Publications"))
    case Ordinary.DefinitionRejected{context,_,_}:Stopped{context,1,None{},None{},None{},None{}}
    case Ordinary.DefinitionDisposalRejected{context,provider,_}:Stopped{context,1,None{},Some{provider},None{},None{}}
def run(world:F.World()) -> Registration:reader_defined(Reader.define(Family.start(world),"FailedTxn/B-reader"))
