import Base
import ordinary-bundle.bend as Front
import bundle.bend as B
import runtime.bend as R
import observe.bend as O
import drive.bend as Drive
import ../complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-canonical-construction.bend as Head
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Provider
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

def Raw() -> Type:P.Pack<K.Incoming,B.Raw()>
def Cooked() -> Type:P.Pack<K.Payload,B.Cooked()>
type Packet is Type:Packet{cooked:Cooked(),undo:Cooked() -> Raw()}
def pack(cooked:Cooked(),undo:Cooked() -> Raw()) -> Packet:Packet{cooked,undo}
def unpack(packet:Packet) -> Raw():
  match packet:
    case Packet{cooked,undo}:undo(cooked)
def construct(context:K.Context<K.SchemaA>,raw:Raw()) -> CS.Staged<K.Context<K.SchemaA>,Raw(),Cooked(),B.ConstructorError()>:
  Head.canonical_stage(~K.SchemaA,~K.Context<K.SchemaA>,~K.Rest,~K.Incoming,~K.Payload,~B.Raw(),~B.Cooked(),~K.Custom,~K.identity(~K.SchemaA),~K.project,~K.incoming,~K.decoded,~K.take(~K.SchemaA),~K.put(~K.SchemaA),~K.stage(~K.SchemaA),context,raw)
def plan() -> Front.Plan<K.SchemaA,Raw(),Cooked()>:Front.compose(~K.SchemaA,~K.Incoming,~K.Payload,~B.Raw(),~B.Cooked(),Front.component(~K.SchemaA,~K.Incoming,~K.Payload,K.identity(~K.SchemaA)),B.plan())
def Input() -> Type:Cmd.Input<K.SchemaA,Raw()>
def Output() -> Type:Cmd.Output<K.SchemaA,Raw(),B.ConstructorError()>
def Owner() -> Type:AD.Owner<K.SchemaA,B.Store,R.Mail,U32,Packet,K.Context<K.SchemaA>>
def request(owner:Owner(),input:Input()) -> Owner() & Output():Front.request(~K.SchemaA,~B.Store,~R.Mail,~U32,~Packet,~K.Context<K.SchemaA>,~Raw(),~Cooked(),~B.ConstructorError(),~construct,~pack,~unpack,plan(),owner,input)
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input(),Output()>,input:Input(),owner:H) -> H & Output():Cap.owned_request(~H,~Input(),~Output(),~cap,owner,input)
def run_owned(owner:Owner(),input:Input()) -> Owner() & Output():Provider.provide_owned(~Owner(),~Input(),~Output(),~Input(),~Output(),~request,~body,input,owner)
def Args() -> Type:K.Context<K.SchemaA> & Input()
type OwnedOutput is Type:OwnedOutput{context:K.Context<K.SchemaA>,output:Output(),prepared:List<BT.Prepared<K.SchemaA,Packet>>}
def finished(context:K.Context<K.SchemaA>,output:Output(),prepared:List<BT.Prepared<K.SchemaA,Packet>>,result:T.Returned<R.World(),String>) -> Sys.Outcome<R.World(),String,OwnedOutput>:
  match result:
    case T.Returned{world,T.Success{}}:Sys.Succeeded{world,OwnedOutput{context,output,prepared}}
    case T.Returned{world,T.Failure{error}}:Sys.Failed{world,error}
def owned_result(result:Owner() & Output()) -> Sys.Outcome<R.World(),String,OwnedOutput>:
  match result:
    case (AD.Owner{BT.Batch{tx,prepared},context},output):finished(context,output,prepared,Commands.tx_finish(~K.SchemaA,~B.Store,~R.Mail,~U32,~String,tx,T.Success{}))
def runner(world:R.World(),args:Args()) -> Sys.Outcome<R.World(),String,OwnedOutput>:
  match args:
    case (context,input):owned_result(run_owned(AD.Owner{BT.begin(~K.SchemaA,~B.Store,~R.Mail,~U32,~Packet,T.begin(~R.World(),~U32,world)),context},input))
def Registry() -> Type:Sys.Registry<K.SchemaA,B.Store,R.Mail,U32,Args(),String,OwnedOutput,runner>
def RunResult() -> Type:Sys.RunResult<K.SchemaA,B.Store,R.Mail,U32,Args(),String,OwnedOutput,runner>
def run(registry:Registry(),world:R.World(),context:K.Context<K.SchemaA>,raw:Raw()) -> RunResult():Sys.run_tracked(~K.SchemaA,~B.Store,~R.Mail,~U32,~Args(),~String,~OwnedOutput,~runner,registry,world,(context,Cmd.Input{Cmd.Spawn{},raw}))
def raw_join(head:K.Incoming & String,tail:B.Raw() & String) -> Raw() & String:
  match head tail:
    case (a,x),(b,y):(P.Pack{a,b},"duplicate-head=" ++ x ++ "/remaining=" ++ y)
def raw_observe(raw:Raw()) -> Raw() & String:
  match raw:
    case P.Pack{head,tail}:raw_join(K.incoming_observe(head),K.raw_observe(tail))
def packet_text(observed:Raw() & String) -> String:
  match observed:
    case (raw,text):text
def prepared_text(prepared:List<BT.Prepared<K.SchemaA,Packet>>) -> String:
  match prepared:
    case []:"[]"
    case BT.Prepared{target,payload,position} <> rest:"[" ++ packet_text(raw_observe(unpack(payload))) ++ ";" ++ prepared_text(rest) ++ "]"
    case BT.ReservationReceipt{target} <> rest:"[reservation;" ++ prepared_text(rest) ++ "]"
def registry_observe(owner:Registry()) -> Registry() & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"{ns=" ++ U32.show(ns) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(&2,String,x => x,access) ++ ",cursor=" ++ U32.show(cursor) ++ "}")
def extra_observed(normal:String,registry:Registry() & String,extra:K.Incoming & String) -> String:
  match registry extra:
    case (reg,r),(owner,e):normal ++ "\nduplicate-owner-final=" ++ e ++ "|registry=" ++ r
def extra_finished(registry:Registry(),extra:K.Incoming,normal:String) -> String:extra_observed(normal,registry_observe(registry),K.incoming_observe(extra))
def repaired(prefix:String,registry:Registry(),world:R.World(),context:K.Context<K.SchemaA>,raw:Raw()) -> String:
  match raw:
    case P.Pack{extra,remaining}:prefix ++ "\n" ++ extra_finished(registry,extra,Drive.begin_returned(world,context,remaining))
def refusal_world(prefix:String,registry:Registry(),context:K.Context<K.SchemaA>,raw:Raw(),result:R.World() & String) -> String:
  match result:
    case (world,text):repaired(prefix ++ "|world=" ++ text,registry,world,context,raw)
def refusal_context(prefix:String,registry:Registry(),world:R.World(),raw:Raw(),result:K.Context<K.SchemaA> & String) -> String:
  match result:
    case (context,text):refusal_world(prefix ++ "|context=" ++ text,registry,context,raw,O.world(world))
def refusal_raw(prefix:String,registry:Registry(),world:R.World(),context:K.Context<K.SchemaA>,result:Raw() & String) -> String:
  match result:
    case (raw,text):refusal_context(prefix ++ "|raw=" ++ text,registry,world,raw,K.context_observe(~K.SchemaA,context))
def completed(prefix:String,result:RunResult()) -> String:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,OwnedOutput{context,Cmd.Refused{raw,AD.DeclarationRefused{SF.DuplicateKey{SF.Component{},key}}},prepared}}}:refusal_raw(prefix ++ "\nduplicate-refused=" ++ key ++ "|prepared=" ++ prepared_text(prepared),registry,world,context,raw_observe(raw))
    case Sys.Completed{registry,Sys.Succeeded{world,OwnedOutput{context,output,prepared}}}:"unexpected-admission|prepared=" ++ prepared_text(prepared)
    case Sys.Completed{registry,Sys.Failed{world,error}}:"unexpected-failure=" ++ error
    case Sys.RegistrationRejected{registry,world,args}:"unexpected-registration-refusal"
def initial_world(registry:Registry(),context:K.Context<K.SchemaA>,result:R.World() & String) -> String:
  match result:
    case (world,text):completed("duplicate-initial=" ++ text,run(registry,world,context,P.Pack{K.Incoming{ANode{ALeaf{91},ALeaf{92}},D.Number{8},False{}},Drive.sample(D.Text{"bad"},False{})}))
def registered(result:Sys.RegistrationResult<K.SchemaA,B.Store,R.Mail,U32,Args(),String,OwnedOutput,runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:initial_world(registry,K.context(~K.SchemaA),O.world(world))
    case Sys.RegistrationFailed{world}:"unexpected-registration-failure"
def begun(world:R.World()) -> String:registered(Sys.register(~K.SchemaA,~B.Store,~R.Mail,~U32,~Args(),~String,~OwnedOutput,~runner,world,"duplicate-bundle",["bundle:write"]))
