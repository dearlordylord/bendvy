import Base
import readings.bend as Read

# Nominal descriptor families bind the authority to the application's schema.
type Parent<S: Data> is Data: Parent{}
type OtherParent<S: Data> is Data: OtherParent{}
type ReadGrant<H: Type,S: Data,Key: Data,E: Data,-get: H -> H & List<&2,Read.KeyReading<S,E>>> is Data:
  ReadGrant{}
type WriteGrant<H: Type,S: Data,Key: Data,E: Data,-put: H -> E -> H> is Data:
  WriteGrant{}

def all(~H: Type,~S: Data,~Key: Data,~E: Data,~get: H -> H & List<&2,Read.KeyReading<S,E>>,_: ReadGrant<H,S,Key,E,get>,owner: H) -> H & List<&2,Read.KeyReading<S,E>>:
  get(owner)

def write(~H: Type,~S: Data,~Key: Data,~E: Data,~put: H -> E -> H,_: WriteGrant<H,S,Key,E,put>,owner: H,event: E) -> H:
  put(owner,event)

# Gameplay sees H universally and receives only the declared Parent grant.
def gameplay(~H: Type,~S: Data,~E: Data,~get: H -> H & List<&2,Read.KeyReading<S,E>>,grant: ReadGrant<H,S,Parent<S>,E,get>,owner: H) -> H & List<&2,Read.KeyReading<S,E>>:
  all(~H,~S,~Parent<S>,~E,~get,grant,owner)
