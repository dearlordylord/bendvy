import Base
import state.bend as State
import consumer.bend as Consumer

def main() -> String & String:
  (Consumer.scenario(~State.Workshop,31,100),Consumer.scenario(~State.Garden,47,200))
