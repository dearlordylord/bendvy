import Base
import app.bend as A
import other.bend as B
def main() -> IO(Unit):
  IO.bind(Unit,Unit,IO.print("schema-A"),u => IO.bind(Unit,Unit,A.main(),u => IO.bind(Unit,Unit,IO.print("schema-B"),u => B.main())))
