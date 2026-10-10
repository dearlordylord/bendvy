import Base
import ./ordinary-app-records.bend as Leaf
import ./ordinary-app-registration-fields.bend as Stored
import ./ordinary-app-registration-run.bend as Run
import ./ordinary-app-dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~RA:Type,~CE:Data,~RE:Data,~RO:Type,put:Leaf.Record<S,Stored.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>> -> H,convert:Sys.Outcome<W.World<S,C,R,E>,Error,Out> -> Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<Unit,RO>>,rejected:Args -> D.Arguments<Unit,RA>,result:Run.TransportResult<S,W.World<S,C,R,E>,Args,Error,Out,Stored.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>) -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>:
  match result:
    case Run.Completed{token,fields,outcome}:D.Completed{put(Leaf.Record{token,fields}),convert(outcome)}
    case Run.RegistrationRejected{token,fields,world,args}:D.RegistrationRejected{put(Leaf.Record{token,fields}),world,rejected(args)}
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~RA:Type,~CE:Data,~RE:Data,~RO:Type,put:Leaf.Record<S,Stored.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>> -> H,convert:Sys.Outcome<W.World<S,C,R,E>,Error,Out> -> Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<Unit,RO>>,rejected:Args -> D.Arguments<Unit,RA>,record:Leaf.Record<S,Stored.Token<Sys.Registry<S,C,R,E,Args,Error,Out,runner>>>,world:W.World<S,C,R,E>,args:Args) -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>:
  match record:
    case Leaf.Record{token,fields}:returned(~S,~C,~R,~E,~H,~Args,~Error,~Out,~runner,~RA,~CE,~RE,~RO,put,convert,rejected,Run.run(~S,~C,~R,~E,~Args,~Error,~Out,~runner,token,fields,world,args))
def current_cursor(~S:Data,fields:Stored.Fields<S>) -> U32:
  match fields:
    case Stored.Fields{_,_,_,_,cursor,_,_,_}:cursor
def component(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~CE:Data,~RA:Type,~RE:Data,~RO:Type,~runner:W.World<S,C,R,E> -> (Unit & U32) -> Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,Unit>>,put:Leaf.Record<S,Stored.Token<Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,runner>>> -> H,convert:Sys.Outcome<W.World<S,C,R,E>,CE,List<&2,Unit>> -> Sys.Outcome<W.World<S,C,R,E>,D.Error<CE,RE>,D.Output<Unit,RO>>,rejected:(Unit & U32) -> D.Arguments<Unit,RA>,record:Leaf.Record<S,Stored.Token<Sys.Registry<S,C,R,E,Unit & U32,CE,List<&2,Unit>,runner>>>,world:W.World<S,C,R,E>) -> D.DispatchResult<S,C,R,E,H,D.Arguments<Unit,RA>,D.Error<CE,RE>,D.Output<Unit,RO>>:
  match record:
    case Leaf.Record{token,+fields}:invoke(~S,~C,~R,~E,~H,~(Unit & U32),~CE,~List<&2,Unit>,~runner,~RA,~CE,~RE,~RO,put,convert,rejected,Leaf.Record{token,fields},world,(Unit{},current_cursor(~S,fields)))
