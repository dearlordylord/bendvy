import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as System

def selected(~P:Type,owner:P) -> P & Bool: (owner,True{})
def read(~S:Data,~P:Type,~Request:Type,~Projection:Data,~at:P -> Request -> P & Projection,name:String) -> Query.Declaration<S,P,Cap.Request<P,Request,Projection>>:
  Query.Declaration{Cap.Request{at},selected(~P),[Query.Clause{name,Query.Read{}}]}
def absent(~S:Data,~P:Type) -> Query.Declaration<S,P,Unit>:
  Query.Declaration{Unit{},selected(~P),[]}
def access(~S:Data,~P:Type,~Request:Type,~Projection:Data,~declaration:Query.Declaration<S,P,Cap.Request<P,Request,Projection>>) -> List<&2,String>:
  System.access(~S,Query.clauses(~S,~P,~Cap.Request<P,Request,Projection>,declaration))
def at(~S:Data,~P:Type,~Request:Type,~Projection:Data,~declaration:Query.Declaration<S,P,Cap.Request<P,Request,Projection>>,owner:P,input:Request) -> P & Projection:
  Cap.request(~P,~Request,~Projection,~Query.grant(~S,~P,~Cap.Request<P,Request,Projection>,declaration),owner,input)
def provide(~S:Data,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Observation:Type,~declaration:Query.Declaration<S,P,Cap.Request<P,Request,Projection>>,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & Observation,owner:P,args:Args) -> P & Observation:
  Cap.invoke_owned(~(H => Cap.Request<H,Request,Projection>),~Args,~Observation,~(H => read => input => ctx => body(H,read,ctx,input)),~P,~Query.grant(~S,~P,~Cap.Request<P,Request,Projection>,declaration),args,owner)
