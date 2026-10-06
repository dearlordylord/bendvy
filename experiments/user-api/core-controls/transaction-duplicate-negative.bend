import Base
import ../../../src/ecs/transaction.bend as T

type World is Type:
  World{payload: Array<U32>, earlier: U32, commands: List<&1, (World -> World)>, events: List<&2, U32>}

def replace(world: World, payload: Array<U32>) -> World:
  match world:
    case World{old, earlier, commands, events}:
      World{payload, earlier, commands, events}

def change(tx: T.Tx<World, U32>, payload: Array<U32>) -> T.Tx<World, U32>:
  match tx:
    case T.Tx{World{old, earlier, committed, published}, undo, commands, events}:
      T.Tx{World{payload, earlier, committed, published}, (w => replace(w, old)) <> undo, commands, events}

def enqueue(world: World, commands: List<&1, (World -> World)>) -> World:
  match world:
    case World{payload, earlier, existing, events}:
      World{payload, earlier, List.append(&1, (World -> World), existing, commands), events}

def publish(world: World, events: List<&2, U32>) -> World:
  match world:
    case World{payload, earlier, commands, existing}:
      World{payload, earlier, commands, List.append(&2, U32, existing, events)}

def command(world: World, n: U32) -> World:
  match world:
    case World{payload, earlier, commands, events}:
      World{payload, (earlier * 10 + n : U32), commands, events}

def apply(commands: List<&1, (World -> World)>, world: World) -> World:
  match commands:
    case Nil{}:
      world
    case Con{f, rest}:
      apply(rest, f(world))

def barrier(world: World) -> World:
  match world:
    case World{payload, earlier, commands, events}:
      apply(commands, World{payload, earlier, [], events})

def report_value(value: Array<U32> & U32, earlier: U32, events: List<&2, U32>) -> U32:
  match value:
    case (_, x):
      (x * 1000 + earlier * 10 + U32.from_nat(List.length(&2, U32, events)) : U32)

def report(result: T.Returned<World, U32>) -> U32:
  match result:
    case T.Returned{World{payload, earlier, commands, events}, _}:
      report_value(payload[0], earlier, events)

def success_report(result: T.Returned<World, U32>) -> U32:
  match result:
    case T.Returned{world, outcome}:
      report(T.Returned{barrier(world), outcome})

def trial(outcome: T.Outcome<U32>) -> T.Returned<World, U32>:
  tx = T.begin(~World, ~U32, World{[0 : U32^0n], 7, [], []})
  tx = change(tx, [1 : U32^0n])
  tx = change(tx, [2 : U32^0n])
  tx = T.stage(~World, ~U32, tx, w => command(w, 1))
  tx = T.stage(~World, ~U32, tx, w => command(w, 2))
  tx = T.emit(~World, ~U32, tx, 9)
  T.finish(~World, ~U32, ~U32, ~enqueue, ~publish, tx, outcome)

def main() -> U32:
  tx = T.begin(~World, ~U32, World{[0 : U32^0n], 7, [], []})
  a = T.stage(~World, ~U32, tx, w => command(w, 1))
  b = T.emit(~World, ~U32, tx, 9)
  report(T.finish(~World, ~U32, ~U32, ~enqueue, ~publish, a, T.Success{}))
