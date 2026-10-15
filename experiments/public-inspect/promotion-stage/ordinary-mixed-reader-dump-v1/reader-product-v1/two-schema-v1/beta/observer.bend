import Base
import fixture.bend as F
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/lifecycle.bend as Life
import ../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../src/ecs/event-stream.bend as Stream
import ../../../../../../../src/ecs/event-family-runtime.bend as Family
import ../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../src/ecs/internal/relation-failures/domains.bend as Domains
import ../../../../../../../src/ecs/internal/relation-failures/queue.bend as Queue
import ../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../../../src/ecs/ordinary-app-access.bend as Access

import ../../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as ReaderParam
import ../../../../../../../src/ecs/reader-parameter.bend as RP
import ../../../../../../../src/ecs/removals.bend as Rm

def strings(items:List<&2,String>) -> String:
  F.list_json(~String,~F.quoted,items)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:"position("++U32.show(id)++","++Nat.show(cursor)++","++Nat.show(registeredAt)++")"
def batch(~A:Data,~render:A -> String,value:Ev.Batch<A>) -> String:
  match value:
    case Ev.Batch{tick,values}:"batch("++Nat.show(tick)++","++F.list_json(~A,~render,values)++")"
def domain_key(value:Event.Domain<F.Schema,F.event_type()>) -> String:
  match value:
    case Event.Domain{key}:F.quoted(key)
def stream(value:F.family_type()) -> String:
  match value:
    case Stream.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:"stream("++domain_key(domain)++","++F.list_json(~Ev.Batch<F.event_type()>,~batch(~F.event_type(),~F.notice_json),batches)++","++F.list_json(~Ev.Position,~position,positions)++","++U32.show(nextReader)++","++Nat.show(frameStart)++","++Nat.show(boundary)++","++Nat.show(capacity)++","++Nat.show(dropped)++")"
def key(value:Domains.DescriptorKey<F.Schema>) -> String:
  match value:
    case Domains.DeclaredKey{id}:U32.show(id)
def queued(value:Queue.Batch<F.event_type()>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:"batch("++Nat.show(tick)++","++Nat.show(count)++","++F.list_json(~F.event_type(),~F.notice_json,values)++")"
def queue(value:Queue.Queue<F.event_type()>) -> String:
  match value:
    case Queue.Queue{front,back,size,dropped}:"queue("++F.list_json(~Queue.Batch<F.event_type()>,~queued,front)++","++F.list_json(~Queue.Batch<F.event_type()>,~queued,back)++","++Nat.show(size)++","++Nat.show(dropped)++")"
def domain(value:Domains.Domain<F.Schema,F.event_type()>) -> String:
  match value:
    case Domains.Domain{identity,values,readers}:"domain("++key(identity)++","++queue(values)++","++F.list_json(~U32,~U32.show,readers)++")"
def failures(value:Mixed.Failures<F.Schema,F.Publication>) -> String:
  match value:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:"failures("++F.list_json(~Domains.Domain<F.Schema,F.event_type()>,~domain,domains)++","++F.list_json(~Ev.Position,~position,positions)++","++Nat.show(tick)++","++Nat.show(frameStart)++","++Nat.show(boundary)++","++Nat.show(capacity)++","++U32.show(nextReader)++")"
def state(value:Mixed.State<F.Schema,F.Publication,F.family_type(),Unit>) -> Mixed.State<F.Schema,F.Publication,F.family_type(),Unit> & String:
  match value:
    case Mixed.State{Family.State{+family,Unit{},+journal,+frameStart},+failureState}:(Mixed.State{Family.State{family,Unit{},journal,frameStart},failureState},"state("++stream(family)++","++F.list_json(~Ev.Batch<F.Publication>,~batch(~F.Publication,~F.publication_json),journal)++","++Nat.show(frameStart)++","++failures(failureState)++")")
def bool_array_result(value:Array<Bool> & Array<Bool>) -> Array<Bool> & String:
  match value:
    case (array,copy):(array,List.show(&1,Bool,F.boolean,Array.to_list(~Bool,copy)))
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  bool_array_result(Array.clone(Bool,value))
def cell(value:Maybe<&1,U32>) -> Maybe<&1,U32> & String:
  match value:
    case None{}:(None{},"none")
    case Some{+number}:(Some{number},"some("++U32.show(number)++")")
def column_leaf(value:Maybe<&1,U32> & String) -> Array<Maybe<&1,U32>> & String:
  match value:
    case (value,text):(ALeaf{value},"L("++text++")")
def column_nodes(value:(Array<Maybe<&1,U32>> & String) & (Array<Maybe<&1,U32>> & String)) -> Array<Maybe<&1,U32>> & String:
  match value:
    case ((left,leftText),(right,rightText)):(ANode{left,right},"N("++leftText++","++rightText++")")
def column_array(value:Array<Maybe<&1,U32>>) -> Array<Maybe<&1,U32>> & String:
  match value:
    case ALeaf{value}:column_leaf(cell(value))
    case ANode{left,right}:column_nodes((column_array(left),column_array(right)))
def stamp(value:Life.Entry) -> String:
  match value:
    case Life.Entry{id,Life.Stamp{added,changed}}:"stamp("++U32.show(id)++","++U32.show(added)++","++U32.show(changed)++")"
def column_returned(+stamps:List<&2,Life.Entry>,result:Array<Maybe<&1,U32>> & String) -> F.store_type() & String:
  match result:
    case (values,text):(Col.Column{values,stamps},"column("++text++","++F.list_json(~Life.Entry,~stamp,stamps)++")")
def column(value:F.store_type()) -> F.store_type() & String:
  match value:
    case Col.Column{values,stamps}:column_returned(stamps,column_array(values))
    case other:(other,"unexpected-column-variant")
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"registration("++U32.show(id)++","++F.quoted(name)++","++strings(access)++")"
def pending_tail(head:F.world_type() -> F.world_type(),result:List<(F.world_type() -> F.world_type())> & Nat) -> List<(F.world_type() -> F.world_type())> & Nat:
  match result:
    case (rest,count):(head <> rest,1n+count)
def pending(value:List<(F.world_type() -> F.world_type())>) -> List<(F.world_type() -> F.world_type())> & Nat:
  match value:
    case []:([],0n)
    case head <> rest:pending_tail(head,pending(rest))
type Header is Data:
  Header{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,F.event_type()>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
def world_final(header:Header,live:Array<Bool>,store:F.store_type(),commands:List<(F.world_type() -> F.world_type())>,liveText:String,storeText:String,count:Nat) -> F.world_type() & String:
  match header:
    case Header{+namespace,+nextId,+highWater,+capacity,+depth,+events,+registrations,+nextSystemId,+clock}:(W.World{namespace,nextId,highWater,live,capacity,depth,store,Unit{},events,commands,registrations,nextSystemId,clock},"world("++U32.show(namespace)++","++U32.show(nextId)++","++U32.show(highWater)++","++liveText++","++U32.show(capacity)++","++Nat.show(depth)++","++storeText++",unit,"++F.list_json(~F.event_type(),~F.notice_json,events)++","++Nat.show(count)++","++F.list_json(~W.RegistrationMeta,~registration,registrations)++","++U32.show(nextSystemId)++","++U32.show(clock)++")")
def world_commands(header:Header,live:Array<Bool>,store:F.store_type(),liveText:String,storeText:String,result:List<(F.world_type() -> F.world_type())> & Nat) -> F.world_type() & String:
  match result:
    case (commands,count):world_final(header,live,store,commands,liveText,storeText,count)
def world_store(header:Header,live:Array<Bool>,commands:List<(F.world_type() -> F.world_type())>,liveText:String,result:F.store_type() & String) -> F.world_type() & String:
  match result:
    case (store,storeText):world_commands(header,live,store,liveText,storeText,pending(commands))
def world_live(header:Header,store:F.store_type(),commands:List<(F.world_type() -> F.world_type())>,result:Array<Bool> & String) -> F.world_type() & String:
  match result:
    case (live,liveText):world_store(header,live,commands,liveText,column(store))
def world(value:F.world_type()) -> F.world_type() & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,Unit{},events,commands,registrations,nextSystemId,clock}:world_live(Header{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},store,commands,bool_array(live))
def context_state(worldValue:F.world_type(),worldText:String,+tick:Nat,result:Mixed.State<F.Schema,F.Publication,F.family_type(),Unit> & String) -> F.context_type() & String:
  match result:
    case (stateValue,stateText):(Route.Runtime{worldValue,stateValue,tick},"context("++worldText++","++stateText++","++Nat.show(tick)++")")
def context_world(stateValue:Mixed.State<F.Schema,F.Publication,F.family_type(),Unit>,tick:Nat,result:F.world_type() & String) -> F.context_type() & String:
  match result:
    case (worldValue,worldText):context_state(worldValue,worldText,tick,state(stateValue))
def context(value:F.context_type()) -> F.context_type() & String:
  match value:
    case Route.Runtime{worldValue,stateValue,tick}:context_world(stateValue,tick,world(worldValue))
def observed(value:F.context_type() & String) -> F.context_type() & DTO.Observation<String>:
  match value:
    case (value,text):(value,DTO.Observation{text,[]})
def observe(value:F.context_type()) -> F.context_type() & DTO.Observation<String>:
  observed(context(value))
def mode(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"read"
    case Query.Write{}:"write"
    case Query.Optional{}:"optional"
    case Query.With{}:"with"
    case Query.Without{}:"without"
    case Query.Added{}:"added"
    case Query.Changed{}:"changed"
def category(value:Fields.UseCategory) -> String:
  match value:
    case Fields.ComponentUse{}:"component"
    case Fields.ResourceUse{}:"resource"
    case Fields.EventUse{}:"event"
def source(value:Fields.ReaderSource) -> String:
  match value:
    case Fields.QuerySource{}:"query"
    case Fields.MessageSource{}:"message"
    case Fields.RemovalSource{}:"removal"
    case Fields.RelationFailureSource{}:"relation-failure"
def use(value:Fields.DeclaredUse) -> String:
  match value:
    case Fields.DeclaredUse{kind,origin,key,access}:"use("++category(kind)++","++source(origin)++","++F.quoted(key)++","++mode(access)++")"
def clause(value:Query.Clause<F.Schema>) -> String:
  match value:
    case Query.Clause{key,access}:"clause("++F.quoted(key)++","++mode(access)++")"
def binding(value:DTO.Binding<F.Schema>) -> String:
  match value:
    case DTO.Binding{namespace,id,name,access,cursor,slot,clauses}:"binding("++U32.show(namespace)++","++U32.show(id)++","++F.quoted(name)++","++strings(access)++","++U32.show(cursor)++","++F.quoted(slot)++","++F.list_json(~Query.Clause<F.Schema>,~clause,clauses)++")"
def description(value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<F.Schema>>,DTO.Observation<String>>>) -> String:
  match value:
    case None{}:"none"
    case Some{DTO.Product{bindings,DTO.Observation{physical,rendered}}}:"description("++F.list_json(~DTO.Binding<F.Schema>,~binding,bindings)++","++physical++","++strings(rendered)++")"

def access_category(value:Access.Category) -> String:
  match value:
    case Access.Components{}:"components"
    case Access.Resources{}:"resources"
    case Access.Events{}:"events"
    case Access.Services{}:"services"
def role(value:Access.Role) -> String:
  match value:
    case Access.Reader{}:"reader"
    case Access.Writer{}:"writer"
    case Access.Filter{}:"filter"
def access_use(value:Access.Use) -> String:
  match value:
    case Access.Use{namespace,id,name,access,kind}:"access("++U32.show(namespace)++","++U32.show(id)++","++F.quoted(name)++","++mode(access)++","++role(kind)++")"
def access_entry(value:Access.Entry) -> String:
  match value:
    case Access.Entry{kind,key,uses}:"entry("++access_category(kind)++","++F.quoted(key)++","++F.list_json(~Access.Use,~access_use,uses)++")"
def index(value:Maybe<&2,List<&2,Access.Entry>>) -> String:
  match value:
    case None{}:"none"
    case Some{entries}:"index("++F.list_json(~Access.Entry,~access_entry,entries)++")"

def registration_facts(value:RP.RegistrationFacts) -> String:
  match value:
    case RP.RegistrationFacts{namespace,id,name,access}:"facts("++U32.show(namespace)++","++U32.show(id)++","++F.quoted(name)++","++strings(access)++")"
def event_owner(value:F.e_owner()) -> F.e_owner() & String:
  match value:
    case ReaderParam.EventOwner{+facts,Route.Reader{+namespace,+id,+registryId}}:(ReaderParam.EventOwner{facts,Route.Reader{namespace,id,registryId}},"event-owner("++registration_facts(facts)++","++U32.show(namespace)++","++U32.show(id)++","++U32.show(registryId)++")")
def removal_owner(value:F.m_owner()) -> F.m_owner() & String:
  match value:
    case ReaderParam.RemovalOwner{+facts,Rm.Reader{+namespace,+id,+name,+cursor}}:(ReaderParam.RemovalOwner{facts,Rm.Reader{namespace,id,name,cursor}},"removal-owner("++registration_facts(facts)++","++U32.show(namespace)++","++U32.show(id)++","++F.quoted(name)++","++Nat.show(cursor)++")")
def maybe_id(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{id}:"some("++U32.show(id)++")"
def relation_owner(value:F.r_owner()) -> F.r_owner() & String:
  match value:
    case ReaderParam.RelationOwner{+facts,+id,+keys}:(ReaderParam.RelationOwner{facts,id,keys},"relation-owner("++registration_facts(facts)++","++maybe_id(id)++","++F.list_json(~Domains.DescriptorKey<F.Schema>,~key,keys)++")")
def owner_returned(value:(F.e_owner() & String) & ((F.e_owner() & String) & ((F.m_owner() & String) & (F.r_owner() & String)))) -> F.all_owner() & String:
  match value:
    case ((ea,ta),((eb,tb),((m,tm),(r,tr)))):((Unit{},(ea,(eb,(m,r)))),"owners(unit,"++ta++","++tb++","++tm++","++tr++")")
def owners(value:F.all_owner()) -> F.all_owner() & String:
  match value:
    case (Unit{},(ea,(eb,(m,r)))):owner_returned((event_owner(ea),(event_owner(eb),(removal_owner(m),relation_owner(r)))))
