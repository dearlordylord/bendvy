"""Independent five-entity boundary model; expected formatting awaits source freeze."""
class State:
    def __init__(self):
        self.entities = {}
        self.clock = 0
        self.counter = 10
        self.cursor = 0
        self.array_receipts = []
        self.unit_receipts = []
        self.facts = []

    def populate(self):
        for ident in range(1, 6):
            self.facts.extend([('Reserved', ident), ('Activated', ident)])
            row = {}
            self.entities[ident] = row
            authored = [('Primary', ident != 4, ident * 10),
                        ('Bonus', ident not in (2, 5), ident * 100),
                        ('Active', ident != 5, None),
                        ('Hidden', ident == 3, None)]
            for family, present, seed in authored:
                if present:
                    self.clock += 1
                    row[family] = (None if seed is None else (seed, seed + 1), self.clock)
                    receipts = self.unit_receipts if seed is None else self.array_receipts
                    receipts.append(None)
                    self.facts.append(('Replaced', family))

    def joined(self):
        return [(ident, row['Primary'][0][0], row.get('Bonus', (None,))[0])
                for ident, row in self.entities.items()
                if 'Primary' in row]

    def presence(self):
        return list(self.entities)

    def run(self, threshold=5):
        if not self.presence():
            return False
        rows = self.joined()
        if rows and rows[0][1] > threshold:
            self.counter += 1
            self.cursor = self.clock
            return True
        return False


def selftest():
    s = State()
    assert not s.run()
    s.populate()
    assert (s.clock, len(s.array_receipts), len(s.unit_receipts), len(s.facts)) == (12, 7, 5, 22)
    assert s.joined() == [(1, 10, (100, 101)), (2, 20, None), (3, 30, (300, 301)), (5, 50, None)]
    assert s.presence() == [1, 2, 3, 4, 5]
    assert s.run() and s.run()
    assert (s.counter, s.cursor, s.clock) == (12, 12, 12)


if __name__ == '__main__':
    selftest()
