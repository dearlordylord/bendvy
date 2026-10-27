import Base
import ./event-runtime.bend as Ev

# The ordinary typed event domain is supplied once to grants and registration.
# Schema-scoped name for one Data event stream. Owns no stream, payload
# or cursor; use the same declaration for typed grants and registration.
# For affine Type events use the owned-event APIs, not this Data-only domain.
# Full typed-family contract: docs/parity/typed-data-events.md.
type Domain<S:Data,E:Data> is Data:
  Domain{key:String}
# Requested event access: Read observes a stream; Write publishes to it.
# A write declaration does not implicitly confer read access.
type Mode is Data:
  Read{}
  Write{}
# Event domain and requested read/write mode used for registration metadata.
# This Data declaration owns no reader and does not itself publish or retain events.
type Declaration<S:Data,E:Data> is Data:
  Declaration{domain:Domain<S,E>,mode:Mode}
# Name a Data event domain in schema S. Does not create storage, register a
# reader or validate collisions; typed family setup supplies stream routing.
# Example: Event.write(~S,~E,Event.domain(~S,~E,"hit")); see
# test-fixtures/connected-performance/failedtxn-health64/consumer/health-access.bend.
def domain(~S:Data,~E:Data,key:String) -> Domain<S,E>:Domain{key}
# Declare read access to this Data stream without allocating a cursor.
# Register a reader to obtain independent visibility and retention ownership.
def read(~S:Data,~E:Data,domain:Domain<S,E>) -> Declaration<S,E>:Declaration{domain,Read{}}
# Declare publication access to this Data stream without publishing an event.
# Visibility and rollback follow the enclosing publication/transaction path.
def write(~S:Data,~E:Data,domain:Domain<S,E>) -> Declaration<S,E>:Declaration{domain,Write{}}
# Return the domain key suffixed with :read or :write for registration metadata.
# This string does not grant access or identify an actual runtime world.
def access(~S:Data,~E:Data,declaration:Declaration<S,E>) -> String:
  match declaration:
    case Declaration{Domain{key},Read{}}:String.concat([key,":read"])
    case Declaration{Domain{key},Write{}}:String.concat([key,":write"])
# Select a typed read grant: Some only for Read, None for Write.
# observe is trusted owner-threading setup; constructing a grant invokes no
# reader and does not advance a cursor or inspect a stream.
def reading(~S:Data,~E:Data,~H:Type,~observe:H -> H & Ev.Reading<E>,declaration:Declaration<S,E>) -> Maybe<&2,Ev.ReadAccess<H,E,observe>>:
  match declaration:
    case Declaration{_,Read{}}:Some{Ev.ReadAccess{}}
    case Declaration{_,Write{}}:None{}
# Select a typed publication grant: Some only for Write, None for Read.
# publish is a trusted owner-threading operation; the declaration does not
# make arbitrary callback effects transactional or execute publication here.
def publishing(~S:Data,~E:Data,~H:Type,~publish:H -> E -> H,declaration:Declaration<S,E>) -> Maybe<&2,Ev.WriteAccess<H,E,publish>>:
  match declaration:
    case Declaration{_,Write{}}:Some{Ev.WriteAccess{}}
    case Declaration{_,Read{}}:None{}
# Trusted setup constructor for a closed read operation indexed by observe.
# Accepts a domain without mode validation; prefer reading when checking a
# Declaration. Runtime world/reader checks belong to the supplied operation.
def read_grant(~S:Data,~E:Data,~H:Type,~observe:H -> H & Ev.Reading<E>,_:Domain<S,E>) -> Ev.ReadAccess<H,E,observe>:Ev.ReadAccess{}
# Trusted setup constructor for a closed publication operation indexed by
# publish. Accepts a domain without checking a Declaration mode. Runtime
# authority and rollback are properties of the supplied operation, not this token.
def write_grant(~S:Data,~E:Data,~H:Type,~publish:H -> E -> H,_:Domain<S,E>) -> Ev.WriteAccess<H,E,publish>:Ev.WriteAccess{}
