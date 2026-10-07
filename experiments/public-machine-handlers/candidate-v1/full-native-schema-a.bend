# Diagnostic root: actual schemaA six complete positive/refusal applications.
import Base
import full-driver-v2.bend as Driver
import full-provider.bend as P

def main() -> IO(Unit):
  Driver.print_rows(Driver.rows(~P.SchemaA,"schemaA",Driver.cases()))
