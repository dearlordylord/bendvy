# IO-only backend seam: both real nominal-schema foreign controls, complete rows.
import Base
import full-driver-v2.bend as Driver
import full-foreign-controls.bend as Foreign
import ../../../src/ecs/event-runtime.bend as Ev

def main() -> IO(Unit):
  Driver.print_rows(Ev.append(~String,Foreign.schemaA(),Foreign.schemaB()))
