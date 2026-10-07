import Base
import ./main.bend as M
import ./schema.bend as S
import ../../src/ecs/world.bend as W

def main() -> IO(Unit):
  M.created(~M.timing_finished,W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty,W.factory(),Unit{}))
