import Base
import ../main.bend as M

def bad(world:M.World(~M.First)) -> M.World(~M.First) & M.World(~M.First):(world,world)
