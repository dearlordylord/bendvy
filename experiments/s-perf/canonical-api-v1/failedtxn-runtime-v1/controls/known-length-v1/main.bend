import Base
import ../../report-buffer.bend as B

def repeated_go(count:Nat,+head:Char,acc:String) -> String:
  match count:
    case 0n:acc
    case 1n+rest:repeated_go(rest,head,SCon{head,acc})
def repeated(count:Nat,head:Char) -> String:repeated_go(count,head,SNil{})
def row(+value:String) -> IO(Unit):IO.bind(Unit,Unit,B.write(B.known(value,String.length(value),B.empty())),_=>IO.write("\n"))
def many(count:Nat,buffer:B.Buffer) -> B.Buffer:
  match count:
    case 0n:buffer
    case 1n+rest:many(rest,B.known("q",1n,buffer))
def suffix(_:Unit) -> IO(Unit):
  IO.bind(Unit,Unit,row(repeated(100001n,'w')),_=>IO.bind(Unit,Unit,B.write(many(10003n,B.empty())),_=>IO.write("\n")))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,B.write(B.known("",0n,B.empty())),_=>
    IO.bind(Unit,Unit,row("ASCII xyz 012"),_=>
      IO.bind(Unit,Unit,row("Aα😀Z"),_=>
        IO.bind(Unit,Unit,row(repeated(4095n,'x')),_=>
          IO.bind(Unit,Unit,row(repeated(4096n,'y')),_=>IO.bind(Unit,Unit,row(repeated(4097n,'z')),suffix))))))
