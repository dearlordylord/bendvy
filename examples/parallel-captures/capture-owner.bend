import Base
import ./contexts.bend as C
import ../../src/ecs/execution-capture.bend as Capture

def text_observed(count:String,result:C.Text() & String) -> String:
  match result:
    case (_,text):count ++ ";" ++ text
def count_observed(text:C.Text(),result:C.Count() & String) -> String:
  match result:
    case (_,count):text_observed(count,Capture.observe(~C.TextContext,~String,~String,~C.text_step,~String,~C.text_snapshot,text))
def observed(count:C.Count(),text:C.Text()) -> String:
  count_observed(text,Capture.observe(~Array<U32>,~U32,~U32,~C.count_step,~String,~C.count_snapshot,count))
def text_second(count:C.Count(),result:C.Text() & String) -> String:
  match result:
    case (text,_):observed(count,text)
def text_first(count:C.Count(),result:C.Text() & String) -> String:
  match result:
    case (text,_):text_second(count,Capture.invoke(~C.TextContext,~String,~String,~C.text_step,text,"y"))
def count_second(result:C.Count() & U32) -> String:
  match result:
    case (count,_):text_first(count,Capture.invoke(~C.TextContext,~String,~String,~C.text_step,C.text(),"x"))
def count_first(result:C.Count() & U32) -> String:
  match result:
    case (count,_):count_second(Capture.invoke(~Array<U32>,~U32,~U32,~C.count_step,count,3))
def main() -> IO(Unit):
  IO.print(count_first(Capture.invoke(~Array<U32>,~U32,~U32,~C.count_step,C.count(),2)))
