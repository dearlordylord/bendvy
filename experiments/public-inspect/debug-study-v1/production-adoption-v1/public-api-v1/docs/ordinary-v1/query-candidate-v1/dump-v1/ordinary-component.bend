import Base
import ./dump.bend as Dump
import ../app.bend as App
import ../declaration.bend as Query
import ../scenario-schema.bend as S
import ../scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

def plain(debug:App.Debug,world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.plain_store(),~Unit,~Unit,~View.FullCell,~Queries.plain_read(),debug,world)

def transient(debug:App.Debug,world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.transient_store(),~Unit,~Unit,~View.FullCell,~Queries.transient_read(),debug,world)

def constructed(debug:App.Debug,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.constructed_store(),~Unit,~Unit,~View.FullCell,~Queries.constructed_read(),debug,world)

# Test-only adversarial callback: an observable trap for disabled execution.
# This is not an approved mutating presentation API contract.
def counted(got:Array<U32> & U32) -> Array<U32> & View.FullCell:
  match got:
    case (owner,count):View.view(Array.set(U32,owner,1,(count + 1 : U32)))
def trap_view(owner:Array<U32>) -> Array<U32> & View.FullCell:
  counted(Array.get(U32,owner,1))

def plain_disabled_probe(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.plain_store(),~Unit,~Unit,~View.FullCell,~Query.read(~S.Schema,~Array<U32>,~S.plain_store(),~Unit,~Unit,~Queries.plain_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~trap_view,~Queries.plain_position_take,~Queries.plain_position_put),App.Disabled{},world)

def transient_disabled_probe(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.transient_store(),~Unit,~Unit,~View.FullCell,~Query.read(~S.Schema,~Array<U32>,~S.transient_store(),~Unit,~Unit,~Queries.transient_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~trap_view,~Queries.transient_position_take,~Queries.transient_position_put),App.Disabled{},world)

def constructed_disabled_probe(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Dump.Population<S.Schema,View.FullCell>>:
  Dump.query(~S.Schema,~S.constructed_store(),~Unit,~Unit,~View.FullCell,~Query.read(~S.Schema,~Array<U32>,~S.constructed_store(),~Unit,~Unit,~Queries.constructed_position_rest(),~View.FullCell,~Unit,~S.identity("Position"),~trap_view,~Queries.constructed_position_take,~Queries.constructed_position_put),App.Disabled{},world)
