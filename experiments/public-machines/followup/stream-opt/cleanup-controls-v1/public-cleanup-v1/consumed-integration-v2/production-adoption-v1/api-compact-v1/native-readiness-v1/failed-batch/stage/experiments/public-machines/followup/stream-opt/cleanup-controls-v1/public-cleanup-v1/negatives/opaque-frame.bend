import Base
import ../caller.bend as D
import ../adapter.bend as G
import ../ports.bend as Ports
import ../current-core/ecs/world.bend as W
import ../current-core/ecs/machine-stream.bend as St

def denied(~F: Type,frame: F,owner: G.Instance<D.SchemaA,D.Store<D.SchemaA>,D.Resources<D.SchemaA>,Unit,Array<U32>,String,Array<U32>,(world => args => D.runner(~D.SchemaA,world,args)),Ports.Two<D.SchemaA,D.AlphaKey,D.BetaKey>>) -> G.Cleanup<D.SchemaA,D.Store<D.SchemaA>,D.Resources<D.SchemaA>,Unit,Array<U32>,String,Array<U32>,(world => args => D.runner(~D.SchemaA,world,args)),Ports.Two<D.SchemaA,D.AlphaKey,D.BetaKey>>:
  G.cleanup(~D.SchemaA,~D.Store<D.SchemaA>,~D.Resources<D.SchemaA>,~Unit,~Array<U32>,~String,~Array<U32>,~(world => args => D.runner(~D.SchemaA,world,args)),~Ports.Two<D.SchemaA,D.AlphaKey,D.BetaKey>,~(ports => ns => id => Ports.validate_two(~D.SchemaA,~D.AlphaKey,~D.BetaKey,ports,ns,id)),~(world => ports => D.remove_two(~D.SchemaA,world,ports)),owner,frame)

def main() -> Unit:
  Unit{}
