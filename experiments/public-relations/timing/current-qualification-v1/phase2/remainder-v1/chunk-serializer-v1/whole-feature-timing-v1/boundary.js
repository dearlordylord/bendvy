let publicTraceBegun = false;
let publicTraceStart;
function io_public_trace_begin() {
  if (publicTraceBegun) throw Error('Duplicate trace Begin');
  publicTraceBegun = true;
  io_out(2, io_bytes(JSON.stringify({boundary:'begin'}) + '\n'));
  publicTraceStart = process.hrtime.bigint();
  return {$: CID(Unit)};
}
function io_public_trace_complete(nodes, characters, sum) {
  if (!publicTraceBegun) throw Error('Completion before Begin');
  if (![nodes, characters, sum].every(x => Number.isInteger(x) && x >= 0 && x <= 0xffffffff)) throw Error('Unforced complete-trace controls');
  const elapsedNs = (process.hrtime.bigint() - publicTraceStart).toString();
  io_out(2, io_bytes(JSON.stringify({boundary: 'complete-trace-forced', nodes, characters, sum, region:'whole-feature-setup-operations-full-trace', elapsedNs}) + '\n'));
  return {$: CID(Unit)};
}
io_eff(CID(complete), io_public_trace_complete);

io_eff(CID(begin), io_public_trace_begin);
