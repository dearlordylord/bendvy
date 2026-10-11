import Base
import ./consumer.bend as C
import ./observer.bend as O
def step6(~S:Data,t1:String,t2:String,t3:String,t4:String,t5:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  (owner,"snapshot1=" ++ t1 ++ "\n" ++ "snapshot2=" ++ t2 ++ "\n" ++ "snapshot3=" ++ t3 ++ "\n" ++ "snapshot4=" ++ t4 ++ "\n" ++ "snapshot5=" ++ t5 ++ "\n" ++ "snapshot6=" ++ text)
def step5(~S:Data,t1:String,t2:String,t3:String,t4:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  step6(~S,t1,t2,t3,t4,text,O.observe(~S,C.inspect(~S,owner)))
def step4(~S:Data,t1:String,t2:String,t3:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  step5(~S,t1,t2,t3,text,O.observe(~S,C.inspect(~S,C.read(~S,owner))))
def step3(~S:Data,t1:String,t2:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  step4(~S,t1,t2,text,O.observe(~S,C.inspect(~S,owner)))
def step2(~S:Data,t1:String,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  step3(~S,t1,text,O.observe(~S,C.inspect(~S,C.remove(~S,owner))))
def step1(~S:Data,returned:C.Fixture<S> & String) -> C.Fixture<S> & String:
  (owner,text)=returned
  step2(~S,text,O.observe(~S,C.inspect(~S,owner)))
def scenario(~S:Data,present:Bool) -> C.Fixture<S> & String:step1(~S,O.observe(~S,C.inspect(~S,C.setup(~S,present))))
def detached(a:C.Fixture<C.A> & String,b:C.Fixture<C.Other> & String) -> String:
  (_,a)=a
  (_,b)=b
  "A=" ++ a ++ "\nOther=" ++ b
def main() -> String:detached(scenario(~C.A,True{}),scenario(~C.Other,False{}))
