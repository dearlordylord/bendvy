import Base
import ../../motion-doc-world.bend as Observe
import ../../motion-report-doc.bend as Doc

type AffineProbe is Type:
  AffineProbe{cells:Array<U32>,serial:U32}

def changed_probe(+serial:U32,observed:Array<U32> & U32) -> AffineProbe & Doc.Doc:
  match observed:
    case (cells,value):
      +changed=U32.add(value,100)
      updated_cells=Array.set(U32,cells,0,changed)
      +updated_serial=U32.add(serial,1)
      cells=updated_cells
      +serial=updated_serial
      (AffineProbe{cells,serial},Doc.text("AffineProbe{first=" ++ U32.show(changed) ++ ";serial=" ++ U32.show(serial) ++ "}"))

def mutate(value:AffineProbe) -> AffineProbe & Doc.Doc:
  match value:
    case AffineProbe{cells,serial}:changed_probe(serial,Array.get(U32,cells,0))

def returned_probe(+serial:U32,observed:Array<U32> & U32) -> AffineProbe & Doc.Doc:
  match observed:
    case (cells,first):(AffineProbe{cells,serial},Doc.text("AffineProbe{first=" ++ U32.show(first) ++ ";serial=" ++ U32.show(serial) ++ "}"))

def observe_returned(value:AffineProbe) -> AffineProbe & Doc.Doc:
  match value:
    case AffineProbe{cells,serial}:returned_probe(serial,Array.get(U32,cells,0))

def initial_cells() -> Array<U32>:ANode{ALeaf{5},ALeaf{8}}
def initial_serial() -> U32:3

def initial_probe() -> AffineProbe:
  cells=initial_cells()
  serial=initial_serial()
  AffineProbe{cells,serial}

def initial_values() -> Array<Maybe<&1,AffineProbe>>:
  ANode{ALeaf{Some{initial_probe()}},ALeaf{None{}}}

def emit_returned(helper_doc:Doc.Doc,observed:Array<Maybe<&1,AffineProbe>> & Doc.Doc) -> IO(Unit):
  match observed:
    case (owner,returned_doc):
      Doc.write(Doc.concat([Doc.text("indexed="),helper_doc,Doc.text("\nreturned="),returned_doc,Doc.text("\n")]))

def emit(helper:Array<Maybe<&1,AffineProbe>> & Doc.Doc) -> IO(Unit):
  match helper:
    case (owner,helper_doc):
      emit_returned(helper_doc,Observe.optional_values(~AffineProbe,~observe_returned,owner))

def main() -> IO(Unit):
  emit(Observe.indexed_optional_values(~AffineProbe,~mutate,2,1n,initial_values()))
