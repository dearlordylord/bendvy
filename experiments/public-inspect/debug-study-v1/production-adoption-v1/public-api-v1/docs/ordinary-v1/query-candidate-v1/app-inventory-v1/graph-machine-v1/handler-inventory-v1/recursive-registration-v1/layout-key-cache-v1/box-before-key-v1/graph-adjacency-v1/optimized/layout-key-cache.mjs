// Completed immutable-by-construction layouts only, one copied file_book lifetime.
let strings = new WeakMap();
let hits = 0;
let misses = 0;
export function resetLayoutKeyCache() {
  strings = new WeakMap();
  hits = 0;
  misses = 0;
}
export function layoutKey(layout) {
  const existing = strings.get(layout);
  if (existing !== undefined) {
    ++hits;
    return existing;
  }
  ++misses;
  const key = JSON.stringify(layout);
  strings.set(layout, key);
  return key;
}
export function layoutKeyStats() { return {hits, misses}; }
