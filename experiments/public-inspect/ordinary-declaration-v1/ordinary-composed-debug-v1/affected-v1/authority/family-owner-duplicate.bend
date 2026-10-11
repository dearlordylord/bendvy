import Base
import ../normal/application.bend as A
import ../normal/bindings.bend as B
import ../other/application.bend as Other
import ../other/bindings.bend as OtherB
def refuse(value:A.Application()) -> A.Application() & A.Application():(value,value)
def main() -> Unit:Unit{}
