// SOURCE ONLY. Artifact review must establish this exact callback is the closed
// fixed framework wrapper. JavaScript cannot inspect affine captures.
function bendvy_trampoline_drive(entry, state) {
  if (typeof entry !== "function") throw new Error("trampoline entry ABI");
  for (;;) {
    const round = entry(state);
    state = undefined;
    if (!round || (round.$ !== "Fail" && round.$ !== "Done"))
      throw new Error("trampoline round ABI; owner recovery is impossible");
    if (round.$ === "Done") return round.value;
    state = round.error;
  }
}
io_eff(CID(trusted_drive), bendvy_trampoline_drive);
