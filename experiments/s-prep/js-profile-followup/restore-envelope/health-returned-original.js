function $$$$047bendvy$045private$045id$045query$045descending$045v1$047experiments$047s$045integrate$047held$045adapter$058prototype_packed_prototype_journalledger_health_returned$(_result_0, _ns_0, _next_0, _columns_0, _aux_0, _metadata_0, _capacity_0, _depth_0, _high_0, _pending_0, _mode_0, _commands_0, _pings_0, _total_0) {
  const _t_0 = _result_0["fst"];
  const _levels_0 = _t_0["levels"];
  const _rawreserve_0 = _t_0["rawreserve"];
  const _rawclass_0 = _t_0["rawclass"];
  const _a_0 = _t_0["a"];
  const _b_0 = _t_0["b"];
  const _c_0 = _t_0["c"];
  const _d_0 = _t_0["d"];
  const _cachedreserve_0 = _t_0["cachedreserve"];
  const _cachedclass_0 = _t_0["cachedclass"];
  const _totals_0 = _t_0["totals"];
  const _epoch_0 = _t_0["epoch"];
  const _ledger_cached_0 = _t_0["ledger_cached"];
  const _t_1 = _t_0["handle"];
  const _space_0 = _t_1["namespace"];
  const _id_0 = _t_1["id"];
  const _undo_0 = _t_0["undo"];
  const _marks_0 = _t_0["marks"];
  const _value_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": {$: "../bendvy-private-id-query-descending-v1/experiments/s-integrate/cached-payload.PrototypeHealthMainSlot", "levels": _levels_0, "rawreserve": _rawreserve_0, "rawclass": _rawclass_0, "a": _a_0, "b": _b_0, "c": _c_0, "d": _d_0, "cachedreserve": _cachedreserve_0, "cachedclass": _cachedclass_0}};
  return {$: "../bendvy-private-id-query-descending-v1/experiments/s-integrate/held-adapter.PrototypeFlatFold", "namespace": _ns_0, "next": _next_0, "columns": (_columns_0[_x_0 % _columns_0.length] = _x_1, _columns_0), "aux": _aux_0, "metadata": _metadata_0, "capacity": _capacity_0, "depth": _depth_0, "high": _high_0, "pending": _pending_0, "ledger": {$: "Some", "value": {$: "../bendvy-private-id-query-descending-v1/experiments/s-integrate/held-adapter.PrototypeJournalLedger", "totals": _totals_0, "epoch": _epoch_0, "cached": _ledger_cached_0}}, "mode": _mode_0, "selected": {$: "../bendvy-private-id-query-descending-v1/experiments/s-integrate/storage.Handle", "namespace": _space_0, "id": _id_0}, "undo": ($$$$047bendvy$045private$045id$045query$045descending$045v1$047experiments$047s$045integrate$047held$045adapter$058prototype_pending_flush$1261$(_undo_0)), "commands": _commands_0, "pings": _pings_0, "marks": _marks_0, "total": ((_total_0 + _value_0) >>> 0)};
}

