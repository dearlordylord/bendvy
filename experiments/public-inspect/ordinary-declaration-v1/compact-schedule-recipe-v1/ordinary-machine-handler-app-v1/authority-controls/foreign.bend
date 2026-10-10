import Base
import ../consumer-public-pruned.bend as Consumer
type Schema is Data:Schema{}
type Other is Data:Other{}
def foreign(app:Consumer.ordinary_application(~Schema)) -> Consumer.ordinary_application(~Other):app
def main() -> Unit:Unit{}
