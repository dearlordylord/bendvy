import Base
import ./world.bend as W
import ./local.bend as Local

# Closed runner identity with an actual affine per-instance capture owner.
def register(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,world: W.World<S,C,R,E>,name: String,access: List<&2,String>,local: L) -> Local.Registered<S,C,R,E,L,Args,Error,Out,runner>:
  Local.register(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,world,name,access,local)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Local.Instance<S,C,R,E,L,Args,Error,Out,runner>,world: W.World<S,C,R,E>,args: Args) -> Local.Run<S,C,R,E,L,Args,Error,Out,runner>:
  Local.run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,instance,world,args)

def skip(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Local.Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Local.Instance<S,C,R,E,L,Args,Error,Out,runner>:
  Local.skip(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,instance)

def observe(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,~V: Data,~project: L -> L & V,instance: Local.Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Local.Instance<S,C,R,E,L,Args,Error,Out,runner> & V:
  Local.observe(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,~V,~project,instance)

def identity(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Local.Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Local.Instance<S,C,R,E,L,Args,Error,Out,runner> & U32:
  Local.identity(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,instance)

def returned(~L: Type,owner: L) -> L:
  owner

# Unregister invalidates the registration and returns the capture unchanged.
def unregister(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Local.Instance<S,C,R,E,L,Args,Error,Out,runner>,world: W.World<S,C,R,E>) -> Local.Disposal<S,C,R,E,L,Args,Error,Out,runner,L>:
  Local.dispose(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,~L,~returned(~L),instance,world)
