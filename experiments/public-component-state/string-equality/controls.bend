import Base
import equality.bend as E

def shown(x: Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"

def pair(+a: String,+b: String) -> String:
  shown(E.equal(a,b)) ++ ":" ++ shown(String.eq(a,b))

def print_lines(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{})
    case line <> rest: IO.bind(Unit,Unit,IO.print(line),u => print_lines(rest))

def rows0() -> List<&2,String>:
  [
    pair("",""),
    pair("","a"),
    pair("","ab"),
    pair("","abc"),
    pair("","abd"),
    pair("","b"),
    pair("","A"),
    pair("","😀"),
    pair("","😀a"),
    pair("","😀b"),
    pair("","😃"),
    pair("","é"),
    pair("","é"),
    pair("","\0"),
    pair("","a\0b"),
    pair("","中文"),
    pair("","𝄞"),
    pair("","􏿿")
  ]

def rows1() -> List<&2,String>:
  [
    pair("a",""),
    pair("a","a"),
    pair("a","ab"),
    pair("a","abc"),
    pair("a","abd"),
    pair("a","b"),
    pair("a","A"),
    pair("a","😀"),
    pair("a","😀a"),
    pair("a","😀b"),
    pair("a","😃"),
    pair("a","é"),
    pair("a","é"),
    pair("a","\0"),
    pair("a","a\0b"),
    pair("a","中文"),
    pair("a","𝄞"),
    pair("a","􏿿")
  ]

def rows2() -> List<&2,String>:
  [
    pair("ab",""),
    pair("ab","a"),
    pair("ab","ab"),
    pair("ab","abc"),
    pair("ab","abd"),
    pair("ab","b"),
    pair("ab","A"),
    pair("ab","😀"),
    pair("ab","😀a"),
    pair("ab","😀b"),
    pair("ab","😃"),
    pair("ab","é"),
    pair("ab","é"),
    pair("ab","\0"),
    pair("ab","a\0b"),
    pair("ab","中文"),
    pair("ab","𝄞"),
    pair("ab","􏿿")
  ]

def rows3() -> List<&2,String>:
  [
    pair("abc",""),
    pair("abc","a"),
    pair("abc","ab"),
    pair("abc","abc"),
    pair("abc","abd"),
    pair("abc","b"),
    pair("abc","A"),
    pair("abc","😀"),
    pair("abc","😀a"),
    pair("abc","😀b"),
    pair("abc","😃"),
    pair("abc","é"),
    pair("abc","é"),
    pair("abc","\0"),
    pair("abc","a\0b"),
    pair("abc","中文"),
    pair("abc","𝄞"),
    pair("abc","􏿿")
  ]

def rows4() -> List<&2,String>:
  [
    pair("abd",""),
    pair("abd","a"),
    pair("abd","ab"),
    pair("abd","abc"),
    pair("abd","abd"),
    pair("abd","b"),
    pair("abd","A"),
    pair("abd","😀"),
    pair("abd","😀a"),
    pair("abd","😀b"),
    pair("abd","😃"),
    pair("abd","é"),
    pair("abd","é"),
    pair("abd","\0"),
    pair("abd","a\0b"),
    pair("abd","中文"),
    pair("abd","𝄞"),
    pair("abd","􏿿")
  ]

def rows5() -> List<&2,String>:
  [
    pair("b",""),
    pair("b","a"),
    pair("b","ab"),
    pair("b","abc"),
    pair("b","abd"),
    pair("b","b"),
    pair("b","A"),
    pair("b","😀"),
    pair("b","😀a"),
    pair("b","😀b"),
    pair("b","😃"),
    pair("b","é"),
    pair("b","é"),
    pair("b","\0"),
    pair("b","a\0b"),
    pair("b","中文"),
    pair("b","𝄞"),
    pair("b","􏿿")
  ]

def rows6() -> List<&2,String>:
  [
    pair("A",""),
    pair("A","a"),
    pair("A","ab"),
    pair("A","abc"),
    pair("A","abd"),
    pair("A","b"),
    pair("A","A"),
    pair("A","😀"),
    pair("A","😀a"),
    pair("A","😀b"),
    pair("A","😃"),
    pair("A","é"),
    pair("A","é"),
    pair("A","\0"),
    pair("A","a\0b"),
    pair("A","中文"),
    pair("A","𝄞"),
    pair("A","􏿿")
  ]

def rows7() -> List<&2,String>:
  [
    pair("😀",""),
    pair("😀","a"),
    pair("😀","ab"),
    pair("😀","abc"),
    pair("😀","abd"),
    pair("😀","b"),
    pair("😀","A"),
    pair("😀","😀"),
    pair("😀","😀a"),
    pair("😀","😀b"),
    pair("😀","😃"),
    pair("😀","é"),
    pair("😀","é"),
    pair("😀","\0"),
    pair("😀","a\0b"),
    pair("😀","中文"),
    pair("😀","𝄞"),
    pair("😀","􏿿")
  ]

def rows8() -> List<&2,String>:
  [
    pair("😀a",""),
    pair("😀a","a"),
    pair("😀a","ab"),
    pair("😀a","abc"),
    pair("😀a","abd"),
    pair("😀a","b"),
    pair("😀a","A"),
    pair("😀a","😀"),
    pair("😀a","😀a"),
    pair("😀a","😀b"),
    pair("😀a","😃"),
    pair("😀a","é"),
    pair("😀a","é"),
    pair("😀a","\0"),
    pair("😀a","a\0b"),
    pair("😀a","中文"),
    pair("😀a","𝄞"),
    pair("😀a","􏿿")
  ]

def rows9() -> List<&2,String>:
  [
    pair("😀b",""),
    pair("😀b","a"),
    pair("😀b","ab"),
    pair("😀b","abc"),
    pair("😀b","abd"),
    pair("😀b","b"),
    pair("😀b","A"),
    pair("😀b","😀"),
    pair("😀b","😀a"),
    pair("😀b","😀b"),
    pair("😀b","😃"),
    pair("😀b","é"),
    pair("😀b","é"),
    pair("😀b","\0"),
    pair("😀b","a\0b"),
    pair("😀b","中文"),
    pair("😀b","𝄞"),
    pair("😀b","􏿿")
  ]

def rows10() -> List<&2,String>:
  [
    pair("😃",""),
    pair("😃","a"),
    pair("😃","ab"),
    pair("😃","abc"),
    pair("😃","abd"),
    pair("😃","b"),
    pair("😃","A"),
    pair("😃","😀"),
    pair("😃","😀a"),
    pair("😃","😀b"),
    pair("😃","😃"),
    pair("😃","é"),
    pair("😃","é"),
    pair("😃","\0"),
    pair("😃","a\0b"),
    pair("😃","中文"),
    pair("😃","𝄞"),
    pair("😃","􏿿")
  ]

def rows11() -> List<&2,String>:
  [
    pair("é",""),
    pair("é","a"),
    pair("é","ab"),
    pair("é","abc"),
    pair("é","abd"),
    pair("é","b"),
    pair("é","A"),
    pair("é","😀"),
    pair("é","😀a"),
    pair("é","😀b"),
    pair("é","😃"),
    pair("é","é"),
    pair("é","é"),
    pair("é","\0"),
    pair("é","a\0b"),
    pair("é","中文"),
    pair("é","𝄞"),
    pair("é","􏿿")
  ]

def rows12() -> List<&2,String>:
  [
    pair("é",""),
    pair("é","a"),
    pair("é","ab"),
    pair("é","abc"),
    pair("é","abd"),
    pair("é","b"),
    pair("é","A"),
    pair("é","😀"),
    pair("é","😀a"),
    pair("é","😀b"),
    pair("é","😃"),
    pair("é","é"),
    pair("é","é"),
    pair("é","\0"),
    pair("é","a\0b"),
    pair("é","中文"),
    pair("é","𝄞"),
    pair("é","􏿿")
  ]

def rows13() -> List<&2,String>:
  [
    pair("\0",""),
    pair("\0","a"),
    pair("\0","ab"),
    pair("\0","abc"),
    pair("\0","abd"),
    pair("\0","b"),
    pair("\0","A"),
    pair("\0","😀"),
    pair("\0","😀a"),
    pair("\0","😀b"),
    pair("\0","😃"),
    pair("\0","é"),
    pair("\0","é"),
    pair("\0","\0"),
    pair("\0","a\0b"),
    pair("\0","中文"),
    pair("\0","𝄞"),
    pair("\0","􏿿")
  ]

def rows14() -> List<&2,String>:
  [
    pair("a\0b",""),
    pair("a\0b","a"),
    pair("a\0b","ab"),
    pair("a\0b","abc"),
    pair("a\0b","abd"),
    pair("a\0b","b"),
    pair("a\0b","A"),
    pair("a\0b","😀"),
    pair("a\0b","😀a"),
    pair("a\0b","😀b"),
    pair("a\0b","😃"),
    pair("a\0b","é"),
    pair("a\0b","é"),
    pair("a\0b","\0"),
    pair("a\0b","a\0b"),
    pair("a\0b","中文"),
    pair("a\0b","𝄞"),
    pair("a\0b","􏿿")
  ]

def rows15() -> List<&2,String>:
  [
    pair("中文",""),
    pair("中文","a"),
    pair("中文","ab"),
    pair("中文","abc"),
    pair("中文","abd"),
    pair("中文","b"),
    pair("中文","A"),
    pair("中文","😀"),
    pair("中文","😀a"),
    pair("中文","😀b"),
    pair("中文","😃"),
    pair("中文","é"),
    pair("中文","é"),
    pair("中文","\0"),
    pair("中文","a\0b"),
    pair("中文","中文"),
    pair("中文","𝄞"),
    pair("中文","􏿿")
  ]

def rows16() -> List<&2,String>:
  [
    pair("𝄞",""),
    pair("𝄞","a"),
    pair("𝄞","ab"),
    pair("𝄞","abc"),
    pair("𝄞","abd"),
    pair("𝄞","b"),
    pair("𝄞","A"),
    pair("𝄞","😀"),
    pair("𝄞","😀a"),
    pair("𝄞","😀b"),
    pair("𝄞","😃"),
    pair("𝄞","é"),
    pair("𝄞","é"),
    pair("𝄞","\0"),
    pair("𝄞","a\0b"),
    pair("𝄞","中文"),
    pair("𝄞","𝄞"),
    pair("𝄞","􏿿")
  ]

def rows17() -> List<&2,String>:
  [
    pair("􏿿",""),
    pair("􏿿","a"),
    pair("􏿿","ab"),
    pair("􏿿","abc"),
    pair("􏿿","abd"),
    pair("􏿿","b"),
    pair("􏿿","A"),
    pair("􏿿","😀"),
    pair("􏿿","😀a"),
    pair("􏿿","😀b"),
    pair("􏿿","😃"),
    pair("􏿿","é"),
    pair("􏿿","é"),
    pair("􏿿","\0"),
    pair("􏿿","a\0b"),
    pair("􏿿","中文"),
    pair("􏿿","𝄞"),
    pair("􏿿","􏿿")
  ]

def rows18() -> List<&2,String>:
  [
    shown(E.registration_equal(7,"runner",["read-phase", "write-mode"],7,"runner",["read-phase", "write-mode"])),
    shown(E.registration_equal(7,"runner",["read-phase", "write-mode"],7,"runner2",["read-phase", "write-mode"])),
    shown(E.registration_equal(7,"runner",["read-phase"],7,"runner",["read-phase", "write-mode"])),
    shown(E.registration_equal(7,"runner",["read-phase", "write-mode"],7,"runner",["write-mode", "read-phase"])),
    shown(E.registration_equal(7,"runner",["read-phase"],7,"runner",["read-phases"])),
    shown(E.registration_equal(7,"runner",["read-phase"],8,"runner",["read-phase"])),
    shown(E.registration_equal(7,"😀runner",["😀read"],7,"😀runner",["😀read"])),
    shown(E.registration_equal(7,"😀runner",["😀read"],7,"😃runner",["😀read"])),
    shown(E.registration_equal(7,"runner",[],7,"runner",[]))
  ]

def main() -> IO(Unit):
  print_lines(List.append(&2,String,rows0(),List.append(&2,String,rows1(),List.append(&2,String,rows2(),List.append(&2,String,rows3(),List.append(&2,String,rows4(),List.append(&2,String,rows5(),List.append(&2,String,rows6(),List.append(&2,String,rows7(),List.append(&2,String,rows8(),List.append(&2,String,rows9(),List.append(&2,String,rows10(),List.append(&2,String,rows11(),List.append(&2,String,rows12(),List.append(&2,String,rows13(),List.append(&2,String,rows14(),List.append(&2,String,rows15(),List.append(&2,String,rows16(),List.append(&2,String,rows17(),rows18())))))))))))))))))))
