// Trusted host boundary. Decimal Nat text preserves every finite binary64 integer.
// No JSON Number round-trip, F32 conversion, U32 mask, or native raw-number parser.
export function normalizeLimit(value = undefined) {
  if (value === undefined || Number.isNaN(value) || value === Infinity) {
    return { tag: 'Unbounded' };
  }
  if (typeof value !== 'number') throw new TypeError('limit must be Number or undefined');
  if (value <= 0) return { tag: 'BoundedNat', count: '0' };
  return { tag: 'BoundedNat', count: BigInt(Math.ceil(value)).toString() };
}

// Lossless native transfer: canonical little-endian decimal digits, [] = zero.
export function normalizedDigits(normalized) {
  if (normalized.tag === 'Unbounded') return { tag: 'Unbounded' };
  if (!/^(0|[1-9][0-9]*)$/.test(normalized.count)) throw new TypeError('noncanonical natural decimal');
  return { tag: 'BoundedDecimal', digits: normalized.count === '0' ? [] : Array.from(normalized.count).reverse().map(d => Number(d)) };
}
