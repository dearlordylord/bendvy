import Base
import ../../../src/ecs/execution-command-local.bend as L
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/world.bend as W

type Token is Type:
  Token{owner:Array<U32>}
def authored(~S:Data,~H:Type,~Q:Type,scope:H,queue:Q,handle:W.Handle<S>) -> H & (Q & (W.Handle<S> & Sys.Completion<String,Unit>)):
  (scope,(queue,(handle,Sys.BodyError{"after-enqueue",Unit{}})))
def body(~S:Data,~H:Type,~Q:Type,~caps:Unit,~commands:L.Commands<Q,S,Token>,scope:H,queue:Q,+handle:W.Handle<S>) -> H & (Q & (W.Handle<S> & Sys.Completion<String,Unit>)):
  authored(~S,~H,~Q,scope,L.insert_field(~Q,~S,~Token,commands)(queue,handle,Token{ALeaf{71}}),handle)
