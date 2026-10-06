import Base
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
type Position is Type:
  Position{x: F32,trail: Array<U32>}
type Velocity is Type:
  Velocity{dx: F32,history: Array<U32>}
type Health is Type:
  Health{hp: F32,history: Array<U32>}
type Armor is Data:
  Armor{value: F32}
type Tag is Data:
  Tag{}
type PositionView is Data:
  PositionView{x: F32,trail: List<&2,U32>}
type VelocityView is Data:
  VelocityView{dx: F32,history: List<&2,U32>}
type HealthView is Data:
  HealthView{hp: F32,history: List<&2,U32>}
type SimEvent is Data:
  Hit{id: U32,amount: F32,hp: F32}
  Death{id: U32}
type Store is Type:
  Store{positions: Col.Column<Schema,Position>,velocities: Col.Column<Schema,Velocity>,healths: Col.Column<Schema,Health>,armors: Col.Column<Schema,Armor>,tags: Col.Column<Schema,Tag>}
type PositionToken is Data:
  PositionToken{}
type PositionRest is Type:
  PositionRest{velocities: Col.Column<Schema,Velocity>,healths: Col.Column<Schema,Health>,armors: Col.Column<Schema,Armor>,tags: Col.Column<Schema,Tag>}
def take_positions(store: Store) -> PositionRest & Col.Column<Schema,Position>:
  match store:
    case Store{positions,velocities,healths,armors,tags}: (PositionRest{velocities,healths,armors,tags},positions)
def put_positions(rest: PositionRest,column: Col.Column<Schema,Position>) -> Store:
  match rest:
    case PositionRest{velocities,healths,armors,tags}: Store{column,velocities,healths,armors,tags}
type VelocityToken is Data:
  VelocityToken{}
type VelocityRest is Type:
  VelocityRest{positions: Col.Column<Schema,Position>,healths: Col.Column<Schema,Health>,armors: Col.Column<Schema,Armor>,tags: Col.Column<Schema,Tag>}
def take_velocities(store: Store) -> VelocityRest & Col.Column<Schema,Velocity>:
  match store:
    case Store{positions,velocities,healths,armors,tags}: (VelocityRest{positions,healths,armors,tags},velocities)
def put_velocities(rest: VelocityRest,column: Col.Column<Schema,Velocity>) -> Store:
  match rest:
    case VelocityRest{positions,healths,armors,tags}: Store{positions,column,healths,armors,tags}
type HealthToken is Data:
  HealthToken{}
type HealthRest is Type:
  HealthRest{positions: Col.Column<Schema,Position>,velocities: Col.Column<Schema,Velocity>,armors: Col.Column<Schema,Armor>,tags: Col.Column<Schema,Tag>}
def take_healths(store: Store) -> HealthRest & Col.Column<Schema,Health>:
  match store:
    case Store{positions,velocities,healths,armors,tags}: (HealthRest{positions,velocities,armors,tags},healths)
def put_healths(rest: HealthRest,column: Col.Column<Schema,Health>) -> Store:
  match rest:
    case HealthRest{positions,velocities,armors,tags}: Store{positions,velocities,column,armors,tags}
type ArmorToken is Data:
  ArmorToken{}
type ArmorRest is Type:
  ArmorRest{positions: Col.Column<Schema,Position>,velocities: Col.Column<Schema,Velocity>,healths: Col.Column<Schema,Health>,tags: Col.Column<Schema,Tag>}
def take_armors(store: Store) -> ArmorRest & Col.Column<Schema,Armor>:
  match store:
    case Store{positions,velocities,healths,armors,tags}: (ArmorRest{positions,velocities,healths,tags},armors)
def put_armors(rest: ArmorRest,column: Col.Column<Schema,Armor>) -> Store:
  match rest:
    case ArmorRest{positions,velocities,healths,tags}: Store{positions,velocities,healths,column,tags}
type TagToken is Data:
  TagToken{}
type TagRest is Type:
  TagRest{positions: Col.Column<Schema,Position>,velocities: Col.Column<Schema,Velocity>,healths: Col.Column<Schema,Health>,armors: Col.Column<Schema,Armor>}
def take_tags(store: Store) -> TagRest & Col.Column<Schema,Tag>:
  match store:
    case Store{positions,velocities,healths,armors,tags}: (TagRest{positions,velocities,healths,armors},tags)
def put_tags(rest: TagRest,column: Col.Column<Schema,Tag>) -> Store:
  match rest:
    case TagRest{positions,velocities,healths,armors}: Store{positions,velocities,healths,armors,column}
def array_join(left_view: Array<U32> & List<&2,U32>,right_view: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,+xs) = left_view
  (right,+ys) = right_view
  (ANode{left,right},List.append(&2,U32,xs,ys))
def array_view(array: Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{+value}: (ALeaf{value},value <> [])
    case ANode{left,right}: array_join(array_view(left),array_view(right))
def project_position_join(+scalar: F32,viewed: Array<U32> & List<&2,U32>) -> Position & PositionView:
  (array,+values) = viewed
  (Position{scalar,array},PositionView{scalar,values})
def project_position(owner: Position) -> Position & PositionView:
  match owner:
    case Position{+x,trail}: project_position_join(x,array_view(trail))
def project_velocity_join(+scalar: F32,viewed: Array<U32> & List<&2,U32>) -> Velocity & VelocityView:
  (array,+values) = viewed
  (Velocity{scalar,array},VelocityView{scalar,values})
def project_velocity(owner: Velocity) -> Velocity & VelocityView:
  match owner:
    case Velocity{+dx,history}: project_velocity_join(dx,array_view(history))
def project_health_join(+scalar: F32,viewed: Array<U32> & List<&2,U32>) -> Health & HealthView:
  (array,+values) = viewed
  (Health{scalar,array},HealthView{scalar,values})
def project_health(owner: Health) -> Health & HealthView:
  match owner:
    case Health{+hp,history}: project_health_join(hp,array_view(history))
def project_armor(owner: Armor) -> Armor & Armor:
  match owner:
    case Armor{+value}: (Armor{value},Armor{value})
def project_tag(owner: Tag) -> Tag & Tag:
  match owner:
    case Tag{}: (Tag{},Tag{})
def position() -> C.Family<Schema,Store,PositionRest,Position,PositionView,PositionToken,take_positions,put_positions,project_position>:
  C.define(~Schema,~Store,~F32,~SimEvent,~PositionRest,~Position,~PositionView,~PositionToken,~take_positions,~put_positions,~project_position,"Position")
def velocity() -> C.Family<Schema,Store,VelocityRest,Velocity,VelocityView,VelocityToken,take_velocities,put_velocities,project_velocity>:
  C.define(~Schema,~Store,~F32,~SimEvent,~VelocityRest,~Velocity,~VelocityView,~VelocityToken,~take_velocities,~put_velocities,~project_velocity,"Velocity")
def health() -> C.Family<Schema,Store,HealthRest,Health,HealthView,HealthToken,take_healths,put_healths,project_health>:
  C.define(~Schema,~Store,~F32,~SimEvent,~HealthRest,~Health,~HealthView,~HealthToken,~take_healths,~put_healths,~project_health,"Health")
def armor() -> C.Family<Schema,Store,ArmorRest,Armor,Armor,ArmorToken,take_armors,put_armors,project_armor>:
  C.define(~Schema,~Store,~F32,~SimEvent,~ArmorRest,~Armor,~Armor,~ArmorToken,~take_armors,~put_armors,~project_armor,"Armor")
def tag() -> C.Family<Schema,Store,TagRest,Tag,Tag,TagToken,take_tags,put_tags,project_tag>:
  C.define(~Schema,~Store,~F32,~SimEvent,~TagRest,~Tag,~Tag,~TagToken,~take_tags,~put_tags,~project_tag,"Tag")
def empty_store(unit: Unit) -> Store:
  Store{Col.empty(~Schema,~Position),Col.empty(~Schema,~Velocity),Col.empty(~Schema,~Health),Col.empty(~Schema,~Armor),Col.empty(~Schema,~Tag)}
def create(factory: W.Factory,dt: F32) -> W.Creation<Schema,Store,F32,SimEvent>:
  W.create(~Schema,~Store,~F32,~SimEvent,~empty_store,factory,dt)

type Bundle is Type:
  Bundle{position: Maybe<&1,Position>,velocity: Maybe<&1,Velocity>,health: Maybe<&1,Health>,armor: Maybe<&1,Armor>,tag: Maybe<&1,Tag>}
def replaced(result: C.Replacement<W.World<Schema,Store,F32,SimEvent>,Position>) -> W.World<Schema,Store,F32,SimEvent>:
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def consume_replaced(~Owner: Type,result: C.Replacement<W.World<Schema,Store,F32,SimEvent>,Owner>) -> W.World<Schema,Store,F32,SimEvent>:
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def populate_position(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,incoming: Maybe<&1,Position>) -> W.World<Schema,Store,F32,SimEvent>:
  consume_replaced(~Position,C.structural_replace(~Schema,~Store,~F32,~SimEvent,~PositionRest,~Position,~PositionView,~PositionToken,~take_positions,~put_positions,~project_position,position(),world,handle,incoming))
def populate_velocity(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,incoming: Maybe<&1,Velocity>) -> W.World<Schema,Store,F32,SimEvent>:
  consume_replaced(~Velocity,C.structural_replace(~Schema,~Store,~F32,~SimEvent,~VelocityRest,~Velocity,~VelocityView,~VelocityToken,~take_velocities,~put_velocities,~project_velocity,velocity(),world,handle,incoming))
def populate_health(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,incoming: Maybe<&1,Health>) -> W.World<Schema,Store,F32,SimEvent>:
  consume_replaced(~Health,C.structural_replace(~Schema,~Store,~F32,~SimEvent,~HealthRest,~Health,~HealthView,~HealthToken,~take_healths,~put_healths,~project_health,health(),world,handle,incoming))
def populate_armor(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,incoming: Maybe<&1,Armor>) -> W.World<Schema,Store,F32,SimEvent>:
  consume_replaced(~Armor,C.structural_replace(~Schema,~Store,~F32,~SimEvent,~ArmorRest,~Armor,~Armor,~ArmorToken,~take_armors,~put_armors,~project_armor,armor(),world,handle,incoming))
def populate_tag(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,incoming: Maybe<&1,Tag>) -> W.World<Schema,Store,F32,SimEvent>:
  consume_replaced(~Tag,C.structural_replace(~Schema,~Store,~F32,~SimEvent,~TagRest,~Tag,~Tag,~TagToken,~take_tags,~put_tags,~project_tag,tag(),world,handle,incoming))
def populate_inner(world: W.World<Schema,Store,F32,SimEvent>,+handle: W.Handle<Schema>,bundle: Bundle) -> W.World<Schema,Store,F32,SimEvent>:
  match bundle:
    case Bundle{position,velocity,health,armor,tag}:
      populate_tag(populate_armor(populate_health(populate_velocity(populate_position(world,handle,position),handle,velocity),handle,health),handle,armor),handle,tag)
def clear_column_result(~Owner: Type,result: Col.SwapOutcome<Schema,Owner>) -> Col.Column<Schema,Owner>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def clear_column(~Owner: Type,handle: W.Handle<Schema>,column: Col.Column<Schema,Owner>) -> Col.Column<Schema,Owner>:
  match handle:
    case W.Handle{_,id}: clear_column_result(~Owner,Col.swap(~Schema,~Owner,column,id,None{}))
def clear_inner(store: Store,+handle: W.Handle<Schema>) -> Store:
  match store:
    case Store{positions,velocities,healths,armors,tags}: Store{clear_column(~Position,handle,positions),clear_column(~Velocity,handle,velocities),clear_column(~Health,handle,healths),clear_column(~Armor,handle,armors),clear_column(~Tag,handle,tags)}

# This finite consumer admits exactly the one/two-cell arrays in its frozen
# fixture. Unsupported lengths are explicit failures, never truncated owners.
def array_second(+first: U32,+second: U32,rest: List<&2,U32>) -> Maybe<&1,Array<U32>>:
  match rest:
    case []: Some{ANode{ALeaf{first},ALeaf{second}}}
    case _ <> _: None{}
def array_tail(+first: U32,rest: List<&2,U32>) -> Maybe<&1,Array<U32>>:
  match rest:
    case []: Some{ALeaf{first}}
    case +second <> rest: array_second(first,second,rest)
def array_from_values(values: List<&2,U32>) -> Maybe<&1,Array<U32>>:
  match values:
    case []: None{}
    case +first <> rest: array_tail(first,rest)
def position_owner_join(+x: F32,incoming: Maybe<&1,Array<U32>>) -> Maybe<&1,Position>:
  match incoming:
    case None{}: None{}
    case Some{trail}: Some{Position{x,trail}}
def position_owner(view: PositionView) -> Maybe<&1,Position>:
  match view:
    case PositionView{+x,trail}: position_owner_join(x,array_from_values(trail))
def health_owner_join(+hp: F32,incoming: Maybe<&1,Array<U32>>) -> Maybe<&1,Health>:
  match incoming:
    case None{}: None{}
    case Some{history}: Some{Health{hp,history}}
def health_owner(view: HealthView) -> Maybe<&1,Health>:
  match view:
    case HealthView{+hp,history}: health_owner_join(hp,array_from_values(history))

def populate(world: W.World<Schema,Store,F32,SimEvent>,handle: W.Handle<Schema>,bundle: Bundle) -> W.World<Schema,Store,F32,SimEvent>:
  match handle:
    case W.Handle{+namespace,+id}: populate_inner(world,W.Handle{namespace,id},bundle)
def clear(store: Store,handle: W.Handle<Schema>) -> Store:
  match handle:
    case W.Handle{+namespace,+id}: clear_inner(store,W.Handle{namespace,id})

def actor_a() -> Bundle:
  Bundle{Some{Position{0.0,ANode{ALeaf{10},ALeaf{11}}}},Some{Velocity{2.0,ALeaf{20}}},Some{Health{5.0,ALeaf{50}}},Some{Armor{1.0}},Some{Tag{}}}
def actor_b() -> Bundle:
  Bundle{Some{Position{10.0,ALeaf{12}}},Some{Velocity{-1.0,ALeaf{21}}},Some{Health{3.0,ALeaf{51}}},None{},None{}}
def actor_c() -> Bundle:
  Bundle{Some{Position{20.0,ALeaf{13}}},None{},Some{Health{9.0,ALeaf{52}}},None{},Some{Tag{}}}
def ghost() -> Bundle:
  Bundle{Some{Position{999.0,ALeaf{999}}},None{},None{},None{},None{}}
