import Base
import ordinary-declaration.bend as Identity
import schema-fragments.bend as SF
import bundle-pack.bend as Pack
import bundle-requests.bend as Cmd
import bundle-construction.bend as CS
import bundle-insert-adapter.bend as AD

# Metadata only. Raw constructors and the declared factory/binding remain trusted.
# This plan supplies no World, storage or provider capability.
type Plan<-S:Data,-Raw:Type,-Cooked:Type> is Data:
  Plan{entries:List<&2,SF.Entry<S>>}
def terminal(~S:Data) -> Plan<S,Unit,Unit>:Plan{[]}
def component(~S:Data,~I:Type,~P:Type,+identity:Identity.Declaration<S,P>) -> Plan<S,I,P>:
  Plan{[SF.Entry{SF.Component{},Identity.key(~S,~P,identity),Identity.key(~S,~P,identity)}]}
def compose(~S:Data,~HR:Type,~HC:Type,~TR:Type,~TC:Type,head:Plan<S,HR,HC>,tail:Plan<S,TR,TC>) -> Plan<S,Pack.Pack<HR,TR>,Pack.Pack<HC,TC>>:
  match head tail:
    case Plan{heads} Plan{tails}:Plan{List.append(&2,SF.Entry<S>,heads,tails)}
def checked(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~construct:Context -> Raw -> CS.Staged<Context,Raw,Cooked,Error>,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,validation:SF.Validation,owner:AD.Owner<S,Store,R,E,Packet,Context>,input:Cmd.Input<S,Raw>) -> AD.Owner<S,Store,R,E,Packet,Context> & Cmd.Output<S,Raw,Error>:
  match validation input:
    case SF.Invalid{error} Cmd.Input{_,raw}:(owner,Cmd.Refused{raw,AD.DeclarationRefused{error}})
    case SF.Valid{} input:Cmd.request(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Cooked,~Error,~construct,~pack,~unpack,owner,input)
def request(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~construct:Context -> Raw -> CS.Staged<Context,Raw,Cooked,Error>,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,plan:Plan<S,Raw,Cooked>,owner:AD.Owner<S,Store,R,E,Packet,Context>,input:Cmd.Input<S,Raw>) -> AD.Owner<S,Store,R,E,Packet,Context> & Cmd.Output<S,Raw,Error>:
  match plan:
    case Plan{entries}:checked(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Cooked,~Error,~construct,~pack,~unpack,SF.validate(~S,entries),owner,input)
