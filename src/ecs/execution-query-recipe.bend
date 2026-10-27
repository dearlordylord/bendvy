import Base
import ./execution-composer-layout.bend as L
import ./execution-query-matches.bend as Match

type QueryKind is Data:
  ReadRows{}
  WriteRows{}
type Bound is Data:
  AllLive{}
  With{route:L.Route}
  Without{route:L.Route}
  And{left:Bound,right:Bound}
  Or{left:Bound,right:Bound}
# Symbolic declaration only. Physical domains do not exist until admission
# inspects actual full-World handles/storage; predicates are operation-local.
type Entry is Data:
  Entry{route:L.Route,kind:QueryKind,bound:Bound,presence:Match.Presence}
type Recipe<-S:Data,-WC:Type> is Data:
  Recipe{entry:Entry}
def brand(-S:Data,-WC:Type,entries:List<&2,Entry>) -> List<&2,Recipe<S,WC>>:
  match entries:
    case []:[]
    case entry <> rest:Recipe{entry} <> brand(S,WC,rest)
def bound_valid(~full:L.Layout,bound:Bound) -> Bool:
  match bound:
    case AllLive{}:True{}
    case With{route}:L.valid(full,route)
    case Without{route}:L.valid(full,route)
    case And{left,right}:Bool.and(bound_valid(~full,left),bound_valid(~full,right))
    case Or{left,right}:Bool.and(bound_valid(~full,left),bound_valid(~full,right))
