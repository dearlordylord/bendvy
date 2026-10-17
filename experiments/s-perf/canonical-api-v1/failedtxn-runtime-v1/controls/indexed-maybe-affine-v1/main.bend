import Base
import ../../report-doc.bend as D
import ../../motion-doc-world.bend as DW
import ../../../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Old

def lifted(observed:Array<U32> & String) -> Array<U32> & D.Doc:
  match observed:
    case (owner,text):(owner,D.text(text))
def incremented(observed:Array<U32> & U32) -> Array<U32> & D.Doc:
  match observed:
    case (owner,value):lifted(Old.u32_array(Array.set(U32,owner,0,U32.add(value,100))))
def projected(owner:Array<U32>) -> Array<U32> & D.Doc:incremented(Array.get(U32,owner,0))
def old_optional(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:Old.optional(~Array<U32>,~Old.u32_array,value)
def observed(result:Array<Maybe<&1,Array<U32>>> & String) -> String:
  match result:
    case (_,text):text
def returned(result:Array<Maybe<&1,Array<U32>>> & D.Doc) -> IO(Unit):
  match result:
    case (owner,text):D.write(D.concat([D.text("encoded="),text,D.text("\nreturned="),D.text(observed(Old.array(~Maybe<&1,Array<U32>>,~old_optional,owner))),D.text("\n")]))
def input() -> Array<Maybe<&1,Array<U32>>>:ANode{ANode{ALeaf{None{}},ALeaf{Some{ANode{ALeaf{11},ALeaf{12}}}}},ANode{ALeaf{Some{ANode{ALeaf{21},ALeaf{22}}}},ALeaf{None{}}}}
def main() -> IO(Unit):returned(DW.balanced_optional_values(~Array<U32>,~projected,input()))
