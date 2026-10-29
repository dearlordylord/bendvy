import Base

type Outcome<-Value:Data,-Error:Data> is Data:
  Saved{value:Value}
  RefusedPending{}
  Refused{error:Error}

# Framework boundary. The ordinary adapter supplies the closed owner inventory,
# not deferred history or a caller's estimate of outstanding work.
def checked(~Actual:Type,~Value:Data,~Error:Data,~project:Actual -> Actual & Outcome<Value,Error>,result:Actual & Bool) -> Actual & Outcome<Value,Error>:
  match result:
    case (actual,True{}):(actual,RefusedPending{})
    case (actual,False{}):project(actual)
def save(~Actual:Type,~Value:Data,~Error:Data,~pending:Actual -> Actual & Bool,~project:Actual -> Actual & Outcome<Value,Error>,actual:Actual) -> Actual & Outcome<Value,Error>:
  checked(~Actual,~Value,~Error,~project,pending(actual))
