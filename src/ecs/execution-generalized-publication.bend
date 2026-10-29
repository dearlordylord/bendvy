import Base
import ./world.bend as W
import ./change-tick.bend as Tick

# These are closed framework methods over the actual retained node inventory.
# Collect observes remaining queues even when publication was refused.
def collected(~S:Data,~C:Type,~R:Type,~E:Data,-Nodes:Type,world:W.World<S,C,R,E>,result:Nodes & List<&2,U32>) -> W.World<S,C,R,E> & (Nodes & List<&2,U32>):
  (world,result)
def published(~S:Data,~C:Type,~R:Type,~E:Data,~Nodes:Type,~collect:List<&2,U32> -> Nodes -> Nodes & List<&2,U32>,ids:List<&2,U32>,result:W.World<S,C,R,E> & Nodes) -> W.World<S,C,R,E> & (Nodes & List<&2,U32>):
  match result:
    case (world,nodes):collected(~S,~C,~R,~E,Nodes,world,collect(ids,nodes))
def clocked(~S:Data,~C:Type,~R:Type,~E:Data,~Nodes:Type,~publish:List<&2,U32> -> Tick.Tick -> W.World<S,C,R,E> -> Nodes -> W.World<S,C,R,E> & Nodes,~collect:List<&2,U32> -> Nodes -> Nodes & List<&2,U32>,+ids:List<&2,U32>,nodes:Nodes,result:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E> & (Nodes & List<&2,U32>):
  match result:
    case (world,tick):published(~S,~C,~R,~E,~Nodes,~collect,ids,publish(ids,tick,world,nodes))
def pending(~S:Data,~C:Type,~R:Type,~E:Data,~Nodes:Type,~publish:List<&2,U32> -> Tick.Tick -> W.World<S,C,R,E> -> Nodes -> W.World<S,C,R,E> & Nodes,~collect:List<&2,U32> -> Nodes -> Nodes & List<&2,U32>,ids:List<&2,U32>,result:W.World<S,C,R,E> & (Nodes & Bool)) -> W.World<S,C,R,E> & (Nodes & List<&2,U32>):
  match result:
    case (world,(nodes,False{})):collected(~S,~C,~R,~E,Nodes,world,collect(ids,nodes))
    case (world,(nodes,True{})):clocked(~S,~C,~R,~E,~Nodes,~publish,~collect,ids,nodes,W.advance_clock(~S,~C,~R,~E,world))
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~Nodes:Type,~hasPending:List<&2,U32> -> W.World<S,C,R,E> -> Nodes -> W.World<S,C,R,E> & (Nodes & Bool),~publish:List<&2,U32> -> Tick.Tick -> W.World<S,C,R,E> -> Nodes -> W.World<S,C,R,E> & Nodes,~collect:List<&2,U32> -> Nodes -> Nodes & List<&2,U32>,+ids:List<&2,U32>,world:W.World<S,C,R,E>,nodes:Nodes) -> W.World<S,C,R,E> & (Nodes & List<&2,U32>):
  pending(~S,~C,~R,~E,~Nodes,~publish,~collect,ids,hasPending(ids,world,nodes))
