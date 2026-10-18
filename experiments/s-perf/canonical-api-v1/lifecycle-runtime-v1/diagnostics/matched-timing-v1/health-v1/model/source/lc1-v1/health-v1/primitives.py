"""Independent LC1 primitives; record schemas are supplied by the source binding.

String values retain Bend Char's complete U32 domain. ASCII reconstruction is
an explicit finite-fixture operation, not a generic Unicode encoding promise.
"""
from dataclasses import dataclass
from typing import Callable, Generic, TypeVar

U32_MAX = (1 << 32) - 1
T = TypeVar('T')


class InvalidLC1(ValueError):
    pass


def natural(value: int, maximum: int | None = None) -> int:
    if type(value) is not int or value < 0 or (maximum is not None and value > maximum):
        raise InvalidLC1('integer outside declared domain')
    return value


def decimal_bytes(value: int) -> bytes:
    # Avoid inheriting Python's configurable int-to-string digit limit as an
    # undeclared Bend Nat bound.
    natural(value)
    if value == 0:
        return b'0'
    digits = bytearray()
    while value:
        value, digit = divmod(value, 10)
        digits.append(48 + digit)
    return bytes(reversed(digits))


def encode_u32(value: int) -> bytes:
    return b'u' + decimal_bytes(natural(value, U32_MAX)) + b';'


def encode_nat(value: int) -> bytes:
    return b'n' + decimal_bytes(natural(value)) + b';'


def encode_bool(value: bool) -> bytes:
    if type(value) is not bool:
        raise InvalidLC1('expected Bool')
    return b'1' if value else b'0'


def encode_option(value: T | None, item: Callable[[T], bytes]) -> bytes:
    return b'0' if value is None else b'1' + item(value)


def encode_list(values: list[T] | tuple[T, ...], item: Callable[[T], bytes]) -> bytes:
    return b'q' + str(len(values)).encode('ascii') + b';' + b''.join(item(v) for v in values)


@dataclass(frozen=True)
class Chars:
    codes: tuple[int, ...]

    def __post_init__(self):
        for code in self.codes:
            natural(code, U32_MAX)

    @classmethod
    def from_ascii(cls, value: str):
        value.encode('ascii')
        return cls(tuple(map(ord, value)))

    def ascii_bytes(self) -> bytes:
        if any(code > 127 for code in self.codes):
            raise InvalidLC1('outside source-bound ASCII fixture')
        return bytes(self.codes)


def encode_string(value: Chars) -> bytes:
    return b's' + str(len(value.codes)).encode('ascii') + b';' + b''.join(map(encode_u32, value.codes))


@dataclass(frozen=True)
class Leaf(Generic[T]):
    value: T


@dataclass(frozen=True)
class Node(Generic[T]):
    left: 'Leaf[T] | Node[T]'
    right: 'Leaf[T] | Node[T]'


def encode_tree(value: Leaf[T] | Node[T], item: Callable[[T], bytes]) -> bytes:
    pieces = []
    stack = [value]
    while stack:
        current = stack.pop()
        if isinstance(current, Leaf):
            pieces.extend((b'l', item(current.value)))
        elif isinstance(current, Node):
            pieces.append(b'a')
            stack.extend((current.right, current.left))
        else:
            raise InvalidLC1('unknown physical tree constructor')
    return b''.join(pieces)


class Reader:
    def __init__(self, raw: bytes):
        if type(raw) is not bytes:
            raise InvalidLC1('wire must be bytes')
        self.raw = raw
        self.position = 0

    def literal(self, expected: bytes):
        end = self.position + len(expected)
        if self.raw[self.position:end] != expected:
            raise InvalidLC1(f'expected {expected!r} at byte {self.position}')
        self.position = end

    def digit_tag(self) -> bool:
        if self.position == len(self.raw):
            raise InvalidLC1('truncated Boolean/option tag')
        tag = self.raw[self.position]
        self.position += 1
        if tag not in (48, 49):
            raise InvalidLC1('unknown Boolean/option tag')
        return tag == 49

    def decimal(self, maximum: int | None = None) -> int:
        start = self.position
        value = 0
        while self.position < len(self.raw):
            char = self.raw[self.position]
            if char == 59:
                if self.position == start:
                    raise InvalidLC1('empty decimal')
                if self.position - start > 1 and self.raw[start] == 48:
                    raise InvalidLC1('noncanonical leading zero')
                self.position += 1
                return value
            if not 48 <= char <= 57:
                raise InvalidLC1('nondecimal integer')
            value = value * 10 + char - 48
            if maximum is not None and value > maximum:
                raise InvalidLC1('integer outside declared domain')
            self.position += 1
        raise InvalidLC1('unterminated decimal')

    def u32(self) -> int:
        self.literal(b'u')
        return self.decimal(U32_MAX)

    def nat(self) -> int:
        self.literal(b'n')
        return self.decimal()

    def boolean(self) -> bool:
        return self.digit_tag()

    def option(self, item: Callable[[], T]) -> T | None:
        return item() if self.digit_tag() else None

    def sequence(self, item: Callable[[], T]) -> list[T]:
        self.literal(b'q')
        count = self.decimal()
        if count > len(self.raw) - self.position:
            raise InvalidLC1('list count exceeds remaining encoded items')
        return [item() for _ in range(count)]

    def string(self) -> Chars:
        self.literal(b's')
        count = self.decimal()
        if count > (len(self.raw) - self.position) // 3:
            raise InvalidLC1('character count exceeds remaining encoded U32s')
        return Chars(tuple(self.u32() for _ in range(count)))

    def tree(self, item: Callable[[], T]) -> Leaf[T] | Node[T]:
        # Each stack frame is a branch awaiting its left or right child.
        frames = []
        while True:
            if self.position == len(self.raw):
                raise InvalidLC1('truncated physical tree')
            tag = self.raw[self.position]
            self.position += 1
            if tag == 97:
                frames.append(None)
                continue
            if tag != 108:
                raise InvalidLC1('unknown physical tree tag')
            value = Leaf(item())
            while frames and frames[-1] is not None:
                value = Node(frames.pop(), value)
            if not frames:
                return value
            frames[-1] = value

    def finish(self):
        if self.position != len(self.raw):
            raise InvalidLC1(f'trailing bytes at byte {self.position}')
