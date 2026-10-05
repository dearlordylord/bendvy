import Base
import ./transport.bend as T

type ScalarOwner is Type:
  ScalarOwner{value: U32}
type ArrayOwner is Type:
  ArrayOwner{values: Array<U32>}
def scalar_show(v: ScalarOwner) -> String:
  match v:
    case ScalarOwner{x}: "Scalar(" ++ U32.show(x) ++ ")"
def array_show(v: ArrayOwner) -> String:
  match v:
    case ArrayOwner{x}: "Array" ++ List.show(&1,U32,U32.show,Array.to_list(U32,x))
def flag_show(v: Maybe<&2,U32>) -> String:
  Maybe.show(&2,U32,U32.show,v)
def meta_show(v: T.Metadata<U32>) -> String:
  match v:
    case T.Metadata{l,f,a,c}: Bool.show(l) ++ "/" ++ flag_show(f) ++ "/" ++ U32.show(a) ++ "/" ++ U32.show(c)
def observation_show(v: Maybe<&2,T.Metadata<U32>>) -> String:
  Maybe.show(&2,T.Metadata<U32>,meta_show,v)
def one_mshow(v: Maybe<ScalarOwner>) -> String:
  Maybe.show(&1,ScalarOwner,scalar_show,v)
def one_ashow(v: Maybe<ArrayOwner>) -> String:
  Maybe.show(&1,ArrayOwner,array_show,v)
def one_original() -> T.Original<ScalarOwner,ArrayOwner,U32>:
  T.Original{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{False{},Some{99},13,14}}},2,1n,2}
def one_columns() -> T.Columns<ScalarOwner,ArrayOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,2}
def one_original_show(r: T.Original<ScalarOwner,ArrayOwner,U32>) -> String:
  match r:
    case T.Original{m,a,meta,c,d,h}: List.show(&1,Maybe<ScalarOwner>,one_mshow,Array.to_list(Maybe<ScalarOwner>,m)) ++ "|" ++ List.show(&1,Maybe<ArrayOwner>,one_ashow,Array.to_list(Maybe<ArrayOwner>,a)) ++ "|" ++ List.show(&1,T.Metadata<U32>,meta_show,Array.to_list(T.Metadata<U32>,meta)) ++ "|" ++ U32.show(c) ++ "/" ++ Nat.show(d) ++ "/" ++ U32.show(h)
def one_columns_show(r: T.Columns<ScalarOwner,ArrayOwner,U32>) -> String:
  match r:
    case T.Columns{m,a,l,f,ad,ch,c,d,h}: List.show(&1,Maybe<ScalarOwner>,one_mshow,Array.to_list(Maybe<ScalarOwner>,m)) ++ "|" ++ List.show(&1,Maybe<ArrayOwner>,one_ashow,Array.to_list(Maybe<ArrayOwner>,a)) ++ "|" ++ List.show(&1,Bool,Bool.show,Array.to_list(Bool,l)) ++ "|" ++ List.show(&1,Maybe<&2,U32>,flag_show,Array.to_list(Maybe<&2,U32>,f)) ++ "|" ++ List.show(&1,U32,U32.show,Array.to_list(U32,ad)) ++ "|" ++ List.show(&1,U32,U32.show,Array.to_list(U32,ch)) ++ "|" ++ U32.show(c) ++ "/" ++ Nat.show(d) ++ "/" ++ U32.show(h)
def one_original_done(result: T.Original<ScalarOwner,ArrayOwner,U32> & Maybe<&2,T.Metadata<U32>>) -> String:
  match result:
    case (r,observation): observation_show(observation) ++ ";" ++ one_original_show(r)
def one_run_original(+id: U32,tick: U32) -> String:
  one_original_done(T.original_read(ScalarOwner,ArrayOwner,U32,T.original_mark(ScalarOwner,ArrayOwner,U32,one_original(),id,tick),id))
def one_columns_done(result: T.Columns<ScalarOwner,ArrayOwner,U32> & Maybe<&2,T.Metadata<U32>>) -> String:
  match result:
    case (r,observation): observation_show(observation) ++ ";" ++ one_columns_show(r)
def one_run_columns(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,one_columns(),id,tick),id))
def two_mshow(v: Maybe<ArrayOwner>) -> String:
  Maybe.show(&1,ArrayOwner,array_show,v)
def two_ashow(v: Maybe<ScalarOwner>) -> String:
  Maybe.show(&1,ScalarOwner,scalar_show,v)
def two_original() -> T.Original<ArrayOwner,ScalarOwner,U32>:
  T.Original{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{False{},Some{99},13,14}}},2,1n,2}
def two_columns() -> T.Columns<ArrayOwner,ScalarOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,2}
def two_original_show(r: T.Original<ArrayOwner,ScalarOwner,U32>) -> String:
  match r:
    case T.Original{m,a,meta,c,d,h}: List.show(&1,Maybe<ArrayOwner>,two_mshow,Array.to_list(Maybe<ArrayOwner>,m)) ++ "|" ++ List.show(&1,Maybe<ScalarOwner>,two_ashow,Array.to_list(Maybe<ScalarOwner>,a)) ++ "|" ++ List.show(&1,T.Metadata<U32>,meta_show,Array.to_list(T.Metadata<U32>,meta)) ++ "|" ++ U32.show(c) ++ "/" ++ Nat.show(d) ++ "/" ++ U32.show(h)
def two_columns_show(r: T.Columns<ArrayOwner,ScalarOwner,U32>) -> String:
  match r:
    case T.Columns{m,a,l,f,ad,ch,c,d,h}: List.show(&1,Maybe<ArrayOwner>,two_mshow,Array.to_list(Maybe<ArrayOwner>,m)) ++ "|" ++ List.show(&1,Maybe<ScalarOwner>,two_ashow,Array.to_list(Maybe<ScalarOwner>,a)) ++ "|" ++ List.show(&1,Bool,Bool.show,Array.to_list(Bool,l)) ++ "|" ++ List.show(&1,Maybe<&2,U32>,flag_show,Array.to_list(Maybe<&2,U32>,f)) ++ "|" ++ List.show(&1,U32,U32.show,Array.to_list(U32,ad)) ++ "|" ++ List.show(&1,U32,U32.show,Array.to_list(U32,ch)) ++ "|" ++ U32.show(c) ++ "/" ++ Nat.show(d) ++ "/" ++ U32.show(h)
def two_original_done(result: T.Original<ArrayOwner,ScalarOwner,U32> & Maybe<&2,T.Metadata<U32>>) -> String:
  match result:
    case (r,observation): observation_show(observation) ++ ";" ++ two_original_show(r)
def two_run_original(+id: U32,tick: U32) -> String:
  two_original_done(T.original_read(ArrayOwner,ScalarOwner,U32,T.original_mark(ArrayOwner,ScalarOwner,U32,two_original(),id,tick),id))
def two_columns_done(result: T.Columns<ArrayOwner,ScalarOwner,U32> & Maybe<&2,T.Metadata<U32>>) -> String:
  match result:
    case (r,observation): observation_show(observation) ++ ";" ++ two_columns_show(r)
def two_run_columns(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,two_columns(),id,tick),id))
def one_run_converted(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,T.from_original(ScalarOwner,ArrayOwner,U32,one_original()),id,tick),id))
def two_run_converted(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,T.from_original(ArrayOwner,ScalarOwner,U32,two_original()),id,tick),id))
def one_highzero_original() -> T.Original<ScalarOwner,ArrayOwner,U32>:
  T.Original{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{False{},Some{99},13,14}}},2,1n,0}
def one_highzero_columns() -> T.Columns<ScalarOwner,ArrayOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,0}
def one_highzero_run_original(+id: U32,tick: U32) -> String:
  one_original_done(T.original_read(ScalarOwner,ArrayOwner,U32,T.original_mark(ScalarOwner,ArrayOwner,U32,one_highzero_original(),id,tick),id))
def one_highzero_run_columns(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,one_highzero_columns(),id,tick),id))
def one_highzero_run_converted(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,T.from_original(ScalarOwner,ArrayOwner,U32,one_highzero_original()),id,tick),id))
def one_highone_original() -> T.Original<ScalarOwner,ArrayOwner,U32>:
  T.Original{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{True{},Some{99},13,14}}},2,1n,1}
def one_highone_columns() -> T.Columns<ScalarOwner,ArrayOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ScalarOwner{41}}},ALeaf{None{}}},ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{7},ALeaf{8}}}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{True{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,1}
def one_highone_run_original(+id: U32,tick: U32) -> String:
  one_original_done(T.original_read(ScalarOwner,ArrayOwner,U32,T.original_mark(ScalarOwner,ArrayOwner,U32,one_highone_original(),id,tick),id))
def one_highone_run_columns(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,one_highone_columns(),id,tick),id))
def one_highone_run_converted(+id: U32,tick: U32) -> String:
  one_columns_done(T.columns_read(ScalarOwner,ArrayOwner,U32,T.columns_mark(ScalarOwner,ArrayOwner,U32,T.from_original(ScalarOwner,ArrayOwner,U32,one_highone_original()),id,tick),id))
def two_highzero_original() -> T.Original<ArrayOwner,ScalarOwner,U32>:
  T.Original{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{False{},Some{99},13,14}}},2,1n,0}
def two_highzero_columns() -> T.Columns<ArrayOwner,ScalarOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,0}
def two_highzero_run_original(+id: U32,tick: U32) -> String:
  two_original_done(T.original_read(ArrayOwner,ScalarOwner,U32,T.original_mark(ArrayOwner,ScalarOwner,U32,two_highzero_original(),id,tick),id))
def two_highzero_run_columns(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,two_highzero_columns(),id,tick),id))
def two_highzero_run_converted(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,T.from_original(ArrayOwner,ScalarOwner,U32,two_highzero_original()),id,tick),id))
def two_highone_original() -> T.Original<ArrayOwner,ScalarOwner,U32>:
  T.Original{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{T.Metadata{True{},Some{9},3,4}},ALeaf{T.Metadata{True{},Some{99},13,14}}},2,1n,1}
def two_highone_columns() -> T.Columns<ArrayOwner,ScalarOwner,U32>:
  T.Columns{ANode{ALeaf{Some{ArrayOwner{ANode{ALeaf{51},ALeaf{52}}}}},ALeaf{None{}}},ANode{ALeaf{Some{ScalarOwner{61}}},ALeaf{None{}}},ANode{ALeaf{True{}},ALeaf{True{}}},ANode{ALeaf{Some{9}},ALeaf{Some{99}}},ANode{ALeaf{3},ALeaf{13}},ANode{ALeaf{4},ALeaf{14}},2,1n,1}
def two_highone_run_original(+id: U32,tick: U32) -> String:
  two_original_done(T.original_read(ArrayOwner,ScalarOwner,U32,T.original_mark(ArrayOwner,ScalarOwner,U32,two_highone_original(),id,tick),id))
def two_highone_run_columns(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,two_highone_columns(),id,tick),id))
def two_highone_run_converted(+id: U32,tick: U32) -> String:
  two_columns_done(T.columns_read(ArrayOwner,ScalarOwner,U32,T.columns_mark(ArrayOwner,ScalarOwner,U32,T.from_original(ArrayOwner,ScalarOwner,U32,two_highone_original()),id,tick),id))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("one/1/original:" ++ one_run_original(1,88))
    IO.print("one/1/columns:" ++ one_run_columns(1,88))
    IO.print("one/1/converted:" ++ one_run_converted(1,88))
    IO.print("one/2/original:" ++ one_run_original(2,88))
    IO.print("one/2/columns:" ++ one_run_columns(2,88))
    IO.print("one/2/converted:" ++ one_run_converted(2,88))
    IO.print("one/0/original:" ++ one_run_original(0,88))
    IO.print("one/0/columns:" ++ one_run_columns(0,88))
    IO.print("one/0/converted:" ++ one_run_converted(0,88))
    IO.print("one/3/original:" ++ one_run_original(3,88))
    IO.print("one/3/columns:" ++ one_run_columns(3,88))
    IO.print("one/3/converted:" ++ one_run_converted(3,88))
    IO.print("one/4294967295/original:" ++ one_run_original(4294967295,88))
    IO.print("one/4294967295/columns:" ++ one_run_columns(4294967295,88))
    IO.print("one/4294967295/converted:" ++ one_run_converted(4294967295,88))
    IO.print("two/1/original:" ++ two_run_original(1,88))
    IO.print("two/1/columns:" ++ two_run_columns(1,88))
    IO.print("two/1/converted:" ++ two_run_converted(1,88))
    IO.print("two/2/original:" ++ two_run_original(2,88))
    IO.print("two/2/columns:" ++ two_run_columns(2,88))
    IO.print("two/2/converted:" ++ two_run_converted(2,88))
    IO.print("two/0/original:" ++ two_run_original(0,88))
    IO.print("two/0/columns:" ++ two_run_columns(0,88))
    IO.print("two/0/converted:" ++ two_run_converted(0,88))
    IO.print("two/3/original:" ++ two_run_original(3,88))
    IO.print("two/3/columns:" ++ two_run_columns(3,88))
    IO.print("two/3/converted:" ++ two_run_converted(3,88))
    IO.print("two/4294967295/original:" ++ two_run_original(4294967295,88))
    IO.print("two/4294967295/columns:" ++ two_run_columns(4294967295,88))
    IO.print("two/4294967295/converted:" ++ two_run_converted(4294967295,88))
    IO.print("one-highzero/1/original:" ++ one_highzero_run_original(1,88))
    IO.print("one-highzero/1/columns:" ++ one_highzero_run_columns(1,88))
    IO.print("one-highzero/1/converted:" ++ one_highzero_run_converted(1,88))
    IO.print("one-highone/2/original:" ++ one_highone_run_original(2,88))
    IO.print("one-highone/2/columns:" ++ one_highone_run_columns(2,88))
    IO.print("one-highone/2/converted:" ++ one_highone_run_converted(2,88))
    IO.print("two-highzero/1/original:" ++ two_highzero_run_original(1,88))
    IO.print("two-highzero/1/columns:" ++ two_highzero_run_columns(1,88))
    IO.print("two-highzero/1/converted:" ++ two_highzero_run_converted(1,88))
    IO.print("two-highone/2/original:" ++ two_highone_run_original(2,88))
    IO.print("two-highone/2/columns:" ++ two_highone_run_columns(2,88))
    IO.print("two-highone/2/converted:" ++ two_highone_run_converted(2,88))
