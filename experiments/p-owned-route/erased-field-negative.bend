import Base

type Ghost<-A: Type> is Type:
  Ghost{-proof: A}

def extract(-A: Type, ghost: Ghost<A>) -> A:
  match ghost:
    case Ghost{proof}: proof
