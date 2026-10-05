import Base

type Cache<-Raw:Type,-View:Data> is Type:
  Cache{raw:Raw,cached:View}
type Check<-View:Data> is Data:
  Check{raw:View,cached:View}
type Checked<-Raw:Type,-View:Data> is Type:
  Checked{cache:Cache<Raw,View>,checks:List<&2,Check<View>>}
def init_done(-Raw:Type,-View:Data,result:Raw & View) -> Cache<Raw,View>:
  match result:
    case (raw,cached): Cache{raw,cached}
def init(-Raw:Type,-View:Data,get:Raw -> Raw & View,raw:Raw) -> Cache<Raw,View>:
  init_done(Raw,View,get(raw))
def get(-Raw:Type,-View:Data,owner:Cache<Raw,View>) -> Cache<Raw,View> & View:
  match owner:
    case Cache{raw,+cached}: (Cache{raw,cached},cached)
def swap_done(-Raw:Type,-View:Data,patch:View -> U32 -> View,cached:View,value:U32,result:Raw & U32) -> Cache<Raw,View> & U32:
  match result:
    case (raw,old): (Cache{raw,patch(cached,value)},old)
def swap(-Raw:Type,-View:Data,write:Raw -> U32 -> Raw & U32,patch:View -> U32 -> View,owner:Cache<Raw,View>,+value:U32) -> Cache<Raw,View> & U32:
  match owner:
    case Cache{raw,cached}: swap_done(Raw,View,patch,cached,value,write(raw,value))
def audit_done(-Raw:Type,-View:Data,+cached:View,result:Raw & View) -> Cache<Raw,View> & Check<View>:
  match result:
    case (raw,observed): (Cache{raw,cached},Check{observed,cached})
def audit(-Raw:Type,-View:Data,uncached:Raw -> Raw & View,owner:Cache<Raw,View>) -> Cache<Raw,View> & Check<View>:
  match owner:
    case Cache{raw,cached}: audit_done(Raw,View,cached,uncached(raw))
def checked_audited(-Raw:Type,-View:Data,checks:List<&2,Check<View>>,result:Cache<Raw,View> & Check<View>) -> Checked<Raw,View>:
  match result:
    case (cache,check): Checked{cache,check <> checks}
def checkpoint(-Raw:Type,-View:Data,uncached:Raw -> Raw & View,owner:Checked<Raw,View>) -> Checked<Raw,View>:
  match owner:
    case Checked{cache,checks}: checked_audited(Raw,View,checks,audit(Raw,View,uncached,cache))
def checked_get_done(-Raw:Type,-View:Data,checks:List<&2,Check<View>>,result:Cache<Raw,View> & View) -> Checked<Raw,View> & View:
  match result:
    case (cache,view): (Checked{cache,checks},view)
def checked_read(-Raw:Type,-View:Data,owner:Checked<Raw,View>) -> Checked<Raw,View> & View:
  match owner:
    case Checked{cache,checks}: checked_get_done(Raw,View,checks,get(Raw,View,cache))
def checked_written(-Raw:Type,-View:Data,uncached:Raw -> Raw & View,checks:List<&2,Check<View>>,result:Cache<Raw,View> & U32) -> Checked<Raw,View> & U32:
  match result:
    case (cache,old): (checkpoint(Raw,View,uncached,Checked{cache,checks}),old)
def checked_swap(-Raw:Type,-View:Data,write:Raw -> U32 -> Raw & U32,patch:View -> U32 -> View,uncached:Raw -> Raw & View,owner:Checked<Raw,View>,value:U32) -> Checked<Raw,View> & U32:
  match owner:
    case Checked{cache,checks}: checked_written(Raw,View,uncached,checks,swap(Raw,View,write,patch,cache,value))
def release(-Raw:Type,-View:Data,owner:Checked<Raw,View>) -> Raw & List<&2,Check<View>>:
  match owner:
    case Checked{Cache{raw,_},checks}: (raw,List.reverse(&2,Check<View>,checks))
