import Base
import ./fixture.bend as F
import ../../../../src/ecs/ordinary-machine-transition-reader.bend as Reader
import ../../../../src/ecs/machine-stream.bend as Stream
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/event-runtime.bend as Event
import ../../../../src/ecs/machine.bend as M

def callback(~S:Data,world:F.World(~S),input:Reader.Input<U32,Array<U32>>) -> Sys.Outcome<F.World(~S),Unit,Array<U32>>:
  match input:
    case Reader.Input{_,args}:Sys.Succeeded{world,args}
def take(~S:Data) -> (F.Resources(~S) -> F.Resources(~S) & Stream.Stream<U32>):Reader.initialized_take(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S))
def put(~S:Data) -> (F.Resources(~S) -> Stream.Stream<U32> -> F.Resources(~S)):Reader.initialized_put(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S))
def declaration(~S:Data) -> Reader.Declaration<S,F.Mode,U32,F.Resources(~S),take(~S),put(~S)>:Reader.from_initialization(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S),~F.mode_declaration(~S))
def Owned(~S:Data) -> Type:Reader.instance_type(~S,~F.Mode,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Array<U32>,~Unit,~Array<U32>,~take(~S),~put(~S),~callback(~S))
def Registration(~S:Data) -> Type:Reader.registration_type(~S,~F.Mode,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Array<U32>,~Unit,~Array<U32>,~take(~S),~put(~S),~callback(~S))
def Returned(~S:Data) -> Type:Reader.ReadResult<F.World(~S),Owned(~S),Array<U32>,Unit,Array<U32>,U32>
def register(~S:Data,world:F.World(~S)) -> Registration(~S):Reader.register(~S,~F.Mode,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Array<U32>,~Unit,~Array<U32>,~take(~S),~put(~S),~callback(~S),~declaration(~S),world,"slow-mode")
def read(~S:Data,owner:Owned(~S),world:F.World(~S),args:Array<U32>) -> Returned(~S):Reader.read(~S,~F.Mode,~U32,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Array<U32>,~Unit,~Array<U32>,~take(~S),~put(~S),~callback(~S),owner,world,args)
