// Diagnostic-only, shallow ordered layout provenance; no compiler decisions.
const LIMIT = 256;
const buckets = new Map();
let calls = 0, omitted = 0, errors = 0, unknownCalls = 0;
let loadedKeys = new Set();
const definitionCounts = new Map();
export function loadedBook(book) { loadedKeys = new Set(Object.keys(book.tlds)); }
function shape(lay) {
  return {width: lay.ks.length, kinds: [...lay.ks], arms: lay.arms === null ? null :
    Object.keys(lay.arms).map(name => ({name, fields: lay.arms[name].map(field => field.ks.length)}))};
}
export function observe(definition, from, to) {
  ++calls;
  if (loadedKeys.has(definition)) definitionCounts.set(definition,(definitionCounts.get(definition)??0)+1);
  else ++unknownCalls;
  try {
    const row = {definition, displayedDefinition: definition.replace(":", "."), from: shape(from), to: shape(to)};
    const key = JSON.stringify(row);
    if (buckets.has(key)) { ++buckets.get(key).calls; return; }
    if (buckets.size === LIMIT) { ++omitted; return; }
    buckets.set(key, {...row, calls: 1});
  } catch (_) { ++errors; } // Diagnostic failure cannot replace compiler outcome.
}
export function snapshot() {
  return {scope: 'shallow val_to attribution, not timings/installed compiler', calls, omitted, errors, unknownCalls, definitionCounts: [...definitionCounts],
    rows: [...buckets.values()].map(row => JSON.parse(JSON.stringify(row)))};
}
