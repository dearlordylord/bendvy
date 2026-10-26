import Base
import ./execution-event-family.bend as Family
import ./execution-access.bend as Access
import ./owned-event-log.bend as Log
import ./execution-event-view.bend as View

type Writer<-H:Type,-P:Type> is Type:
  Writer{publish:P -> H -> H & Family.Publication<P>}
type Reader<-S:Data,-H:Type,-P:Type,-key:String,-V:Data> is Type:
  Reader{next:Family.Reader<S,P,key> -> H -> H & Family.Reading<S,P,key,V>}
type Command<-S:Data,-P:Type,-key:String> is Type:
  Register{start:Family.Start}
  Remove{reader:Family.Reader<S,P,key>}
  Update{}
  Shutdown{}
type Outcome<-S:Data,-P:Type,-key:String> is Type:
  Registration{result:Family.Registration<S,P,key>}
  Removal{result:Family.Removal<S,P,key>}
  Retired{rows:List<Log.Row<P>>}
type Admin<-S:Data,-H:Type,-P:Type,-key:String> is Type:
  Admin{apply:Command<S,P,key> -> H -> H & Outcome<S,P,key>}

# The caller supplies the canonical closed-layout writable resource grant.
# Its physical slot remains the sole conflict identity for every event operation.
def writer(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,cap:Access.ResourceWrite<H,Family.Family<S,P,key>,V>) -> Writer<H,P>:
  Writer{payload=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Family.Publication<P>,cap)(family=>Family.publish(~S,~P,~key,family,payload))}
def read_returned(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,cursor:Family.Reader<S,P,key>,result:H & View.View<S,P,key,V>) -> H & Family.Reading<S,P,key,V>:
  match result:
    case (scope,view):(scope,View.read(~S,~P,~key,~V,view,cursor))
def reader(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,cap:Access.ResourceRead<H,View.View<S,P,key,V>>) -> Reader<S,H,P,key,V>:
  Reader{cursor=>scope=>read_returned(~S,~H,~P,~key,~V,cursor,Access.resource_read_field(~H,~View.View<S,P,key,V>,cap)(scope))}
def registered(~S:Data,~P:Type,~key:String,result:Family.Family<S,P,key> & Family.Registration<S,P,key>) -> Family.Family<S,P,key> & Outcome<S,P,key>:
  match result:
    case (family,result):(family,Registration{result})
def removed(~S:Data,~P:Type,~key:String,result:Family.Family<S,P,key> & Family.Removal<S,P,key>) -> Family.Family<S,P,key> & Outcome<S,P,key>:
  match result:
    case (family,result):(family,Removal{result})
def retired(~S:Data,~P:Type,~key:String,result:Family.Family<S,P,key> & List<Log.Row<P>>) -> Family.Family<S,P,key> & Outcome<S,P,key>:
  match result:
    case (family,rows):(family,Retired{rows})
def administer(~S:Data,~P:Type,~key:String,command:Command<S,P,key>,family:Family.Family<S,P,key>) -> Family.Family<S,P,key> & Outcome<S,P,key>:
  match command:
    case Register{start}:registered(~S,~P,~key,Family.register(~S,~P,~key,start,family))
    case Remove{reader}:removed(~S,~P,~key,Family.remove(~S,~P,~key,family,reader))
    case Update{}:retired(~S,~P,~key,Family.update(~S,~P,~key,family))
    case Shutdown{}:retired(~S,~P,~key,Family.shutdown(~S,~P,~key,family))
def admin(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,cap:Access.ResourceWrite<H,Family.Family<S,P,key>,V>) -> Admin<S,H,P,key>:
  Admin{command=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Outcome<S,P,key>,cap)(family=>administer(~S,~P,~key,command,family))}
