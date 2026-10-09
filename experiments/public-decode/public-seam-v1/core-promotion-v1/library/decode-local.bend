import ../dependencies/snapshot/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import Base
import ./decode-frame.bend as F
import ./decode-requests.bend as Request
import ./decode-owned-journal.bend as Journal
import ../dependencies/snapshot/ordinary-declaration.bend as Identity
import ../dependencies/snapshot/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch

# State/sink adapters are application-selected, closed typed functions. A failed
# run returns its Local owner and no output, exactly like existing Local.Outcome.
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> A -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,world:W.World<S,C,R,E>,name:String,access:List<&2,String>,local:L) -> Local.Registered<S,C,R,E,L,A,Error,Out,runner>:
  Local.register(~S,~C,~R,~E,~L,~A,~Error,~Out,~runner,world,name,access,local)

def succeeded(~World:Type,~L:Type,~Error:Data,~Out:Type,world:World,result:L & Out) -> Local.Outcome<World,L,Error,Out>:
  match result:
    case (local,output):Local.Succeeded{world,local,output}

def committed(~World:Type,~L:Type,~A:Type,~Rows:Data,~Error:Data,~Out:Type,~success:L -> A -> Rows -> L & Out,~failure:L -> A -> L,local:L,args:A,rows:Rows,result:T.Returned<World,Error>) -> Local.Outcome<World,L,Error,Out>:
  match result:
    case T.Returned{world,T.Success{}}:succeeded(~World,~L,~Error,~Out,world,success(local,args,rows))
    case T.Returned{world,T.Failure{error}}:Local.Failed{world,failure(local,args),error}

def recovered(~S:Data,~World:Type,~L:Type,~A:Type,~P:Type,~Q:Type,~Error:Data,~Out:Type,~recover:L -> A -> List<Request.Packet<P>> -> List<Journal.Pending<Q>> -> L,error:Error,local:L,args:A,prepared:List<Batch.Prepared<S,Request.Packet<P>>>,pending:List<Journal.Pending<Q>>,result:Journal.Returned<World,Request.Packet<P>,Q>) -> Local.Outcome<World,L,Error,Out>:
  match result:
    case Journal.Returned{world,owners,more}:Local.Failed{world,recover(local,args,List.append(&1,Request.Packet<P>,owners,Batch.originals(~S,~Request.Packet<P>,prepared)),List.append(&1,Journal.Pending<Q>,pending,more)),error}

def abort(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~L:Type,~A:Type,~Error:Data,~Out:Type,~recover:L -> A -> List<Request.Packet<P>> -> List<Journal.Pending<Q>> -> L,error:Error,local:L,args:A,frame:F.Frame<S,C,R,E,P,Q,identity,project>) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match frame:
    case F.Frame{Request.Owner{Batch.Batch{tx,prepared},_},_,_,_,receipts,pending}:recovered(~S,~W.World<S,C,R,E>,~L,~A,~P,~Q,~Error,~Out,~recover,error,local,args,prepared,pending,Journal.abort(~W.World<S,C,R,E>,~E,~Request.Packet<P>,~Q,receipts,tx))

# Non-empty deferred packets require the separate deferred completion route.
# Pending is never silently accepted as a completed rollback.
def traversal(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~L:Type,~A:Type,~Rows:Data,~Error:Data,~Out:Type,~success:L -> A -> Rows -> L & Out,~failure:L -> A -> L,~recover:L -> A -> List<Request.Packet<P>> -> List<Journal.Pending<Q>> -> L,rejected:Error,local:L,result:F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Error> & Rows))) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case (F.Frame{Request.Owner{Batch.Batch{tx,[]},_},_,_,_,_,[]},(args,(T.Success{},rows))):committed(~W.World<S,C,R,E>,~L,~A,~Rows,~Error,~Out,~success,~failure,local,args,rows,Commands.tx_finish(~S,~C,~R,~E,~Error,tx,T.Success{}))
    case (frame,(args,(T.Success{},_))):abort(~S,~C,~R,~E,~P,~Q,~identity,~project,~L,~A,~Error,~Out,~recover,rejected,local,args,frame)
    case (frame,(args,(T.Failure{error},_))):abort(~S,~C,~R,~E,~P,~Q,~identity,~project,~L,~A,~Error,~Out,~recover,error,local,args,frame)

def deferred(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~L:Type,~Out:Type,~recover:L -> Out -> List<Request.Packet<P>> -> L,local:L,output:Out,result:Batch.Finished<S,C,R,E,Request.Packet<P>,Error>) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case Batch.Committed{world}:Local.Succeeded{world,local,output}
    case Batch.Failed{world,packets,error}:Local.Failed{world,recover(local,output,packets),error}

# Construction uses the same retained nominal descriptor as the grants.
def begin_owner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,world:W.World<S,C,R,E>,codec:Decl.Constructed<S,P,identity,project>) -> Request.Owner<S,C,R,E,P,identity,project>:
  Request.Owner{Batch.begin(~S,~C,~R,~E,~Request.Packet<P>,T.begin(~W.World<S,C,R,E>,~E,world)),codec}
def begin_frame(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,world:W.World<S,C,R,E>,codec:Decl.Constructed<S,P,identity,project>) -> F.Frame<S,C,R,E,P,Q,identity,project>:
  F.Frame{begin_owner(~S,~C,~R,~E,~P,~identity,~project,world,codec),W.Handle{0,0},None{},0,[],[]}
def finish_deferred(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~attempt:W.World<S,C,R,E> -> W.Handle<S> -> Request.Packet<P> -> Delivery.Delivery<W.World<S,C,R,E>,Request.Packet<P>>,~delivery_recover:W.World<S,C,R,E> -> Request.Packet<P> -> W.WorldError -> W.World<S,C,R,E>,~L:Type,~Out:Type,~recover:L -> Out -> List<Request.Packet<P>> -> L,local:L,output:Out,owner:Request.Owner<S,C,R,E,P,identity,project>,outcome:T.Outcome<Error>) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  deferred(~S,~C,~R,~E,~P,~Error,~L,~Out,~recover,local,output,Request.finish(~S,~C,~R,~E,~P,~Error,~identity,~project,~attempt,~delivery_recover,owner,outcome))
