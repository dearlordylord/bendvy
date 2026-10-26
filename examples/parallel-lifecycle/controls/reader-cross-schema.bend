import Base
import ../notice-positive-core.bend as Core

def rebrand(reader:Core.Reader(~Core.First)) -> Core.Reader(~Core.Second):reader
