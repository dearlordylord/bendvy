import Base
import ./fixture-1.bend as F
import ./fixture-3.bend as B
import ./fixture-4.bend as FailureReader
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as D
type TypedView is Data:TypedView{key:String,mode:Event.Mode,namespace:U32,readerId:U32,registryId:U32,registryNamespace:U32,systemId:U32,name:String,access:List<&2,String>,cursor:U32}
type FailureView is Data:FailureView{descriptor:G.Descriptor<F.S>,namespace:U32,systemId:U32,name:String,access:List<&2,String>,cursor:U32,keys:List<&2,D.DescriptorKey<F.S>>}
type View is Data:View{first:TypedView,slow:TypedView,second:TypedView,failure:FailureView}
def typed1(owner:B.Owner1()) -> B.Owner1() & TypedView:
  match owner:
    case Reader.Owner{Event.Declaration{Event.Domain{+key},+mode},Route.Reader{+namespace,+readerId,+registryId},Sys.Registry{+registryNamespace,+systemId,+name,+access,+cursor}}:(Reader.Owner{Event.Declaration{Event.Domain{key},mode},Route.Reader{namespace,readerId,registryId},Sys.Registry{registryNamespace,systemId,name,access,cursor}},TypedView{key,mode,namespace,readerId,registryId,registryNamespace,systemId,name,access,cursor})
def typed2(owner:B.Owner2()) -> B.Owner2() & TypedView:
  match owner:
    case Reader.Owner{Event.Declaration{Event.Domain{+key},+mode},Route.Reader{+namespace,+readerId,+registryId},Sys.Registry{+registryNamespace,+systemId,+name,+access,+cursor}}:(Reader.Owner{Event.Declaration{Event.Domain{key},mode},Route.Reader{namespace,readerId,registryId},Sys.Registry{registryNamespace,systemId,name,access,cursor}},TypedView{key,mode,namespace,readerId,registryId,registryNamespace,systemId,name,access,cursor})
def typed3(owner:B.Owner3()) -> B.Owner3() & TypedView:
  match owner:
    case Reader.Owner{Event.Declaration{Event.Domain{+key},+mode},Route.Reader{+namespace,+readerId,+registryId},Sys.Registry{+registryNamespace,+systemId,+name,+access,+cursor}}:(Reader.Owner{Event.Declaration{Event.Domain{key},mode},Route.Reader{namespace,readerId,registryId},Sys.Registry{registryNamespace,systemId,name,access,cursor}},TypedView{key,mode,namespace,readerId,registryId,registryNamespace,systemId,name,access,cursor})
def failure(owner:B.Owner4()) -> B.Owner4() & FailureView:
  match owner:
    case FailureReader.Owner{Decl.Declaration{+descriptor},K.Reader{Sys.Registry{+namespace,+id,+name,+access,+cursor},+keys}}:(FailureReader.Owner{Decl.Declaration{descriptor},K.Reader{Sys.Registry{namespace,id,name,access,cursor},keys}},FailureView{descriptor,namespace,id,name,access,cursor,keys})
def returned(base:Unit,first:B.Owner1() & TypedView,slow:B.Owner2() & TypedView,second:B.Owner3() & TypedView,reader:B.Owner4() & FailureView) -> B.Owners4() & View:
  match first slow second reader:
    case (first,firstView),(slow,slowView),(second,secondView),(reader,readerView):(((((base,first),slow),second),reader),View{firstView,slowView,secondView,readerView})
def owners(value:B.Owners4()) -> B.Owners4() & View:
  match value:
    case ((((base,first),slow),second),reader):returned(base,typed1(first),typed2(slow),typed3(second),failure(reader))
