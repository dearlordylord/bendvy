import Base
import ../../../../../../../../../src/ecs/reader-parameter.bend as RP
import ../../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../../../src/ecs/compose.bend as Compose
import ../../../../../../../../../src/ecs/inspector.bend as Inspector
import ../../../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../../src/ecs/relation-commands.bend as Notice
import ../../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../../../src/ecs/inspector-query.bend as IQ
import ../ordinary-combined-consumer.bend as Core

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}

# These payloads are deliberately affine Type values. Their query projections
# are copyable values, as required by ordinary detached query rows.
type PayloadA is Type:
  PayloadA{number:U32,token:Token}
type Token is Type:
  Token{}
type PayloadB is Type:
  PayloadB{enabled:Bool}
type ViewA is Data:
  ViewA{number:U32}
type ViewB is Data:
  ViewB{enabled:Bool}

def event_a() -> Data:
  Notice.Notice<SchemaA,Unit>
def event_b() -> Data:
  Notice.Notice<SchemaB,Unit>
def store_a() -> Type:
  Col.Column<SchemaA,PayloadA> & Col.Column<SchemaA,PayloadB>
def store_b() -> Type:
  Col.Column<SchemaB,PayloadA> & Col.Column<SchemaB,PayloadB>
def frame_a() -> Type:
  Compose.Frame<SchemaA,store_a(),Unit,event_a()>
def frame_b() -> Type:
  Compose.Frame<SchemaB,store_b(),Unit,event_b()>
def inspector_a() -> Type:
  Inspector.Frame<SchemaA,store_a(),Unit,event_a()>
def inspector_b() -> Type:
  Inspector.Frame<SchemaB,store_b(),Unit,event_b()>
def context_a() -> Type:
  Route.Runtime<SchemaA,store_a(),Unit,event_a(),Mixed.State<SchemaA,Unit,Unit,Unit>>
def context_b() -> Type:
  Route.Runtime<SchemaB,store_b(),Unit,event_b(),Mixed.State<SchemaB,Unit,Unit,Unit>>

def take_first(~S:Data,~A:Type,~B:Type,store:Col.Column<S,A> & Col.Column<S,B>) -> Col.Column<S,B> & Col.Column<S,A>:
  match store:
    case (column,rest):(rest,column)
def put_first(~S:Data,~A:Type,~B:Type,rest:Col.Column<S,B>,column:Col.Column<S,A>) -> Col.Column<S,A> & Col.Column<S,B>:
  (column,rest)
def take_second(~S:Data,~A:Type,~B:Type,store:Col.Column<S,A> & Col.Column<S,B>) -> Col.Column<S,A> & Col.Column<S,B>:
  match store:
    case (rest,column):(rest,column)
def put_second(~S:Data,~A:Type,~B:Type,rest:Col.Column<S,A>,column:Col.Column<S,B>) -> Col.Column<S,A> & Col.Column<S,B>:
  (rest,column)

def project_a(value:PayloadA) -> PayloadA & ViewA:
  match value:
    case PayloadA{+number,token}:(PayloadA{number,token},ViewA{number})
def project_b(value:PayloadB) -> PayloadB & ViewB:
  match value:
    case PayloadB{+enabled}:(PayloadB{enabled},ViewB{enabled})

def binding_a() -> Binding.Binding<SchemaA,store_a(),Col.Column<SchemaA,PayloadB>,PayloadA,ViewA,Unit,take_first(~SchemaA,~PayloadA,~PayloadB),put_first(~SchemaA,~PayloadA,~PayloadB),project_a>:
  Binding.bind(~SchemaA,~store_a(),~Col.Column<SchemaA,PayloadB>,~PayloadA,~ViewA,~Unit,~take_first(~SchemaA,~PayloadA,~PayloadB),~put_first(~SchemaA,~PayloadA,~PayloadB),~project_a,Identity.component(~SchemaA,~PayloadA,"payload-a"))
def binding_b() -> Binding.Binding<SchemaA,store_a(),Col.Column<SchemaA,PayloadA>,PayloadB,ViewB,Unit,take_second(~SchemaA,~PayloadA,~PayloadB),put_second(~SchemaA,~PayloadA,~PayloadB),project_b>:
  Binding.bind(~SchemaA,~store_a(),~Col.Column<SchemaA,PayloadA>,~PayloadB,~ViewB,~Unit,~take_second(~SchemaA,~PayloadA,~PayloadB),~put_second(~SchemaA,~PayloadA,~PayloadB),~project_b,Identity.component(~SchemaA,~PayloadB,"payload-b"))
def binding_schema_b() -> Binding.Binding<SchemaB,store_b(),Col.Column<SchemaB,PayloadB>,PayloadA,ViewA,Unit,take_first(~SchemaB,~PayloadA,~PayloadB),put_first(~SchemaB,~PayloadA,~PayloadB),project_a>:
  Binding.bind(~SchemaB,~store_b(),~Col.Column<SchemaB,PayloadB>,~PayloadA,~ViewA,~Unit,~take_first(~SchemaB,~PayloadA,~PayloadB),~put_first(~SchemaB,~PayloadA,~PayloadB),~project_a,Identity.component(~SchemaB,~PayloadA,"payload-a"))

def declaration_a_type() -> Type:
  Observable.Declaration<SchemaA,frame_a(),Cap.Read<frame_a(),ViewA>,inspector_a(),Cmp.Access<ViewA>>
def declaration_b_type() -> Type:
  Observable.Declaration<SchemaA,frame_a(),Cap.Read<frame_a(),ViewB>,inspector_a(),Cmp.Access<ViewB>>
def declaration_schema_b_type() -> Type:
  Observable.Declaration<SchemaB,frame_b(),Cap.Read<frame_b(),ViewA>,inspector_b(),Cmp.Access<ViewA>>
def declaration_a() -> declaration_a_type():
  Observable.read(~SchemaA,~store_a(),~Col.Column<SchemaA,PayloadB>,~PayloadA,~ViewA,~Unit,~take_first(~SchemaA,~PayloadA,~PayloadB),~put_first(~SchemaA,~PayloadA,~PayloadB),~project_a,~Unit,~event_a(),binding_a())
def declaration_b() -> declaration_b_type():
  Observable.read(~SchemaA,~store_a(),~Col.Column<SchemaA,PayloadA>,~PayloadB,~ViewB,~Unit,~take_second(~SchemaA,~PayloadA,~PayloadB),~put_second(~SchemaA,~PayloadA,~PayloadB),~project_b,~Unit,~event_a(),binding_b())
def declaration_schema_b() -> declaration_schema_b_type():
  Observable.read(~SchemaB,~store_b(),~Col.Column<SchemaB,PayloadB>,~PayloadA,~ViewA,~Unit,~take_first(~SchemaB,~PayloadA,~PayloadB),~put_first(~SchemaB,~PayloadA,~PayloadB),~project_a,~Unit,~event_b(),binding_schema_b())

def parameter_a_type() -> Data:
  RP.Param<context_a(),Unit,QParam.Rows<SchemaA,Cmp.Access<ViewA>>,Unit,QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a()),QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a()),QParam.commit_context(~context_a()),QParam.release_context(~context_a())>
def parameter_b_type() -> Data:
  RP.Param<context_a(),Unit,QParam.Rows<SchemaA,Cmp.Access<ViewB>>,Unit,QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b()),QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b()),QParam.commit_context(~context_a()),QParam.release_context(~context_a())>
def parameter_schema_b_type() -> Data:
  RP.Param<context_b(),Unit,QParam.Rows<SchemaB,Cmp.Access<ViewA>>,Unit,QParam.validate_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b()),QParam.prepare_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b()),QParam.commit_context(~context_b()),QParam.release_context(~context_b())>
def parameter_a() -> parameter_a_type():
  QParam.from_observable(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a())
def parameter_b() -> parameter_b_type():
  QParam.from_observable(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b())
def parameter_schema_b() -> parameter_schema_b_type():
  QParam.from_observable(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b())

def validate_a(context:context_a(),owner:Unit) -> context_a() & (Unit & Bool):
  QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a())(context,owner)
def validate_b(context:context_a(),owner:Unit) -> context_a() & (Unit & Bool):
  QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b())(context,owner)
def validate_schema_b(context:context_b(),owner:Unit) -> context_b() & (Unit & Bool):
  QParam.validate_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b())(context,owner)
def prepare_fn_a() -> context_a() -> @+cursor:U32 -> Unit -> context_a() & (Unit & (QParam.Rows<SchemaA,Cmp.Access<ViewA>> & Unit)):
  QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a())
def prepare_fn_b() -> context_a() -> @+cursor:U32 -> Unit -> context_a() & (Unit & (QParam.Rows<SchemaA,Cmp.Access<ViewB>> & Unit)):
  QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b())
def prepare_fn_schema_b() -> context_b() -> @+cursor:U32 -> Unit -> context_b() & (Unit & (QParam.Rows<SchemaB,Cmp.Access<ViewA>> & Unit)):
  QParam.prepare_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b())
def commit_fn_a() -> context_a() -> Unit -> Unit -> @+cursor:U32 -> context_a() & Unit:
  QParam.commit_context(~context_a())
def release_fn_a() -> context_a() -> Unit -> context_a():
  QParam.release_context(~context_a())

def declared_query(context:context_a(),parameter:parameter_a_type()) -> context_a() & (Unit & (QParam.Rows<SchemaA,Cmp.Access<ViewA>> & Unit)):
  RP.prepare(~context_a(),~Unit,~QParam.Rows<SchemaA,Cmp.Access<ViewA>>,~Unit,~QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a()),~QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewA>,~Cmp.Access<ViewA>,~declaration_a()),~QParam.commit_context(~context_a()),~QParam.release_context(~context_a()),parameter,context,0,Unit{})
def declared_query_b(context:context_a(),parameter:parameter_b_type()) -> context_a() & (Unit & (QParam.Rows<SchemaA,Cmp.Access<ViewB>> & Unit)):
  RP.prepare(~context_a(),~Unit,~QParam.Rows<SchemaA,Cmp.Access<ViewB>>,~Unit,~QParam.validate_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b()),~QParam.prepare_context(~SchemaA,~store_a(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_a(),ViewB>,~Cmp.Access<ViewB>,~declaration_b()),~QParam.commit_context(~context_a()),~QParam.release_context(~context_a()),parameter,context,0,Unit{})
def declared_query_schema_b(context:context_b(),parameter:parameter_schema_b_type()) -> context_b() & (Unit & (QParam.Rows<SchemaB,Cmp.Access<ViewA>> & Unit)):
  RP.prepare(~context_b(),~Unit,~QParam.Rows<SchemaB,Cmp.Access<ViewA>>,~Unit,~QParam.validate_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b()),~QParam.prepare_context(~SchemaB,~store_b(),~Unit,~Unit,~Unit,~Unit,~Cap.Read<frame_b(),ViewA>,~Cmp.Access<ViewA>,~declaration_schema_b()),~QParam.commit_context(~context_b()),~QParam.release_context(~context_b()),parameter,context,0,Unit{})

def operational_read() -> Query.Declaration<SchemaA,frame_a(),Cap.Read<frame_a(),ViewA>>:
  Observable.operational(~SchemaA,~frame_a(),~Cap.Read<frame_a(),ViewA>,~inspector_a(),~Cmp.Access<ViewA>,declaration_a())
def operational_write() -> Query.Declaration<SchemaA,frame_a(),Cap.Write<frame_a(),PayloadA,ViewA>>:
  Observable.operational(~SchemaA,~frame_a(),~Cap.Write<frame_a(),PayloadA,ViewA>,~inspector_a(),~Cmp.Access<ViewA>,
    Observable.write(~SchemaA,~store_a(),~Col.Column<SchemaA,PayloadB>,~PayloadA,~ViewA,~Unit,~take_first(~SchemaA,~PayloadA,~PayloadB),~put_first(~SchemaA,~PayloadA,~PayloadB),~project_a,~Unit,~event_a(),binding_a()))
def write_with_declared_write(frame:frame_a()) -> frame_a():
  Cap.set(~frame_a(),~PayloadA,~ViewA,Query.grant(~SchemaA,~frame_a(),~Cap.Write<frame_a(),PayloadA,ViewA>,operational_write()),frame,PayloadA{0,Token{}})
def read_with_declared_read(frame:frame_a()) -> frame_a() & Cmp.Access<ViewA>:
  Query.execute_read(~SchemaA,~frame_a(),~ViewA,operational_read(),frame)

def core_provider_type() -> Type:
  Core.provider_type()
def core_reader_owner_type() -> Type:
  Core.all_owner()
def keep_provider(provider:core_provider_type()) -> core_provider_type():
  provider
def keep_reader_owner(owner:core_reader_owner_type()) -> core_reader_owner_type():
  owner
