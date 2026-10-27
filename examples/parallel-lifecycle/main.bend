import Base
import ./filters.bend as Filters

# Ordinary runnable lifecycle entry; the full filter observation is its output.
def main() -> IO(Unit):
  Filters.main()
