import Base
import internal/relation-failures/domains.bend as D
import relation-types.bend as G

# Trusted ordinary relation declaration: the same descriptor supplies mutation,
# domain identity and reader access metadata. No second numeric/name registry.
type Declaration<S:Data> is Data: Declaration{descriptor:G.Descriptor<S>}
def relation(~S:Data,descriptor:G.Descriptor<S>) -> Declaration<S>: Declaration{descriptor}
def key(~S:Data,declaration:Declaration<S>) -> D.DescriptorKey<S>:
  match declaration:
    case Declaration{G.Descriptor{id,_,_,_}}: D.DeclaredKey{id}
def access(~S:Data,declaration:Declaration<S>) -> String:
  match declaration:
    case Declaration{G.Descriptor{_,name,_,_}}: String.concat([name,":read"])
def keys(~S:Data,declarations:List<&2,Declaration<S>>) -> List<&2,D.DescriptorKey<S>>:
  match declarations:
    case []: []
    case declaration <> rest: key(~S,declaration) <> keys(~S,rest)
def accesses(~S:Data,declarations:List<&2,Declaration<S>>) -> List<&2,String>:
  match declarations:
    case []: []
    case declaration <> rest: access(~S,declaration) <> accesses(~S,rest)
