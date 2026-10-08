import Base
import ledger-driver.bend as L
import correctness-main.bend as Render
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/types.bend as T

def completed(result:L.Ledger<T.SchemaA>) -> IO(Unit):
  IO.print("{\"A\":" ++ Render.rendered(~T.SchemaA,result) ++ "}")
def main() -> IO(Unit):
  IO.bind(L.Ledger<T.SchemaA>,Unit,L.run(~T.SchemaA,L.Correctness{},1n),result => completed(result))

# Whole one-schema13setup/45operation/58capture/21checkpoint driver, no clocks.
# Both actual schemas and a separate full116/42 union remain required.
