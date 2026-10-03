import Base
import ./api.bend as A

type MotionToken is Data:
  Position{}
type HealthToken is Data:
  HitPoints{}
type Tag is Data:
  Tag{}
type TagCell is Type:
  TagCell{tag: Maybe<&2, Tag>}
type CombatData is Data:
  CombatData{damage: U32, armor: Maybe<&2, U32>}
type CombatCell is Type:
  CombatCell{damage: U32, armor: Maybe<&2, U32>}

def tag_get(c: TagCell) -> TagCell & Maybe<&2, Tag>:
  match c:
    case TagCell{+tag}: (TagCell{tag}, tag)
def combat_get(c: CombatCell) -> CombatCell & CombatData:
  match c:
    case CombatCell{+damage, +armor}: (CombatCell{damage, armor}, CombatData{damage, armor})
def present(~T: Data, m: Maybe<&2, T>) -> Bool:
  match m:
    case None{}: False{}
    case Some{_}: True{}
def tag_has(c: TagCell) -> TagCell & Bool:
  match c:
    case TagCell{+tag}: (TagCell{tag}, present(~Tag, tag))
def combat_has(c: CombatCell) -> CombatCell & Bool:
  match c:
    case CombatCell{damage, +armor}: (CombatCell{damage, armor}, present(~U32, armor))
def motion() -> A.World<MotionToken, TagCell>:
  A.World{[A.Row{"a", A.Cell{0}, TagCell{Some{Tag{}}}}, A.Row{"b", A.Cell{10}, TagCell{None{}}}]}
def health() -> A.World<HealthToken, CombatCell>:
  A.World{[A.Row{"a", A.Cell{20}, CombatCell{3, Some{1}}}, A.Row{"b", A.Cell{30}, CombatCell{2, None{}}}]}
def tag_show(m: Maybe<&2, Tag>) -> String:
  match m:
    case None{}: "absent"
    case Some{_}: "present{}"
def armor_show(m: Maybe<&2, U32>) -> String:
  match m:
    case None{}: "absent"
    case Some{x}: "present=" ++ U32.show(x)
