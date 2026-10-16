import Base
import ./fixture.bend as F
import ../families-v1/fixture.bend as Pub
import ../ordinary-v1/payload.bend as P

type Host<S:Data> is Type:
  Host{runtime:F.Runtime(~S),foreign:F.Runtime(~S),publisher:Pub.PublisherRegistry(~S),fast:F.Reader_a(~S),fastRegistry:F.Registry_a(~S),slow:F.Reader_a(~S),slowRegistry:F.Registry_a(~S),alerts:F.Reader_b(~S),alertsRegistry:F.Registry_b(~S),crates:F.Reader_c(~S),cratesRegistry:F.Registry_c(~S),args:P.Args}
