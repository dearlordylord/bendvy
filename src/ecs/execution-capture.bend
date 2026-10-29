import Base

type Captured<-Context:Type,-Args:Data,-Out:Data,-step:Context -> Args -> Context & Out> is Type:
  Captured{context:Context}
type Local<-State:Type,-Capture:Type> is Type:
  Local{state:State,capture:Capture}

def bind(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,context:Context) -> Captured<Context,Args,Out,step>:
  Captured{context}
def returned(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,result:Context & Out) -> Captured<Context,Args,Out,step> & Out:
  match result:
    case (context,output):(Captured{context},output)
def invoke(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,capture:Captured<Context,Args,Out,step>,args:Args) -> Captured<Context,Args,Out,step> & Out:
  match capture:
    case Captured{context}:returned(~Context,~Args,~Out,~step,step(context,args))
def observed(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,~Value:Data,result:Context & Value) -> Captured<Context,Args,Out,step> & Value:
  match result:
    case (context,value):(Captured{context},value)
def observe(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,~Value:Data,~project:Context -> Context & Value,capture:Captured<Context,Args,Out,step>) -> Captured<Context,Args,Out,step> & Value:
  match capture:
    case Captured{context}:observed(~Context,~Args,~Out,~step,~Value,project(context))
def release(~Context:Type,~Args:Data,~Out:Data,~step:Context -> Args -> Context & Out,capture:Captured<Context,Args,Out,step>) -> Context:
  match capture:
    case Captured{context}:context
