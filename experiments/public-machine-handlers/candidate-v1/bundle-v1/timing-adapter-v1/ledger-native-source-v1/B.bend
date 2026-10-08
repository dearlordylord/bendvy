import Base
import ../ledger-driver-source-v1/ledger-driver.bend as L
import ../ledger-driver-source-v1/correctness-main.bend as Render
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/types.bend as T

def printed(result:L.Ledger<T.SchemaB>) -> IO(Unit):
  IO.print("{\"B\":" ++ Render.rendered(~T.SchemaB,result) ++ "}")
def main() -> IO(Unit):
  IO.bind(L.Ledger<T.SchemaB>,Unit,L.run(~T.SchemaB,L.Correctness{},1n),result => printed(result))

# Complete schemaB:13 scenarios,45 operations and21 checkpoints.
# 1n is correctness fixture cardinality; no clock requests or measurement count.
# Per-schema source/C diagnostic is not complete Native runtime qualification.
