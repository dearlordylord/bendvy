import Base
import scene/application.bend as A
import scene/provider.bend as P
import scene/gameplay.bend as G
import scene/context.bend as Ctx
import scene/readers.bend as R
import scene/hooks.bend as H
import scene/catalog.bend as Cat
import scene/slots.bend as Slots
import scene/stream.bend as St
import scene/observe.bend as O
import scene/conditions.bend as C
import ../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../bendvy/src/ecs/system.bend as Sys

def user_entry(~S: Data,entry: Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>) -> Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  match entry:
    case Cat.Entry{+key,Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      (Cat.Entry{key,Sys.Registry{ns,id,name,access,cursor}},U32.show(key) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def users_join(~S: Data,head: Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String,rest: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>) -> List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>:
  (entry,text)=head
  (rest,rows)=rest
  (entry <> rest,text <> rows)
def users(~S: Data,entries: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>>) -> List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>:
  match entries:
    case Nil{}: ([],[])
    case Con{head,rest}: users_join(~S,user_entry(~S,head),users(~S,rest))
def user_catalog(~S: Data,pair: List<&1,Cat.Entry<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>> & List<&2,String>) -> Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  (entries,rows)=pair
  (Cat.Catalog{entries},List.show(&2,String,O.text,rows))
def catalog(~S: Data,value: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>) -> Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String:
  match value:
    case Cat.Catalog{entries}: user_catalog(~S,users(~S,entries))

def reader(~S: Data,entry: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>) -> Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String:
  match entry:
    case Slots.Entry{+key,R.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+a,+ai},St.Reader{+b,+bi}}}:
      (Slots.Entry{key,R.Instance{Sys.Registry{ns,id,name,access,cursor},St.Reader{a,ai},St.Reader{b,bi}}},U32.show(key) ++ ":" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor) ++ ":flow=" ++ U32.show(a) ++ ":" ++ U32.show(ai) ++ ":level=" ++ U32.show(b) ++ ":" ++ U32.show(bi))
def readers_join(~S: Data,head: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String,rest: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>) -> List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>:
  (entry,text)=head
  (rest,rows)=rest
  (entry <> rest,text <> rows)
def readers(~S: Data,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>) -> List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>:
  match entries:
    case Nil{}: ([],[])
    case Con{head,rest}: readers_join(~S,reader(~S,head),readers(~S,rest))

def hook_registry(~S: Data,value: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  match value:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def hook_join(~S: Data,a: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String,b: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,(world => operation => Ctx.hook_runner(~S,world,operation))> & String) -> H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  (flow,a)=a
  (level,b)=b
  (H.Owners{flow,level},a ++ "|" ++ b)
def hooks(~S: Data,owners: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String:
  match owners:
    case H.Owners{flow,level}: hook_join(~S,hook_registry(~S,flow),hook_registry(~S,level))
def owners_join(~S: Data,a: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))> & String,b: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & String,c: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>> & List<&2,String>,+attempts: List<&2,String>,+deliveries: List<&2,String>,+conditions: List<&2,String>,+active: List<&2,A.Action<S>>) -> A.Owners<S> & String:
  (users,a)=a
  (hooks,b)=b
  (readers,c)=c
  (A.Owners{users,hooks,readers,attempts,deliveries,conditions,active},"users=" ++ a ++ ";hookOwners=" ++ b ++ ";readerOwners=" ++ List.show(&2,String,O.text,c) ++ ";attempts=" ++ List.show(&2,String,O.text,attempts) ++ ";deliveries=" ++ List.show(&2,String,O.text,deliveries) ++ ";conditions=" ++ List.show(&2,String,O.text,conditions) ++ ";active=" ++ List.show(&2,A.Action<S>,(item => A.action_view(~S,item)),active))
def owners(~S: Data,value: A.Owners<S>) -> A.Owners<S> & String:
  match value:
    case A.Owners{userCatalog,hookOwners,readerEntries,attempts,deliveries,conditions,active}: owners_join(~S,catalog(~S,userCatalog),hooks(~S,hookOwners),readers(~S,readerEntries),attempts,deliveries,conditions,active)

type Observed<S: Data> is Type:
  Observed{owners: A.Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,rows: List<&2,String>}
def observed(~S: Data,label: String,status: String,rows: List<&2,String>,a: A.Owners<S> & String,b: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> Observed<S>:
  (owners,a)=a
  (world,b)=b
  Observed{owners,world,List.append(&2,String,rows,[label ++ "|" ++ status ++ "|" ++ b ++ ";" ++ a])}
def checkpoint(~S: Data,label: String,rows: List<&2,String>,result: A.FrameResult<S>) -> Observed<S>:
  match result:
    case A.FrameResult{owned,world,status}: observed(~S,label,status,rows,owners(~S,owned),O.world(~S,world))
