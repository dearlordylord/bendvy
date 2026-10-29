import Base
import ../../src/ecs/execution-capture.bend as Capture

type TextContext is Type:
  TextContext{token:Array<U32>,words:Array<String>}
def count_changed(+amount:U32,result:Array<U32> & U32) -> Array<U32> & U32:
  match result:
    case (owner,+count):(Array.set(U32,owner,1,U32.add(count,amount)),U32.add(count,amount))
def count_step(owner:Array<U32>,amount:U32) -> Array<U32> & U32:
  count_changed(amount,Array.get(U32,owner,1))
def count_snapshot_tail(id:U32,result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case (owner,count):(owner,U32.show(id) ++ ":" ++ U32.show(count))
def count_snapshot_head(result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case (owner,id):count_snapshot_tail(id,Array.get(U32,owner,1))
def count_snapshot(owner:Array<U32>) -> Array<U32> & String:
  count_snapshot_head(Array.get(U32,owner,0))
def text_changed(token:Array<U32>,+suffix:String,result:Array<String> & String) -> TextContext & String:
  match result:
    case (words,+word):(TextContext{token,Array.set(String,words,0,word ++ suffix)},word ++ suffix)
def text_step(owner:TextContext,suffix:String) -> TextContext & String:
  match owner:
    case TextContext{token,words}:text_changed(token,suffix,Array.get(String,words,0))
def text_snapshot_word(token:Array<U32>,id:U32,result:Array<String> & String) -> TextContext & String:
  match result:
    case (words,word):(TextContext{token,words},U32.show(id) ++ ":" ++ word)
def text_snapshot_token(words:Array<String>,result:Array<U32> & U32) -> TextContext & String:
  match result:
    case (token,id):text_snapshot_word(token,id,Array.get(String,words,0))
def text_snapshot(owner:TextContext) -> TextContext & String:
  match owner:
    case TextContext{token,words}:text_snapshot_token(words,Array.get(U32,token,0))
def Count() -> Type:Capture.Captured<Array<U32>,U32,U32,count_step>
def Text() -> Type:Capture.Captured<TextContext,String,String,text_step>
def count() -> Count():Capture.bind(~Array<U32>,~U32,~U32,~count_step,ANode{ALeaf{201},ALeaf{0}})
def text() -> Text():Capture.bind(~TextContext,~String,~String,~text_step,TextContext{ALeaf{202},ALeaf{"a"}})
