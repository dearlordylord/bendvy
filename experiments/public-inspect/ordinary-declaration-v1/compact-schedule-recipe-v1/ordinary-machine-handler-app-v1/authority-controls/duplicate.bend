import Base
import ../consumer-public-pruned.bend as Consumer
type Schema is Data:Schema{}
def duplicate(app:Consumer.ordinary_application(~Schema)) -> Consumer.ordinary_application(~Schema) & Consumer.ordinary_application(~Schema):(app,app)
def main() -> Unit:Unit{}
