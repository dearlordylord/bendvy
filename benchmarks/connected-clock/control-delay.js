function io_connected_clock_control_delay() {
  const word = new Int32Array(new SharedArrayBuffer(4));
  if (Atomics.wait(word, 0, 0, 20) !== "timed-out") {
    throw Error("connected clock control: delay did not time out");
  }
  return { $: CID(Unit) };
}
io_eff(CID(wait), io_connected_clock_control_delay);
