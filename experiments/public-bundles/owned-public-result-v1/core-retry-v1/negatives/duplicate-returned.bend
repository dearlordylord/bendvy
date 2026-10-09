import Base
import ../../core-consumer-v4/consumer.bend as R
import ../../../../../src/ecs/bundle-requests.bend as Cmd
def returned(result:R.Output()) -> R.Raw() & R.Raw():
  match result:
    case Cmd.Refused{raw,error}:(raw,raw)
    case Cmd.Accepted{target,spawned}:(R.sample(),R.sample())
