import Base
import ./execution-event-family.bend as Family
import ./execution-access.bend as Access
import ./owned-event-log.bend as Log

type Writer<-H:Type,-P:Type> is Type:
  Writer{publish:P -> H -> H & Family.Publication<P>}
type Reader<-S:Data,-H:Type,-P:Type,-key:String,-V:Data> is Type:
  Reader{next:Family.Reader<S,P,key> -> H -> H & Family.Reading<S,P,key,V>}
type Admin<-S:Data,-H:Type,-P:Type,-key:String> is Type:
  Admin{register:Family.Start -> H -> H & Family.Registration<S,P,key>,remove:Family.Reader<S,P,key> -> H -> H & Family.Removal<S,P,key>,update:H -> H & List<Log.Row<P>>,shutdown:H -> H & List<Log.Row<P>>}

# The caller supplies the canonical closed-layout writable resource grant.
# Its physical slot remains the sole conflict identity for every event operation.
def writer(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,~cap:Access.ResourceWrite<H,Family.Family<S,P,key>,V>) -> Writer<H,P>:
  Writer{payload=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Family.Publication<P>,cap)(family=>Family.publish(~S,~P,~key,family,payload))}
def reader(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,~View:Data,~project:P -> Unit -> P & View,~cap:Access.ResourceWrite<H,Family.Family<S,P,key>,V>) -> Reader<S,H,P,key,View>:
  Reader{cursor=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Family.Reading<S,P,key,View>,cap)(family=>Family.read(~S,~P,~key,~View,~project,family,cursor))}
def admin(~S:Data,~H:Type,~P:Type,~key:String,~V:Data,~cap:Access.ResourceWrite<H,Family.Family<S,P,key>,V>) -> Admin<S,H,P,key>:
  Admin{start=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Family.Registration<S,P,key>,cap)(family=>Family.register(~S,~P,~key,start,family)),cursor=>Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,Family.Removal<S,P,key>,cap)(family=>Family.remove(~S,~P,~key,family,cursor)),Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,List<Log.Row<P>>,cap)(Family.update(~S,~P,~key)),Access.resource_own_field(~H,~Family.Family<S,P,key>,~V,List<Log.Row<P>>,cap)(Family.shutdown(~S,~P,~key))}
