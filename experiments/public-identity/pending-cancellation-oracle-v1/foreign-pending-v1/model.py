"""Independent same-schema WorldIO pending-handle refusal and owner trace."""
import base_model as base


class Model(base.Model):
    def __init__(self, namespace):
        super().__init__()
        self.namespace = namespace
        self.events = []
        self.local_events = []

    def world(self):
        text = super().world().split(';visible=')[0]
        return (text.replace('ns=1;', f'ns={self.namespace};').replace('events=[];', 'events=' + base.listing([str(i) for i in self.events]) + ';')
                + ';visible=' + base.listing([f'{self.namespace}:{i}' for i in sorted(self.live)]))

    def reserve(self, payload, record=True):
        ident = super().reserve(payload, record)
        if record:
            self.rows[-1] = f'spawn={self.namespace}:{ident}'
        return ident

    def tx_view(self, label):
        self.rows.append(f'{label}:tx{{undo={len(self.undo)};commands={len(self.local)};events='
                         + base.listing([str(i) for i in self.local_events]) + ';' + self.world() + '}')

    def finish(self):
        super().finish()
        self.events.extend(self.local_events)
        self.local_events = []


def states():
    sender, receiver = Model(1), Model(2)
    sender.snapshot('sender-created')
    sender.begin()
    sender.reserve(10)
    sender.tx_view('sender-pending')
    receiver.snapshot('receiver-created')
    receiver.begin()
    receiver.reserve(20)
    receiver.local_events.append(71)
    receiver.tx_view('before-foreign-pending-refusal')
    before = receiver.world(), list(receiver.local), list(receiver.undo), list(receiver.local_events)
    # Actual sender namespace1/id1 differs from receiver namespace2/id1.
    assert sender.namespace != receiver.namespace
    receiver.rows.append('despawn=MissingEntity')
    receiver.tx_view('after-foreign-pending-refusal')
    assert before == (receiver.world(), receiver.local, receiver.undo, receiver.local_events)
    sender.tx_view('sender-retained')
    assert receiver.despawn(1)
    receiver.tx_view('own-pending-cancelled')
    receiver.finish()
    receiver.snapshot('receiver-committed')
    receiver.apply()
    assert sender.reserved_pending == {1} and len(sender.local) == len(sender.undo) == 1
    assert not sender.live and not sender.commands and sender.trace == [] and sender.returned == []
    assert not receiver.live and not receiver.reserved_pending
    assert receiver.returned == [20] and receiver.trace == [101, 201] and receiver.events == [71]
    return sender, receiver


def render():
    sender, receiver = states()
    return ('sender{' + base.listing(sender.rows) + ';handles=[1:1]}\nreceiver{rows='
            + base.listing(receiver.rows) + ';handles=[2:1]}\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'despawn=MissingEntity') == raw.count(b'despawn=Accepted') == 1
    assert b'events=[71];pending=2' in raw and b'events=[71];pending=0' in raw
    assert raw.endswith(b'}\n')


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
