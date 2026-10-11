import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-removal.bend as Access
import ../consumer-public.bend as C
def main() -> Access.Declaration<C.A,C.Payload>:C.selection(~C.A)
