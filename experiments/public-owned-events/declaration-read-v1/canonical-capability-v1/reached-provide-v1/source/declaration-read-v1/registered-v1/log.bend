import Base
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/read.bend as Scoped
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Row<-P:Type> is Type: Row{key:U32,payload:P}
type Log<-P:Type> is Type: Log{seen:List<&2,U32>,rows:List<Row<P>>}
type Refusal is Data:
  DuplicateKey{key:U32}
  MissingKey{key:U32}
type Published<-P:Type> is Type:
  Published{log:Log<P>}
  Refused{log:Log<P>,incoming:P,error:Refusal}
type Located<-P:Type,-O:Type> is Type: Located{rows:List<Row<P>>,value:Maybe<&1,O>}
type Reading<-P:Type,-O:Type> is Type: Reading{log:Log<P>,value:Maybe<&1,O>,errors:List<&2,Refusal>}
type Partition<-P:Type> is Type: Partition{retained:List<Row<P>>,removed:List<Row<P>>}
type Retirement<-P:Type> is Type: Retirement{log:Log<P>,owners:List<Row<P>>}
def contains(+key:U32,keys:List<&2,U32>) -> Bool:
  match keys:
    case []: False{}
    case head <> tail: Bool.or(U32.is_eq(key,head),contains(key,tail))
def count_added(matches:Bool,rest:Nat) -> Nat:
  match matches:
    case True{}: 1n+rest
    case False{}: rest
def count(+key:U32,keys:List<&2,U32>) -> Nat:
  match keys:
    case []: 0n
    case head <> tail: count_added(U32.is_eq(key,head),count(key,tail))
def keys_join(~P:Type,head:Row<P>,result:List<Row<P>> & List<&2,U32>) -> List<Row<P>> & List<&2,U32>:
  match head result:
    case Row{+key,payload}, (tail,keys): (Row{key,payload} <> tail,key <> keys)
def keys(~P:Type,rows:List<Row<P>>) -> List<Row<P>> & List<&2,U32>:
  match rows:
    case []: ([],[])
    case head <> tail: keys_join(~P,head,keys(~P,tail))
def publish_checked(~P:Type,allowed:Bool,+key:U32,log:Log<P>,incoming:P) -> Published<P>:
  match allowed log:
    case False{} log: Refused{log,incoming,DuplicateKey{key}}
    case True{} Log{seen,rows}: Published{Log{List.append(&2,U32,seen,[key]),List.append(&1,Row<P>,rows,[Row{key,incoming}])}}
def publish(~P:Type,+key:U32,log:Log<P>,incoming:P) -> Published<P>:
  match log:
    case Log{+seen,rows}: publish_checked(~P,Bool.not(contains(key,seen)),key,Log{seen,rows},incoming)
def scoped_head(~P:Type,~O:Type,+key:U32,tail:List<Row<P>>,result:P & O) -> Located<P,O>:
  match result:
    case (payload,value): Located{Row{key,payload} <> tail,Some{value}}
def scanned_head(~P:Type,~O:Type,~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O,matched:Bool,head:Row<P>,result:Located<P,O>) -> Located<P,O>:
  match matched head result:
    case False{}, head, Located{tail,value}: Located{head <> tail,value}
    case True{}, Row{key,payload}, Located{tail,_}: scoped_head(~P,~O,key,tail,Scoped.provide(~P,~O,~at,~body,payload))
def scan(~P:Type,~O:Type,~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O,+key:U32,rows:List<Row<P>>) -> Located<P,O>:
  match rows:
    case []: Located{[],None{}}
    case Row{+actual,payload} <> tail: scanned_head(~P,~O,~at,~body,U32.is_eq(key,actual),Row{actual,payload},scan(~P,~O,~at,~body,key,tail))
def read_result(~P:Type,~O:Type,seen:List<&2,U32>,result:Located<P,O>) -> Reading<P,O>:
  match result:
    case Located{rows,value}: Reading{Log{seen,rows},value,[]}
def read_counted(~P:Type,~O:Type,~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O,seen:List<&2,U32>,+key:U32,rows:List<Row<P>>,count:Nat) -> Reading<P,O>:
  match count:
    case 0n: Reading{Log{seen,rows},None{},[MissingKey{key}]}
    case 1n: read_result(~P,~O,seen,scan(~P,~O,~at,~body,key,rows))
    case _: Reading{Log{seen,rows},None{},[DuplicateKey{key}]}
def read_keyed(~P:Type,~O:Type,~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O,seen:List<&2,U32>,+key:U32,result:List<Row<P>> & List<&2,U32>) -> Reading<P,O>:
  match result:
    case (rows,keys): read_counted(~P,~O,~at,~body,seen,key,rows,count(key,keys))
def read(~P:Type,~O:Type,~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O,log:Log<P>,key:U32) -> Reading<P,O>:
  match log:
    case Log{seen,rows}: read_keyed(~P,~O,~at,~body,seen,key,keys(~P,rows))
def scanned_head_by(~P:Type,~O:Type,~observe:P -> P & O,matched:Bool,head:Row<P>,result:Located<P,O>) -> Located<P,O>:
  match matched head result:
    case False{}, head, Located{tail,value}: Located{head <> tail,value}
    case True{}, Row{key,payload}, Located{tail,_}: scoped_head(~P,~O,key,tail,observe(payload))
def scan_by(~P:Type,~O:Type,~observe:P -> P & O,+key:U32,rows:List<Row<P>>) -> Located<P,O>:
  match rows:
    case []: Located{[],None{}}
    case Row{+actual,payload} <> tail: scanned_head_by(~P,~O,~observe,U32.is_eq(key,actual),Row{actual,payload},scan_by(~P,~O,~observe,key,tail))
def read_result_by(~P:Type,~O:Type,seen:List<&2,U32>,result:Located<P,O>) -> Reading<P,O>:
  match result:
    case Located{rows,value}: Reading{Log{seen,rows},value,[]}
def read_counted_by(~P:Type,~O:Type,~observe:P -> P & O,seen:List<&2,U32>,+key:U32,rows:List<Row<P>>,count:Nat) -> Reading<P,O>:
  match count:
    case 0n: Reading{Log{seen,rows},None{},[MissingKey{key}]}
    case 1n: read_result_by(~P,~O,seen,scan_by(~P,~O,~observe,key,rows))
    case _: Reading{Log{seen,rows},None{},[DuplicateKey{key}]}
def read_keyed_by(~P:Type,~O:Type,~observe:P -> P & O,seen:List<&2,U32>,+key:U32,result:List<Row<P>> & List<&2,U32>) -> Reading<P,O>:
  match result:
    case (rows,keys): read_counted_by(~P,~O,~observe,seen,key,rows,count(key,keys))
def read_by(~P:Type,~O:Type,~observe:P -> P & O,log:Log<P>,key:U32) -> Reading<P,O>:
  match log:
    case Log{seen,rows}: read_keyed_by(~P,~O,~observe,seen,key,keys(~P,rows))
def partitioned(~P:Type,keep:Bool,head:Row<P>,result:Partition<P>) -> Partition<P>:
  match keep result:
    case True{}, Partition{retained,removed}: Partition{head <> retained,removed}
    case False{}, Partition{retained,removed}: Partition{retained,head <> removed}
def partition(~P:Type,+retainedKeys:List<&2,U32>,rows:List<Row<P>>) -> Partition<P>:
  match rows:
    case []: Partition{[],[]}
    case Row{+key,payload} <> tail: partitioned(~P,contains(key,retainedKeys),Row{key,payload},partition(~P,retainedKeys,tail))
def retired(~P:Type,seen:List<&2,U32>,result:Partition<P>) -> Retirement<P>:
  match result:
    case Partition{retained,removed}: Retirement{Log{seen,retained},removed}
def retire(~P:Type,log:Log<P>,retainedKeys:List<&2,U32>) -> Retirement<P>:
  match log:
    case Log{seen,rows}: retired(~P,seen,partition(~P,retainedKeys,rows))
