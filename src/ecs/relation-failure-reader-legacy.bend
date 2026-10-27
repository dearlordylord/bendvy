import Base
import ./relation-failure-reader.bend as Reader
import ./relation-failure-runtime.bend as K
import ./world.bend as W
import ./system.bend as Sy

# Historical registered-system adapter over the shared relation declarations.
def register(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: K.Runtime<S,C,R,E>,+declarations: List<&2,Reader.Declaration<S>>,+name: String) -> K.Registered<S,C,R,E,A,Error,O,runner>:
  K.register(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,Reader.keys(~S,declarations),name,Reader.accesses(~S,declarations))
