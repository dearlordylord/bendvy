import Base
import ../notice-positive-core.bend as Core
import ../../parallel-query/payloads.bend as P
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-lifecycle-notices.bend as Notice

def rebrand(reader:Core.Reader(~Core.First)) -> Notice.Reader<Core.First,Layout.LayoutLeaf{P.Input,U32,P.read,"output"},Notice.Removed{"output"}>:reader
