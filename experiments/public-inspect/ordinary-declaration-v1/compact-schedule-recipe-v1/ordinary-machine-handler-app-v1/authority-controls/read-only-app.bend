import Base
import ../consumer-public-pruned.bend as Consumer
type Schema is Data:Schema{}
def invoke(~Owner:Type,~read:Owner -> Owner & Bool,owner:Owner) -> Consumer.ordinary_application(~Schema) & String:Consumer.ordinary_marker(~Schema,owner)
def main() -> Unit:Unit{}
