import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-bundle.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/owned-public-result-v1/composition.bend as Co
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/owned-public-result-v1/schema-b.bend as O
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-other.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-b.bend as Previous
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/transactions/schema-b.bend as Existing
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Queue
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF

def Input() -> Type: Co.Input<O.Raw()>
def Output() -> Type: Co.Composed<A.Schema,O.Raw(),String>
def RequestInput() -> Type: Cmd.Input<A.Schema,O.Raw()>
def RequestOutput() -> Type: Cmd.Output<A.Schema,O.Raw(),String>
# Closed schema-author lowering keeps four staged entries and five physical families.
# Plan constructor is trusted metadata; keys derive actual five typed declarations.
def array_entry(+identity:Identity.Declaration<A.Schema,Array<U32>>) -> SF.Entry<A.Schema>:
  +key=Identity.key(~A.Schema,~Array<U32>,identity)
  SF.Entry{SF.Component{},key,key}
def tag_entry() -> SF.Entry<A.Schema>:
  +key=Identity.key(~A.Schema,~K.Tag,A.identity_tag())
  SF.Entry{SF.Component{},key,key}
def value_entry() -> SF.Entry<A.Schema>:
  +key=Identity.key(~A.Schema,~U32,A.identity_value())
  SF.Entry{SF.Component{},key,key}
def plan() -> Ordinary.Plan<A.Schema,O.Raw(),O.Cooked()>:
  Ordinary.Plan{[array_entry(A.identity_a()),array_entry(A.identity_front()),array_entry(A.identity_b()),tag_entry(),value_entry()]}
def request(owner:O.Owner(),input:RequestInput()) -> O.Owner() & RequestOutput():
  Ordinary.request(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~K.Context,~O.Raw(),~O.Cooked(),~String,~K.stage_0,~O.pack,~O.unpack,plan(),owner,input)
def clean_batch(+target:W.Handle<A.Schema>,batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match batch:
    case BT.Batch{tx,prepared}: BT.Batch{T.stage(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,tx,w => Queue.despawn_apply_with(~A.Schema,~A.Store,~A.Mail,~U32,~Existing.clear,w,target)),prepared}
def request_clean(owner:O.Owner(),input:RequestInput()) -> O.Owner() & RequestOutput():
  match owner input:
    case AD.Owner{batch,context}, Cmd.Input{Cmd.Insert{+target},raw}: request(AD.Owner{clean_batch(target,batch),context},Cmd.Input{Cmd.Insert{target},raw})
    case owner, input: request(owner,input)
type Args is Type:
  Args{input:Input(),retry:Bool,fail:Bool,cleanup:Bool}
type GameResult is Type:
  GameResult{result:Output(),first:Maybe<&2,AD.Refusal<String>>,returned:String}
def retried(~H:Type,error:AD.Refusal<String>,returned:String,result:H & Output()) -> H & GameResult:
  match result:
    case (ctx,out): (ctx,GameResult{out,Some{error},returned})
def retry_seen(~H:Type,~cap:Owned.OwnedRequest<H,RequestInput(),RequestOutput()>,ctx:H,retry:Bool,replacement:O.Raw(),+error:AD.Refusal<String>,seen:O.Raw() & String) -> H & GameResult:
  match retry seen:
    case False{}, (raw,text): (ctx,GameResult{Co.Composed{Cmd.Refused{raw,error},None{},Some{replacement}},Some{error},text})
    case True{}, (raw,text): retried(~H,error,text,Co.run(~A.Schema,~O.Raw(),~String,~H,~cap,Co.Input{O.repaired(raw),replacement},ctx))
def attempted(~H:Type,~cap:Owned.OwnedRequest<H,RequestInput(),RequestOutput()>,retry:Bool,result:H & Output()) -> H & GameResult:
  match result:
    case (ctx,Co.Composed{Cmd.Refused{raw,error},None{},Some{replacement}}): retry_seen(~H,~cap,ctx,retry,replacement,error,O.raw_0(raw))
    case (ctx,out): (ctx,GameResult{out,None{},""})
def body(~H:Type,~cap:Owned.OwnedRequest<H,RequestInput(),RequestOutput()>,args:Args,ctx:H) -> H & GameResult:
  match args:
    case Args{input,retry,_,_}: attempted(~H,~cap,retry,Co.run(~A.Schema,~O.Raw(),~String,~H,~cap,input,ctx))
def provided(owner:O.Owner(),args:Args,cleanup:Bool) -> O.Owner() & GameResult:
  match cleanup:
    case False{}: Public.provide_owned(~O.Owner(),~RequestInput(),~RequestOutput(),~Args,~GameResult,~request,~body,args,owner)
    case True{}: Public.provide_owned(~O.Owner(),~RequestInput(),~RequestOutput(),~Args,~GameResult,~request_clean,~body,args,owner)

def provisioned(owners:O.Owner() & Args) -> O.Owner() & GameResult:
  match owners:
    case (owner,Args{input,retry,fail,+cleanup}): provided(owner,Args{input,retry,fail,cleanup},cleanup)
def bound(result:SF.Bound<A.Schema,O.Owner() & Args,O.Owner() & GameResult>) -> O.Owner() & GameResult:
  match result:
    case SF.Built{output}: output
    case SF.BindRejected{+error,SF.Fragment{_,(owner,Args{Co.Input{initial,replacement},_,_,_})}}: (owner,GameResult{Co.Composed{Cmd.Refused{initial,AD.DeclarationRefused{error}},None{},Some{replacement}},Some{AD.DeclarationRefused{error}},""})
def declared(owner:O.Owner(),args:Args) -> O.Owner() & GameResult:
  bound(Public.provision_declared(~A.Schema,~(O.Owner() & Args),~(O.Owner() & GameResult),~provisioned,SF.Fragment{Existing.available(),(owner,args)},Existing.required()))

def handle(target:W.Handle<A.Schema>) -> String:
  match target:
    case W.Handle{ns,id}: U32.show(ns) ++ ":" ++ U32.show(id)
def command_output(output:RequestOutput()) -> String:
  match output:
    case Cmd.Accepted{target,spawned}: "accepted:" ++ handle(target) ++ ":" ++ Bool.show(spawned)
    case Cmd.Refused{raw,error}: "refused:" ++ O.refusal(error) ++ ":" ++ K.raw_0(raw)
def second(output:Maybe<&1,RequestOutput()>) -> String:
  match output:
    case None{}: "none"
    case Some{out}: command_output(out)
def unsubmitted(raw:Maybe<&1,O.Raw()>) -> String:
  match raw:
    case None{}: "none"
    case Some{raw}: K.raw_0(raw)
def flow_text(out:Output()) -> String:
  match out:
    case Co.Composed{first,last,unused}: "first=" ++ command_output(first) ++ "|second=" ++ second(last) ++ "|unsubmitted=" ++ unsubmitted(unused)
def game_text(game:GameResult) -> String:
  match game:
    case GameResult{result,error,returned}: flow_text(result) ++ "|first-refusal=" ++ O.first(error) ++ "|returned-before-retry=" ++ returned

def packet_seen(+target:W.Handle<A.Schema>,+position:Nat,tail:List<BT.Prepared<A.Schema,A.Packet>>,texts:List<&2,String>,seen:A.Packet & String) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match seen:
    case (packet,text): (BT.Prepared{target,packet,position} <> tail,(handle(target) ++ ":" ++ Nat.show(position) ++ ":" ++ text) <> texts)
def prepared_head(head:BT.Prepared<A.Schema,A.Packet>,seen:List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match head seen:
    case BT.ReservationReceipt{+target}, (tail,texts): (BT.ReservationReceipt{target} <> tail,("receipt:" ++ handle(target)) <> texts)
    case BT.Prepared{+target,packet,+position}, (tail,texts): packet_seen(target,position,tail,texts,O.packet_read(packet))
def prepared_read(owners:List<BT.Prepared<A.Schema,A.Packet>>) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match owners:
    case []: ([],[])
    case head <> tail: prepared_head(head,prepared_read(tail))

# A failed System has no affine output channel. Return actual packet owners into
# the existing typed World mailbox before producing the genuine Sy.Failed.
def return_output(world:W.World<A.Schema,A.Store,A.Mail,U32>,out:RequestOutput()) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match out:
    case Cmd.Accepted{_,_}: world
    case Cmd.Refused{raw,error}: A.returned(world,A.Original{raw},"body-failed")
def return_second(world:W.World<A.Schema,A.Store,A.Mail,U32>,out:Maybe<&1,RequestOutput()>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match out:
    case None{}: world
    case Some{out}: return_output(world,out)
def return_unused(world:W.World<A.Schema,A.Store,A.Mail,U32>,raw:Maybe<&1,O.Raw()>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match raw:
    case None{}: world
    case Some{raw}: A.returned(world,A.Original{raw},"body-failed")
def return_game(world:W.World<A.Schema,A.Store,A.Mail,U32>,game:GameResult) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match game:
    case GameResult{Co.Composed{first,last,unused},_,_}: return_unused(return_second(return_output(world,first),last),unused)
def return_packets(packets:List<A.Packet>,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match packets:
    case []: world
    case packet <> tail: return_packets(tail,A.returned(world,A.Original{O.unpack(packet)},"body-failed"))
def failure_meta(context:K.Context,prepared:List<&2,String>,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{old,raw,installed,cold,errors},events,pending,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,A.Mail{old,raw,installed,cold,[Some{"body-failed|caller-context=" ++ A.context_text(context) ++ "|prepared=" ++ List.show(&2,String,K.string_identity,prepared)}]},events,pending,regs,system,clock}
type Delivery is Type:
  Delivery{context:K.Context,game:GameResult,prepared:List<&2,String>}
def finished(context:K.Context,game:GameResult,prepared:List<&2,String>,result:BT.Finished<A.Schema,A.Store,A.Mail,U32,A.Packet,Unit>) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match result:
    case BT.Committed{world}: Sy.Succeeded{world,Delivery{context,game,prepared}}
    case BT.Failed{world,packets,error}: Sy.Failed{failure_meta(context,prepared,return_packets(packets,return_game(world,game))),error}
def finishing(tx:T.Tx<W.World<A.Schema,A.Store,A.Mail,U32>,U32>,context:K.Context,game:GameResult,fail:Bool,seen:List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match fail seen:
    case False{}, (prepared,texts): finished(context,game,texts,BT.finish(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~Unit,~Previous.attempt,~Previous.recover,BT.Batch{tx,prepared},T.Success{}))
    case True{}, (prepared,texts): finished(context,game,texts,BT.finish(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~Unit,~Previous.attempt,~Previous.recover,BT.Batch{tx,prepared},T.Failure{Unit{}}))
def invoked(fail:Bool,result:O.Owner() & GameResult) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match result:
    case (AD.Owner{BT.Batch{tx,prepared},context},game): finishing(tx,context,game,fail,prepared_read(prepared))
def runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Args) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match args:
    case Args{input,retry,+fail,+cleanup}: invoked(fail,declared(AD.Owner{Existing.begin(world),K.context()},Args{input,retry,fail,cleanup}))
def delivery(delivery:Delivery) -> String:
  match delivery:
    case Delivery{context,game,prepared}: game_text(game) ++ "|caller-context=" ++ A.context_text(context) ++ "|prepared=" ++ List.show(&2,String,K.string_identity,prepared)
def registry(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,K.string_identity,access) ++ ":" ++ U32.show(cursor)
def ran(mode:Nat,result:Sy.RunResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Delivery,runner>) -> String:
  match result:
    case Sy.Completed{Sy.Registry{ns,id,name,access,cursor},Sy.Succeeded{world,out}}: "Succeeded|" ++ O.world_snapshot(O.transform(mode,world)) ++ "|registry=" ++ registry(ns,id,name,access,cursor) ++ "|" ++ delivery(out)
    case Sy.Completed{Sy.Registry{ns,id,name,access,cursor},Sy.Failed{world,Unit{}}}: "Failed|" ++ O.world_snapshot(O.transform(mode,world)) ++ "|registry=" ++ registry(ns,id,name,access,cursor)
    case _: "UNEXPECTED_REGISTRATION_RESULT"
def registered(mode:Nat,args:Args,result:Sy.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Delivery,runner>) -> String:
  match result:
    case Sy.Registered{world,registration}: ran(mode,Sy.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Delivery,~runner,registration,world,args))
    case _: "UNEXPECTED_REGISTRATION_REFUSAL"
def run(mode:Nat,invalid:Bool,retry:Bool,fail:Bool,cleanup:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  registered(mode,Args{Co.Input{K.input(True{},Bool.not(invalid)),Previous.replacement()},retry,fail,cleanup},Sy.register(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Delivery,~runner,world,"owned-commands",["write:a","write:front","write:b","write:tag","write:value","bundle.spawn","bundle.insert"]))
