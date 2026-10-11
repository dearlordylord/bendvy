import Base
import ../consumer-public.bend as C
def duplicated(owner:C.Fixture<C.A>) -> C.Fixture<C.A> & C.Fixture<C.A>:(owner,owner)
def main() -> C.Fixture<C.A> & C.Fixture<C.A>:duplicated(C.setup(~C.A))
