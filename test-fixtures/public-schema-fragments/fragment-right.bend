import Base
import ../../src/ecs/schema-fragments.bend as F

type Payload is Type:
  Payload{cells: Array<U32>}
type Token is Data:
  Token{}
def declare(~S: Data) -> F.Descriptor<S,Token,Payload>:
  F.Descriptor{F.Component{},"Velocity","Velocity"}
def fragment(~S: Data) -> F.Fragment<S,Payload>:
  F.fragment(~S,~Payload,[F.entry(~S,~Token,~Payload,declare(~S)),F.Entry{F.Resource{},"Score","Score"},F.Entry{F.Event{},"Tick","Tick"},F.Entry{F.Service{},"Logger","Logger"}],Payload{ANode{ALeaf{2},ALeaf{3}}})

type Logger is Type:
  Logger{calls: Array<U32>}
type Owners is Type:
  Owners{payload: Payload,logger: Logger}
def log_read(read: Array<U32> & U32) -> Logger:
  (array,value) = read
  Logger{Array.set(U32,array,0,(value + 1 : U32))}
def log(logger: Logger) -> Logger:
  match logger:
    case Logger{array}: log_read(Array.get(U32,array,0))
type LoggerToken is Data:
  LoggerToken{}
def logger_descriptor(~S: Data) -> F.Descriptor<S,LoggerToken,Logger>:
  F.Descriptor{F.Service{},"Logger","Logger"}
def supplied(~S: Data) -> F.Fragment<S,Owners>:
  F.fragment(~S,~Owners,[F.entry(~S,~Token,~Payload,declare(~S)),F.Entry{F.Resource{},"Score","Score"},F.Entry{F.Event{},"Tick","Tick"},F.entry(~S,~LoggerToken,~Logger,logger_descriptor(~S))],Owners{Payload{ANode{ALeaf{2},ALeaf{3}}},Logger{ANode{ALeaf{0},ALeaf{99}}}})
