import Base
import ../fixture.bend as F
def wrong(app:F.application(~F.Workshop)) -> F.application(~F.Workshop) & F.application(~F.Workshop):
  (app,app)
