import Base
import ./failure-overlay/experiments/s-integrate/systems.bend as U
import ./failure-overlay/experiments/s-integrate/types.bend as T
import ./failure-overlay/experiments/s-integrate/storage.bend as S
import ./failure-overlay/experiments/s-integrate/observations.bend as O
import ./failure-overlay/experiments/s-integrate/host-observations.bend as E

# Independent finite input specification; evaluate all declared fields before timer end.
def four(value:T.Four,a:U32,b:U32,c:U32,d:U32) -> Bool:
  match value:
    case T.Four{x,y,z,w}: Bool.and(Bool.and(U32.is_eq(x,a),U32.is_eq(y,b)),Bool.and(U32.is_eq(z,c),U32.is_eq(w,d)))
def choose(test:Bool,a:U32,b:U32) -> U32:
  match test:
    case True{}: a
    case False{}: b
def seed_count(-Schema:Data,bindings:List<&2,E.Binding<Schema>>) -> U32:
  match bindings:
    case Nil{}: 0
    case Con{E.Binding{name,_},tail}: U32.add(choose(String.eq(name,"seed"),1,0),seed_count(Schema,tail))
def length(~A:Data,values:List<&2,A>) -> U32:
  match values:
    case Nil{}: 0
    case Con{_,tail}: U32.add(1,length(~A,tail))
def primary(index:U32,i:U32,retry:Bool) -> U32:
  match index:
    case 0: U32.add(i,1)
    case 1: U32.add(1,U32.mul(30,U32.add(i,choose(retry,1,0))))
    case other: other
def key(+index:U32,+count:U32,i:U32) -> U32:
  choose(U32.is_lt(index,count),U32.add(index,1),U32.add(U32.add(count,U32.mul(i,3)),choose(U32.is_eq(index,count),1,3)))
def wanted(+index:U32,+count:U32,+i:U32,retry:Bool) -> T.Four:
  T.Four{choose(U32.is_lt(index,count),primary(index,i,retry),i),choose(U32.is_lt(index,count),U32.add(index,1),choose(U32.is_eq(index,count),20,200)),choose(U32.is_lt(index,count),U32.add(index,2),choose(U32.is_eq(index,count),30,300)),choose(U32.is_lt(index,count),U32.add(index,3),choose(U32.is_eq(index,count),40,400))}
def position(value:T.PositionView,expect:T.Four) -> Bool:
  match value expect:
    case T.PositionView{cells,frame} T.Four{a,b,c,d}: Bool.and(four(cells,a,b,c,d),U32.is_eq(frame,7))
def vitals(value:T.VitalsView,expect:T.Four) -> Bool:
  match value expect:
    case T.VitalsView{cells,reserve,class} T.Four{a,b,c,d}: Bool.and(four(cells,a,b,c,d),Bool.and(U32.is_eq(reserve,9),U32.is_eq(class,2)))
def velocity(value:Maybe<&2,T.VelocityView>,present:Bool) -> Bool:
  match value present:
    case None{} False{}: True{}
    case Some{T.VelocityView{cells,moving}} True{}: Bool.and(four(cells,1,2,3,4),moving)
    case _ _: False{}
def armor(value:Maybe<&2,T.ArmorView>,present:Bool) -> Bool:
  match value present:
    case None{} False{}: True{}
    case Some{T.ArmorView{cells,grade}} True{}: Bool.and(four(cells,1,2,3,4),U32.is_eq(grade,3))
    case _ _: False{}
def selected(value:Maybe<&2,T.Selected>,present:Bool) -> Bool:
  match value present:
    case None{} False{}: True{}
    case Some{T.Selected{group}} True{}: U32.is_eq(group,8)
    case _ _: False{}
def tracked(value:Maybe<&2,T.Tracked>,present:Bool) -> Bool:
  match value present:
    case None{} False{}: True{}
    case Some{T.Tracked{group}} True{}: U32.is_eq(group,8)
    case _ _: False{}
def row(~Schema:Data,~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,~aux:Maybe<&2,AV> -> Bool -> Bool,~flag:Maybe<&2,F> -> Bool -> Bool,+index:U32,+count:U32,+i:U32,retry:Bool,value:O.QueryRow<Schema,V,AV,F>) -> Bool:
  match value:
    case O.QueryRow{S.Handle{namespace,id},v,a,f}: Bool.and(Bool.and(U32.is_eq(namespace,1),U32.is_eq(id,key(index,count,i))),Bool.and(main(v,wanted(index,count,i,retry)),Bool.and(aux(a,Bool.and(U32.is_lt(index,count),U32.is_eq(U32.mod(index,3),0))),flag(f,Bool.and(U32.is_lt(index,count),U32.is_eq(U32.mod(index,3),1))))))
def rows(~Schema:Data,~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,~aux:Maybe<&2,AV> -> Bool -> Bool,~flag:Maybe<&2,F> -> Bool -> Bool,values:List<&2,O.QueryRow<Schema,V,AV,F>>,+index:U32,+count:U32,+i:U32,+retry:Bool) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,tail}: Bool.and(row(~Schema,~V,~AV,~F,~main,~aux,~flag,index,count,i,retry,head),rows(~Schema,~V,~AV,~F,~main,~aux,~flag,tail,U32.add(index,1),count,i,retry))
def lookup_result(~Schema:Data,~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,~aux:Maybe<&2,AV> -> Bool -> Bool,~flag:Maybe<&2,F> -> Bool -> Bool,live:Bool,index:U32,count:U32,i:U32,retry:Bool,result:T.Access<O.QueryRow<Schema,V,AV,F>>) -> Bool:
  match live result:
    case False{} T.Missing{}: True{}
    case True{} T.Found{value}: row(~Schema,~V,~AV,~F,~main,~aux,~flag,index,count,i,retry,value)
    case _ _: False{}
def lookup_key(+index:U32,+count:U32,+i:U32,+retry:Bool) -> U32:
  choose(U32.is_lt(index,choose(retry,3,2)),U32.add(U32.add(count,U32.mul(i,3)),U32.add(index,1)),U32.add(U32.add(count,U32.mul(U32.sub(i,U32.sub(index,choose(retry,3,2))),3)),2))
def lookups(~Schema:Data,~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,~aux:Maybe<&2,AV> -> Bool -> Bool,~flag:Maybe<&2,F> -> Bool -> Bool,values:List<&2,E.Lookup<Schema,V,AV,F>>,+index:U32,+count:U32,+i:U32,+retry:Bool,+applied:Bool) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{E.Lookup{_,S.Handle{namespace,id},result},tail}: Bool.and(Bool.and(U32.is_eq(namespace,1),U32.is_eq(id,lookup_key(index,count,i,retry))),Bool.and(lookup_result(~Schema,~V,~AV,~F,~main,~aux,~flag,Bool.and(applied,Bool.or(U32.is_eq(index,0),U32.is_eq(index,2))),U32.add(count,choose(U32.is_eq(index,0),0,1)),count,i,retry,result),lookups(~Schema,~V,~AV,~F,~main,~aux,~flag,tail,U32.add(index,1),count,i,retry,applied)))
def ledger(+i:U32,retry:Bool,value:Maybe<&2,T.LedgerView>) -> Bool:
  match value:
    case Some{T.LedgerView{cells,epoch}}: Bool.and(four(cells,choose(retry,U32.mul(U32.add(i,1),101),U32.add(U32.mul(i,101),1)),101,102,103),U32.is_eq(epoch,4))
    case None{}: False{}
def observed(~Schema:Data,~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,~aux:Maybe<&2,AV> -> Bool -> Bool,~flag:Maybe<&2,F> -> Bool -> Bool,+count:U32,+i:U32,+retry:Bool,+applied:Bool,+values:List<&2,O.QueryRow<Schema,V,AV,F>>,+ls:List<&2,E.Lookup<Schema,V,AV,F>>,lv:Maybe<&2,T.LedgerView>) -> Bool:
  Bool.and(Bool.and(U32.is_eq(length(~O.QueryRow<Schema,V,AV,F>,values),U32.add(count,choose(applied,2,0))),U32.is_eq(length(~E.Lookup<Schema,V,AV,F>,ls),U32.add(U32.add(i,1),choose(retry,3,2)))),Bool.and(rows(~Schema,~V,~AV,~F,~main,~aux,~flag,values,0,count,i,retry),Bool.and(lookups(~Schema,~V,~AV,~F,~main,~aux,~flag,ls,0,count,i,retry,applied),ledger(i,retry,lv))))
def motion(+count:U32,+i:U32,+phase:String,rows:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,ls:List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,lv:Maybe<&2,T.LedgerView>) -> Bool:
  observed(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~position,~velocity,~selected,count,i,Bool.not(String.eq(phase,"failed-before-barrier")),String.eq(phase,"applied-FIFO"),rows,ls,lv)
def health(+count:U32,+i:U32,+phase:String,rows:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,ls:List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,lv:Maybe<&2,T.LedgerView>) -> Bool:
  observed(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~vitals,~armor,~tracked,count,i,Bool.not(String.eq(phase,"failed-before-barrier")),String.eq(phase,"applied-FIFO"),rows,ls,lv)
def codes(~P:Data,~code:P -> U32,values:List<&2,P>,wanted:List<&2,U32>) -> Bool:
  match values wanted:
    case Nil{} Nil{}: True{}
    case Con{head,tail} Con{value,rest}: Bool.and(U32.is_eq(code(head),value),codes(~P,~code,tail,rest))
    case _ _: False{}
def b_messages(i:U32) -> List<&2,U32>:
  match i:
    case 0: [0]
    case +other: [U32.sub(U32.mul(other,2),1),U32.mul(other,2)]
def read_wanted_kind(b:Bool,+i:U32,step:String) -> List<&2,U32>:
  match b:
    case True{}: b_messages(i)
    case False{}: [U32.add(U32.mul(i,2),choose(String.eq(step,"failed-publications"),0,1))]
def read_wanted_prime(prime:Bool,i:U32,name:String,step:String) -> List<&2,U32>:
  match prime:
    case True{}: []
    case False{}: read_wanted_kind(String.eq(name,"B"),i,step)
def read_wanted(i:U32,name:String,+step:String) -> List<&2,U32>:
  read_wanted_prime(String.eq(step,"prime"),i,name,step)
def read_tick(i:U32,+name:String,+step:String) -> U32:
  choose(String.eq(step,"prime"),choose(String.eq(name,"B"),3,4),U32.add(U32.mul(i,14),choose(String.eq(name,"B"),choose(String.eq(step,"fail"),7,10),choose(String.eq(step,"failed-publications"),9,13))))
def read_frame(i:U32,name:String,+step:String) -> U32:
  choose(String.eq(step,"prime"),2,U32.add(U32.mul(i,10),choose(String.eq(name,"B"),choose(String.eq(step,"fail"),3,6),choose(String.eq(step,"failed-publications"),5,8))))
def motion_code(value:T.MotionPing) -> U32:
  match value:
    case T.MotionPing{code}: code
def health_code(value:T.HealthPing) -> U32:
  match value:
    case T.HealthPing{code}: code
def read(~P:Data,~code:P -> U32,+i:U32,+name:String,+step:String,count:U32,values:List<&2,P>,lag:Bool,tick:U32,frame:U32) -> Bool:
  Bool.and(Bool.not(lag),Bool.and(U32.is_eq(count,choose(String.eq(step,"prime"),1,U32.add(U32.mul(i,2),choose(Bool.or(String.eq(step,"fail"),String.eq(step,"failed-publications")),2,3)))),Bool.and(codes(~P,~code,values,read_wanted(i,name,step)),Bool.and(U32.is_eq(tick,read_tick(i,name,step)),U32.is_eq(frame,read_frame(i,name,step))))))

def main_access(motion:Bool,expected:T.Four,value:T.Access<T.MainView>) -> Bool:
  match motion value:
    case True{} T.Found{T.MotionMain{view}}: position(view,expected)
    case False{} T.Found{T.HealthMain{view}}: vitals(view,expected)
    case _ _: False{}
def reserved_missing(value:T.Access<T.MainView>) -> Bool:
  match value:
    case T.Missing{}: True{}
    case _: False{}
def own_a(+i:U32,motion:Bool,views:List<&2,U.Observation>) -> Bool:
  match views:
    case Con{U.MainObserved{main},Con{U.LedgerObserved{lv},Con{U.ReservedObserved{missing},Nil{}}}}: Bool.and(main_access(motion,T.Four{U32.add(i,1),1,2,3},main),Bool.and(ledger(i,False{},lv),reserved_missing(missing)))
    case _: False{}
def own_b(+i:U32,+motion:Bool,views:List<&2,U.Observation>) -> Bool:
  match views:
    case Con{U.MainObserved{first},Con{U.MainObserved{second},Con{U.LedgerObserved{lv},Con{U.ReservedObserved{missing},Nil{}}}}}: Bool.and(Bool.and(main_access(motion,T.Four{U32.add(U32.mul(i,30),11),2,3,4},first),main_access(motion,T.Four{U32.add(U32.mul(i,30),31),2,3,4},second)),Bool.and(ledger(i,True{},lv),reserved_missing(missing)))
    case _: False{}
def own(i:U32,b:Bool,motion:Bool,views:List<&2,U.Observation>) -> Bool:
  match b:
    case False{}: own_a(i,motion,views)
    case True{}: own_b(i,motion,views)
def reservation(~V:Data,~AV:Data,~F:Data,~main:V -> T.Four -> Bool,+i:U32,+b:Bool,value:Maybe<&2,O.BundleView<V,AV,F>>) -> Bool:
  match value:
    case Some{O.BundleView{Some{v},None{},None{}}}: main(v,T.Four{i,choose(b,200,20),choose(b,300,30),choose(b,400,40)})
    case _: False{}
def escaped(-Schema:Data,count:U32,i:U32,b:Bool,failed:Bool,value:Maybe<&2,S.Handle<Schema>>) -> Bool:
  match value:
    case Some{S.Handle{ns,id}}: Bool.and(U32.is_eq(ns,1),U32.is_eq(id,U32.add(U32.add(count,U32.mul(i,3)),choose(b,choose(failed,2,3),1))))
    case None{}: False{}
def did_fail(value:T.Outcome) -> Bool:
  match value:
    case T.Success{}: False{}
    case T.Failure{_}: True{}
def published(i:U32,b:Bool,failed:Bool,values:List<&2,U32>) -> Bool:
  match failed values:
    case True{} Nil{}: True{}
    case False{} Con{v,Nil{}}: U32.is_eq(v,U32.add(U32.mul(i,2),choose(b,1,0)))
    case _ _: False{}
