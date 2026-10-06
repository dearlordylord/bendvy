import Base
import /tmp/bendvy-live-first-native/experiments/s-integrate/types.bend as T
import /tmp/bendvy-live-first-native/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-live-first-native/experiments/s-integrate/transaction.bend as X
import /tmp/bendvy-live-first-native/experiments/s-integrate/held.bend as H
import /tmp/bendvy-live-first-native/experiments/s-integrate/cache.bend as CC
import /tmp/bendvy-live-first-native/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-live-first-native/experiments/s-integrate/prototype-static-client.bend as SC

def inspect(~Owner: Type, owner: Owner) -> Owner:
  match owner:
    case H.Held{world,main,ledger,handle,undo,commands,pings,marks}: H.Held{world,main,ledger,handle,undo,commands,pings,marks}
