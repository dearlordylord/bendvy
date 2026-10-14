// Shared across independently emitted modules in the same host JS realm.
// This registry is trusted host infrastructure, not gameplay authority.
const bendvy_namespace_slot = Symbol.for("bendvy.world.namespace.v1");
if (!Object.prototype.hasOwnProperty.call(globalThis, bendvy_namespace_slot)) {
  Object.defineProperty(globalThis, bendvy_namespace_slot, {
    value: { next: 1 }, writable: false, configurable: false, enumerable: false
  });
}
function bendvy_namespace_fresh() {
  const state = globalThis[bendvy_namespace_slot];
  if (state.next >= 0xffffffff) return 0;
  return state.next++;
}
io_eff(CID(fresh), bendvy_namespace_fresh);
