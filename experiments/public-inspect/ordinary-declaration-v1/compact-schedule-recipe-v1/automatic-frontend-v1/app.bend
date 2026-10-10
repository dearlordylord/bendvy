import Base
# Every invocation returns the next affine method with the same owner.
type Method<Inner:Type,View:Data> is Type:
  Method{call:Inner -> Inner & (Maybe<&2,View> & Method<Inner,View>)}
type ApplicationType<Inner:Type,View:Data> is Type:
  Application{inner:Inner,method:Method<Inner,View>}
def renewed(~Inner:Type,~View:Data,~observe:Inner -> Inner & Maybe<&2,View>,result:Inner & Maybe<&2,View>) -> Inner & (Maybe<&2,View> & Method<Inner,View>):
  match result:
    case (inner,view):(inner,(view,Method{inner=>renewed(~Inner,~View,~observe,observe(inner))}))
def generated(~Inner:Type,~View:Data,~observe:Inner -> Inner & Maybe<&2,View>,inner:Inner) -> ApplicationType<Inner,View>:
  Application{inner,Method{inner=>renewed(~Inner,~View,~observe,observe(inner))}}
def observed(~Inner:Type,~View:Data,result:Inner & (Maybe<&2,View> & Method<Inner,View>)) -> ApplicationType<Inner,View> & Maybe<&2,View>:
  match result:
    case (inner,(view,method)):(Application{inner,method},view)
def called(~Inner:Type,~View:Data,inner:Inner,method:Method<Inner,View>) -> ApplicationType<Inner,View> & Maybe<&2,View>:
  match method:
    case Method{call}:observed(~Inner,~View,call(inner))
def snapshot(~Inner:Type,~View:Data,app:ApplicationType<Inner,View>) -> ApplicationType<Inner,View> & Maybe<&2,View>:
  match app:
    case Application{inner,method}:called(~Inner,~View,inner,method)
