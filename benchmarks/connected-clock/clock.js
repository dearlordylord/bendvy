let connectedClockStart = null;
const connectedClockLimit = (1n << 48n) - 1n;
function io_connected_clock_begin() {
  if (connectedClockStart !== null) throw Error("connected clock: begin while active");
  connectedClockStart = process.hrtime.bigint();
  return 0;
}
function io_connected_clock_end() {
  if (connectedClockStart === null) throw Error("connected clock: end without begin");
  const elapsed = process.hrtime.bigint() - connectedClockStart;
  if (elapsed < 0n || elapsed > connectedClockLimit) throw Error("connected clock: elapsed exceeds Nat range");
  connectedClockStart = null;
  return Number(elapsed);
}
io_eff(CID(begin), io_connected_clock_begin);
io_eff(CID(end), io_connected_clock_end);
