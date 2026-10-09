import Base
import ./dump.bend as Dump
import ../app.bend as App
import ../scenario-schema.bend as S
import ../scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

def plain(debug:App.Debug,world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.component(~S.Schema,~Array<U32>,~S.plain_store(),~Unit,~Unit,~Queries.plain_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~View.view,~Queries.plain_position_take,~Queries.plain_position_put,debug,world)

def transient(debug:App.Debug,world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.component(~S.Schema,~Array<U32>,~S.transient_store(),~Unit,~Unit,~Queries.transient_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~View.view,~Queries.transient_position_take,~Queries.transient_position_put,debug,world)

def constructed(debug:App.Debug,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.component(~S.Schema,~Array<U32>,~S.constructed_store(),~Unit,~Unit,~Queries.constructed_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~View.view,~Queries.constructed_position_take,~Queries.constructed_position_put,debug,world)
