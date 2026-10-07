import Base
import retention-fail-skip-workshop.bend as W
import retention-fail-skip-garden.bend as G
def main() -> String:
  "Workshop\n" ++ W.main() ++ "Garden\n" ++ G.main()
