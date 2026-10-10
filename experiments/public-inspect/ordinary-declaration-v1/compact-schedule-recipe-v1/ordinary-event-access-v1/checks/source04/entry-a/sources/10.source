import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import event-declaration.bend as Event
# Sole retained operational Registry; debug never reads an event payload or Reader.
type Owner<S:Data,E:Data,Registry:Type> is Type:
  Owner{declaration:Event.Declaration<S,E>,registry:Registry,debug:Bool}
type Category is Data:
  Events{}
type Role is Data:
  Reader{}
  Writer{}
type Use is Data:
  Use{category:Category,key:String,mode:Event.Mode,role:Role,namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
def role(mode:Event.Mode) -> Role:
  match mode:
    case Event.Read{}:Reader{}
    case Event.Write{}:Writer{}
def enabled(~S:Data,~E:Data,~Registry:Type,owner:Owner<S,E,Registry>,flag:Bool) -> Owner<S,E,Registry>:
  match owner:
    case Owner{declaration,registry,_}:Owner{declaration,registry,flag}
def bind(~S:Data,~E:Data,~Registry:Type,declaration:Event.Declaration<S,E>,registry:Registry) -> Owner<S,E,Registry>:Owner{declaration,registry,False{}}
def described(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,declaration:Event.Declaration<S,E>,registry:Sys.Registry<S,C,R,E,A,Error,O,runner>) -> Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>> & Maybe<&2,Use>:
  match declaration registry:
    case Event.Declaration{Event.Domain{+key},+mode} Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Owner{Event.Declaration{Event.Domain{key},mode},Sys.Registry{namespace,id,name,access,cursor},True{}},Some{Use{Events{},key,mode,role(mode),namespace,id,name,access,cursor}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,owner:Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>) -> Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>> & Maybe<&2,Use>:
  match owner:
    case Owner{declaration,registry,False{}}:(Owner{declaration,registry,False{}},None{})
    case Owner{declaration,registry,True{}}:described(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,registry)

type WriterResult<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Completed{owner:Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,outcome:Sys.Outcome<W.World<S,C,R,E>,Error,O>}
  Rejected{owner:Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,world:W.World<S,C,R,E>,args:A}
def writer_returned(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,declaration:Event.Declaration<S,E>,debug:Bool,result:Sys.RunResult<S,C,R,E,A,Error,O,runner>) -> WriterResult<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sys.Completed{registry,outcome}:Completed{Owner{declaration,registry,debug},outcome}
    case Sys.RegistrationRejected{registry,world,args}:Rejected{Owner{declaration,registry,debug},world,args}
def run_writer(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,owner:Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>,world:W.World<S,C,R,E>,args:A) -> WriterResult<S,C,R,E,A,Error,O,runner>:
  match owner:
    case Owner{declaration,registry,debug}:writer_returned(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,debug,Sys.run(~S,~C,~R,~E,~A,~Error,~O,~runner,registry,world,args))

type ReaderResult<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Ran{runtime:Ev.Runtime<S,C,R,E>,reader:Ev.Reader<S>,owner:Owner<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,completion:Ev.Completion<Error,O,A>}
def reader_returned(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,declaration:Event.Declaration<S,E>,debug:Bool,result:Ev.RunResult<S,C,R,E,A,Error,O,runner>) -> ReaderResult<S,C,R,E,A,Error,O,runner>:
  match result:
    case Ev.Ran{runtime,reader,registry,completion}:Ran{runtime,reader,Owner{declaration,registry,debug},completion}
def run_reader(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,owner:Owner<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>,runtime:Ev.Runtime<S,C,R,E>,reader:Ev.Reader<S>,args:A) -> ReaderResult<S,C,R,E,A,Error,O,runner>:
  match owner:
    case Owner{declaration,registry,debug}:reader_returned(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,debug,Ev.run(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,reader,registry,args))

type WriterRegistered<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  WriterRegistered{world:W.World<S,C,R,E>,owner:Owner<S,E,Sys.Registry<S,C,R,E,A,Error,O,runner>>}
  WriterFailed{world:W.World<S,C,R,E>}
def writer_registered(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,declaration:Event.Declaration<S,E>,result:Sys.RegistrationResult<S,C,R,E,A,Error,O,runner>) -> WriterRegistered<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sys.RegistrationFailed{world}:WriterFailed{world}
    case Sys.Registered{world,registry}:WriterRegistered{world,Owner{declaration,registry,False{}}}
def register_writer(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> A -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,world:W.World<S,C,R,E>,+declaration:Event.Declaration<S,E>,name:String) -> WriterRegistered<S,C,R,E,A,Error,O,runner>:
  writer_registered(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,Event.register_writer(~S,~C,~R,~E,~A,~Error,~O,~runner,world,declaration,name))

type ReaderRegistered<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  ReaderRegistered{runtime:Ev.Runtime<S,C,R,E>,reader:Ev.Reader<S>,owner:Owner<S,E,Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>>}
  ReaderFailed{runtime:Ev.Runtime<S,C,R,E>}
def reader_registered(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,declaration:Event.Declaration<S,E>,result:Ev.Registered<S,C,R,E,A,Error,O,runner>) -> ReaderRegistered<S,C,R,E,A,Error,O,runner>:
  match result:
    case Ev.RegisterFailed{runtime}:ReaderFailed{runtime}
    case Ev.Registered{runtime,reader,registry}:ReaderRegistered{runtime,reader,Owner{declaration,registry,False{}}}
def register_reader(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,runtime:Ev.Runtime<S,C,R,E>,+declaration:Event.Declaration<S,E>,name:String) -> ReaderRegistered<S,C,R,E,A,Error,O,runner>:
  reader_registered(~S,~C,~R,~E,~A,~Error,~O,~runner,declaration,Event.register_reader(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,declaration,name))
