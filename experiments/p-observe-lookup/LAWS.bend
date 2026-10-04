import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

law lookup_full_exact:
  for +world: T.World
  for +handle: T.Handle
  for +selection: T.Selection
  {M.lookup(world, handle, selection) == S.lookup(world, handle, selection) : T.Lookup}
