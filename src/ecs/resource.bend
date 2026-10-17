import Base
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./world.bend as W
import ./transaction.bend as T

def get_join(~S: Data,~C: Type,~R: Type,~E: Data,~V: Data,observed: W.World<S,C,R,E> & V,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State) -> T.Tx<W.World<S,C,R,E>,E> & V:
  (world,value) = observed
  (T.Tx{world,undo,commands,events,trace},value)

def tx_get(~S: Data,~C: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V,tx: T.Tx<W.World<S,C,R,E>,E>) -> T.Tx<W.World<S,C,R,E>,E> & V:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: get_join(~S,~C,~R,~E,~V,W.observe_resource(~S,~C,~R,~E,~V,~project,world),undo,commands,events,trace)

def restore_join(~S: Data,~C: Type,~R: Type,~E: Data,replaced: W.World<S,C,R,E> & R) -> W.World<S,C,R,E>:
  (world,discarded) = replaced
  world

def restore(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,old: R) -> W.World<S,C,R,E>:
  restore_join(~S,~C,~R,~E,W.replace_resource(~S,~C,~R,~E,world,old))

def replace_join(~S: Data,~C: Type,~R: Type,~E: Data,replaced: W.World<S,C,R,E> & R,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State) -> T.Tx<W.World<S,C,R,E>,E>:
  (world,old) = replaced
  T.Tx{world,(w => restore(~S,~C,~R,~E,w,old)) <> undo,commands,events,trace}

def tx_replace(~S: Data,~C: Type,~R: Type,~E: Data,tx: T.Tx<W.World<S,C,R,E>,E>,replacement: R) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: replace_join(~S,~C,~R,~E,W.replace_resource(~S,~C,~R,~E,world,replacement),undo,commands,events,trace)
