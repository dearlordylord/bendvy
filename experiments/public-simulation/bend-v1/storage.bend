import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Store<-S: Data> is Type:
  Store{position: Col.Column<S,Array<U32>>,velocity: Col.Column<S,Array<U32>>,health: Col.Column<S,Array<U32>>}
type PositionRest<-S: Data> is Type:
  PositionRest{velocity: Col.Column<S,Array<U32>>,health: Col.Column<S,Array<U32>>}
type VelocityRest<-S: Data> is Type:
  VelocityRest{position: Col.Column<S,Array<U32>>,health: Col.Column<S,Array<U32>>}
type HealthRest<-S: Data> is Type:
  HealthRest{position: Col.Column<S,Array<U32>>,velocity: Col.Column<S,Array<U32>>}
type PositionToken<-S: Data> is Data: PositionToken{}
type VelocityToken<-S: Data> is Data: VelocityToken{}
type HealthToken<-S: Data> is Data: HealthToken{}
def take_position(~S: Data,store: Store<S>) -> PositionRest<S> & Col.Column<S,Array<U32>>:
  match store:
    case Store{position,velocity,health}: (PositionRest{velocity,health},position)
def put_position(~S: Data,rest: PositionRest<S>,position: Col.Column<S,Array<U32>>) -> Store<S>:
  match rest:
    case PositionRest{velocity,health}: Store{position,velocity,health}
def take_velocity(~S: Data,store: Store<S>) -> VelocityRest<S> & Col.Column<S,Array<U32>>:
  match store:
    case Store{position,velocity,health}: (VelocityRest{position,health},velocity)
def put_velocity(~S: Data,rest: VelocityRest<S>,velocity: Col.Column<S,Array<U32>>) -> Store<S>:
  match rest:
    case VelocityRest{position,health}: Store{position,velocity,health}
def take_health(~S: Data,store: Store<S>) -> HealthRest<S> & Col.Column<S,Array<U32>>:
  match store:
    case Store{position,velocity,health}: (HealthRest{position,velocity},health)
def put_health(~S: Data,rest: HealthRest<S>,health: Col.Column<S,Array<U32>>) -> Store<S>:
  match rest:
    case HealthRest{position,velocity}: Store{position,velocity,health}
def empty(~S: Data,unit: Unit) -> Store<S>:
  Store{Col.empty_indexed(~S,~Array<U32>),Col.empty_indexed(~S,~Array<U32>),Col.empty_indexed(~S,~Array<U32>)}
