import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as Pack

# An ordinary schema context owns its constructor factories and other owners.
# Both factory and rest return through the authored lenses; neither is copied.
# Canonical decode-construction.request/fallible_request satisfy this request
# shape. Error remains the caller's selected Data type, including their distinct
# validation/constructor errors. This introduces no default retry or inverse.
def restored(~Ctx:Type,~Factory:Type,~Rest:Type,~I:Type,~P:Type,~Error:Data,~restore:Factory -> Rest -> Ctx,rest:Rest,observed:Factory & Build.Construction<I,P,Error>) -> Ctx & Build.Construction<I,P,Error>:
  match observed:
    case (factory,result): (restore(factory,rest),result)
def projected(~Ctx:Type,~Factory:Type,~Rest:Type,~I:Type,~P:Type,~Error:Data,~restore:Factory -> Rest -> Ctx,~request:Factory -> I -> Factory & Build.Construction<I,P,Error>,input:I,observed:Factory & Rest) -> Ctx & Build.Construction<I,P,Error>:
  match observed:
    case (factory,rest): restored(~Ctx,~Factory,~Rest,~I,~P,~Error,~restore,rest,request(factory,input))
def head(~Ctx:Type,~Factory:Type,~Rest:Type,~I:Type,~P:Type,~Error:Data,~project:Ctx -> Factory & Rest,~restore:Factory -> Rest -> Ctx,~request:Factory -> I -> Factory & Build.Construction<I,P,Error>,ctx:Ctx,input:I) -> Ctx & Build.Construction<I,P,Error>:
  projected(~Ctx,~Factory,~Rest,~I,~P,~Error,~restore,~request,input,project(ctx))
# Tail is arbitrary Type. The caller recursively supplies another stage or the
# existing terminal; this is not an unrolled family-count-specific bundle API.
def stage(~Ctx:Type,~Factory:Type,~Rest:Type,~I:Type,~P:Type,~TR:Type,~TC:Type,~Error:Data,~project:Ctx -> Factory & Rest,~restore:Factory -> Rest -> Ctx,~request:Factory -> I -> Factory & Build.Construction<I,P,Error>,~tail:Ctx -> TR -> Build.Staged<Ctx,TR,TC,Error>,ctx:Ctx,input:Pack.Pack<I,TR>) -> Build.Staged<Ctx,Pack.Pack<I,TR>,Pack.Pack<P,TC>,Error>:
  Build.stage(~Ctx,~I,~P,~TR,~TC,~Error,~head(~Ctx,~Factory,~Rest,~I,~P,~Error,~project,~restore,~request),~tail,ctx,input)

# Actual canonical factory request, with retained runtime input codec and nominal
# declaration. Custom constructor errors remain distinct from validation errors.
def none_positions(~Error:Data,positions:List<&2,Maybe<&2,Error>>) -> List<&2,Maybe<&2,Error>>:
  match positions:
    case []:[]
    case head <> tail:None{} <> none_positions(~Error,tail)
def first_only(~Error:Data,positions:List<&2,Maybe<&2,Error>>) -> List<&2,Maybe<&2,Error>>:
  match positions:
    case []:[]
    case head <> tail:head <> none_positions(~Error,tail)
def without_tail_errors(~Ctx:Type,~Raw:Type,~Cooked:Type,~Error:Data,result:Build.Staged<Ctx,Raw,Cooked,Error>) -> Build.Staged<Ctx,Raw,Cooked,Error>:
  match result:
    case Build.Valid{context,cooked,undo,positions}:Build.Valid{context,cooked,undo,positions}
    case Build.Failed{context,raw,positions}:Build.Failed{context,raw,first_only(~Error,positions)}
def canonical_stage(~S:Data,~Ctx:Type,~Rest:Type,~I:Type,~P:Type,~TR:Type,~TC:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,~take:Ctx -> Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build> & Rest,~put:Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build> -> Rest -> Ctx,~tail:Ctx -> TR -> Build.Staged<Ctx,TR,TC,Constructor.Error<Custom>>,ctx:Ctx,input:Pack.Pack<I,TR>) -> Build.Staged<Ctx,Pack.Pack<I,TR>,Pack.Pack<P,TC>,Constructor.Error<Custom>>:
  without_tail_errors(~Ctx,~Pack.Pack<I,TR>,~Pack.Pack<P,TC>,~Constructor.Error<Custom>,stage(~Ctx,~Constructor.FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,~Rest,~I,~P,~TR,~TC,~Constructor.Error<Custom>,~take,~put,~(factory => input => Constructor.fallible_request(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory,input)),~tail,ctx,input))
