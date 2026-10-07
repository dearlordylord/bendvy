import Base
import relation-types.bend as G
import relation-commands.bend as A
import owned-world.bend as O

def bad(~S: Data,components: O.Components<S>) -> A.Store<S,O.Components<S>> & G.Graph<S>:
  A.graph_read(~S,~O.Components<S>,components)
