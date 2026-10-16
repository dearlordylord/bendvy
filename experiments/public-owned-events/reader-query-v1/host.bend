import Base
import ./fixture.bend as F
import ../families-v1/fixture.bend as Pub

type Host<S:Data> is Type:
  Host{runtime:F.Runtime(~S),foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),reader:F.Reader(~S),registry:F.Registry(~S),args:F.Args,observations:List<F.Observation>}
