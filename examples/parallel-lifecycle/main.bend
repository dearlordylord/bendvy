import Base
import ./filters.bend as Filters
import ./notice-scenario.bend as Notices

# Ordinary runnable lifecycle entry: filters followed by independent notice readers.
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Filters.main(),_ => Notices.main())
