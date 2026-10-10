import Base
import consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def main() -> Consumer.Scene & Consumer.Scene:
  (Consumer.scenario(Tx.Success{}),Consumer.scenario(Tx.Failure{Consumer.Aborted{}}))
