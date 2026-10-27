import Base

# The existential field retains the actual typed owner header across a pure
# call. Its native layout stays boxed even when the held product is wide.
# Bind the header before that call: native ANF hoists nested call arguments
# before inline constructor arguments, otherwise retaining the unpacked owners.
type Header<-Input:Type,-Output:Type> is Type:
  Header{-Held:Type,held:Held,resume:Held -> Input -> Output}
def returned(-Input:Type,-Output:Type,header:Header<Input,Output>,value:Input) -> Output:
  match header:
    case Header{Held,held,resume}:resume(held,value)
def decided(-Output:Type,header:Header<(Bool & Bool),Output>,valid:Bool,compatible:Bool) -> Output:
  returned(Bool & Bool,Output,header,(valid,compatible))
