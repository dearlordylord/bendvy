import Base
import ../../report-doc.bend as D

def repeated_go(count:Nat,+head:Char,acc:String) -> String:
  match count:
    case 0n:acc
    case 1n+rest:repeated_go(rest,head,SCon{head,acc})
def repeated(count:Nat,head:Char) -> String:repeated_go(count,head,SNil{})
def row(value:String) -> IO(Unit):D.write(D.join(D.text(value),D.text("\n")))
def many(count:Nat,acc:D.Doc) -> D.Doc:
  match count:
    case 0n:acc
    case 1n+rest:many(rest,D.join(acc,D.text("q")))
def suffix(_:Unit) -> IO(Unit):IO.bind(Unit,Unit,row(repeated(100001n,'w')),_=>D.write(D.join(many(10003n,D.text("")),D.text("\n"))))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,D.write(D.text("")),_=>
    IO.bind(Unit,Unit,row("ASCII xyz 012"),_=>
      IO.bind(Unit,Unit,row("Aα😀Z"),_=>
        IO.bind(Unit,Unit,row(repeated(4095n,'x')),_=>
          IO.bind(Unit,Unit,row(repeated(4096n,'y')),_=>IO.bind(Unit,Unit,row(repeated(4097n,'z')),suffix))))))
