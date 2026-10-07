import Base
import candidate.bend as C
import ../../../../src/ecs/world.bend as W

def old_meta(meta: C.RegistrationMeta) -> W.RegistrationMeta:
  match meta:
    case C.RegistrationMeta{id,name,access}: W.RegistrationMeta{id,name,access}
def old_list(metas: List<&2,C.RegistrationMeta>) -> List<&2,W.RegistrationMeta>:
  match metas:
    case []: []
    case meta <> rest: old_meta(meta) <> old_list(rest)
def shown(x: Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"
def meta_pair(+meta: C.RegistrationMeta,+id: U32,+name: String,+access: List<&2,String>) -> String:
  shown(C.registration_meta_matches(meta,id,name,access)) ++ ":" ++ shown(W.registration_meta_matches(old_meta(meta),id,name,access))
def list_pair(+metas: List<&2,C.RegistrationMeta>,+id: U32,+name: String,+access: List<&2,String>) -> String:
  shown(C.registration_list_matches(metas,id,name,access)) ++ ":" ++ shown(W.registration_list_matches(old_list(metas),id,name,access))
def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),u => print_lines(rest))

def rows0() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{0,"",[]},0,"",[]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{0,"",[]},7,"runner",["write-mode", "read-phase"])]

def rows1() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows2() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows3() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"runner2",["read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows4() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"Runner",["read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows5() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{8,"runner",["read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows6() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"😀runner",["read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows7() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},7,"runner",["write-mode", "read-phase"])]

def rows8() -> List<&2,String>:
  [meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},0,"",[]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"runner",["write-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"runner2",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"Runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},8,"runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"😀runner",["read-phase"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"runner",["read-phase", "write-mode"]),
    meta_pair(C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},7,"runner",["write-mode", "read-phase"])]

def rows9() -> List<&2,String>:
  [list_pair([],0,"",[]),
    list_pair([],7,"runner",["read-phase"]),
    list_pair([],7,"runner",["write-phase"]),
    list_pair([],7,"runner2",["read-phase"]),
    list_pair([],7,"Runner",["read-phase"]),
    list_pair([],8,"runner",["read-phase"]),
    list_pair([],7,"😀runner",["read-phase"]),
    list_pair([],7,"runner",["read-phase", "write-mode"]),
    list_pair([],7,"runner",["write-mode", "read-phase"])]

def rows10() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],0,"",[]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-mode", "read-phase"])]

def rows11() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],0,"",[]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{0,"",[]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]}],7,"runner",["write-mode", "read-phase"])]

def rows12() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],0,"",[]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-mode", "read-phase"]},C.RegistrationMeta{7,"runner",["read-phase", "write-mode"]},C.RegistrationMeta{7,"😀runner",["read-phase"]},C.RegistrationMeta{8,"runner",["read-phase"]},C.RegistrationMeta{7,"Runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{0,"",[]}],7,"runner",["write-mode", "read-phase"])]

def rows13() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],0,"",[]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{7,"runner2",["read-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-mode", "read-phase"])]

def rows14() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],0,"",[]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{7,"runner",["read-phase"]},C.RegistrationMeta{7,"runner2",["read-phase"]}],7,"runner",["write-mode", "read-phase"])]

def rows15() -> List<&2,String>:
  [list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],0,"",[]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner2",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"Runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],8,"runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"😀runner",["read-phase"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["read-phase", "write-mode"]),
    list_pair([C.RegistrationMeta{7,"runner",["write-phase"]},C.RegistrationMeta{7,"runner",["read-phase"]}],7,"runner",["write-mode", "read-phase"])]

def main() -> IO(Unit):
  print_lines(List.append(&2,String,rows0(),List.append(&2,String,rows1(),List.append(&2,String,rows2(),List.append(&2,String,rows3(),List.append(&2,String,rows4(),List.append(&2,String,rows5(),List.append(&2,String,rows6(),List.append(&2,String,rows7(),List.append(&2,String,rows8(),List.append(&2,String,rows9(),List.append(&2,String,rows10(),List.append(&2,String,rows11(),List.append(&2,String,rows12(),List.append(&2,String,rows13(),List.append(&2,String,rows14(),rows15()))))))))))))))))
