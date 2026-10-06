import Base
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/component.bend as Cmp

def main() -> List<&2,Bool>:
  Q.selected_value(~U32,Q.Optional{},Cmp.ComponentAbsent{}) <>
  Q.selected_value(~U32,Q.Required{},Cmp.ComponentAbsent{}) <>
  Q.selected_value(~U32,Q.Present{},Cmp.Found{7}) <>
  Q.selected_value(~U32,Q.Absent{},Cmp.ComponentAbsent{}) <>
  Q.selected_value(~U32,Q.Absent{},Cmp.Found{7}) <> []
