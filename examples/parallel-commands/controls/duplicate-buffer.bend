import Base

def bad(~Q:Type,queue:Q) -> Q & Q:
  (queue,queue)
