import Base
import ../events.bend as Events

def forbidden(~S:Data,reader:Events.Reader(~S)) -> Events.Reader(~S) & Events.Reader(~S):(reader,reader)
