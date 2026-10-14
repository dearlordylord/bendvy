// Existing near-saturation input staged in trusted host state; the actual
// production allocator and complete WorldIO program remain unchanged.
const filename = process.argv[2];
if (process.argv.length !== 3) throw new Error("one qualified program required");
Object.defineProperty(globalThis, Symbol.for("bendvy.world.namespace.v1"), {
  value: { next: 0xfffffffd }, writable: false, configurable: false,
  enumerable: false
});
process.argv = [process.execPath, filename];
require(filename);
