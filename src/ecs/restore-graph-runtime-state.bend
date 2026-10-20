import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./world-resource-owner.bend as WR
import ./owner-product.bend as Product
import ./event-family-runtime.bend as Family
import ./event-family-routing.bend as Route
import ./event-notice-runtime.bend as Mixed
import ./owned-event-family-catalog.bend as Catalog
import ./relation-commands.bend as Notice
import ./internal/relation-failures/domains.bend as Domains
import ./internal/relation-failures/queue.bend as Queue
import ./relation-types.bend as Graph

def classify(~S:Data,~P:Data,value:Notice.Notice<S,P>) -> Maybe<Domains.DescriptorKey<S>>:
  match value:
    case Notice.RelationFailed{Graph.Failure{Graph.Descriptor{id,_,_,_},_,_,_,_}}:Some{Domains.DeclaredKey{id}}
    case _:None{}
def publish_clocked(~S:Data,~C:Type,~Resources:Type,~P:Data,~F:Type,~Owners:Type,~sync:F -> Nat -> List<&2,P> -> F,metadata:Mixed.State<S,P,F,Owners> & Nat,result:W.World<S,C,Resources,Notice.Notice<S,P>> & Tick.Tick) -> Route.Runtime<S,C,Resources,Notice.Notice<S,P>,Mixed.State<S,P,F,Owners>>:
  match metadata result:
    case (Mixed.State{typed,Mixed.Failures{domains,positions,+failureTick,start,boundary,capacity,nextReader}},+tick),(world,clock):Mixed.ingest(~S,~C,~Resources,~P,~F,~Owners,~sync,~classify(~S,~P),1n+Nat.max(1n,Nat.max(tick,Nat.max(failureTick,Tick.total(clock)))),Route.Runtime{world,Mixed.State{typed,Mixed.Failures{domains,positions,failureTick,start,boundary,capacity,nextReader}},tick})
def publish(~S:Data,~C:Type,~Resources:Type,~P:Data,~F:Type,~Owners:Type,~sync:F -> Nat -> List<&2,P> -> F,world:W.World<S,C,Resources,Notice.Notice<S,P>>,metadata:Mixed.State<S,P,F,Owners> & Nat) -> Route.Runtime<S,C,Resources,Notice.Notice<S,P>,Mixed.State<S,P,F,Owners>>:
  publish_clocked(~S,~C,~Resources,~P,~F,~Owners,~sync,metadata,W.clock(~S,~C,~Resources,~Notice.Notice<S,P>,world))

# This adapter retains the ordinary mixed Runtime's exact metadata/owner type.
def clear_domain(~S:Data,~P:Data,value:Domains.Domain<S,Notice.Notice<S,P>>) -> Domains.Domain<S,Notice.Notice<S,P>>:
  match value:
    case Domains.Domain{key,Queue.Queue{_,_,_,dropped},readers}:Domains.Domain{key,Queue.Queue{[],[],0n,dropped},readers}
def clear_domains(~S:Data,~P:Data,values:List<&2,Domains.Domain<S,Notice.Notice<S,P>>>) -> List<&2,Domains.Domain<S,Notice.Notice<S,P>>>:
  match values:
    case []:[]
    case head <> rest:clear_domain(~S,~P,head) <> clear_domains(~S,~P,rest)
def clear_metadata(~S:Data,~P:Data,~F:Type,~Owners:Type,~clear:F -> F,metadata:Mixed.State<S,P,F,Owners> & Nat) -> Mixed.State<S,P,F,Owners> & Nat:
  match metadata:
    case (Mixed.State{Family.State{family,owners,_,familyStart},Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}},familyTick):(Mixed.State{Family.State{clear(family),owners,[],familyStart},Mixed.Failures{clear_domains(~S,~P,domains),positions,tick,frameStart,boundary,capacity,nextReader}},familyTick)
def drained(~S:Data,~C:Type,~User:Type,~Logs:Type,~Machines:Type,~P:Data,~F:Type,~Owners:Type,~Receipt:Type,~clear:F -> F,rest:WR.Rest<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>>,user:User,machines:Machines,metadata:Mixed.State<S,P,F,Owners> & Nat,result:Logs & Receipt) -> W.World<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>> & ((Mixed.State<S,P,F,Owners> & Nat) & Receipt):
  match result:
    case (logs,receipt):(W.events_replace(~S,~C,~Product.Owner<Product.Owner<User,Logs>,Machines>,~Notice.Notice<S,P>,WR.put(~S,~C,~Product.Owner<Product.Owner<User,Logs>,Machines>,~Notice.Notice<S,P>,rest,Product.Owner{Product.Owner{user,logs},machines}),[]),(clear_metadata(~S,~P,~F,~Owners,~clear,metadata),receipt))
def resource_taken(~S:Data,~C:Type,~User:Type,~Logs:Type,~Machines:Type,~P:Data,~F:Type,~Owners:Type,~Receipt:Type,~drain:Logs -> Logs & Receipt,~clear:F -> F,metadata:Mixed.State<S,P,F,Owners> & Nat,result:WR.Rest<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>> & Product.Owner<Product.Owner<User,Logs>,Machines>) -> W.World<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>> & ((Mixed.State<S,P,F,Owners> & Nat) & Receipt):
  match result:
    case (rest,Product.Owner{Product.Owner{user,logs},machines}):drained(~S,~C,~User,~Logs,~Machines,~P,~F,~Owners,~Receipt,~clear,rest,user,machines,metadata,drain(logs))
# Internal admitted cleanup derives its complete log/stream tree from the catalog.
# Allocator, store, registrations and all progress fields are unchanged.
def admit(~S:Data,~C:Type,~User:Type,~Logs:Type,~Machines:Type,~P:Data,~F:Type,~Owners:Type,~Receipt:Type,~retain:Logs -> List<&2,P> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,~clear:F -> F,-catalog:Catalog.Catalog<P,Logs,F,Receipt,retain,drain,clear>,world:W.World<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>>,metadata:Mixed.State<S,P,F,Owners> & Nat) -> W.World<S,C,Product.Owner<Product.Owner<User,Logs>,Machines>,Notice.Notice<S,P>> & ((Mixed.State<S,P,F,Owners> & Nat) & Receipt):
  resource_taken(~S,~C,~User,~Logs,~Machines,~P,~F,~Owners,~Receipt,~drain,~clear,metadata,WR.take(~S,~C,~Product.Owner<Product.Owner<User,Logs>,Machines>,~Notice.Notice<S,P>,world))
