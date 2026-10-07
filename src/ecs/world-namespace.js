// One allocator per emitted program, shared by all canonical world creations.
let bendvy_namespace_next = 1;
function bendvy_namespace_fresh() {
  if (bendvy_namespace_next >= 0xffffffff) return 0;
  return bendvy_namespace_next++;
}
io_eff(CID(fresh), bendvy_namespace_fresh);
