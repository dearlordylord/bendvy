import Base
import owned-driver.bend as D
import json.bend as J

def main() -> IO(Unit):
  IO.print("{\"format\":1,\"application\":\"Workshop\",\"checkpoints\":" ++ J.array(D.main()) ++ "}")
