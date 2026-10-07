let publicTraceBegun = false;
function io_public_trace_begin() {
  if (publicTraceBegun) throw Error('Duplicate trace Begin');
  publicTraceBegun = true;
  io_out(2, io_bytes(JSON.stringify({boundary:'begin'}) + '\n'));
  return {$: CID(Unit)};
}
function io_public_trace_complete(nodes, characters, sum) {
  if (!publicTraceBegun) throw Error('Completion before Begin');
  if (![nodes, characters, sum].every(x => Number.isInteger(x) && x >= 0 && x <= 0xffffffff)) throw Error('Unforced complete-trace controls');
  io_out(2, io_bytes(JSON.stringify({boundary: 'complete-trace-forced', nodes, characters, sum}) + '\n'));
  return {$: CID(Unit)};
}
io_eff(CID(complete), io_public_trace_complete);

io_eff(CID(begin), io_public_trace_begin);
