import Base
import ./records.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
# Representation-only transport of the existing Sys.run_tracked discriminants.
# No output, rejected argument or affine owner is duplicated or finalized here.
type TransportResult<S:Data,World:Type,Args:Type,Error:Data,Out:Type,Token:Type> is Type:
  Completed{token:Token,fields:Records.Fields<S>,outcome:Sys.Outcome<World,Error,Out>}
  RegistrationRejected{token:Token,fields:Records.Fields<S>,world:World,args:Args}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,slot:String,clauses:List<&2,Query.Clause<S>>,kind:Records.RegistrationKind,registry:Sys.Registry<S,C,R,E,Args,Error,Out,runner>) -> Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Records.Fields<S>:
  match registry:
    case Sys.Registry{namespace,id,name,access,cursor}:(Records.Token{},Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind})
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,outcome:Sys.Outcome<W.World<S,C,R,E>,Error,Out>,result:Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Records.Fields<S>) -> TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>:
  match result:
    case (token,fields):Completed{token,fields,outcome}
def rejected(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,world:W.World<S,C,R,E>,args:Args,result:Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>> & Records.Fields<S>) -> TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>:
  match result:
    case (token,fields):RegistrationRejected{token,fields,world,args}
def captured(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,slot:String,clauses:List<&2,Query.Clause<S>>,kind:Records.RegistrationKind,result:Sys.RunResult<S,C,R,E,Args,Error,Out,runner>) -> TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>:
  match result:
    case Sys.Completed{registry,outcome}:completed(~S,~C,~R,~E,~Args,~Error,~Out,~runner,outcome,returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,slot,clauses,kind,registry))
    case Sys.RegistrationRejected{registry,world,args}:rejected(~S,~C,~R,~E,~Args,~Error,~Out,~runner,world,args,returned(~S,~C,~R,~E,~Args,~Error,~Out,~runner,slot,clauses,kind,registry))
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,fields:Records.Fields<S>,world:W.World<S,C,R,E>,args:Args) -> TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>:
  match fields:
    case Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}:captured(~S,~C,~R,~E,~Args,~Error,~Out,~runner,slot,clauses,kind,Sys.run_tracked(~S,~C,~R,~E,~Args,~Error,~Out,~runner,Sys.Registry{namespace,id,name,access,cursor},world,args))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,token:Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>,fields:Records.Fields<S>,world:W.World<S,C,R,E>,args:Args) -> TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Records.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>:
  match token:
    case Records.Token{}:restored(~S,~C,~R,~E,~Args,~Error,~Out,~runner,fields,world,args)
