import Base
import ../consumer-public.bend as Consumer
def invalid(~S:Data,app:Consumer.Application(~S)) -> Consumer.Application(~S) & Consumer.Application(~S):(app,app)
def main() -> Unit:Unit{}
