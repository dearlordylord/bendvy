import Base
import system.bend as S
import second-schema.bend as Second
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

type Other is Data: Other{}
def runner(world:W.World<Other,Array<U32>,Array<Bool>,Bool>,input:Ev.Input<Bool,Array<U32>>) -> Sys.Outcome<W.World<Other,Array<U32>,Array<Bool>,Bool>,String,Array<U32>>:
  match input:
    case Ev.Input{_,_,args}: Sys.Succeeded{world,args}
def wrong(events:Domains.Events<Other,Bool>,world:W.World<Other,Array<U32>,Array<Bool>,Bool>,owner:Ordinary.Owner<Second.Schema,Second.Registry()>,args:Array<U32>) -> S.Returned<Other,Array<U32>,Array<Bool>,Bool,Array<U32>,String,Array<U32>,runner>:
  S.run(~Other,~Array<U32>,~Array<Bool>,~Bool,~Array<U32>,~String,~Array<U32>,~runner,events,owner,world,args)
