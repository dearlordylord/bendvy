import Base
import ../normal/application.bend as A
import ../normal/bindings.bend as B
import ../other/application.bend as Other
import ../other/bindings.bend as OtherB
def refuse(value:B.ServiceOwner()) -> B.ServiceOwner() & B.ServiceOwner():(value,value)
def main() -> Unit:Unit{}
