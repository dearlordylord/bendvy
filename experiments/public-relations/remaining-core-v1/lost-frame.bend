import Base
import consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/relation-cleanup.bend as Clean
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A

def forget_frames(~S:Data,result:Clean.CleanupResult<S,Consumer.Components,Array<U32>,U32>) -> Clean.CleanupResult<S,Consumer.Components,Array<U32>,U32>:
  match result:
    case Clean.Complete{world}:Clean.Complete{world}
    case Clean.Incomplete{world,_}:Clean.Incomplete{world,[]}
def short_result(~S:Data,+namespace:U32) -> Clean.CleanupResult<S,Consumer.Components,Array<U32>,U32>:
  Clean.units(~S,~Consumer.Components,~Array<U32>,~U32,~Consumer.clear(~S),~Consumer.record(~S),4n,Clean.drive(~S,~Consumer.Components,~Array<U32>,~U32,~Consumer.clear(~S),~Consumer.record(~S),0n,[G.CleanupEnter{1}],Consumer.setup(~S,namespace),namespace,Consumer.descriptors(~S)),namespace,Consumer.descriptors(~S))
def split_result(~S:Data,+namespace:U32) -> Clean.CleanupResult<S,Consumer.Components,Array<U32>,U32>:
  Clean.units(~S,~Consumer.Components,~Array<U32>,~U32,~Consumer.clear(~S),~Consumer.record(~S),32n,forget_frames(~S,short_result(~S,namespace)),namespace,Consumer.descriptors(~S))
def uninterrupted_result(~S:Data,+namespace:U32) -> Clean.CleanupResult<S,Consumer.Components,Array<U32>,U32>:
  Clean.drive(~S,~Consumer.Components,~Array<U32>,~U32,~Consumer.clear(~S),~Consumer.record(~S),36n,[G.CleanupEnter{1}],Consumer.setup(~S,namespace),namespace,Consumer.descriptors(~S))
def joined(+split:String,+uninterrupted:String) -> String:
  "split\n" ++ split ++ "uninterrupted\n" ++ uninterrupted ++ "equal=" ++ Bool.show(String.eq(split,uninterrupted)) ++ "\n"
def run(~S:Data,+namespace:U32) -> String:
  joined(Consumer.done(~S,Consumer.result_observe(~S,split_result(~S,namespace))),Consumer.done(~S,Consumer.result_observe(~S,uninterrupted_result(~S,namespace))))
def main() -> String:
  "Workshop\n" ++ run(~Consumer.Workshop,31) ++ "Garden\n" ++ run(~Consumer.Garden,47)
