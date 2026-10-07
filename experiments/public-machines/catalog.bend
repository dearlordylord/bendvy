import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys

# Trusted engine catalog. Closed runners define the opaque gameplay boundary;
# the catalog itself never crosses that boundary and owns every registry once.
type Entry<S: Data,C: Type,R: Type,E: Data,A: Type,X: Data,O: Type,-run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>> is Type:
  Entry{key: U32,registry: Sys.Registry<S,C,R,E,A,X,O,run>}
type Catalog<S: Data,C: Type,R: Type,E: Data,A: Type,X: Data,O: Type,-run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>> is Type:
  Catalog{entries: List<&1,Entry<S,C,R,E,A,X,O,run>>}
type Selected<S: Data,C: Type,R: Type,E: Data,A: Type,X: Data,O: Type,-run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>> is Type:
  Found{registry: Sys.Registry<S,C,R,E,A,X,O,run>,rest: List<&1,Entry<S,C,R,E,A,X,O,run>>}
  Absent{rest: List<&1,Entry<S,C,R,E,A,X,O,run>>}

def selected_join(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,head: Entry<S,C,R,E,A,X,O,run>,selected: Selected<S,C,R,E,A,X,O,run>) -> Selected<S,C,R,E,A,X,O,run>:
  match selected:
    case Found{registry,rest}: Found{registry,head <> rest}
    case Absent{rest}: Absent{head <> rest}
def restore_selected(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,key: U32,selected: Selected<S,C,R,E,A,X,O,run>) -> List<&1,Entry<S,C,R,E,A,X,O,run>>:
  match selected:
    case Found{registry,rest}: Entry{key,registry} <> rest
    case Absent{rest}: rest
def select_step(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,same: Bool,entry: Entry<S,C,R,E,A,X,O,run>,tail: Selected<S,C,R,E,A,X,O,run>) -> Selected<S,C,R,E,A,X,O,run>:
  match same entry:
    case True{}, Entry{key,registry}: Found{registry,restore_selected(~S,~C,~R,~E,~A,~X,~O,~run,key,tail)}
    case False{}, entry: selected_join(~S,~C,~R,~E,~A,~X,~O,~run,entry,tail)
def select(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,entries: List<&1,Entry<S,C,R,E,A,X,O,run>>,+key: U32) -> Selected<S,C,R,E,A,X,O,run>:
  match entries:
    case Nil{}: Absent{[]}
    case Con{Entry{+actual,registry},rest}:
      select_step(~S,~C,~R,~E,~A,~X,~O,~run,U32.is_eq(actual,key),Entry{actual,registry},select(~S,~C,~R,~E,~A,~X,~O,~run,rest,key))

type CatalogResult<S: Data,C: Type,R: Type,E: Data,A: Type,X: Data,O: Type,-run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>> is Type:
  Completed{catalog: Catalog<S,C,R,E,A,X,O,run>,outcome: Sys.Outcome<W.World<S,C,R,E>,X,O>}
  Refused{catalog: Catalog<S,C,R,E,A,X,O,run>,world: W.World<S,C,R,E>,args: A}

def returned(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,key: U32,rest: List<&1,Entry<S,C,R,E,A,X,O,run>>,result: Sys.RunResult<S,C,R,E,A,X,O,run>) -> CatalogResult<S,C,R,E,A,X,O,run>:
  match result:
    case Sys.Completed{registry,outcome}: Completed{Catalog{Entry{key,registry} <> rest},outcome}
    case Sys.RegistrationRejected{registry,world,args}: Refused{Catalog{Entry{key,registry} <> rest},world,args}
def registered(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,key: U32,rest: List<&1,Entry<S,C,R,E,A,X,O,run>>,args: A,result: Sys.RegistrationResult<S,C,R,E,A,X,O,run>) -> CatalogResult<S,C,R,E,A,X,O,run>:
  match result:
    case Sys.Registered{world,registry}: returned(~S,~C,~R,~E,~A,~X,~O,~run,key,rest,Sys.run(~S,~C,~R,~E,~A,~X,~O,~run,registry,world,args))
    case Sys.RegistrationFailed{world}: Refused{Catalog{rest},world,args}
def run_selected(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,selected: Selected<S,C,R,E,A,X,O,run>,world: W.World<S,C,R,E>,key: U32,name: String,access: List<&2,String>,args: A) -> CatalogResult<S,C,R,E,A,X,O,run>:
  match selected:
    case Found{registry,rest}: returned(~S,~C,~R,~E,~A,~X,~O,~run,key,rest,Sys.run(~S,~C,~R,~E,~A,~X,~O,~run,registry,world,args))
    case Absent{rest}: registered(~S,~C,~R,~E,~A,~X,~O,~run,key,rest,args,Sys.register(~S,~C,~R,~E,~A,~X,~O,~run,world,name,access))
def invoke(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~X: Data,~O: Type,~run: W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,X,O>,catalog: Catalog<S,C,R,E,A,X,O,run>,world: W.World<S,C,R,E>,+key: U32,name: String,access: List<&2,String>,args: A) -> CatalogResult<S,C,R,E,A,X,O,run>:
  match catalog:
    case Catalog{entries}: run_selected(~S,~C,~R,~E,~A,~X,~O,~run,select(~S,~C,~R,~E,~A,~X,~O,~run,entries,key),world,key,name,access,args)
