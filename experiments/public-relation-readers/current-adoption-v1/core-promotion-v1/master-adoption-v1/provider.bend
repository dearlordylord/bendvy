import Base
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/relation-failure-runtime.bend as K
import ../../../../../src/ecs/internal/relation-failures/readings.bend as Read

# Trusted provider retains every affine owner. Gameplay receives abstract H and
# precisely one closed read capability; descriptor filtering occurred in K.run.
type Context<S:Data,C:Type,R:Type,E:Data,A:Type> is Type:
  Context{world:W.World<S,C,R,E>,readings:List<&2,Read.KeyReading<S,E>>,args:A}

def project(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,owner:Context<S,C,R,E,A>) -> Context<S,C,R,E,A> & List<&2,Read.KeyReading<S,E>>:
  match owner:
    case Context{world,+readings,args}: (Context{world,readings,args},readings)

def gameplay(~H:Type,~S:Data,~E:Data,~cap:Cap.ValueRead<H,List<&2,Read.KeyReading<S,E>>>,owner:H) -> H & List<&2,Read.KeyReading<S,E>>:
  Cap.value_read(~H,~List<&2,Read.KeyReading<S,E>>,~cap,owner)

def returned(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,result:Context<S,C,R,E,A> & List<&2,Read.KeyReading<S,E>>) -> W.World<S,C,R,E> & K.Input<S,E,A>:
  match result:
    case (Context{world,_,args},readings): (world,K.Input{readings,args})

def read(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,world:W.World<S,C,R,E>,input:K.Input<S,E,A>) -> W.World<S,C,R,E> & K.Input<S,E,A>:
  match input:
    case K.Input{readings,args}: returned(~S,~C,~R,~E,~A,gameplay(~Context<S,C,R,E,A>,~S,~E,~Cap.ValueRead{project(~S,~C,~R,~E,~A)},Context{world,readings,args}))
