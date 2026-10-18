"""Canonical typed LC2 integers; no whitespace or sentinel scanning."""
from legacy import Chars, InvalidLC1, LC1Reader, U32_MAX, natural


def encode_nat(value):
    natural(value)
    result = bytearray()
    while True:
        low, value = value & 31, value >> 5
        result.append(32 + low + (32 if value else 0))
        if not value:
            return bytes(result)


def encode_u32(value):
    return encode_nat(natural(value, U32_MAX))


def encode_string(value):
    return b's' + encode_nat(len(value.codes)) + b''.join(encode_u32(c) for c in value.codes)


class Reader(LC1Reader):
    def varint(self, maximum=None):
        value = 0
        shift = 0
        groups = 0
        while True:
            if self.position == len(self.raw):
                raise InvalidLC1('truncated LC2 varint')
            code = self.raw[self.position]
            self.position += 1
            if not 32 <= code <= 95:
                raise InvalidLC1('unknown LC2 varint byte')
            payload = code & 31
            groups += 1
            value |= payload << shift
            if maximum is not None and value > maximum:
                raise InvalidLC1('LC2 integer outside declared domain')
            if code < 64:
                if groups > 1 and payload == 0:
                    raise InvalidLC1('overlong LC2 varint')
                return value
            if maximum is not None and groups >= 7:
                raise InvalidLC1('LC2 U32 exceeds seven groups')
            shift += 5

    def u32(self):
        return self.varint(U32_MAX)

    def nat(self):
        return self.varint()

    def sequence(self, item):
        self.literal(b'q')
        count = self.nat()
        if count > len(self.raw) - self.position:
            raise InvalidLC1('LC2 list count exceeds remaining encoded items')
        return [item() for _ in range(count)]

    def string(self):
        self.literal(b's')
        count = self.nat()
        if count > len(self.raw) - self.position:
            raise InvalidLC1('LC2 string count exceeds remaining encoded U32s')
        return Chars(tuple(self.u32() for _ in range(count)))
