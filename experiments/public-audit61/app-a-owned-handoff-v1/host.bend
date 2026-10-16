import Base
import main.bend as App
# Standard terminal entry; no CNI or namespace helper.
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(App.main())
