import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./contexts.bend as Context
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-system.bend as Sys

def LeftLocal() -> Type:Capture.Local<Array<U32>,Context.Count()>
def RightLocal() -> Type:Capture.Local<Array<U32>,Context.Text()>
def state_changed(result:Array<U32> & U32) -> Array<U32> & U32:
  match result:
    case (state,+runs):(Array.set(U32,state,1,U32.add(runs,1)),U32.add(runs,1))
def advance(state:Array<U32>) -> Array<U32> & U32:state_changed(Array.get(U32,state,1))
def completion(failed:Bool,output:String) -> Sys.Completion<String,String>:
  match failed:
    case True{}:Sys.BodyError{"after-write",output}
    case False{}:Sys.Success{output}
def left_written(~H:Type,state:Array<U32>,capture:Context.Count(),+runs:U32,value:U32,result:H & String) -> H & (LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,_):(scope,(Capture.Local{state,capture},completion(U32.is_eq(runs,2),U32.show(runs) ++ "/capture=" ++ U32.show(value))))
def left_captured(~H:Type,~cap:A.ResourceWrite<H,P.Counter,String>,scope:H,state:Array<U32>,runs:U32,result:Context.Count() & U32) -> H & (LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (capture,value):left_written(~H,state,capture,runs,value,A.resource_modify_field(~H,~P.Counter,~String,cap)(P.update_counter,scope))
def left_advanced(~H:Type,~cap:A.ResourceWrite<H,P.Counter,String>,scope:H,capture:Context.Count(),result:Array<U32> & U32) -> H & (LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):left_captured(~H,~cap,scope,state,runs,Capture.invoke(~Array<U32>,~U32,~U32,~Context.count_step,capture,2))
def left(~S:Data,~H:Type,~caps:D.LeftOps(~S)(H),scope:H,local:LeftLocal()) -> H & (LeftLocal() & Sys.Completion<String,String>):
  match local:
    case Capture.Local{state,capture}:left_advanced(~H,~caps,scope,capture,advance(state))
def right_written(~H:Type,state:Array<U32>,capture:Context.Text(),runs:U32,value:String,result:H & String) -> H & (RightLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,_):(scope,(Capture.Local{state,capture},Sys.Success{U32.show(runs) ++ "/capture=" ++ value}))
def right_captured(~H:Type,~cap:A.ResourceWrite<H,P.Score,String>,scope:H,state:Array<U32>,runs:U32,result:Context.Text() & String) -> H & (RightLocal() & Sys.Completion<String,String>):
  match result:
    case (capture,value):right_written(~H,state,capture,runs,value,A.resource_modify_field(~H,~P.Score,~String,cap)(P.update_score,scope))
def right_advanced(~H:Type,~cap:A.ResourceWrite<H,P.Score,String>,scope:H,capture:Context.Text(),result:Array<U32> & U32) -> H & (RightLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):right_captured(~H,~cap,scope,state,runs,Capture.invoke(~Context.TextContext,~String,~String,~Context.text_step,capture,"x"))
def right(~S:Data,~H:Type,~caps:D.RightOps(~S)(H),scope:H,local:RightLocal()) -> H & (RightLocal() & Sys.Completion<String,String>):
  match local:
    case Capture.Local{state,capture}:right_advanced(~H,~caps,scope,capture,advance(state))
def left_local(id:U32,captureId:U32) -> LeftLocal():Capture.Local{ANode{ALeaf{id},ALeaf{0}},Capture.bind(~Array<U32>,~U32,~U32,~Context.count_step,ANode{ALeaf{captureId},ALeaf{0}})}
def right_local() -> RightLocal():Capture.Local{ANode{ALeaf{601},ALeaf{0}},Context.text()}
def left_observed(state:String,result:Context.Count() & String) -> String:
  match result:
    case (_,capture):state ++ "/" ++ capture
def left_state(capture:Context.Count(),result:Array<U32> & String) -> String:
  match result:
    case (_,state):left_observed(state,Capture.observe(~Array<U32>,~U32,~U32,~Context.count_step,~String,~Context.count_snapshot,capture))
def observe_left(local:LeftLocal()) -> String:
  match local:
    case Capture.Local{state,capture}:left_state(capture,Context.count_snapshot(state))
def right_observed(state:String,result:Context.Text() & String) -> String:
  match result:
    case (_,capture):state ++ "/" ++ capture
def right_state(capture:Context.Text(),result:Array<U32> & String) -> String:
  match result:
    case (_,state):right_observed(state,Capture.observe(~Context.TextContext,~String,~String,~Context.text_step,~String,~Context.text_snapshot,capture))
def observe_right(local:RightLocal()) -> String:
  match local:
    case Capture.Local{state,capture}:right_state(capture,Context.count_snapshot(state))
