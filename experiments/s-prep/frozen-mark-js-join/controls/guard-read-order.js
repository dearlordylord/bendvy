function $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058storage_mark_all$(_marks_0, _world_0, _tick_0) {
  if (_marks_0.$ === "Nil") {
    const _namespace_0 = _world_0["namespace"];
    const _next_0 = _world_0["next"];
    const _t_0 = _world_0["rows"];
    const _main_0 = _t_0["main"];
    const _aux_0 = _t_0["aux"];
    const _t_1 = _t_0["metadata"];
    const _live_0 = _t_1["live"];
    const _flags_0 = _t_1["flags"];
    const _added_0 = _t_1["added"];
    const _changed_0 = _t_1["changed"];
    const _capacity_0 = _t_0["capacity"];
    const _depth_0 = _t_0["depth"];
    const _high_0 = _t_0["high_water"];
    const _pending_0 = _world_0["pending"];
    const _ledger_0 = _world_0["ledger"];
    const _mode_0 = _world_0["mode"];
    return {$: "../bendvy-live-first-native/experiments/s-integrate/storage.World", "namespace": _namespace_0, "next": _next_0, "rows": {$: "../bendvy-live-first-native/experiments/s-integrate/storage.Rows", "main": _main_0, "aux": _aux_0, "metadata": {$: "../bendvy-live-first-native/experiments/s-integrate/storage.MetadataColumns", "live": _live_0, "flags": _flags_0, "added": _added_0, "changed": _changed_0}, "capacity": _capacity_0, "depth": _depth_0, "high_water": _high_0}, "pending": _pending_0, "ledger": _ledger_0, "mode": _mode_0};
  } else {
    const _namespace_1 = _world_0["namespace"];
    const _next_1 = _world_0["next"];
    const _t_2 = _world_0["rows"];
    const _main_1 = _t_2["main"];
    const _aux_1 = _t_2["aux"];
    const _t_3 = _t_2["metadata"];
    const _live_1 = _t_3["live"];
    const _flags_1 = _t_3["flags"];
    const _added_1 = _t_3["added"];
    const _changed_1 = _t_3["changed"];
    const _capacity_1 = _t_2["capacity"];
    const _depth_1 = _t_2["depth"];
    const _high_1 = _t_2["high_water"];
    const _pending_1 = _world_0["pending"];
    const _ledger_1 = _world_0["ledger"];
    const _mode_1 = _world_0["mode"];
    return $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_loop$(_marks_0, _namespace_1, _next_1, _main_1, _aux_1, _flags_1, _added_1, {$: "Tuple", "fst": _live_1, "snd": _changed_1}, _capacity_1, _depth_1, _high_1, _pending_1, _ledger_1, _mode_1, _tick_0);
  }
}
function $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_loop$($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) {
  for (;;) {
    {
      const _marks_0 = $0;
      const _namespace_0 = $1;
      const _next_0 = $2;
      const _main_0 = $3;
      const _aux_0 = $4;
      const _flags_0 = $5;
      const _added_0 = $6;
      const _transport_0 = $7;
      const _capacity_0 = $8;
      const _depth_0 = $9;
      const _high_0 = $10;
      const _pending_0 = $11;
      const _ledger_0 = $12;
      const _mode_0 = $13;
      const _tick_0 = $14;
      if (_marks_0.$ === "Nil") {
        const _live_0 = _transport_0["fst"];
        const _changed_0 = _transport_0["snd"];
        return {$: "../bendvy-live-first-native/experiments/s-integrate/storage.World", "namespace": _namespace_0, "next": _next_0, "rows": {$: "../bendvy-live-first-native/experiments/s-integrate/storage.Rows", "main": _main_0, "aux": _aux_0, "metadata": {$: "../bendvy-live-first-native/experiments/s-integrate/storage.MetadataColumns", "live": _live_0, "flags": _flags_0, "added": _added_0, "changed": _changed_0}, "capacity": _capacity_0, "depth": _depth_0, "high_water": _high_0}, "pending": _pending_0, "ledger": _ledger_0, "mode": _mode_0};
      } else {
        const _t_0 = _marks_0["head"];
        const _foreign_0 = _t_0["namespace"];
        const _id_0 = _t_0["id"];
        const _rest_0 = _marks_0["tail"];
        const _live_1 = _transport_0["fst"];
        const _changed_1 = _transport_0["snd"];
        $0 = _rest_0;
        $1 = _namespace_0;
        $2 = _next_0;
        $3 = _main_0;
        $4 = _aux_0;
        $5 = _flags_0;
        $6 = _added_0;
        $7 = ($$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_guard$(($Bool$and$((_namespace_0 === _foreign_0), ($Bool$and$((0 < _id_0), ($Bool$and$((_id_0 <= _capacity_0), (_id_0 <= _high_0))))))), _live_1, _changed_1, _id_0, _tick_0));
        $8 = _capacity_0;
        $9 = _depth_0;
        $10 = _high_0;
        $11 = _pending_0;
        $12 = _ledger_0;
        $13 = _mode_0;
        $14 = _tick_0;
        continue;
      }
    }
  }
}
function $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_guard$(_valid_0, _live_0, _changed_0, _id_0, _tick_0) {
  _live_0[0];if (!_valid_0) {
    return {$: "Tuple", "fst": _live_0, "snd": _changed_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_live$__product_split(_changed_0, ((_id_0 - 1) >>> 0), _tick_0, (_live_0), (_live_0[_x_0 % _live_0.length]));
  }
}
function $$$$047bendvy$045live$045first$045native$047experiments$047s$045integrate$047transaction$058prototype_storage_mark_live$__product_split(_changed_0, _index_0, _tick_0, __product_fst, __product_snd) {
  const _live_0 = __product_fst;
  const _t_0 = __product_snd;
  if (!_t_0) {
    return {$: "Tuple", "fst": _live_0, "snd": _changed_0};
  } else {
    return {$: "Tuple", "fst": _live_0, "snd": (_changed_0[_index_0 % _changed_0.length] = _tick_0, _changed_0)};
  }
}
function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}