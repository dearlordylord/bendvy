function word_to_u32(w) {
  let x = 0;
  for (let i = 0; w.$ === "WCon"; i++) {
    x |= Number(w.head) << i;
    w = w.tail;
  }
  return x >>> 0;
}

function u32_to_word(x) {
  let w = {$: "WNil"};
  for (let i = 31; i >= 0; i--) {
    w = {$: "WCon", head: ((x >>> i) & 1) === 1, tail: w};
  }
  return w;
}

function cmp_new(a, b) {
  return {$: a < b ? "LT"
    : a === b ? "EQ" : "GT"};
}

function nat_divmod(a, b) {
  return b === 0 ? {$: "Tuple", fst: 0, snd: a}
    : {$: "Tuple", fst: Math.trunc(a / b), snd: a % b};
}

function nat_chk(n) {
  if (n > 281474976710655) {
    throw "bend: a Nat past the largest immediate 2^48-1";
  }
  return n;
}

function nat_host(n) {
  const int = typeof n === "bigint" || Number.isInteger(n);
  if (int && n >= 0 && n <= 2 ** 53) {
    return Number(n);
  }
  return { [Symbol.toPrimitive]() { throw "bend: a Nat past the largest immediate 2^48-1"; } };
}

function f32_show(x) {
  if (x !== x) {
    return "nan";
  }
  if (!Number.isFinite(x) || Object.is(x, -0)) {
    return x < 0 ? "-inf"
      : x === 0 ? "-0" : "inf";
  }
  let s = "x";
  for (let p = 1; p <= 9 && f32_round(s) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return s;
}

function f32_bits(x) {
  return new Uint32Array(new Float32Array([x]).buffer)[0];
}

function f32_from_bits(u) {
  return new Float32Array(new Uint32Array([u]).buffer)[0];
}

function f32_read(s) {
  const re = /^\s*[+-]?((\d+\.?\d*|\.\d+)(e[+-]?\d+)?|inf(inity)?|nan)$/i;
  const v = f32_round(s.replace(/inf\w*/i, "Infinity"));
  return re.test(s) ? {$: "Some", value: v} : {$: "None"};
}

const f32_round = function f32_round(s) {
  const d = Number(s);
  const a = Math.abs(d);
  const f = Math.fround(a);
  const g = 2 * a - Math.min(f, 2 ** 128);
  if (g === f || Math.fround(g) !== g || g === Infinity) {
    return Math.sign(d) * f;
  }
  let k = 0;
  while (a * 2 ** k % 1 !== 0) {
    k += 1;
  }
  const [, i, r, e] = /(\d*)\.?(\d*)(?:e([+-]?\d+))?$/i.exec(s);
  const n = Number(e ?? 0) - r.length;
  const x = BigInt(i + r) * 2n ** BigInt(k) * 10n ** BigInt(Math.max(n, 0));
  const y = BigInt(a * 2 ** k) * 10n ** BigInt(Math.max(-n, 0));
  return Math.sign(d) * (x === y || x > y !== g > f ? f : g);
};

function char_new(code) {
  if (code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) {
    throw "bend: " + code + " is not a Unicode scalar value";
  }
  return String.fromCodePoint(code);
}

// Array
// =====

function array_new(d, v) {
  if (d > 31) {
    throw "bend: an array past the deepest block class 31";
  }
  return Array(2 ** d).fill(v);
}

function array_node(a, b) {
  if (a.length !== b.length) {
    throw "bend: runtime fail-stop";
  }
  return a.concat(b);
}

function array_rmw(a, i, f) {
  const at = i % a.length;
  const old = a[at];
  a[at] = f(old);
  return {$: "Tuple", fst: a, snd: old};
}

// Run
// ===

function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}

function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}

function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}

function run_lib(f, n) {
  return (...a) => a.length < n ? run_lib((...b) => f(...a, ...b), n - a.length)
    : f(...a);
}

// Effect
// ======

const $0eff = Object.create(null);

function io_eff(k, run, need) {
  if (k in $0eff) {
    throw new Error("bend: two effects register " + k);
  }
  $0eff[k] = { run, need };
}
(() => {
// IO
// ==

function io_print(text) {
  io_out(1, io_bytes(text + "\n"));
  return { $: "Unit" };
}

io_eff("IO.print", io_print);

})();

for (const k of ["IO.print"]) {
  if (!(k in $0eff)) {
    throw new Error("bend: no effect registers " + k);
  }
}

// Program
// =======

function $main$() {
  const _x_0 = ($run$1261$(10));
  const _x_1 = (_x_0 + "\n");
  const _x_2 = ($run$1261$(9));
  const _x_3 = ("\n" + _x_1);
  const _x_4 = (_x_2 + _x_3);
  const _x_5 = ($run$1261$(8));
  const _x_6 = ("\n" + _x_4);
  const _x_7 = (_x_5 + _x_6);
  const _x_8 = ($run$1261$(7));
  const _x_9 = ("\n" + _x_7);
  const _x_10 = (_x_8 + _x_9);
  const _x_11 = ($run$1261$(6));
  const _x_12 = ("\n" + _x_10);
  const _x_13 = (_x_11 + _x_12);
  const _x_14 = ($run$1261$(5));
  const _x_15 = ("\n" + _x_13);
  const _x_16 = (_x_14 + _x_15);
  const _x_17 = ($run$1261$(4));
  const _x_18 = ("\n" + _x_16);
  const _x_19 = (_x_17 + _x_18);
  const _x_20 = ($run$1261$(3));
  const _x_21 = ("\n" + _x_19);
  const _x_22 = (_x_20 + _x_21);
  const _x_23 = ($run$1261$(2));
  const _x_24 = ("\n" + _x_22);
  const _x_25 = (_x_23 + _x_24);
  const _x_26 = ($run$1261$(1));
  const _x_27 = ("\n" + _x_25);
  const _x_28 = (_x_26 + _x_27);
  const _x_29 = ($run$1261$(0));
  const _x_30 = ("\n" + _x_28);
  const _x_31 = (_x_29 + _x_30);
  const _x_32 = ($run$1260$(10));
  const _x_33 = ("\n" + _x_31);
  const _x_34 = (_x_32 + _x_33);
  const _x_35 = ($run$1260$(9));
  const _x_36 = ("\n" + _x_34);
  const _x_37 = (_x_35 + _x_36);
  const _x_38 = ($run$1260$(8));
  const _x_39 = ("\n" + _x_37);
  const _x_40 = (_x_38 + _x_39);
  const _x_41 = ($run$1260$(7));
  const _x_42 = ("\n" + _x_40);
  const _x_43 = (_x_41 + _x_42);
  const _x_44 = ($run$1260$(6));
  const _x_45 = ("\n" + _x_43);
  const _x_46 = (_x_44 + _x_45);
  const _x_47 = ($run$1260$(5));
  const _x_48 = ("\n" + _x_46);
  const _x_49 = (_x_47 + _x_48);
  const _x_50 = ($run$1260$(4));
  const _x_51 = ("\n" + _x_49);
  const _x_52 = (_x_50 + _x_51);
  const _x_53 = ($run$1260$(3));
  const _x_54 = ("\n" + _x_52);
  const _x_55 = (_x_53 + _x_54);
  const _x_56 = ($run$1260$(2));
  const _x_57 = ("\n" + _x_55);
  const _x_58 = (_x_56 + _x_57);
  const _x_59 = ($run$1260$(1));
  const _x_60 = ("\n" + _x_58);
  const _x_61 = (_x_59 + _x_60);
  const _x_62 = ($run$1260$(0));
  const _x_63 = ("\n" + _x_61);
  return (_x_64) => $IO$print$((_x_62 + _x_63), _x_64);
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $run$1260$(_which_0) {
  return $first_created$1260$(_which_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), {$: "handle-application.Payload", "cells": array_node([100], [101]), "name": "resource", "target": {$: "None"}})));
}

function $run$1261$(_which_0) {
  return $first_created$1261$(_which_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), {$: "handle-application.Payload", "cells": array_node([100], [101]), "name": "resource", "target": {$: "None"}})));
}

function $first_created$1260$(_which_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _factory_0 = _result_0["factory"];
    const _first_0 = _result_0["world"];
    return $first_ready$1260$(_which_0, _factory_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_first_0)));
  } else {
    return "first-create-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": 1};
}

function $first_created$1261$(_which_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _factory_0 = _result_0["factory"];
    const _first_0 = _result_0["world"];
    return $first_ready$1261$(_which_0, _factory_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_first_0)));
  } else {
    return "first-create-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $first_ready$1260$(_which_0, _factory_0, _result_0) {
  const _first_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _own_0 = _t_0["handle"];
    return $second_created$1260$(_which_0, _own_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1261$(_first_0, _own_0, {$: "handle-application.Payload", "cells": array_node([11], [12]), "name": "seed", "target": {$: "Some", "value": _own_0}})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, {$: "handle-application.Payload", "cells": array_node([300], [301]), "name": "foreignresource", "target": {$: "None"}})));
  } else {
    return "first-reserve-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($handle$045application$058empty$1260$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $first_ready$1261$(_which_0, _factory_0, _result_0) {
  const _first_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _own_0 = _t_0["handle"];
    return $second_created$1261$(_which_0, _own_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1263$(_first_0, _own_0, {$: "handle-application.Payload", "cells": array_node([11], [12]), "name": "seed", "target": {$: "Some", "value": _own_0}})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(_factory_0, {$: "handle-application.Payload", "cells": array_node([300], [301]), "name": "foreignresource", "target": {$: "None"}})));
  } else {
    return "first-reserve-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1261$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($handle$045application$058empty$1261$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $second_created$1260$(_which_0, _own_0, _first_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _factory_0 = _result_0["factory"];
    const _second_0 = _result_0["world"];
    return $second_ready$1260$(_which_0, _own_0, _first_0, _factory_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_second_0)));
  } else {
    return "second-create-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1261$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}}};
  } else {
    if (!_grow_0) {
      const _namespace_0 = _world_0["namespace"];
      const _nextId_0 = _world_0["nextId"];
      const _highWater_0 = _world_0["highWater"];
      const _live_0 = _world_0["live"];
      const _capacity_0 = _world_0["capacity"];
      const _depth_0 = _world_0["depth"];
      const _store_0 = _world_0["store"];
      const _resource_0 = _world_0["resource"];
      const _events_0 = _world_0["events"];
      const _pending_0 = _world_0["pending"];
      const _registrations_0 = _world_0["registrations"];
      const _nextSystemId_0 = _world_0["nextSystemId"];
      const _clock_0 = _world_0["clock"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
    } else {
      const _namespace_1 = _world_0["namespace"];
      const _nextId_1 = _world_0["nextId"];
      const _highWater_1 = _world_0["highWater"];
      const _live_1 = _world_0["live"];
      const _capacity_1 = _world_0["capacity"];
      const _depth_1 = _world_0["depth"];
      const _store_1 = _world_0["store"];
      const _resource_1 = _world_0["resource"];
      const _events_1 = _world_0["events"];
      const _pending_1 = _world_0["pending"];
      const _registrations_1 = _world_0["registrations"];
      const _nextSystemId_1 = _world_0["nextSystemId"];
      const _clock_1 = _world_0["clock"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
    }
  }
}

function $Bool$not$(_b_0) {
  if (!_b_0) {
    return true;
  } else {
    return false;
  }
}

function $handle$045application$058empty$1260$(_unit_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1260$();
}

function $second_created$1261$(_which_0, _own_0, _first_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _factory_0 = _result_0["factory"];
    const _second_0 = _result_0["world"];
    return $second_ready$1261$(_which_0, _own_0, _first_0, _factory_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_second_0)));
  } else {
    return "second-create-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1263$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1261$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}}};
  } else {
    if (!_grow_0) {
      const _namespace_0 = _world_0["namespace"];
      const _nextId_0 = _world_0["nextId"];
      const _highWater_0 = _world_0["highWater"];
      const _live_0 = _world_0["live"];
      const _capacity_0 = _world_0["capacity"];
      const _depth_0 = _world_0["depth"];
      const _store_0 = _world_0["store"];
      const _resource_0 = _world_0["resource"];
      const _events_0 = _world_0["events"];
      const _pending_0 = _world_0["pending"];
      const _registrations_0 = _world_0["registrations"];
      const _nextSystemId_0 = _world_0["nextSystemId"];
      const _clock_0 = _world_0["clock"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
    } else {
      const _namespace_1 = _world_0["namespace"];
      const _nextId_1 = _world_0["nextId"];
      const _highWater_1 = _world_0["highWater"];
      const _live_1 = _world_0["live"];
      const _capacity_1 = _world_0["capacity"];
      const _depth_1 = _world_0["depth"];
      const _store_1 = _world_0["store"];
      const _resource_1 = _world_0["resource"];
      const _events_1 = _world_0["events"];
      const _pending_1 = _world_0["pending"];
      const _registrations_1 = _world_0["registrations"];
      const _nextSystemId_1 = _world_0["nextSystemId"];
      const _clock_1 = _world_0["clock"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
    }
  }
}

function $handle$045application$058empty$1261$(_unit_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1261$();
}

function $second_ready$1260$(_which_0, _own_0, _first_0, _cursor_0, _result_0) {
  const _second_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _foreign_0 = _t_0["handle"];
    return $run_again$1260$(_which_0, _own_0, _foreign_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1261$(_second_0, _foreign_0, {$: "handle-application.Payload", "cells": array_node([21], [22]), "name": "seed", "target": {$: "Some", "value": _foreign_0}})), ($factory_cursor$(_cursor_0)), ($handle$045application$058admit$1260$(_which_0, _first_0, ($operation_target$1260$(_which_0, _own_0, _foreign_0)), ($input$1260$(_which_0, _own_0, _foreign_0)))));
  } else {
    return "second-reserve-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1261$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return $populate_world$1260$(_world_0, _handle_0, _payload_0);
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(true, _handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$($0, $1, $2, $3) {
  for (;;) {
    {
      const _remaining_0 = $0;
      const _capacity_0 = $1;
      const _depth_0 = $2;
      const _live_0 = $3;
      if (_remaining_0 === 0) {
        return {$: "../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0};
      } else {
        const _rest_0 = (_remaining_0 - 1);
        $0 = _rest_0;
        $1 = (Math.imul(_capacity_0, 2) >>> 0);
        $2 = nat_chk(_depth_0 + 1);
        $3 = array_node(_live_0, array_new(_depth_0, false));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}};
}

function $second_ready$1261$(_which_0, _own_0, _first_0, _cursor_0, _result_0) {
  const _second_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _foreign_0 = _t_0["handle"];
    return $run_again$1261$(_which_0, _own_0, _foreign_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1263$(_second_0, _foreign_0, {$: "handle-application.Payload", "cells": array_node([21], [22]), "name": "seed", "target": {$: "Some", "value": _foreign_0}})), ($factory_cursor$(_cursor_0)), ($handle$045application$058admit$1261$(_which_0, _first_0, ($operation_target$1261$(_which_0, _own_0, _foreign_0)), ($input$1261$(_which_0, _own_0, _foreign_0)))));
  } else {
    return "second-reserve-failed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1263$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return $populate_world$1261$(_world_0, _handle_0, _payload_0);
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1261$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1261$(true, _handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}};
}

function $run_again$1260$(_which_0, _own_0, _foreign_0, _second_0, _cursor_0, _result_0) {
  const _world_0 = _result_0["world"];
  return $handle$045controls$058render$1260$(_second_0, _cursor_0, ($handle$045application$058admit$1260$(_which_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, run_clo((_x_0) => {
  return $marker$1260$(_x_0);
}))), ($operation_target$1260$(_which_0, _own_0, _foreign_0)), ($input$1260$(_which_0, _own_0, _foreign_0)))));
}

function $factory_cursor$(_factory_0) {
  const _nextNamespace_0 = _factory_0["nextNamespace"];
  return _nextNamespace_0;
}

function $handle$045application$058admit$1260$(_which_0, _world_0, _target_0, _payload_0) {
  if (_which_0 == 0) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 15) == 0) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 8) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if ((_which_0 & 15) == 8) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 4) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 7) == 4) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 2) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if ((_which_0 & 7) == 2) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 6) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 7) == 6) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 1) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 15) == 1) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 9) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 15) == 9) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 5) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if ((_which_0 & 7) == 5) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 3) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 7) == 3) {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  } else if (_which_0 == 7) {
    return $handle$045application$058component_request$1260$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else {
    return $handle$045application$058resource_request$1260$(_world_0, _payload_0);
  }
}

function $operation_target$1260$(_which_0, _own_0, _foreign_0) {
  if (_which_0 == 9) {
    return _foreign_0;
  } else {
    return _own_0;
  }
}

function $input$1260$(_which_0, _own_0, _foreign_0) {
  return {$: "handle-application.Payload", "cells": array_node(array_node([41], [42]), array_node([43], [44])), "name": "incoming", "target": ($target$1260$(_which_0, _own_0, _foreign_0))};
}

function $populate_world$1260$(_world_0, _target_0, _payload_0) {
  return $handle$045application$058populate$1260$(_world_0, _target_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _ns_0 = _handle_0["namespace"];
  const _id_0 = _handle_0["id"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $run_again$1261$(_which_0, _own_0, _foreign_0, _second_0, _cursor_0, _result_0) {
  const _world_0 = _result_0["world"];
  return $handle$045controls$058render$1261$(_second_0, _cursor_0, ($handle$045application$058admit$1261$(_which_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1261$(_world_0, run_clo((_x_0) => {
  return $marker$1261$(_x_0);
}))), ($operation_target$1261$(_which_0, _own_0, _foreign_0)), ($input$1261$(_which_0, _own_0, _foreign_0)))));
}

function $handle$045application$058admit$1261$(_which_0, _world_0, _target_0, _payload_0) {
  if (_which_0 == 0) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 15) == 0) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 8) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if ((_which_0 & 15) == 8) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 4) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 7) == 4) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 2) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if ((_which_0 & 7) == 2) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 6) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 7) == 6) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 1) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 15) == 1) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 9) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else if ((_which_0 & 15) == 9) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 5) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if ((_which_0 & 7) == 5) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 3) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Spawn"}, _payload_0);
  } else if ((_which_0 & 7) == 3) {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  } else if (_which_0 == 7) {
    return $handle$045application$058component_request$1261$(_world_0, {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert", "target": _target_0}, _payload_0);
  } else {
    return $handle$045application$058resource_request$1261$(_world_0, _payload_0);
  }
}

function $operation_target$1261$(_which_0, _own_0, _foreign_0) {
  if (_which_0 == 9) {
    return _foreign_0;
  } else {
    return _own_0;
  }
}

function $input$1261$(_which_0, _own_0, _foreign_0) {
  return {$: "handle-application.Payload", "cells": array_node(array_node([41], [42]), array_node([43], [44])), "name": "incoming", "target": ($target$1261$(_which_0, _own_0, _foreign_0))};
}

function $populate_world$1261$(_world_0, _target_0, _payload_0) {
  return $handle$045application$058populate$1261$(_world_0, _target_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1261$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _ns_0 = _handle_0["namespace"];
  const _id_0 = _handle_0["id"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $handle$045controls$058render$1260$(_foreign_0, _cursor_0, _result_0) {
  const _world_0 = _result_0["world"];
  const _incoming_0 = _result_0["incoming"];
  const _checked_0 = _result_0["checked"];
  const _host_0 = _result_0["host"];
  const _x_0 = ($U32$show$(_cursor_0));
  const _x_1 = ($handle$045controls$058snapshot$1260$(_foreign_0));
  const _x_2 = ("|factory:" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($handle$045controls$058snapshot$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1260$(_world_0))));
  const _x_5 = ("|foreign:" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($handle$045controls$058host_text$(_host_0));
  const _x_8 = ("|" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($handle$045controls$058incoming_text$1260$(_incoming_0));
  const _x_11 = ("|host:" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($handle$045controls$058checked_text$(_checked_0));
  const _x_14 = ("|" + _x_12);
  return (_x_13 + _x_14);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $marker$1260$(_world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1260$(_world_0, {$: "Con", "head": 77, "tail": {$: "Nil"}});
}

function $handle$045application$058component_request$1260$(_world_0, _operation_0, _payload_0) {
  return $handle$045application$058request_component_in_world$1260$(_operation_0, _payload_0, ($handle$045application$058namespace$1260$(_world_0)));
}

function $handle$045application$058resource_request$1260$(_world_0, _payload_0) {
  return $handle$045application$058request_resource_in_world$1260$(_payload_0, ($handle$045application$058namespace$1260$(_world_0)));
}

function $target$1260$(_which_0, _own_0, _foreign_0) {
  if (_which_0 == 0) {
    return {$: "Some", "value": _foreign_0};
  } else if ((_which_0 & 7) == 0) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 4) {
    return $zero_target$1260$(_own_0);
  } else if ((_which_0 & 7) == 4) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 2) {
    return {$: "Some", "value": _foreign_0};
  } else if (_which_0 == 10) {
    return {$: "None"};
  } else if ((_which_0 & 3) == 2) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 1) {
    return {$: "Some", "value": _foreign_0};
  } else if ((_which_0 & 7) == 1) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 5) {
    return $zero_target$1260$(_own_0);
  } else if ((_which_0 & 7) == 5) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 3) {
    return $zero_target$1260$(_own_0);
  } else {
    return {$: "Some", "value": _own_0};
  }
}

function $handle$045application$058populate$1260$(_world_0, _target_0, _payload_0) {
  return $handle$045application$058populated$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1260$(($handle$045application$058family$1260$()), _world_0, _target_0, {$: "Some", "value": _payload_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}}};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _nextId_0 = _world_0["nextId"];
    const _highWater_0 = _world_0["highWater"];
    const _live_0 = _world_0["live"];
    const _capacity_0 = _world_0["capacity"];
    const _depth_0 = _world_0["depth"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    const _id_0 = _handle_0["id"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}};
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $handle$045controls$058render$1261$(_foreign_0, _cursor_0, _result_0) {
  const _world_0 = _result_0["world"];
  const _incoming_0 = _result_0["incoming"];
  const _checked_0 = _result_0["checked"];
  const _host_0 = _result_0["host"];
  const _x_0 = ($U32$show$(_cursor_0));
  const _x_1 = ($handle$045controls$058snapshot$1261$(_foreign_0));
  const _x_2 = ("|factory:" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($handle$045controls$058snapshot$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1261$(_world_0))));
  const _x_5 = ("|foreign:" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($handle$045controls$058host_text$(_host_0));
  const _x_8 = ("|" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($handle$045controls$058incoming_text$1261$(_incoming_0));
  const _x_11 = ("|host:" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($handle$045controls$058checked_text$(_checked_0));
  const _x_14 = ("|" + _x_12);
  return (_x_13 + _x_14);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1261$(_world_0, _command_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $marker$1261$(_world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, {$: "Con", "head": 77, "tail": {$: "Nil"}});
}

function $handle$045application$058component_request$1261$(_world_0, _operation_0, _payload_0) {
  return $handle$045application$058request_component_in_world$1261$(_operation_0, _payload_0, ($handle$045application$058namespace$1261$(_world_0)));
}

function $handle$045application$058resource_request$1261$(_world_0, _payload_0) {
  return $handle$045application$058request_resource_in_world$1261$(_payload_0, ($handle$045application$058namespace$1261$(_world_0)));
}

function $target$1261$(_which_0, _own_0, _foreign_0) {
  if (_which_0 == 0) {
    return {$: "Some", "value": _foreign_0};
  } else if ((_which_0 & 7) == 0) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 4) {
    return $zero_target$1261$(_own_0);
  } else if ((_which_0 & 7) == 4) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 2) {
    return {$: "Some", "value": _foreign_0};
  } else if (_which_0 == 10) {
    return {$: "None"};
  } else if ((_which_0 & 3) == 2) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 1) {
    return {$: "Some", "value": _foreign_0};
  } else if ((_which_0 & 7) == 1) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 5) {
    return $zero_target$1261$(_own_0);
  } else if ((_which_0 & 7) == 5) {
    return {$: "Some", "value": _own_0};
  } else if (_which_0 == 3) {
    return $zero_target$1261$(_own_0);
  } else {
    return {$: "Some", "value": _own_0};
  }
}

function $handle$045application$058populate$1261$(_world_0, _target_0, _payload_0) {
  return $handle$045application$058populated$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1261$(($handle$045application$058family$1261$()), _world_0, _target_0, {$: "Some", "value": _payload_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}}};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _nextId_0 = _world_0["nextId"];
    const _highWater_0 = _world_0["highWater"];
    const _live_0 = _world_0["live"];
    const _capacity_0 = _world_0["capacity"];
    const _depth_0 = _world_0["depth"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    const _id_0 = _handle_0["id"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}};
  }
}

function $handle$045controls$058checked_text$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted") {
    const _canonical_0 = _value_0["value"];
    const _x_0 = run_loop($handle$045controls$058raw$(_canonical_0));
    return ("ok:" + _x_0);
  } else {
    const _error_0 = _value_0["error"];
    return $handle$045controls$058error_text$(_error_0);
  }
}

function $handle$045controls$058incoming_text$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return "none;";
  } else {
    const _owner_0 = _value_0["value"];
    const _x_0 = ($handle$045controls$058payload$1260$(_owner_0));
    return (_x_0 + ";");
  }
}

function $handle$045controls$058host_text$(_value_0) {
  if (_value_0.$ === "None") {
    return "not-attempted";
  } else {
    const _t_0 = _value_0["value"];
    if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
      return "accepted";
    } else {
      const _error_0 = _t_0["error"];
      const _x_0 = ($handle$045controls$058world_error$(_error_0));
      return ("rejected:" + _x_0);
    }
  }
}

function $handle$045controls$058snapshot$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _nextId_1 = _nextId_0;
  const _x_0 = ($U32$show$(_clock_0));
  const _x_1 = ($U32$show$(_nextSystemId_0));
  const _x_2 = ("/" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($handle$045controls$058registration_text$(_registrations_0));
  const _x_5 = ("/" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(($List$length$(_pending_0))));
  const _x_8 = ("/" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($handle$045controls$058event_text$(_events_0));
  const _x_11 = ("/" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($handle$045controls$058payload$1260$(_resource_0));
  const _x_14 = ("/" + _x_12);
  const _x_15 = (_x_13 + _x_14);
  const _x_16 = ($handle$045controls$058stored_column$1260$(_nextId_1, _store_0));
  const _x_17 = ("/" + _x_15);
  const _x_18 = (_x_16 + _x_17);
  const _x_19 = ($Nat$show$(_depth_0));
  const _x_20 = ("/" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  const _x_22 = ($U32$show$(_capacity_0));
  const _x_23 = ("/" + _x_21);
  const _x_24 = (_x_22 + _x_23);
  const _x_25 = ($handle$045controls$058bools$(_live_0));
  const _x_26 = ("/" + _x_24);
  const _x_27 = (_x_25 + _x_26);
  const _x_28 = ($U32$show$(_highWater_0));
  const _x_29 = ("/" + _x_27);
  const _x_30 = (_x_28 + _x_29);
  const _x_31 = ($U32$show$(_nextId_1));
  const _x_32 = ("/" + _x_30);
  const _x_33 = (_x_31 + _x_32);
  const _x_34 = ($U32$show$(_namespace_0));
  const _x_35 = ("/" + _x_33);
  return (_x_34 + _x_35);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_pending_0, {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Nil"}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1260$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $handle$045application$058request_component_in_world$1260$(_operation_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _namespace_0 = _observed_0["snd"];
  return $handle$045application$058component_request_at$1260$(_namespace_0, _world_0, _operation_0, _payload_0);
}

function $handle$045application$058namespace$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _namespace_0};
}

function $handle$045application$058request_resource_in_world$1260$(_payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _namespace_0 = _observed_0["snd"];
  return $handle$045application$058resource_request_at$1260$(_namespace_0, _world_0, _payload_0);
}

function $zero_target$1260$(_own_0) {
  const _namespace_0 = _own_0["namespace"];
  return {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": 0}};
}

function $handle$045application$058populated$1260$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    return _world_1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1260$(_family_0, _world_0, _handle_0, _incoming_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $handle$045application$058family$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": "HandlePayload"};
}

function $handle$045controls$058incoming_text$1261$(_value_0) {
  if (_value_0.$ === "None") {
    return "none;";
  } else {
    const _owner_0 = _value_0["value"];
    const _x_0 = ($handle$045controls$058payload$1261$(_owner_0));
    return (_x_0 + ";");
  }
}

function $handle$045controls$058snapshot$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _nextId_1 = _nextId_0;
  const _x_0 = ($U32$show$(_clock_0));
  const _x_1 = ($U32$show$(_nextSystemId_0));
  const _x_2 = ("/" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($handle$045controls$058registration_text$(_registrations_0));
  const _x_5 = ("/" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(($List$length$(_pending_0))));
  const _x_8 = ("/" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($handle$045controls$058event_text$(_events_0));
  const _x_11 = ("/" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($handle$045controls$058payload$1261$(_resource_0));
  const _x_14 = ("/" + _x_12);
  const _x_15 = (_x_13 + _x_14);
  const _x_16 = ($handle$045controls$058stored_column$1261$(_nextId_1, _store_0));
  const _x_17 = ("/" + _x_15);
  const _x_18 = (_x_16 + _x_17);
  const _x_19 = ($Nat$show$(_depth_0));
  const _x_20 = ("/" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  const _x_22 = ($U32$show$(_capacity_0));
  const _x_23 = ("/" + _x_21);
  const _x_24 = (_x_22 + _x_23);
  const _x_25 = ($handle$045controls$058bools$(_live_0));
  const _x_26 = ("/" + _x_24);
  const _x_27 = (_x_25 + _x_26);
  const _x_28 = ($U32$show$(_highWater_0));
  const _x_29 = ("/" + _x_27);
  const _x_30 = (_x_28 + _x_29);
  const _x_31 = ($U32$show$(_nextId_1));
  const _x_32 = ("/" + _x_30);
  const _x_33 = (_x_31 + _x_32);
  const _x_34 = ($U32$show$(_namespace_0));
  const _x_35 = ("/" + _x_33);
  return (_x_34 + _x_35);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1261$(_pending_0, {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Nil"}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $handle$045application$058request_component_in_world$1261$(_operation_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _namespace_0 = _observed_0["snd"];
  return $handle$045application$058component_request_at$1261$(_namespace_0, _world_0, _operation_0, _payload_0);
}

function $handle$045application$058namespace$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _namespace_0};
}

function $handle$045application$058request_resource_in_world$1261$(_payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _namespace_0 = _observed_0["snd"];
  return $handle$045application$058resource_request_at$1261$(_namespace_0, _world_0, _payload_0);
}

function $zero_target$1261$(_own_0) {
  const _namespace_0 = _own_0["namespace"];
  return {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": 0}};
}

function $handle$045application$058populated$1261$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    return _world_1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1261$(_family_0, _world_0, _handle_0, _incoming_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $handle$045application$058family$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": "HandlePayload"};
}

function $handle$045controls$058raw$(_value_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_value_0));
  const _x_1 = nat_chk(4 * _x_0);
  return $handle$045controls$058raw_walk$(nat_chk(1 + _x_1), {$: "Con", "head": {$: "handle-controls.VisitRaw", "value": _value_0}, "tail": {$: "Nil"}}, {$: "Nil"});
}

function $handle$045controls$058error_text$(_error_0) {
  if (_error_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid") {
    const _path_0 = _error_0["path"];
    const _expected_0 = _error_0["expected"];
    const _actual_0 = _error_0["actual"];
    const _x_0 = run_loop($handle$045controls$058raw$(_actual_0));
    const _x_1 = (":" + _x_0);
    const _x_2 = (_expected_0 + _x_1);
    const _x_3 = (":" + _x_2);
    return (_path_0 + _x_3);
  } else {
    const _path_1 = _error_0["path"];
    return (_path_1 + ":fuel-exhausted");
  }
}

function $handle$045controls$058payload$1260$(_owner_0) {
  const _cells_0 = _owner_0["cells"];
  const _name_0 = _owner_0["name"];
  const _target_0 = _owner_0["target"];
  const _x_0 = ($handle$045controls$058target_text$1260$(_target_0));
  const _x_1 = ($handle$045controls$058cell_values$(_cells_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = (":" + _x_3);
  return (_name_0 + _x_4);
}

function $handle$045controls$058world_error$(_error_0) {
  if (_error_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity") {
    return "MissingEntity";
  } else if (_error_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded") {
    return "CapacityExceeded";
  } else if (_error_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.NamespaceExhausted") {
    return "NamespaceExhausted";
  } else {
    return "SystemIdExhausted";
  }
}

function $handle$045controls$058bools$(_values_0) {
  if (_values_0.length === 1) {
    const _t_0 = _values_0[0];
    if (_t_0) {
      return "1";
    } else {
      return "0";
    }
  } else {
    const _left_0 = _values_0.slice(0, _values_0.length >> 1);
    const _right_0 = _values_0.slice(_values_0.length >> 1);
    const _x_0 = ($handle$045controls$058bools$(_left_0));
    const _x_1 = ($handle$045controls$058bools$(_right_0));
    return (_x_0 + _x_1);
  }
}

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
}

function $handle$045controls$058stored_column$1260$(_nextId_0, _column_0) {
  const _x_0 = ((_nextId_0 - 1) >>> 0);
  return $handle$045controls$058stored_column_rows$1260$(($handle$045controls$058column_rows$1260$(_x_0, 1, _column_0)));
}

function $handle$045controls$058event_text$(_values_0) {
  if (_values_0.$ === "Nil") {
    return "";
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    const _x_0 = ($handle$045controls$058event_text$(_rest_0));
    const _x_1 = ($U32$show$(_value_0));
    const _x_2 = ("," + _x_0);
    return (_x_1 + _x_2);
  }
}

function $List$length$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = _xs_0["tail"];
    return nat_chk(($List$length$(_t_0)) + 1);
  }
}

function $handle$045controls$058registration_text$(_entries_0) {
  if (_entries_0.$ === "Nil") {
    return "";
  } else {
    const _t_0 = _entries_0["head"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _tail_0 = _entries_0["tail"];
    const _x_0 = ($handle$045controls$058registration_text$(_tail_0));
    const _x_1 = ($List$show$1261$(_access_0));
    const _x_2 = (";" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    const _x_4 = (_name_0 + _x_3);
    const _x_5 = ($U32$show$(_id_0));
    const _x_6 = (":" + _x_4);
    return (_x_5 + _x_6);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_commands_0, _world_0) {
  if (_commands_0.$ === "Nil") {
    return _world_0;
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return run_tail(_command_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_rest_0, _world_0)));
  }
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, _published_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $handle$045application$058component_request_at$1260$(_namespace_0, _world_0, _operation_0, _payload_0) {
  return $handle$045application$058component_result$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1260$(($handle$045application$058frame_at$1260$(_namespace_0, _world_0)), {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Input", "operation": _operation_0, "raw": _payload_0})));
}

function $handle$045application$058resource_request_at$1260$(_namespace_0, _world_0, _payload_0) {
  return $handle$045application$058resource_result$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1262$(($handle$045application$058frame_at$1260$(_namespace_0, _world_0)), _payload_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1260$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1260$(_handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $handle$045controls$058payload$1261$(_owner_0) {
  const _cells_0 = _owner_0["cells"];
  const _name_0 = _owner_0["name"];
  const _target_0 = _owner_0["target"];
  const _x_0 = ($handle$045controls$058target_text$1261$(_target_0));
  const _x_1 = ($handle$045controls$058cell_values$(_cells_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = (":" + _x_3);
  return (_name_0 + _x_4);
}

function $handle$045controls$058stored_column$1261$(_nextId_0, _column_0) {
  const _x_0 = ((_nextId_0 - 1) >>> 0);
  return $handle$045controls$058stored_column_rows$1261$(($handle$045controls$058column_rows$1261$(_x_0, 1, _column_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1261$(_commands_0, _world_0) {
  if (_commands_0.$ === "Nil") {
    return _world_0;
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return run_tail(_command_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1261$(_rest_0, _world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, _published_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $handle$045application$058component_request_at$1261$(_namespace_0, _world_0, _operation_0, _payload_0) {
  return $handle$045application$058component_result$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1264$(($handle$045application$058frame_at$1261$(_namespace_0, _world_0)), {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Input", "operation": _operation_0, "raw": _payload_0})));
}

function $handle$045application$058resource_request_at$1261$(_namespace_0, _world_0, _payload_0) {
  return $handle$045application$058resource_result$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1266$(($handle$045application$058frame_at$1261$(_namespace_0, _world_0)), _payload_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1261$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1261$(_handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
}

function $handle$045controls$058raw_walk$(_fuel_0, _todo_0, _stack_0) {
  if (_fuel_0 === 0) {
    return "formatter-budget-error";
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $handle$045controls$058raw_step$(_todo_0, _stack_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $handle$045controls$058raw_walk$(_rest_0, _x_0, _x_1);
});
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_raw_0) {
  if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _t_0 = _raw_0["items"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _head_0 = _t_0["head"];
      const _rest_0 = _t_0["tail"];
      const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_head_0));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _rest_0}));
      return nat_chk(_x_0 + _x_1);
    }
  } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
    const _t_1 = _raw_0["fields"];
    if (_t_1.$ === "Nil") {
      return 1;
    } else {
      const _t_2 = _t_1["head"];
      const _child_0 = _t_2["value"];
      const _rest_1 = _t_1["tail"];
      const _x_2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_child_0));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": _rest_1}));
      return nat_chk(_x_2 + _x_3);
    }
  } else {
    return 1;
  }
}

function $handle$045controls$058cell_values$(_owner_0) {
  if (_owner_0.length === 1) {
    const _value_0 = _owner_0[0];
    const _x_0 = ($U32$show$(_value_0));
    return (_x_0 + ",");
  } else {
    const _left_0 = _owner_0.slice(0, _owner_0.length >> 1);
    const _right_0 = _owner_0.slice(_owner_0.length >> 1);
    const _x_1 = ($handle$045controls$058cell_values$(_left_0));
    const _x_2 = ($handle$045controls$058cell_values$(_right_0));
    return (_x_1 + _x_2);
  }
}

function $handle$045controls$058target_text$1260$(_target_0) {
  if (_target_0.$ === "None") {
    return "null";
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _x_0 = ($U32$show$(_id_0));
    const _x_1 = ($U32$show$(_namespace_0));
    const _x_2 = (":" + _x_0);
    return (_x_1 + _x_2);
  }
}

function $Nat$show$fin$($0, $1, $2) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _g_0 = $0;
      const _acc_0 = $1;
      const _dq_0 = $2;
      const _d_0 = _dq_0["fst"];
      const _t_0 = _dq_0["snd"];
      if (_t_0 === 0) {
        return (_d_0 + _acc_0);
      } else {
        const _p_0 = (_t_0 - 1);
        $0 = _g_0;
        $1 = nat_chk(_p_0 + 1);
        $2 = (_d_0 + _acc_0);
        $pc = 1; continue;
      }
    }
    case 1: {
      const _f_0 = $0;
      const _n_0 = $1;
      const _acc_0 = $2;
      if (_f_0 === 0) {
        return _acc_0;
      } else {
        const _g_0 = (_f_0 - 1);
        $0 = _g_0;
        $1 = _acc_0;
        $2 = ($Nat$show$put$(nat_divmod(_n_0, 10)));
        $pc = 0; continue;
      }
    }
  }
}

function $Nat$show$put$(_qr_0) {
  const _q_0 = _qr_0["fst"];
  const _r_0 = _qr_0["snd"];
  const _x_0 = nat_chk(48 + _r_0);
  return {$: "Tuple", "fst": char_new((_x_0 >>> 0)), "snd": _q_0};
}

function $handle$045controls$058stored_column_rows$1260$(_result_0) {
  const _rows_0 = _result_0["snd"];
  return _rows_0;
}

function $handle$045controls$058column_rows$1260$(_fuel_0, _id_0, _column_0) {
  if (_fuel_0 === 0) {
    return {$: "Tuple", "fst": _column_0, "snd": ""};
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $handle$045controls$058column_rows_after_view$1260$(($handle$045controls$058row_view$1260$(_id_0, _column_0)), run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $handle$045controls$058column_rows$1260$(_rest_0, _x_0, _x_1);
});
}));
  }
}

function $List$show$1261$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1261$(_t_0));
    const _x_1 = (_h_0 + _x_0);
    return ("[" + _x_1);
  }
}

function $U32$show$go$($0, $1, $2, $3) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _f_0 = $0;
      const _n_0 = $1;
      const _acc_0 = $2;
      if (_f_0 === 0) {
        return _acc_0;
      } else {
        const _g_0 = (_f_0 - 1);
        $0 = _g_0;
        $1 = _acc_0;
        $2 = _n_0;
        $3 = (_n_0 === 0);
        $pc = 1; continue;
      }
    }
    case 1: {
      const _g_0 = $0;
      const _acc_0 = $1;
      const _n_0 = $2;
      const _z_0 = $3;
      if (_z_0) {
        return _acc_0;
      } else {
        const _x_0 = (10 === 0 ? _n_0 : _n_0 % 10);
        $0 = _g_0;
        $1 = (10 === 0 ? 0 : (_n_0 / 10) >>> 0);
        $2 = (char_new(((48 + _x_0) >>> 0)) + _acc_0);
        $pc = 0; continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_left_0, _right_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1260$(($List$reverse$(_left_0)), _right_0);
}

function $handle$045application$058component_result$1260$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _output_0 = _result_0["snd"];
  return $handle$045application$058component_done$1260$(_output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1260$(_owner_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1260$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1260$(($handle$045application$058component_grant$1260$())))(_ctx_0), _input_0);
}

function $handle$045application$058frame_at$1260$(_namespace_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($handle$045application$058component_declaration$1260$(_namespace_0)));
}

function $handle$045application$058resource_result$1260$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _output_0 = _result_0["snd"];
  return $handle$045application$058resource_done$1260$(_output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1260$(_owner_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1262$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1262$(($handle$045application$058resource_grant$1260$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _tick_0 = _clocked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1260$((_tick_0 < 4294967295), _world_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_incoming_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1260$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0);
}

function $handle$045controls$058target_text$1261$(_target_0) {
  if (_target_0.$ === "None") {
    return "null";
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _x_0 = ($U32$show$(_id_0));
    const _x_1 = ($U32$show$(_namespace_0));
    const _x_2 = (":" + _x_0);
    return (_x_1 + _x_2);
  }
}

function $handle$045controls$058stored_column_rows$1261$(_result_0) {
  const _rows_0 = _result_0["snd"];
  return _rows_0;
}

function $handle$045controls$058column_rows$1261$(_fuel_0, _id_0, _column_0) {
  if (_fuel_0 === 0) {
    return {$: "Tuple", "fst": _column_0, "snd": ""};
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $handle$045controls$058column_rows_after_view$1261$(($handle$045controls$058row_view$1261$(_id_0, _column_0)), run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $handle$045controls$058column_rows$1261$(_rest_0, _x_0, _x_1);
});
}));
  }
}

function $handle$045application$058component_result$1261$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _output_0 = _result_0["snd"];
  return $handle$045application$058component_done$1261$(_output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1261$(_owner_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1264$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1264$(($handle$045application$058component_grant$1261$())))(_ctx_0), _input_0);
}

function $handle$045application$058frame_at$1261$(_namespace_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($handle$045application$058component_declaration$1261$(_namespace_0)));
}

function $handle$045application$058resource_result$1261$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _output_0 = _result_0["snd"];
  return $handle$045application$058resource_done$1261$(_output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1261$(_owner_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1266$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1266$(($handle$045application$058resource_grant$1261$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1261$(_id_0, _incoming_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _tick_0 = _clocked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1261$((_tick_0 < 4294967295), _world_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_incoming_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1261$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0);
}

function $handle$045controls$058raw_step$(_todo_0, _stack_0, _next_0) {
  if (_todo_0.$ === "Nil") {
    return $handle$045controls$058raw_finished$(_stack_0);
  } else {
    const _t_0 = _todo_0["head"];
    if (_t_0.$ === "handle-controls.VisitRaw") {
      const _value_0 = _t_0["value"];
      const _rest_0 = _todo_0["tail"];
      return run_tail(_next_0(($List$append$(($handle$045controls$058raw_expand$(_value_0)), _rest_0))), _stack_0);
    } else if (_t_0.$ === "handle-controls.Ready") {
      const _text_0 = _t_0["text"];
      const _rest_1 = _todo_0["tail"];
      return run_tail(_next_0(_rest_1), {$: "Con", "head": _text_0, "tail": _stack_0});
    } else if (_t_0.$ === "handle-controls.ArrayEnd") {
      const _count_0 = _t_0["count"];
      const _rest_2 = _todo_0["tail"];
      return run_tail(_next_0(_rest_2), ($handle$045controls$058array_end$(_count_0, _stack_0)));
    } else if (_t_0.$ === "handle-controls.ObjectEnd") {
      const _count_1 = _t_0["count"];
      const _rest_3 = _todo_0["tail"];
      return run_tail(_next_0(_rest_3), ($handle$045controls$058object_end$(_count_1, _stack_0)));
    } else {
      const _name_0 = _t_0["name"];
      const _rest_4 = _todo_0["tail"];
      return run_tail(_next_0(_rest_4), ($handle$045controls$058field_end$(_name_0, _stack_0)));
    }
  }
}

function $Nat$show$go$($0, $1, $2) {
  let $pc = 1;
  for (;;) switch ($pc) {
    case 0: {
      const _g_0 = $0;
      const _acc_0 = $1;
      const _dq_0 = $2;
      const _d_0 = _dq_0["fst"];
      const _t_0 = _dq_0["snd"];
      if (_t_0 === 0) {
        return (_d_0 + _acc_0);
      } else {
        const _p_0 = (_t_0 - 1);
        $0 = _g_0;
        $1 = nat_chk(_p_0 + 1);
        $2 = (_d_0 + _acc_0);
        $pc = 1; continue;
      }
    }
    case 1: {
      const _f_0 = $0;
      const _n_0 = $1;
      const _acc_0 = $2;
      if (_f_0 === 0) {
        return _acc_0;
      } else {
        const _g_0 = (_f_0 - 1);
        $0 = _g_0;
        $1 = _acc_0;
        $2 = ($Nat$show$put$(nat_divmod(_n_0, 10)));
        $pc = 0; continue;
      }
    }
  }
}

function $handle$045controls$058column_rows_after_view$1260$(_observed_0, _next_0) {
  const _column_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _index_0 = _t_0["index"];
  const _value_0 = _t_0["value"];
  const _stamp_0 = _t_0["stamp"];
  const _index_1 = _index_0;
  const _text_0 = ($handle$045controls$058row_text$(_index_1, _value_0, _stamp_0));
  const _nextId_0 = ((_index_1 + 1) >>> 0);
  return $handle$045controls$058column_rows_join$1260$(_text_0, _next_0(_nextId_0)(_column_0));
}

function $handle$045controls$058row_view$1260$(_id_0, _column_0) {
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_taken$1260$(_id_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1260$(_column_0, _id_1)));
}

function $List$show$go$1261$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1261$(_t_0));
    const _x_1 = (_h_0 + _x_0);
    return (", " + _x_1);
  }
}

function $U32$show$fin$($0, $1, $2, $3) {
  let $pc = 1;
  for (;;) switch ($pc) {
    case 0: {
      const _f_0 = $0;
      const _n_0 = $1;
      const _acc_0 = $2;
      if (_f_0 === 0) {
        return _acc_0;
      } else {
        const _g_0 = (_f_0 - 1);
        $0 = _g_0;
        $1 = _acc_0;
        $2 = _n_0;
        $3 = (_n_0 === 0);
        $pc = 1; continue;
      }
    }
    case 1: {
      const _g_0 = $0;
      const _acc_0 = $1;
      const _n_0 = $2;
      const _z_0 = $3;
      if (_z_0) {
        return _acc_0;
      } else {
        const _x_0 = (10 === 0 ? _n_0 : _n_0 % 10);
        $0 = _g_0;
        $1 = (10 === 0 ? 0 : (_n_0 / 10) >>> 0);
        $2 = (char_new(((48 + _x_0) >>> 0)) + _acc_0);
        $pc = 0; continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1260$($0, $1) {
  for (;;) {
    {
      const _reversed_0 = $0;
      const _output_0 = $1;
      if (_reversed_0.$ === "Nil") {
        return _output_0;
      } else {
        const _head_0 = _reversed_0["head"];
        const _rest_0 = _reversed_0["tail"];
        $0 = _rest_0;
        $1 = {$: "Con", "head": _head_0, "tail": _output_0};
        continue;
      }
    }
  }
}

function $List$reverse$(_xs_0) {
  return $List$reverse$go$(_xs_0, {$: "Nil"});
}

function $handle$045application$058component_done$1260$(_output_0, _finished_0) {
  if (_finished_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed") {
    const _world_0 = _finished_0["world"];
    return $handle$045application$058component_output_done$1260$(_world_0, _output_0);
  } else {
    const _world_1 = _finished_0["world"];
    return {$: "handle-application.Outcome", "world": _world_1, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1260$(_owner_0, _outcome_0) {
  const _batch_0 = _owner_0["batch"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058finish$1260$(_batch_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1260$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $handle$045application$058component_grant$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058grant$1260$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $handle$045application$058component_declaration$1260$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(($handle$045application$058codec$(_namespace_0)));
}

function $handle$045application$058resource_done$1260$(_output_0, _finished_0) {
  if (_finished_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed") {
    const _world_0 = _finished_0["world"];
    return $handle$045application$058resource_output_done$1260$(_world_0, _output_0);
  } else {
    const _world_1 = _finished_0["world"];
    return {$: "handle-application.Outcome", "world": _world_1, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1262$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $handle$045application$058resource_grant$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058grant$1260$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1260$(_allowed_0, _world_0, _id_0, _observed_0) {
  if (!_allowed_0) {
    const _incoming_0 = _observed_0["fst"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  } else {
    const _incoming_1 = _observed_0["fst"];
    const _present_0 = _observed_0["snd"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _present_0, _incoming_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": false};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "Tuple", "fst": {$: "Some", "value": _owner_1}, "snd": true};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": false};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _nextId_0 = _world_0["nextId"];
    const _highWater_0 = _world_0["highWater"];
    const _live_0 = _world_0["live"];
    const _capacity_0 = _world_0["capacity"];
    const _depth_0 = _world_0["depth"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1260$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $handle$045controls$058column_rows_after_view$1261$(_observed_0, _next_0) {
  const _column_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _index_0 = _t_0["index"];
  const _value_0 = _t_0["value"];
  const _stamp_0 = _t_0["stamp"];
  const _index_1 = _index_0;
  const _text_0 = ($handle$045controls$058row_text$(_index_1, _value_0, _stamp_0));
  const _nextId_0 = ((_index_1 + 1) >>> 0);
  return $handle$045controls$058column_rows_join$1261$(_text_0, _next_0(_nextId_0)(_column_0));
}

function $handle$045controls$058row_view$1261$(_id_0, _column_0) {
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_taken$1261$(_id_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1261$(_column_0, _id_1)));
}

function $handle$045application$058component_done$1261$(_output_0, _finished_0) {
  if (_finished_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed") {
    const _world_0 = _finished_0["world"];
    return $handle$045application$058component_output_done$1261$(_world_0, _output_0);
  } else {
    const _world_1 = _finished_0["world"];
    return {$: "handle-application.Outcome", "world": _world_1, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058finish$1261$(_owner_0, _outcome_0) {
  const _batch_0 = _owner_0["batch"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058finish$1261$(_batch_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1264$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $handle$045application$058component_grant$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058grant$1261$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $handle$045application$058component_declaration$1261$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$(($handle$045application$058codec$(_namespace_0)));
}

function $handle$045application$058resource_done$1261$(_output_0, _finished_0) {
  if (_finished_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed") {
    const _world_0 = _finished_0["world"];
    return $handle$045application$058resource_output_done$1261$(_world_0, _output_0);
  } else {
    const _world_1 = _finished_0["world"];
    return {$: "handle-application.Outcome", "world": _world_1, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1266$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $handle$045application$058resource_grant$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058grant$1261$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1261$(_allowed_0, _world_0, _id_0, _observed_0) {
  if (!_allowed_0) {
    const _incoming_0 = _observed_0["fst"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  } else {
    const _incoming_1 = _observed_0["fst"];
    const _present_0 = _observed_0["snd"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1261$(_id_0, _present_0, _incoming_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": false};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "Tuple", "fst": {$: "Some", "value": _owner_1}, "snd": true};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": false};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _nextId_0 = _world_0["nextId"];
    const _highWater_0 = _world_0["highWater"];
    const _live_0 = _world_0["live"];
    const _capacity_0 = _world_0["capacity"];
    const _depth_0 = _world_0["depth"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1261$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $handle$045controls$058raw_finished$(_stack_0) {
  if (_stack_0.$ === "Con") {
    const _value_0 = _stack_0["head"];
    const _t_0 = _stack_0["tail"];
    if (_t_0.$ === "Nil") {
      return _value_0;
    } else {
      return "formatter-stack-error";
    }
  } else {
    return "formatter-stack-error";
  }
}

function $List$append$(_xs_0, _ys_0) {
  if (_xs_0.$ === "Nil") {
    return _ys_0;
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    return {$: "Con", "head": _h_0, "tail": ($List$append$(_t_0, _ys_0))};
  }
}

function $handle$045controls$058raw_expand$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Missing") {
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": "missing"}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": "null"}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
    const _value_1 = _value_0["value"];
    const _x_0 = ($U32$show$(_value_1));
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("u32:" + _x_0)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
    const _magnitude_0 = _value_0["magnitude"];
    const _x_1 = ($Nat$show$(_magnitude_0));
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("integer:" + _x_1)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
    const _value_2 = _value_0["value"];
    const _x_2 = f32_show(_value_2);
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("f32:" + _x_2)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
    const _high_0 = _value_0["high"];
    const _low_0 = _value_0["low"];
    const _x_3 = ($U32$show$(_low_0));
    const _x_4 = ($U32$show$(_high_0));
    const _x_5 = (":" + _x_3);
    const _x_6 = (_x_4 + _x_5);
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("binary64:" + _x_6)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
    const _value_3 = _value_0["value"];
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("str:" + _value_3)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
    const _units_0 = _value_0["units"];
    const _x_7 = ($List$show$1260$(_units_0));
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("utf16:" + _x_7)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
    const _t_0 = _value_0["value"];
    if (_t_0) {
      return {$: "Con", "head": {$: "handle-controls.Ready", "text": "bool:true"}, "tail": {$: "Nil"}};
    } else {
      return {$: "Con", "head": {$: "handle-controls.Ready", "text": "bool:false"}, "tail": {$: "Nil"}};
    }
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle") {
    const _namespace_0 = _value_0["namespace"];
    const _id_0 = _value_0["id"];
    const _x_8 = ($U32$show$(_id_0));
    const _x_9 = ($U32$show$(_namespace_0));
    const _x_10 = (":" + _x_8);
    const _x_11 = (_x_9 + _x_10);
    return {$: "Con", "head": {$: "handle-controls.Ready", "text": ("handle:" + _x_11)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _items_0 = _value_0["items"];
    return $List$append$(($handle$045controls$058raw_visits$(_items_0)), {$: "Con", "head": {$: "handle-controls.ArrayEnd", "count": ($List$length$(_items_0))}, "tail": {$: "Nil"}});
  } else {
    const _fields_0 = _value_0["fields"];
    return $List$append$(($handle$045controls$058raw_field_visits$(_fields_0)), {$: "Con", "head": {$: "handle-controls.ObjectEnd", "count": ($List$length$(_fields_0))}, "tail": {$: "Nil"}});
  }
}

function $handle$045controls$058array_end$(_count_0, _stack_0) {
  return $handle$045controls$058array_end_pair$(($handle$045controls$058collect_strings$(_count_0, _stack_0, {$: "Nil"})));
}

function $handle$045controls$058object_end$(_count_0, _stack_0) {
  return $handle$045controls$058object_end_pair$(($handle$045controls$058collect_strings$(_count_0, _stack_0, {$: "Nil"})));
}

function $handle$045controls$058field_end$(_name_0, _stack_0) {
  if (_stack_0.$ === "Con") {
    const _value_0 = _stack_0["head"];
    const _rest_0 = _stack_0["tail"];
    const _x_0 = (":" + _value_0);
    return {$: "Con", "head": (_name_0 + _x_0), "tail": _rest_0};
  } else {
    return {$: "Nil"};
  }
}

function $handle$045controls$058row_text$(_index_0, _value_0, _stamp_0) {
  const _added_0 = _stamp_0["added"];
  const _changed_0 = _stamp_0["changed"];
  const _x_0 = ($U32$show$(_changed_0));
  const _x_1 = (_x_0 + ";");
  const _x_2 = ($U32$show$(_added_0));
  const _x_3 = (":" + _x_1);
  const _x_4 = (_x_2 + _x_3);
  const _x_5 = ($handle$045controls$058raw_view_text$(_value_0));
  const _x_6 = ("stamp:" + _x_4);
  const _x_7 = (_x_5 + _x_6);
  const _x_8 = ($U32$show$(_index_0));
  const _x_9 = ("=" + _x_7);
  const _x_10 = (_x_8 + _x_9);
  return ("row" + _x_10);
}

function $handle$045controls$058column_rows_join$1260$(_text_0, _result_0) {
  const _column_0 = _result_0["fst"];
  const _rows_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _column_0, "snd": (_text_0 + _rows_0)};
}

function $handle$045controls$058row_view_taken$1260$(_id_0, _result_0) {
  const _column_0 = _result_0["fst"];
  const _value_0 = _result_0["snd"];
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_stamped$1260$(_id_1, _value_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_1)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $List$reverse$go$($0, $1) {
  for (;;) {
    {
      const _xs_0 = $0;
      const _acc_0 = $1;
      if (_xs_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _h_0 = _xs_0["head"];
        const _t_0 = _xs_0["tail"];
        $0 = _t_0;
        $1 = {$: "Con", "head": _h_0, "tail": _acc_0};
        continue;
      }
    }
  }
}

function $handle$045application$058component_output_done$1260$(_world_0, _output_0) {
  if (_output_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Accepted") {
    const _canonical_0 = _output_0["canonical"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}}};
  } else {
    const _owner_0 = _output_0["owner"];
    const _t_0 = _output_0["error"];
    if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation") {
      const _error_0 = _t_0["error"];
      return {$: "handle-application.Outcome", "world": _world_0, "incoming": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}, "host": {$: "None"}};
    } else {
      const _error_1 = _t_0["error"];
      return $handle$045application$058component_entity_refused$1260$(_world_0, _owner_0, _error_1);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058finish$1260$(_batch_0, _outcome_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058committed$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058stage$1260$(($List$reverse$(_prepared_0)), _tx_0)), {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
  } else {
    const _error_0 = _outcome_0["error"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058failed$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1260$(($List$reverse$(_prepared_0)))), _error_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1260$(_tx_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058grant$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058apply$1260$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(_codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $handle$045application$058codec$(_namespace_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "cells", "codec": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue", "inner": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"}}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "name", "codec": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "target", "codec": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable", "inner": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.HandleValue", "namespace": _namespace_0}}}, "tail": {$: "Nil"}}}}};
}

function $handle$045application$058resource_output_done$1260$(_world_0, _output_0) {
  if (_output_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Replaced") {
    const _canonical_0 = _output_0["canonical"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}}};
  } else {
    const _owner_0 = _output_0["owner"];
    const _error_0 = _output_0["error"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "Some", "value": _owner_0}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058grant$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058apply$1260$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _incomingPresent_0, _incoming_0, _advanced_0) {
  const _world_0 = _advanced_0["fst"];
  const _tick_0 = _advanced_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1260$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $handle$045controls$058column_rows_join$1261$(_text_0, _result_0) {
  const _column_0 = _result_0["fst"];
  const _rows_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _column_0, "snd": (_text_0 + _rows_0)};
}

function $handle$045controls$058row_view_taken$1261$(_id_0, _result_0) {
  const _column_0 = _result_0["fst"];
  const _value_0 = _result_0["snd"];
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_stamped$1261$(_id_1, _value_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1261$(_column_0, _id_1)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1261$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $handle$045application$058component_output_done$1261$(_world_0, _output_0) {
  if (_output_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Accepted") {
    const _canonical_0 = _output_0["canonical"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}}};
  } else {
    const _owner_0 = _output_0["owner"];
    const _t_0 = _output_0["error"];
    if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation") {
      const _error_0 = _t_0["error"];
      return {$: "handle-application.Outcome", "world": _world_0, "incoming": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}, "host": {$: "None"}};
    } else {
      const _error_1 = _t_0["error"];
      return $handle$045application$058component_entity_refused$1261$(_world_0, _owner_0, _error_1);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058finish$1261$(_batch_0, _outcome_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058committed$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058stage$1261$(($List$reverse$(_prepared_0)), _tx_0)), {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"})));
  } else {
    const _error_0 = _outcome_0["error"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058failed$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1261$(($List$reverse$(_prepared_0)))), _error_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1261$(_tx_0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058grant$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058apply$1261$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$(_codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $handle$045application$058resource_output_done$1261$(_world_0, _output_0) {
  if (_output_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Replaced") {
    const _canonical_0 = _output_0["canonical"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}}};
  } else {
    const _owner_0 = _output_0["owner"];
    const _error_0 = _output_0["error"];
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "Some", "value": _owner_0}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}, "host": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058grant$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058apply$1261$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1261$(_id_0, _incomingPresent_0, _incoming_0, _advanced_0) {
  const _world_0 = _advanced_0["fst"];
  const _tick_0 = _advanced_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1261$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1261$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $List$show$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($U32$show$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $handle$045controls$058raw_visits$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return {$: "Con", "head": {$: "handle-controls.VisitRaw", "value": _value_0}, "tail": ($handle$045controls$058raw_visits$(_rest_0))};
  }
}

function $handle$045controls$058raw_field_visits$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _fields_0["head"];
    const _name_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _fields_0["tail"];
    return {$: "Con", "head": {$: "handle-controls.VisitRaw", "value": _value_0}, "tail": {$: "Con", "head": {$: "handle-controls.FieldEnd", "name": _name_0}, "tail": ($handle$045controls$058raw_field_visits$(_rest_0))}};
  }
}

function $handle$045controls$058array_end_pair$(_result_0) {
  const _values_0 = _result_0["fst"];
  const _rest_0 = _result_0["snd"];
  const _x_0 = ($handle$045controls$058string_join$(_values_0));
  const _x_1 = (_x_0 + "]");
  return {$: "Con", "head": ("[" + _x_1), "tail": _rest_0};
}

function $handle$045controls$058collect_strings$($0, $1, $2) {
  for (;;) {
    {
      const _count_0 = $0;
      const _stack_0 = $1;
      const _accumulated_0 = $2;
      if (_count_0 === 0) {
        return {$: "Tuple", "fst": _accumulated_0, "snd": _stack_0};
      } else {
        const _remaining_0 = (_count_0 - 1);
        if (_stack_0.$ === "Con") {
          const _value_0 = _stack_0["head"];
          const _tail_0 = _stack_0["tail"];
          $0 = _remaining_0;
          $1 = _tail_0;
          $2 = {$: "Con", "head": _value_0, "tail": _accumulated_0};
          continue;
        } else {
          return {$: "Tuple", "fst": _accumulated_0, "snd": {$: "Nil"}};
        }
      }
    }
  }
}

function $handle$045controls$058object_end_pair$(_result_0) {
  const _values_0 = _result_0["fst"];
  const _rest_0 = _result_0["snd"];
  const _x_0 = ($handle$045controls$058string_join$(_values_0));
  const _x_1 = (_x_0 + "}");
  return {$: "Con", "head": ("{" + _x_1), "tail": _rest_0};
}

function $handle$045controls$058raw_view_text$(_value_0) {
  if (_value_0.$ === "None") {
    return "none;";
  } else {
    const _canonical_0 = _value_0["value"];
    const _x_0 = run_loop($handle$045controls$058raw$(_canonical_0));
    return (_x_0 + ";");
  }
}

function $handle$045controls$058row_view_stamped$1260$(_id_0, _value_0, _result_0) {
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_done$1260$(_id_1, _value_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Owned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $handle$045application$058component_entity_refused$1260$(_world_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": _error_0}}};
  } else {
    const _payload_0 = _owner_0["value"];
    return $handle$045application$058component_entity_error$1260$(_world_0, _error_0, ($handle$045application$058project$1260$(_payload_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058committed$1260$(_observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed", "world": _world_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1260$(_tx_0, _outcome_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058stage$1260$(_prepared_0, _tx_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1260$(_prepared_0, ($List$reverse$(_commands_0)), 0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Nil"}, "events": _events_0});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058failed$1260$(_payloads_0, _error_0, _observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Failed", "world": _world_0, "payloads": _payloads_0, "error": _error_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1260$($0) {
  for (;;) {
    {
      const _prepared_0 = $0;
      if (_prepared_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          continue;
        } else {
          const _payload_0 = _t_0["payload"];
          const _tail_1 = _prepared_0["tail"];
          return {$: "Con", "head": _payload_0, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1260$(_tail_1))};
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058apply$1260$(_ctx_0, _input_0) {
  const _operation_0 = _input_0["operation"];
  const _raw_0 = _input_0["raw"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058constructed$1260$(_ctx_0, _operation_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1260$(($handle$045application$058component_factory$1260$(1)), _raw_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(_tx_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058apply$1260$(_ctx_0, _input_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058constructed$1260$(_ctx_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1261$(($handle$045application$058resource_factory$1260$(1)), _input_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Swapped") {
    const _previous_0 = _t_0["previous"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0};
  } else {
    const _incoming_0 = _t_0["incoming"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, ($handle$045application$058take$1260$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$(_available_0, _clock_0) {
  if (!_available_0) {
    return _clock_0;
  } else {
    return ((_clock_0 + 1) >>> 0);
  }
}

function $handle$045controls$058row_view_stamped$1261$(_id_0, _value_0, _result_0) {
  const _id_1 = _id_0;
  return $handle$045controls$058row_view_done$1261$(_id_1, _value_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1261$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Owned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned") {
        const _state_0 = _carrier_0["state"];
        return _state_0;
      } else {
        const _inner_0 = _carrier_0["inner"];
        $0 = _inner_0;
        continue;
      }
    }
  }
}

function $handle$045application$058component_entity_refused$1261$(_world_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "None"}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": _error_0}}};
  } else {
    const _payload_0 = _owner_0["value"];
    return $handle$045application$058component_entity_error$1261$(_world_0, _error_0, ($handle$045application$058project$1261$(_payload_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058committed$1261$(_observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Committed", "world": _world_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1261$(_tx_0, _outcome_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(_tx_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058stage$1261$(_prepared_0, _tx_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1261$(_prepared_0, ($List$reverse$(_commands_0)), 0, {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Nil"}, "events": _events_0});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058failed$1261$(_payloads_0, _error_0, _observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Failed", "world": _world_0, "payloads": _payloads_0, "error": _error_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1261$($0) {
  for (;;) {
    {
      const _prepared_0 = $0;
      if (_prepared_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          continue;
        } else {
          const _payload_0 = _t_0["payload"];
          const _tail_1 = _prepared_0["tail"];
          return {$: "Con", "head": _payload_0, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058originals$1261$(_tail_1))};
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058apply$1261$(_ctx_0, _input_0) {
  const _operation_0 = _input_0["operation"];
  const _raw_0 = _input_0["raw"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058constructed$1261$(_ctx_0, _operation_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1262$(($handle$045application$058component_factory$1261$(1)), _raw_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(_tx_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058apply$1261$(_ctx_0, _input_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058constructed$1261$(_ctx_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1263$(($handle$045application$058resource_factory$1261$(1)), _input_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1261$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Swapped") {
    const _previous_0 = _t_0["previous"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0};
  } else {
    const _incoming_0 = _t_0["incoming"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, ($handle$045application$058take$1261$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $List$show$go$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($U32$show$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $handle$045controls$058string_join$(_items_0) {
  if (_items_0.$ === "Nil") {
    return "";
  } else {
    const _item_0 = _items_0["head"];
    const _t_0 = _items_0["tail"];
    if (_t_0.$ === "Nil") {
      return _item_0;
    } else {
      const _x_0 = ($handle$045controls$058string_join$(_t_0));
      const _x_1 = ("," + _x_0);
      return (_item_0 + _x_1);
    }
  }
}

function $handle$045controls$058row_view_done$1260$(_id_0, _value_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _stamp_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _column_0, "snd": {$: "handle-controls.RowView", "index": _id_0, "value": _value_0, "stamp": _stamp_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$((_key_0 === _id_0), _stamp_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $handle$045application$058component_entity_error$1260$(_world_0, _error_0, _projected_0) {
  const _payload_0 = _projected_0["fst"];
  const _canonical_0 = _projected_0["snd"];
  return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "Some", "value": _payload_0}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": _error_0}}};
}

function $handle$045application$058project$1260$(_payload_0) {
  const _cells_0 = _payload_0["cells"];
  const _name_0 = _payload_0["name"];
  const _target_0 = _payload_0["target"];
  return $handle$045application$058project_join$1260$(_name_0, _target_0, ($handle$045application$058array_project$(_cells_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1260$($0, $1, $2, $3) {
  for (;;) {
    {
      const _prepared_0 = $0;
      const _commands_0 = $1;
      const _current_0 = $2;
      const _tx_0 = $3;
      if (_prepared_0.$ === "Nil") {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058remaining$1260$(_commands_0, _tx_0);
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          $1 = _commands_0;
          $2 = _current_0;
          $3 = _tx_0;
          continue;
        } else {
          const _target_1 = _t_0["target"];
          const _payload_0 = _t_0["payload"];
          const _position_0 = _t_0["position"];
          const _tail_1 = _prepared_0["tail"];
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged_after$1260$(_target_1, _payload_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1260$(_tail_1, _x_0, _position_0, _x_1);
});
}), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058preceding$1260$((_position_0 < _current_0 ? 0 : _position_0 - _current_0), _commands_0, _tx_0)));
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058constructed$1260$(_ctx_0, _operation_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid") {
    const _owner_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _owner_1 = _result_0["cooked"];
    const _undo_0 = _result_0["undo"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058returned$1260$(_undo_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1261$(_ctx_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Input", "operation": _operation_0, "owner": _owner_1})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1260$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(_inputCodec_0, _input_0)));
}

function $handle$045application$058component_factory$1260$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1260$(($handle$045application$058component_declaration$1260$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058constructed$1260$(_ctx_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid") {
    const _owner_0 = _value_0["raw"];
    const _error_0 = _value_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _owner_1 = _value_0["cooked"];
    const _undo_0 = _value_0["undo"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058returned$1260$(_undo_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1263$(_ctx_0, _owner_1)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1261$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(_inputCodec_0, _input_0)));
}

function $handle$045application$058resource_factory$1260$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1261$(($handle$045application$058resource_declaration$1260$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1260$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incomingPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1260$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $handle$045application$058take$1260$(_column_0) {
  return {$: "Tuple", "fst": {$: "Unit"}, "snd": _column_0};
}

function $handle$045controls$058row_view_done$1261$(_id_0, _value_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _stamp_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _column_0, "snd": {$: "handle-controls.RowView", "index": _id_0, "value": _value_0, "stamp": _stamp_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1261$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1261$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $handle$045application$058component_entity_error$1261$(_world_0, _error_0, _projected_0) {
  const _payload_0 = _projected_0["fst"];
  const _canonical_0 = _projected_0["snd"];
  return {$: "handle-application.Outcome", "world": _world_0, "incoming": {$: "Some", "value": _payload_0}, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _canonical_0}, "host": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": _error_0}}};
}

function $handle$045application$058project$1261$(_payload_0) {
  const _cells_0 = _payload_0["cells"];
  const _name_0 = _payload_0["name"];
  const _target_0 = _payload_0["target"];
  return $handle$045application$058project_join$1261$(_name_0, _target_0, ($handle$045application$058array_project$(_cells_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1261$($0, $1, $2, $3) {
  for (;;) {
    {
      const _prepared_0 = $0;
      const _commands_0 = $1;
      const _current_0 = $2;
      const _tx_0 = $3;
      if (_prepared_0.$ === "Nil") {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058remaining$1261$(_commands_0, _tx_0);
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          $1 = _commands_0;
          $2 = _current_0;
          $3 = _tx_0;
          continue;
        } else {
          const _target_1 = _t_0["target"];
          const _payload_0 = _t_0["payload"];
          const _position_0 = _t_0["position"];
          const _tail_1 = _prepared_0["tail"];
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged_after$1261$(_target_1, _payload_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged$1261$(_tail_1, _x_0, _position_0, _x_1);
});
}), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058preceding$1261$((_position_0 < _current_0 ? 0 : _position_0 - _current_0), _commands_0, _tx_0)));
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058constructed$1261$(_ctx_0, _operation_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid") {
    const _owner_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _owner_1 = _result_0["cooked"];
    const _undo_0 = _result_0["undo"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058returned$1261$(_undo_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1265$(_ctx_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Input", "operation": _operation_0, "owner": _owner_1})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1262$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1263$(_inputCodec_0, _input_0)));
}

function $handle$045application$058component_factory$1261$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1262$(($handle$045application$058component_declaration$1261$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058constructed$1261$(_ctx_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid") {
    const _owner_0 = _value_0["raw"];
    const _error_0 = _value_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _owner_1 = _value_0["cooked"];
    const _undo_0 = _value_0["undo"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058returned$1261$(_undo_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1267$(_ctx_0, _owner_1)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1263$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1263$(_inputCodec_0, _input_0)));
}

function $handle$045application$058resource_factory$1261$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1263$(($handle$045application$058resource_declaration$1261$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1261$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1261$(_rest_0, _id_0, _incomingPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1261$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $handle$045application$058take$1261$(_column_0) {
  return {$: "Tuple", "fst": {$: "Unit"}, "snd": _column_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$(_found_0, _stamp_0, _other_0) {
  if (_found_0) {
    return _stamp_0;
  } else {
    return _other_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)), (_id_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, ($handle$045application$058project$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($handle$045application$058project$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($handle$045application$058project$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $handle$045application$058project_join$1260$(_name_0, _target_0, _observed_0) {
  const _cells_0 = _observed_0["fst"];
  const _items_0 = _observed_0["snd"];
  return $handle$045application$058project_target$1260$(_name_0, _cells_0, _items_0, _target_0);
}

function $handle$045application$058array_project$(_cells_0) {
  if (_cells_0.length === 1) {
    const _value_0 = _cells_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": _value_0}, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _cells_0.slice(0, _cells_0.length >> 1);
    const _right_0 = _cells_0.slice(_cells_0.length >> 1);
    return $handle$045application$058array_join$(($handle$045application$058array_project$(_left_0)), ($handle$045application$058array_project$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058remaining$1260$($0, $1) {
  for (;;) {
    {
      const _commands_0 = $0;
      const _tx_0 = $1;
      if (_commands_0.$ === "Nil") {
        return _tx_0;
      } else {
        const _command_0 = _commands_0["head"];
        const _tail_0 = _commands_0["tail"];
        $0 = _tail_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_tx_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged_after$1260$(_target_0, _payload_0, _next_0, _result_0) {
  const _after_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return run_tail(_next_0(_after_0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058enqueue$1260$(_before_0, _target_0, _payload_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058preceding$1260$($0, $1, $2) {
  for (;;) {
    {
      const _count_0 = $0;
      const _commands_0 = $1;
      const _tx_0 = $2;
      if (_count_0 === 0) {
        return {$: "Tuple", "fst": _commands_0, "snd": _tx_0};
      } else {
        const _rest_0 = (_count_0 - 1);
        if (_commands_0.$ === "Nil") {
          return {$: "Tuple", "fst": {$: "Nil"}, "snd": _tx_0};
        } else {
          const _command_0 = _commands_0["head"];
          const _tail_0 = _commands_0["tail"];
          $0 = _rest_0;
          $1 = _tail_0;
          $2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_tx_0, _command_0));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058returned$1260$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted") {
    const _target_0 = _t_0["target"];
    const _spawned_0 = _t_0["spawned"];
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Accepted", "target": _target_0, "spawned": _spawned_0, "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058refused$1260$(_undo_0, _owner_0, _error_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1261$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_grant$1260$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(_receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid", "raw": _owner_0, "error": _error_0};
  } else {
    const _canonical_0 = _t_0["value"];
    return $handle$045application$058build$1260$(_owner_0, _canonical_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1260$(_codec_0, ($handle$045application$058incoming$1260$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1260$(_declaration_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1260$(_declaration_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058returned$1260$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced") {
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Replaced", "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Refused", "owner": _undo_0(_owner_0), "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1263$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1260$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1261$(_declaration_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1261$(_declaration_0))};
}

function $handle$045application$058resource_declaration$1260$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$(($handle$045application$058codec$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incoming_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _previous_0 = _result_0["previous"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_previous_0)));
  } else {
    const _column_1 = _result_0["column"];
    const _incoming_1 = _result_0["incoming"];
    return {$: "Tuple", "fst": ($handle$045application$058put$1260$(_rest_0, _column_1)), "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/component.SwapRejected", "incoming": _incoming_1}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1260$(_column_0, _target_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, ($Bool$and$((_target_0 > 0), (_target_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1261$(_values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1261$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, ($handle$045application$058project$1261$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($handle$045application$058project$1261$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1261$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($handle$045application$058project$1261$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1261$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $handle$045application$058project_join$1261$(_name_0, _target_0, _observed_0) {
  const _cells_0 = _observed_0["fst"];
  const _items_0 = _observed_0["snd"];
  return $handle$045application$058project_target$1261$(_name_0, _cells_0, _items_0, _target_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1261$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1261$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$(_undo_0, _world_0)), "outcome": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058remaining$1261$($0, $1) {
  for (;;) {
    {
      const _commands_0 = $0;
      const _tx_0 = $1;
      if (_commands_0.$ === "Nil") {
        return _tx_0;
      } else {
        const _command_0 = _commands_0["head"];
        const _tail_0 = _commands_0["tail"];
        $0 = _tail_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1261$(_tx_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058staged_after$1261$(_target_0, _payload_0, _next_0, _result_0) {
  const _after_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return run_tail(_next_0(_after_0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058enqueue$1261$(_before_0, _target_0, _payload_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058preceding$1261$($0, $1, $2) {
  for (;;) {
    {
      const _count_0 = $0;
      const _commands_0 = $1;
      const _tx_0 = $2;
      if (_count_0 === 0) {
        return {$: "Tuple", "fst": _commands_0, "snd": _tx_0};
      } else {
        const _rest_0 = (_count_0 - 1);
        if (_commands_0.$ === "Nil") {
          return {$: "Tuple", "fst": {$: "Nil"}, "snd": _tx_0};
        } else {
          const _command_0 = _commands_0["head"];
          const _tail_0 = _commands_0["tail"];
          $0 = _rest_0;
          $1 = _tail_0;
          $2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1261$(_tx_0, _command_0));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058returned$1261$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted") {
    const _target_0 = _t_0["target"];
    const _spawned_0 = _t_0["spawned"];
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Accepted", "target": _target_0, "spawned": _spawned_0, "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058refused$1261$(_undo_0, _owner_0, _error_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1265$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1265$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_grant$1261$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1261$(_receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid", "raw": _owner_0, "error": _error_0};
  } else {
    const _canonical_0 = _t_0["value"];
    return $handle$045application$058build$1261$(_owner_0, _canonical_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1263$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1261$(_codec_0, ($handle$045application$058incoming$1261$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1262$(_declaration_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1262$(_declaration_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045resource$058returned$1261$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced") {
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Replaced", "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-resource.Refused", "owner": _undo_0(_owner_0), "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1267$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1267$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1261$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1263$(_declaration_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1263$(_declaration_0))};
}

function $handle$045application$058resource_declaration$1261$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$(($handle$045application$058codec$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1261$(_rest_0, _id_0, _incoming_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _previous_0 = _result_0["previous"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1261$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_previous_0)));
  } else {
    const _column_1 = _result_0["column"];
    const _incoming_1 = _result_0["incoming"];
    return {$: "Tuple", "fst": ($handle$045application$058put$1261$(_rest_0, _column_1)), "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/component.SwapRejected", "incoming": _incoming_1}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1261$(_column_0, _target_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1261$(_column_0, _target_0, ($Bool$and$((_target_0 > 0), (_target_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0, _fits_0) {
  if (!_isnormal_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_exceptional_0, _id_0))};
  } else {
    if (!_fits_0) {
      return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
    } else {
      const _x_0 = ((_id_0 - 1) >>> 0);
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, {$: "Tuple", fst: _added_0, snd: _added_0[_x_0 % _added_0.length]});
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0) {
  return $Bool$and$((_id_0 > 0), (_id_0 <= 131072));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1260$(($handle$045application$058project$1260$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _remaining_0 = $5;
      const _past_0 = $6;
      const _phase_0 = $7;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($handle$045application$058project$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, ($handle$045application$058project$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _remaining_0 = $5;
      const _past_0 = $6;
      const _phase_0 = $7;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($handle$045application$058project$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $handle$045application$058project_target$1260$(_name_0, _cells_0, _items_0, _target_0) {
  if (_target_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "None"}}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "tail": {$: "Nil"}}}}}};
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    return {$: "Tuple", "fst": {$: "handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _id_0}}}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _namespace_0, "id": _id_0}}, "tail": {$: "Nil"}}}}}};
  }
}

function $handle$045application$058array_join$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1260$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1260$(_commands_0, _world_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1260$(_world_0, _events_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1260$(_world_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$($0, $1) {
  for (;;) {
    {
      const _undo_0 = $0;
      const _world_0 = $1;
      if (_undo_0.$ === "Nil") {
        return _world_0;
      } else {
        const _inverse_0 = _undo_0["head"];
        const _rest_0 = _undo_0["tail"];
        $0 = _rest_0;
        $1 = _inverse_0(_world_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_tx_0, _command_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": _command_0, "tail": _commands_0}, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058enqueue$1260$(_tx_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_tx_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply$1260$(_x_0, _handle_0, _payload_0);
}));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058refused$1260$(_undo_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "None"}, "error": _error_0};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "Some", "value": _undo_0(_owner_1)}, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_grant$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request$1260$(_x_0, _x_1);
});
})};
}

function $handle$045application$058build$1260$(_payload_0, _canonical_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Constructed", "cooked": _payload_0, "undo": run_clo((_x_0) => {
  return $handle$045application$058reverse$1260$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1260$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $handle$045application$058incoming$1260$(_payload_0) {
  return $handle$045application$058project$1260$(_payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1260$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1260$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(($handle$045application$058resource_declaration$1260$(1)), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1261$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$(_codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, _observed_0) {
  const _previous_0 = _observed_0["fst"];
  const _wasPresent_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($handle$045application$058put$1260$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0)))), "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/component.Swapped", "previous": _previous_0}};
}

function $handle$045application$058put$1260$(_unit_0, _column_0) {
  return _column_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, _valid_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
    }
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
    }
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
    }
  } else {
    const _carrier_2 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1261$(($handle$045application$058project$1261$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_0)));
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _remaining_0 = $5;
      const _past_0 = $6;
      const _phase_0 = $7;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($handle$045application$058project$1261$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, ($handle$045application$058project$1261$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _remaining_0 = $5;
      const _past_0 = $6;
      const _phase_0 = $7;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($handle$045application$058project$1261$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $handle$045application$058project_target$1261$(_name_0, _cells_0, _items_0, _target_0) {
  if (_target_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "None"}}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "tail": {$: "Nil"}}}}}};
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    return {$: "Tuple", "fst": {$: "handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "Some", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _id_0}}}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _namespace_0, "id": _id_0}}, "tail": {$: "Nil"}}}}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1261$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1261$(_commands_0, _world_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1261$(_world_0, _events_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$($0, $1) {
  for (;;) {
    {
      const _undo_0 = $0;
      const _world_0 = $1;
      if (_undo_0.$ === "Nil") {
        return _world_0;
      } else {
        const _inverse_0 = _undo_0["head"];
        const _rest_0 = _undo_0["tail"];
        $0 = _rest_0;
        $1 = _inverse_0(_world_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1261$(_tx_0, _command_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": _command_0, "tail": _commands_0}, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058enqueue$1261$(_tx_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1261$(_tx_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply$1261$(_x_0, _handle_0, _payload_0);
}));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045constructed$045requests$058refused$1261$(_undo_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "None"}, "error": _error_0};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-constructed-requests.Refused", "owner": {$: "Some", "value": _undo_0(_owner_1)}, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1265$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_grant$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request$1261$(_x_0, _x_1);
});
})};
}

function $handle$045application$058build$1261$(_payload_0, _canonical_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Constructed", "cooked": _payload_0, "undo": run_clo((_x_0) => {
  return $handle$045application$058reverse$1261$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1261$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $handle$045application$058incoming$1261$(_payload_0) {
  return $handle$045application$058project$1261$(_payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1262$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1267$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1261$() {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(($handle$045application$058resource_declaration$1261$(1)), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1263$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$(_codec_0) {
  return {$: "../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1261$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, _observed_0) {
  const _previous_0 = _observed_0["fst"];
  const _wasPresent_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($handle$045application$058put$1261$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1261$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0)))), "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/component.Swapped", "previous": _previous_0}};
}

function $handle$045application$058put$1261$(_unit_0, _column_0) {
  return _column_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1261$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1261$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1261$(_column_0, _target_0, _valid_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
    }
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
    }
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
    }
  } else {
    const _carrier_2 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _observed_0) {
  const _added_0 = _observed_0["fst"];
  const _first_0 = _observed_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, {$: "Tuple", fst: _changed_0, snd: _changed_0[_x_0 % _changed_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1260$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$($0, $1) {
  for (;;) {
    {
      const _rows_0 = $0;
      const _values_0 = $1;
      if (_rows_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
        return _values_0;
      } else {
        const _id_0 = _rows_0["id"];
        const _owner_0 = _rows_0["owner"];
        const _rest_0 = _rows_0["rest"];
        const _x_0 = ((_id_0 - 1) >>> 0);
        const _x_1 = {$: "Some", "value": _owner_0};
        $0 = _rest_0;
        $1 = (_values_0[_x_0 % _values_0.length] = _x_1, _values_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.HistoryNil") {
        return _values_0;
      } else {
        const _id_0 = _past_0["id"];
        const _owner_0 = _past_0["value"];
        const _rest_0 = _past_0["rest"];
        const _x_0 = ((_id_0 - 1) >>> 0);
        $0 = _rest_0;
        $1 = (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1260$($0, $1) {
  for (;;) {
    {
      const _commands_0 = $0;
      const _world_0 = $1;
      if (_commands_0.$ === "Nil") {
        return _world_0;
      } else {
        const _command_0 = _commands_0["head"];
        const _rest_0 = _commands_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply$1260$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply_checked$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request$1260$(_frame_0, _input_0) {
  const _owner_0 = _frame_0["owner"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_join$1260$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058request$1260$(_owner_0, _input_0)));
}

function $handle$045application$058reverse$1260$(_payload_0) {
  return _payload_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_raw_0));
  const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_codec_0));
  const _x_2 = nat_chk(_x_0 + 1);
  const _x_3 = nat_chk(_x_1 * _x_2);
  return nat_chk(4 * _x_3);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(_declaration_0, _frame_0, _replacement_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1260$(_frame_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1261$(_declaration_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1260$(17, _values_0, _stamps_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1261$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.HistoryNil") {
        return _values_0;
      } else {
        const _id_0 = _past_0["id"];
        const _owner_0 = _past_0["value"];
        const _rest_0 = _past_0["rest"];
        const _x_0 = ((_id_0 - 1) >>> 0);
        $0 = _rest_0;
        $1 = (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1261$($0, $1) {
  for (;;) {
    {
      const _commands_0 = $0;
      const _world_0 = $1;
      if (_commands_0.$ === "Nil") {
        return _world_0;
      } else {
        const _command_0 = _commands_0["head"];
        const _rest_0 = _commands_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1261$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply$1261$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply_checked$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request$1261$(_frame_0, _input_0) {
  const _owner_0 = _frame_0["owner"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_join$1261$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058request$1261$(_owner_0, _input_0)));
}

function $handle$045application$058reverse$1261$(_payload_0) {
  return _payload_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(_declaration_0, _frame_0, _replacement_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1261$(_frame_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1263$(_declaration_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1261$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1261$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1261$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1261$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1261$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1261$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1261$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1261$(17, _values_0, _stamps_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1261$(_target_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, _observed_0) {
  const _changed_0 = _observed_0["fst"];
  const _last_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _first_0, "changed": _last_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_view_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply_checked$1260$(_observed_0, _handle_0, _payload_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $handle$045application$058recover$1260$(_world_0, _payload_0, {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"});
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058deliver$1260$(($handle$045application$058attempt$1260$(_world_0, _handle_0, _payload_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_join$1260$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _output_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _output_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058request$1260$(_frame_0, _input_0) {
  const _batch_0 = _frame_0["batch"];
  const _declaration_0 = _frame_0["declaration"];
  const _operation_0 = _input_0["operation"];
  const _owner_0 = _input_0["owner"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058validated$1260$(_declaration_0, _batch_0, _operation_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1260$(_declaration_0, _owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$(_fuel_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_codec_0) {
  if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
    const _inner_0 = _codec_0["inner"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_inner_0));
    return nat_chk(1 + _x_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
    const _inner_1 = _codec_0["inner"];
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_inner_1));
    return nat_chk(1 + _x_1);
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
    const _t_0 = _codec_0["fields"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _t_1 = _t_0["head"];
      const _child_0 = _t_1["codec"];
      const _rest_0 = _t_0["tail"];
      const _x_2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_child_0));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": _rest_0}));
      const _x_4 = nat_chk(_x_2 + _x_3);
      return nat_chk(1 + _x_4);
    }
  } else {
    return 1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1260$(_frame_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1260$(_canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1260$(_frame_0, _owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1261$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1261$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_entries_0, _id_0, _stamp_0) {
  return {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _id_0, "stamp": _stamp_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0) {
  if (!_incoming_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$(_column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _incoming_0 = $5;
      const _remaining_0 = $6;
      const _past_0 = $7;
      const _phase_0 = $8;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _incoming_0 = $5;
      const _remaining_0 = $6;
      const _past_0 = $7;
      const _phase_0 = $8;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1260$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _size_0 = $3;
      const _depth_0 = $4;
      const _target_0 = $5;
      const _enough_0 = $6;
      if (_fuel_0 === 0) {
        if (_enough_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0)));
          $2 = _stamps_0;
          $3 = _next_0;
          $4 = nat_chk(_depth_0 + 1);
          $5 = _target_0;
          $6 = (_target_0 <= _next_0);
          continue;
        }
      }
    }
  }
}

function $U32$log2$(_n_0) {
  return $U32$log2$go$(5, _n_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, _column_0, _fits_0) {
  if (_fits_0) {
    return _column_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$(_column_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1260$(17, _values_0, _metadata_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_view_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058apply_checked$1261$(_observed_0, _handle_0, _payload_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $handle$045application$058recover$1261$(_world_0, _payload_0, {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"});
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058deliver$1261$(($handle$045application$058attempt$1261$(_world_0, _handle_0, _payload_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058request_join$1261$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _output_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _output_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058request$1261$(_frame_0, _input_0) {
  const _batch_0 = _frame_0["batch"];
  const _declaration_0 = _frame_0["declaration"];
  const _operation_0 = _input_0["operation"];
  const _owner_0 = _input_0["owner"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058validated$1261$(_declaration_0, _batch_0, _operation_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1262$(_declaration_0, _owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$(_fuel_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1261$(_frame_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1261$(_canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1261$(_frame_0, _owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1263$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1263$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1261$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$(_column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1261$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _incoming_0 = $5;
      const _remaining_0 = $6;
      const _past_0 = $7;
      const _phase_0 = $8;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1261$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1261$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1261$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _capacity_0 = $3;
      const _target_0 = $4;
      const _incoming_0 = $5;
      const _remaining_0 = $6;
      const _past_0 = $7;
      const _phase_0 = $8;
      if (_fuel_0 === 0) {
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1261$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _stamps_0 = $2;
      const _size_0 = $3;
      const _depth_0 = $4;
      const _target_0 = $5;
      const _enough_0 = $6;
      if (_fuel_0 === 0) {
        if (_enough_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0)));
          $2 = _stamps_0;
          $3 = _next_0;
          $4 = nat_chk(_depth_0 + 1);
          $5 = _target_0;
          $6 = (_target_0 <= _next_0);
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, _column_0, _fits_0) {
  if (_fits_0) {
    return _column_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$(_column_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1261$(_target_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1261$(17, _values_0, _metadata_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $handle$045application$058recover$1260$(_world_0, _packet_0, _error_0) {
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058deliver$1260$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Delivered") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return $handle$045application$058recover$1260$(_world_1, _payload_0, _error_0);
  }
}

function $handle$045application$058attempt$1260$(_world_0, _target_0, _packet_0) {
  const _owner_0 = _packet_0["owner"];
  const _original_0 = _packet_0["original"];
  const _canonical_0 = _packet_0["canonical"];
  return $handle$045application$058replacement_result$1260$(_original_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1260$(($handle$045application$058family$1260$()), _world_0, _target_0, _owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058validated$1260$(_declaration_0, _batch_0, _operation_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue$1260$(_declaration_0, _batch_0, _operation_0, _canonical_0, ($handle$045application$058project$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1260$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1260$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _codec_0 = $1;
      const _raw_0 = $2;
      if (_fuel_0 === 0) {
        return _raw_0;
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
          const _inner_0 = _codec_0["inner"];
          if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"};
          } else {
            $0 = _more_0;
            $1 = _inner_0;
            $2 = _raw_0;
            continue;
          }
        } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
          const __0 = _codec_0["inner"];
          if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
            const _t_0 = _raw_0["items"];
            if (_t_0.$ === "Nil") {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": {$: "Nil"}};
            } else {
              const _head_0 = _t_0["head"];
              const _tail_0 = _t_0["tail"];
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_array_join$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, __0, _head_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue", "inner": __0}, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _tail_0})));
            }
          } else {
            return _raw_0;
          }
        } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
          const _t_1 = _codec_0["fields"];
          if (_t_1.$ === "Nil") {
            if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
              return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Nil"}};
            } else {
              return _raw_0;
            }
          } else {
            const _t_2 = _t_1["head"];
            const _name_0 = _t_2["name"];
            const _codec_1 = _t_2["codec"];
            const _rest_0 = _t_1["tail"];
            if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
              const _values_0 = _raw_0["fields"];
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_struct_join$(_name_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, _codec_1, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _values_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": _rest_0}, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": _values_0})));
            } else {
              return _raw_0;
            }
          }
        } else {
          return _raw_0;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _step_0 = $1;
      const _original_0 = $2;
      if (_fuel_0 === 0) {
        if (_step_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop") {
          const _error_0 = _step_0["error"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0};
        } else {
          const _t_0 = _step_0["work"];
          if (_t_0.$ === "Nil") {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_1 = _t_0["head"];
            const _path_0 = _t_1["path"];
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.FuelExhausted", "path": _path_0}};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_step_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop") {
          const _error_1 = _step_0["error"];
          return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_1};
        } else {
          const _t_2 = _step_0["work"];
          if (_t_2.$ === "Nil") {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_3 = _t_2["head"];
            const _codec_0 = _t_3["codec"];
            const _raw_0 = _t_3["raw"];
            const _path_1 = _t_3["path"];
            const _rest_0 = _t_2["tail"];
            $0 = _more_0;
            $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_1, _rest_0));
            $2 = _original_0;
            continue;
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1260$(_canonical_0, _result_0) {
  const _frame_0 = _result_0["fst"];
  return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced", "canonical": _canonical_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1260$(_frame_0, _replacement_0) {
  const _t_0 = _frame_0["owner"];
  const _t_1 = _t_0["batch"];
  const _tx_0 = _t_1["tx"];
  const _prepared_0 = _t_1["prepared"];
  const _declaration_0 = _t_0["declaration"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1260$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1260$(_tx_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1260$(_codec_0, ($handle$045application$058project$1260$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$((_key_0 === _id_0), {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _key_0, "stamp": _stamp_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0) {
  if (!_wasPresent_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _tick_0, "changed": _tick_0};
  } else {
    const _added_0 = _stamp_0["added"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _added_0, "changed": _tick_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0) {
  if (_depth_0 === 0) {
    return [{$: "None"}];
  } else {
    const _rest_0 = (_depth_0 - 1);
    return array_node(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_rest_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_rest_0)));
  }
}

function $U32$log2$go$($0, $1, $2) {
  for (;;) {
    {
      const _k_0 = $0;
      const _n_0 = $1;
      const _b_0 = $2;
      if (_k_0 === 0) {
        return _b_0;
      } else {
        const _p_0 = (_k_0 - 1);
        const _x_0 = (_p_0 >= 32 ? 0 : (1 << _p_0) >>> 0);
        const _s_0 = _x_0;
        const _x_1 = (_s_0 >= 32 ? 0 : (_n_0 >>> _s_0) >>> 0);
        const _x_2 = ($Bool$to_u32$((_x_1 !== 0)));
        const _t_0 = nat_chk(_s_0 * _x_2);
        $0 = _p_0;
        $1 = (_t_0 >= 32 ? 0 : (_n_0 >>> _t_0) >>> 0);
        $2 = nat_chk(_b_0 + _t_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return _column_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1260$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _size_0 = $3;
      const _depth_0 = $4;
      const _target_0 = $5;
      const _enough_0 = $6;
      if (_fuel_0 === 0) {
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0)));
          $2 = _metadata_0;
          $3 = _next_0;
          $4 = nat_chk(_depth_0 + 1);
          $5 = _target_0;
          $6 = (_target_0 <= _next_0);
          continue;
        }
      }
    }
  }
}

function $handle$045application$058recover$1261$(_world_0, _packet_0, _error_0) {
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045delivery$058deliver$1261$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Delivered") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return $handle$045application$058recover$1261$(_world_1, _payload_0, _error_0);
  }
}

function $handle$045application$058attempt$1261$(_world_0, _target_0, _packet_0) {
  const _owner_0 = _packet_0["owner"];
  const _original_0 = _packet_0["original"];
  const _canonical_0 = _packet_0["canonical"];
  return $handle$045application$058replacement_result$1261$(_original_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1261$(($handle$045application$058family$1261$()), _world_0, _target_0, _owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058validated$1261$(_declaration_0, _batch_0, _operation_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue$1261$(_declaration_0, _batch_0, _operation_0, _canonical_0, ($handle$045application$058project$1261$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1262$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1262$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1261$(_canonical_0, _result_0) {
  const _frame_0 = _result_0["fst"];
  return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced", "canonical": _canonical_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1261$(_frame_0, _replacement_0) {
  const _t_0 = _frame_0["owner"];
  const _t_1 = _t_0["batch"];
  const _tx_0 = _t_1["tx"];
  const _prepared_0 = _t_1["prepared"];
  const _declaration_0 = _t_0["declaration"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1261$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1261$(_tx_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1262$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1261$(_codec_0, ($handle$045application$058project$1261$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1261$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1261$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1261$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0) {
  if (_depth_0 === 0) {
    return [{$: "None"}];
  } else {
    const _rest_0 = (_depth_0 - 1);
    return array_node(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_rest_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1261$(_target_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_0)));
  } else {
    return _column_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1261$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _values_0 = $1;
      const _metadata_0 = $2;
      const _size_0 = $3;
      const _depth_0 = $4;
      const _target_0 = $5;
      const _enough_0 = $6;
      if (_fuel_0 === 0) {
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        } else {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0)));
          $2 = _metadata_0;
          $3 = _next_0;
          $4 = nat_chk(_depth_0 + 1);
          $5 = _target_0;
          $6 = (_target_0 <= _next_0);
          continue;
        }
      }
    }
  }
}

function $handle$045application$058replacement_result$1260$(_original_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Delivered", "world": _world_0};
  } else {
    const _world_1 = _result_0["world"];
    const _incoming_0 = _result_0["incoming"];
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Undelivered", "world": _world_1, "payload": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": _incoming_0, "original": _original_0, "canonical": _canonical_0}, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue$1260$(_declaration_0, _batch_0, _operation_0, _canonical_0, _projected_0) {
  const _owner_0 = _projected_0["fst"];
  const _original_0 = _projected_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue_packet$1260$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_array_join$(_head_0, _tail_0) {
  if (_tail_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _values_0 = _tail_0["items"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": {$: "Con", "head": _head_0, "tail": _values_0}};
  } else {
    return _tail_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_struct_join$(_name_0, _head_0, _tail_0) {
  if (_tail_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
    const _fields_0 = _tail_0["fields"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": _name_0, "value": _head_0}, "tail": _fields_0}};
  } else {
    return _tail_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Missing"};
  } else {
    const _t_0 = _fields_0["head"];
    const _key_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _fields_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field_choose$(($String$eq$(_name_0, _key_0)), _value_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _rest_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_0, _rest_0) {
  if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer") {
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
      const __1 = _raw_0["negative"];
      const _magnitude_0 = _raw_0["magnitude"];
      const _x_0 = ($Nat$div$(_magnitude_0, nat_chk(65536 * 65536)));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_0 < 2097152), _path_0, "integer", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger", "negative": __1, "magnitude": _magnitude_0}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
      const _value_0 = _raw_0["value"];
      const _x_1 = Math.fround(Math.floor(_value_0));
      const _x_2 = Math.fround(Math.abs(_value_0));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($Bool$and$((_x_1 === _value_0), (_x_2 < 9007199254740992))), _path_0, "integer", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": _value_0}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
      const _high_0 = _raw_0["high"];
      const _low_0 = _raw_0["low"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer$(_high_0, _low_0)), _path_0, "integer", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": _high_0, "low": _low_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "integer", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber") {
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
      const _value_1 = _raw_0["value"];
      const _x_3 = Math.fround(Math.abs(_value_1));
      const _x_4 = 3.4028234663852886e+38;
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_3 <= _x_4), _path_0, "finite number", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": _value_1}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
      const _high_1 = _raw_0["high"];
      const __5 = _raw_0["low"];
      const _x_5 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_1));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_5 < 2047), _path_0, "finite number", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": _high_1, "low": __5}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "finite number", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue") {
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _units_0 = _raw_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_units_0)), _path_0, "string", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": _units_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "string", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue") {
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "boolean", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Literal") {
    const _value_2 = _codec_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_value_2, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues") {
    const _values_0 = _codec_0["values"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_0, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered") {
    const _values_1 = _codec_0["values"];
    const _expected_0 = _codec_0["expected"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_1, _raw_0)), _path_0, _expected_0, _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
    const __8 = _codec_0["inner"];
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": __8, "raw": _raw_0, "path": _path_0}, "tail": _rest_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
    const _inner_0 = _codec_0["inner"];
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
      const _items_0 = _raw_0["items"];
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_inner_0, _items_0, _path_0, 0, _rest_0))};
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "array", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
    const _fields_0 = _codec_0["fields"];
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
      const _values_2 = _raw_0["fields"];
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_fields_0, _values_2, _path_0, _rest_0))};
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "object", "actual": _raw_0}};
    }
  } else {
    const _ns_0 = _codec_0["namespace"];
    if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle") {
      const _actual_0 = _raw_0["namespace"];
      const _id_0 = _raw_0["id"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($Bool$and$((_ns_0 === _actual_0), (_id_0 > 0))), _path_0, "same-world handle", {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _actual_0, "id": _id_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "same-world handle", "actual": _raw_0}};
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1260$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _tx_0) {
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": {$: "Unit"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1260$(_tx_0, _replacement_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _replacement_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$(_equal_0, _entry_0, _rest_0) {
  if (_equal_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _entry_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)));
}

function $Bool$to_u32$(_b_0) {
  if (!_b_0) {
    return 0;
  } else {
    return 1;
  }
}

function $handle$045application$058replacement_result$1261$(_original_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Delivered", "world": _world_0};
  } else {
    const _world_1 = _result_0["world"];
    const _incoming_0 = _result_0["incoming"];
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-delivery.Undelivered", "world": _world_1, "payload": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": _incoming_0, "original": _original_0, "canonical": _canonical_0}, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue$1261$(_declaration_0, _batch_0, _operation_0, _canonical_0, _projected_0) {
  const _owner_0 = _projected_0["fst"];
  const _original_0 = _projected_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue_packet$1261$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1261$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _tx_0) {
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": {$: "Unit"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1261$(_tx_0, _replacement_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _replacement_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue_packet$1260$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0) {
  if (_operation_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert") {
    const _target_0 = _operation_0["target"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058inserted$1260$(_declaration_0, _target_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058insert$1260$(_batch_0, _target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058spawned$1260$(_declaration_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn$1260$(_batch_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field_choose$(_equal_0, _value_0, _next_0) {
  if (_equal_0) {
    return _value_0;
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(_valid_0, _path_0, _expected_0, _raw_0, _rest_0) {
  if (_valid_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": _expected_0, "actual": _raw_0}};
  }
}

function $Nat$div$(_a_0, _b_0) {
  return $Pair$fst$(nat_divmod(_a_0, _b_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer$(_high_0, _low_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_0));
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0)), (_x_0 < 1076));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  return (2048 === 0 ? _x_0 : _x_0 % 2048);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    const _unit_0 = _units_0["head"];
    const _tail_0 = _units_0["tail"];
    return $Bool$and$((_unit_0 <= 65535), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
      return true;
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
    const _a_1 = _a_0["value"];
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      const _b_1 = _b_0["value"];
      return $String$eq$(_a_1, _b_1);
    } else if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _b_2 = _b_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_a_1)), _b_2);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _a_1})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
    const _a_2 = _a_0["units"];
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _b_3 = _b_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_a_2, _b_3);
    } else if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      const _b_4 = _b_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_a_2, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_b_4)));
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": _a_2})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
    const _a_3 = _a_0["value"];
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
      const _b_5 = _b_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_3, _b_5);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": _a_3})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_a_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_0, _raw_0) {
  if (_values_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _values_0["head"];
    const _tail_0 = _values_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_value_0, _raw_0));
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_tail_0, _raw_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_codec_0, _items_0, _path_0, _index_0, _rest_0) {
  if (_items_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _value_0 = _items_0["head"];
    const _tail_0 = _items_0["tail"];
    const _x_0 = ($U32$show$(_index_0));
    const _x_1 = (_x_0 + "]");
    const _x_2 = ("[" + _x_1);
    return {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _value_0, "path": (_path_0 + _x_2)}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_codec_0, _tail_0, _path_0, ((_index_0 + 1) >>> 0), _rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_fields_0, _values_0, _path_0, _rest_0) {
  if (_fields_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _t_0 = _fields_0["head"];
    const _name_0 = _t_0["name"];
    const _codec_0 = _t_0["codec"];
    const _tail_0 = _fields_0["tail"];
    const _x_0 = ("." + _name_0);
    return {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _values_0)), "path": (_path_0 + _x_0)}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_tail_0, _values_0, _path_0, _rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1260$(_replaced_0, _undo_0, _commands_0, _events_0) {
  const _world_0 = _replaced_0["fst"];
  const _old_0 = _replaced_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1260$(_x_0, _old_0);
}), "tail": _undo_0}, "commands": _commands_0, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _replacement_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _replacement_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _resource_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0) {
  if (!_isnormal_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_exceptional_0, _id_0, _stamp_0))};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$(17, _id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, (_id_0 <= _capacity_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058enqueue_packet$1261$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0) {
  if (_operation_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-requests.Insert") {
    const _target_0 = _operation_0["target"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058inserted$1261$(_declaration_0, _target_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058insert$1261$(_batch_0, _target_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058spawned$1261$(_declaration_0, _canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn$1261$(_batch_0, {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1261$(_replaced_0, _undo_0, _commands_0, _events_0) {
  const _world_0 = _replaced_0["fst"];
  const _old_0 = _replaced_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1261$(_x_0, _old_0);
}), "tail": _undo_0}, "commands": _commands_0, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _replacement_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _replacement_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _resource_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058inserted$1260$(_declaration_0, _target_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted", "target": _target_0, "spawned": false, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058insert$1260$(_batch_0, _target_0, _payload_0) {
  const _t_0 = _batch_0["tx"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _prepared_0 = _batch_0["prepared"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058checked$1260$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _target_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058spawned$1260$(_declaration_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Spawned") {
    const _batch_0 = _result_0["batch"];
    const _target_0 = _result_0["target"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted", "target": _target_0, "spawned": true, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn$1260$(_batch_0, _payload_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_reserved$1260$(_prepared_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_spawn$1260$(_tx_0, {$: "Unit"})));
}

function $Cmp$is_eq$(_c_0) {
  if (_c_0.$ === "EQ") {
    return true;
  } else {
    return false;
  }
}

function $String$order$(_a_0, _b_0) {
  return $Pair$snd$(($String$cmp$(_a_0, _b_0)));
}

function $Pair$fst$(_p_0) {
  const _a_0 = _p_0["fst"];
  return _a_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_checked$(_result_0, _small_0) {
  return $Bool$and$(_small_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_normal$(_result_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_1 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_2 = (2048 === 0 ? _x_1 : _x_1 % 2048);
  const _x_3 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_4 = (2048 === 0 ? _x_3 : _x_3 % 2048);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_parts$((_high_0 >= 2147483648), (2048 === 0 ? _x_0 : _x_0 % 2048), (1048576 === 0 ? _high_0 : _high_0 % 1048576), _low_0, (_x_2 === 2047), (_x_4 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
    const _an_0 = _a_0["negative"];
    const _ah_0 = _a_0["high"];
    const _al_0 = _a_0["low"];
    const _ae_0 = _a_0["exponent"];
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
      const _bn_0 = _b_0["negative"];
      const _bh_0 = _b_0["high"];
      const _bl_0 = _b_0["low"];
      const _be_0 = _b_0["exponent"];
      return $Bool$and$(($Bool$and$(($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_an_0, _bn_0)), (_ah_0 === _bh_0))), (_al_0 === _bl_0))), (_ae_0 === _be_0));
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity") {
    const _a_1 = _a_0["negative"];
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity") {
      const _b_1 = _b_0["negative"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_1, _b_1);
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN") {
    if (_b_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_raw_0) {
  if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
    const _value_0 = _raw_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, false, 0, _value_0, 1074);
  } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
    const _negative_0 = _raw_0["negative"];
    const _value_1 = _raw_0["magnitude"];
    const _x_0 = ($Nat$div$(_value_1, nat_chk(65536 * 65536)));
    const _x_1 = ($Nat$mod$(_value_1, nat_chk(65536 * 65536)));
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, (_x_0 >>> 0), (_x_1 >>> 0), 1074);
  } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
    const _value_2 = _raw_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_numeric$(f32_bits(_value_2));
  } else if (_raw_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
    const _high_0 = _raw_0["high"];
    const _low_0 = _raw_0["low"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0);
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.NotNumber"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_left_0, _right_0) {
  return $Bool$and$(($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_right_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_left_0, _right_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_value_0) {
  if (_value_0 === "") {
    return {$: "Nil"};
  } else {
    const _t_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(0, 2) : _value_0[0]);
    const _tail_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(2) : _value_0.slice(1));
    const _x_0 = _t_0.codePointAt(0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058scalar$(_t_0.codePointAt(0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_tail_0)), (_x_0 < 65536));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_0, _b_0) {
  if (_a_0) {
    if (_b_0) {
      return true;
    } else {
      return false;
    }
  } else {
    if (!_b_0) {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1260$(_world_0, _old_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _old_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _id_0 = $1;
      const _stamp_0 = $2;
      const _added_0 = $3;
      const _changed_0 = $4;
      const _capacity_0 = $5;
      const _depth_0 = $6;
      const _exceptional_0 = $7;
      const _fits_0 = $8;
      if (_fuel_0 === 0) {
        if (_fits_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
        } else {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_fits_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
        } else {
          const _next_0 = ((_capacity_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = _id_0;
          $2 = _stamp_0;
          $3 = array_node(_added_0, array_new(_depth_0, 0));
          $4 = array_node(_changed_0, array_new(_depth_0, 0));
          $5 = _next_0;
          $6 = nat_chk(_depth_0 + 1);
          $7 = _exceptional_0;
          $8 = (_id_0 <= _next_0);
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058inserted$1261$(_declaration_0, _target_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted", "target": _target_0, "spawned": false, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058insert$1261$(_batch_0, _target_0, _payload_0) {
  const _t_0 = _batch_0["tx"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _prepared_0 = _batch_0["prepared"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058checked$1261$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _target_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045requests$058spawned$1261$(_declaration_0, _canonical_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Spawned") {
    const _batch_0 = _result_0["batch"];
    const _target_0 = _result_0["target"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Accepted", "target": _target_0, "spawned": true, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn$1261$(_batch_0, _payload_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_reserved$1261$(_prepared_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_spawn$1261$(_tx_0, {$: "Unit"})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1261$(_world_0, _old_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _old_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058checked$1260$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_checked$1260$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1260$(_prepared_0, _target_0)));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_commands_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_reserved$1260$(_prepared_0, _payload_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _target_0 = _t_1["handle"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_positioned$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1260$({$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt", "target": _target_0}, "tail": _prepared_0}, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_commands_0)))));
  } else {
    const _error_0 = _t_1["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.SpawnRefused", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_spawn$1260$(_tx_0, _payload_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0)), _undo_0, _commands_0, _events_0, _payload_0);
}

function $Pair$snd$(_p_0) {
  const _b_0 = _p_0["snd"];
  return _b_0;
}

function $String$cmp$(_a_0, _b_0) {
  if (_a_0 === "") {
    if (_b_0 === "") {
      return {$: "Tuple", "fst": {$: "Tuple", "fst": "", "snd": ""}, "snd": {$: "EQ"}};
    } else {
      const _h_0 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(0, 2) : _b_0[0]);
      const _t_0 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(2) : _b_0.slice(1));
      return {$: "Tuple", "fst": {$: "Tuple", "fst": "", "snd": (_h_0 + _t_0)}, "snd": {$: "LT"}};
    }
  } else {
    const _h_1 = (_a_0.codePointAt(0) > 0xFFFF ? _a_0.slice(0, 2) : _a_0[0]);
    const _t_1 = (_a_0.codePointAt(0) > 0xFFFF ? _a_0.slice(2) : _a_0.slice(1));
    if (_b_0 === "") {
      return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h_1 + _t_1), "snd": ""}, "snd": {$: "GT"}};
    } else {
      const _h2_0 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(0, 2) : _b_0[0]);
      const _t2_0 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(2) : _b_0.slice(1));
      return $String$cmp$fin$(_t_1, _t2_0, ($Char$cmp$(_h_1, _h2_0)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_normal$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
    const _high_0 = _result_0["high"];
    const _low_0 = _result_0["low"];
    const _exponent_0 = _result_0["exponent"];
    const _x_0 = ($Bool$and$((_high_0 === 0), (_low_0 === 0)));
    const _x_1 = ($Bool$and$((_exponent_0 >= 1074), (_exponent_0 <= 1126)));
    return (_x_0 || _x_1);
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_parts$(_negative_0, _exponent_0, _high_0, _low_0, _special_0, _zero_0) {
  if (_special_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$(_negative_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))));
  } else {
    if (_zero_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, _high_0, _low_0, 0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, ((_high_0 + 1048576) >>> 0), _low_0, ((_exponent_0 - 1) >>> 0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0) {
  const _x_0 = (2 === 0 ? _low_0 : _low_0 % 2);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize_checked$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))), (_x_0 === 0));
}

function $Nat$mod$(_a_0, _b_0) {
  return $Pair$snd$(nat_divmod(_a_0, _b_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_numeric$(_bits_0) {
  const _x_0 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_1 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_2 = (256 === 0 ? _x_1 : _x_1 % 256);
  const _x_3 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_4 = (256 === 0 ? _x_3 : _x_3 % 256);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_parts$(_bits_0, (256 === 0 ? _x_0 : _x_0 % 256), (8388608 === 0 ? _bits_0 : _bits_0 % 8388608), (_x_2 === 255), (_x_4 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_left_0, _right_0) {
  if (_left_0.$ === "Nil") {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058empty$(_right_0);
  } else {
    const _head_0 = _left_0["head"];
    const _tail_0 = _left_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058compared$(_head_0, _right_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_tail_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058scalar$(_code_0, _rest_0, _bmp_0) {
  if (_bmp_0) {
    return {$: "Con", "head": _code_0, "tail": _rest_0};
  } else {
    const _x_0 = ((_code_0 - 65536) >>> 0);
    const _x_1 = (1024 === 0 ? 0 : (_x_0 / 1024) >>> 0);
    const _x_2 = ((_code_0 - 65536) >>> 0);
    const _x_3 = (1024 === 0 ? _x_2 : _x_2 % 1024);
    return {$: "Con", "head": ((55296 + _x_1) >>> 0), "tail": {$: "Con", "head": ((56320 + _x_3) >>> 0), "tail": _rest_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1260$(_replaced_0) {
  const _world_0 = _replaced_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0) {
  const _first_0 = _stamp_0["added"];
  const _last_0 = _stamp_0["changed"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = ((_id_0 - 1) >>> 0);
  return {$: "../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": (_added_0[_x_0 % _added_0.length] = _first_0, _added_0), "changed": (_changed_0[_x_1 % _changed_0.length] = _last_0, _changed_0), "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058checked$1261$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_checked$1261$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1261$(_prepared_0, _target_0)));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_commands_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_reserved$1261$(_prepared_0, _payload_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    const _target_0 = _t_1["handle"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_positioned$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1261$({$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt", "target": _target_0}, "tail": _prepared_0}, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_commands_0)))));
  } else {
    const _error_0 = _t_1["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.SpawnRefused", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_spawn$1261$(_tx_0, _payload_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_world_0)), _undo_0, _commands_0, _events_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1261$(_replaced_0) {
  const _world_0 = _replaced_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_checked$1260$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _result_0) {
  const _prepared_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Refused", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_commands_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1260$(_prepared_0, _target_0) {
  if (_prepared_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": false};
  } else {
    const _t_0 = _prepared_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared") {
      const _handle_0 = _t_0["target"];
      const _payload_0 = _t_0["payload"];
      const _position_0 = _t_0["position"];
      const _tail_0 = _prepared_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared", "target": _handle_0, "payload": _payload_0, "position": _position_0}, false, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1260$(_tail_0, _target_0)));
    } else {
      const _t_1 = _t_0["target"];
      const _ns_0 = _t_1["namespace"];
      const _id_0 = _t_1["id"];
      const _tail_1 = _prepared_0["tail"];
      const _otherNs_0 = _target_0["namespace"];
      const _otherId_0 = _target_0["id"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1260$({$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt", "target": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _ns_0, "id": _id_0}}, ($Bool$and$((_ns_0 === _otherNs_0), (_id_0 === _otherId_0))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1260$(_tail_1, {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _otherNs_0, "id": _otherId_0})));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _position_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared", "target": _target_0, "payload": _payload_0, "position": _position_0}, "tail": _prepared_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1260$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_positioned$1260$(_target_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Spawned", "batch": _batch_0, "target": _target_0};
  } else {
    const _batch_1 = _result_0["batch"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.SpawnRefused", "batch": _batch_1, "payload": _payload_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_join$1260$(_reserved_0, _undo_0, _commands_0, _events_0, _payload_0) {
  const _world_0 = _reserved_0["fst"];
  const _reservation_0 = _reserved_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_reserved$1260$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0);
}

function $String$cmp$fin$(_t1_0, _t2_0, _hc_0) {
  const _t_0 = _hc_0["fst"];
  const _h1b_0 = _t_0["fst"];
  const _h2b_0 = _t_0["snd"];
  const _t_1 = _hc_0["snd"];
  if (_t_1.$ === "LT") {
    return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1_0), "snd": (_h2b_0 + _t2_0)}, "snd": {$: "LT"}};
  } else if (_t_1.$ === "EQ") {
    return $String$cmp$rec$(_h1b_0, _h2b_0, ($String$cmp$(_t1_0, _t2_0)));
  } else {
    return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1_0), "snd": (_h2b_0 + _t2_0)}, "snd": {$: "GT"}};
  }
}

function $Char$cmp$(_a_0, _b_0) {
  const _x_0 = _a_0.codePointAt(0);
  const _x_1 = _b_0.codePointAt(0);
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _a_0, "snd": _b_0}, "snd": cmp_new(_x_0, _x_1)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$(_negative_0, _infinite_0) {
  if (_infinite_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity", "negative": _negative_0};
  } else {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize_checked$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _negative_0 = $1;
      const _high_0 = $2;
      const _low_0 = $3;
      const _exponent_0 = $4;
      const _zero_0 = $5;
      const _even_0 = $6;
      if (_fuel_0 === 0) {
        if (_zero_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          } else {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_zero_0) {
          return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          } else {
            const _x_0 = (2 === 0 ? _high_0 : _high_0 % 2);
            const _x_1 = (2 === 0 ? 0 : (_low_0 / 2) >>> 0);
            const _x_2 = (Math.imul(_x_0, 2147483648) >>> 0);
            const _x_3 = (2 === 0 ? 0 : (_low_0 / 2) >>> 0);
            const _x_4 = (2 === 0 ? _x_3 : _x_3 % 2);
            $0 = _more_0;
            $1 = _negative_0;
            $2 = (2 === 0 ? 0 : (_high_0 / 2) >>> 0);
            $3 = ((_x_1 + _x_2) >>> 0);
            $4 = ((_exponent_0 + 1) >>> 0);
            $5 = false;
            $6 = (_x_4 === 0);
            continue;
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_parts$(_bits_0, _exponent_0, _fraction_0, _special_0, _zero_0) {
  if (_special_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$((_bits_0 >= 2147483648), (_fraction_0 === 0));
  } else {
    if (_zero_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, _fraction_0, 925);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, ((_fraction_0 + 8388608) >>> 0), ((_exponent_0 + 924) >>> 0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058empty$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058compared$(_head_0, _other_0, _next_0) {
  if (_other_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _other_0["head"];
    const _tail_0 = _other_0["tail"];
    return $Bool$and$((_head_0 === _value_0), _next_0(_tail_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_checked$1261$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _result_0) {
  const _prepared_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Refused", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": {$: "../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_commands_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1261$(_prepared_0, _target_0) {
  if (_prepared_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": false};
  } else {
    const _t_0 = _prepared_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared") {
      const _handle_0 = _t_0["target"];
      const _payload_0 = _t_0["payload"];
      const _position_0 = _t_0["position"];
      const _tail_0 = _prepared_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared", "target": _handle_0, "payload": _payload_0, "position": _position_0}, false, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1261$(_tail_0, _target_0)));
    } else {
      const _t_1 = _t_0["target"];
      const _ns_0 = _t_1["namespace"];
      const _id_0 = _t_1["id"];
      const _tail_1 = _prepared_0["tail"];
      const _otherNs_0 = _target_0["namespace"];
      const _otherId_0 = _target_0["id"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1261$({$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.ReservationReceipt", "target": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _ns_0, "id": _id_0}}, ($Bool$and$((_ns_0 === _otherNs_0), (_id_0 === _otherId_0))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_find$1261$(_tail_1, {$: "../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _otherNs_0, "id": _otherId_0})));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _position_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted", "batch": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": {$: "Con", "head": {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Prepared", "target": _target_0, "payload": _payload_0, "position": _position_0}, "tail": _prepared_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1261$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058spawn_positioned$1261$(_target_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Spawned", "batch": _batch_0, "target": _target_0};
  } else {
    const _batch_1 = _result_0["batch"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../bendvy/src/ecs/bundle-batch.SpawnRefused", "batch": _batch_1, "payload": _payload_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_join$1261$(_reserved_0, _undo_0, _commands_0, _events_0, _payload_0) {
  const _world_0 = _reserved_0["fst"];
  const _reservation_0 = _reserved_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_reserved$1261$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1260$(_entry_0, _seen_0, _result_0) {
  const _tail_0 = _result_0["fst"];
  const _found_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _entry_0, "tail": _tail_0}, "snd": (_seen_0 || _found_0)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1260$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_reserved$1260$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0) {
  if (_reservation_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected") {
    const _error_0 = _reservation_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": _error_0}};
  } else {
    const _handle_0 = _reservation_0["handle"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1260$(_x_0, _handle_0, _payload_0);
}), "tail": _commands_0}, "events": _events_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": _handle_0}};
  }
}

function $String$cmp$rec$(_h1b_0, _h2b_0, _rr_0) {
  const _t_0 = _rr_0["fst"];
  const _t1b_0 = _t_0["fst"];
  const _t2b_0 = _t_0["snd"];
  const _r_0 = _rr_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1b_0), "snd": (_h2b_0 + _t2b_0)}, "snd": _r_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058receipt_join$1261$(_entry_0, _seen_0, _result_0) {
  const _tail_0 = _result_0["fst"];
  const _found_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _entry_0, "tail": _tail_0}, "snd": (_seen_0 || _found_0)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1261$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_reserved$1261$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0) {
  if (_reservation_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected") {
    const _error_0 = _reservation_0["error"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": _error_0}};
  } else {
    const _handle_0 = _reservation_0["handle"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1262$(_x_0, _handle_0, _payload_0);
}), "tail": _commands_0}, "events": _events_0}, "snd": {$: "../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": _handle_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1260$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1262$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1260$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return _world_0;
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1262$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return _world_0;
  } else {
    return _world_0;
  }
}

// Cli
// ===

let cli_args = [];

function cli(argv) {
  cli_args.push(argv[0]);
  for (let i = 1; i < argv.length; i += 1) {
    if (argv[i] === "--") {
      cli_args.push(...argv.slice(i + 1));
      break;
    } else if (argv[i] === "--bend-help") {
      io_out(1, io_bytes("usage: " + argv[0] + "\n"));
      process.exit(0);
    } else if (argv[i] === "--threads" || argv[i] === "--gpu") {
      i += 1;
    } else {
      cli_args.push(argv[i]);
    }
  }
}

// Show
// ====

// show_val prints a pure main's value as term_show does (see show_main);
// chain is the bracket it continues, or 0. show_chr escapes as char_show.

function show_chr(c, q) {
  const k = { 10: "n", 9: "t", 13: "r", 0: "0", 92: "\\" }[c]
    ?? (c === q.codePointAt(0) ? q : null);
  return k !== null ? "\\" + k : c < 32 || c === 127
    || (c >= 0xD800 && c <= 0xDFFF) || c > 0x10FFFF
    ? "\\u{" + c.toString(16) + "}" : String.fromCodePoint(c);
}

function show_val(D, N, d, v, chain) {
  if (D[d] === 7) {
    const fs = Object.values(typeof v === "boolean"
      ? { $: v ? "True" : "False" } : v);
    let a = d + 3;
    for (; N[D[a]] !== fs[0]; a += 4 + 2 * D[a + 2]) {}
    const o = "{[("[D[a + 3]];
    let s = o === "{" ? fs[0] + "{" : chain === o ? "" : o;
    for (const [j, f] of fs.slice(1).entries()) {
      if (o === "[" ? j === 0 && chain === o : j > 0) {
        s += ", ";
      }
      s += show_val(D, N, D[a + 5 + 2 * j], f, j === 1 && o !== "{" ? o : 0);
    }
    return o === "{" || chain !== o ? s + "}])"[D[a + 3]] : s;
  }
  return D[d] === 0 ? String(v)
    : D[d] === 1 ? f32_show(v).replace(/^-?\d+(?=e|$)/, "$&.0")
    : D[d] === 2 ? v + "n"
    : D[d] === 3 ? "'" + show_chr(v.codePointAt(0), "'") + "'"
    : D[d] === 4 ? "\"" + [...v].map((c) =>
      show_chr(c.codePointAt(0), "\"")).join("") + "\""
    : D[d] === 5 ? "{==}"
    : "[" + v.map((x) => show_val(D, N, D[d + 1], x, 0)).join(", ") + "]";
}

// Io
// ==

// Apple arm64 passes variadic fcntl flags on the stack, so io_sys
// binds fcntl there with the flags as the ninth fixed argument. A
// parked effect waits for fd (a write when out) or until at
// (performance.now()), either one undefined when unused; io_wake
// resumes k with the value of more, and undefined parks it again. The
// waits stay in deadline order, as io_park does in C.

function io_exit(main, show) {
  try {
    if (show !== null) {
      io_out(1, io_bytes(show_val(...show, 0, run_loop(main()), 0) + "\n"));
      process.exit(0);
    }
    process.exit(io_run(main));
  } catch (e) {
    io_errs(String(e));
    process.exit(1);
  }
}

function io_out(fd, data) {
  const fs = require("fs");
  let at = 0;
  while (at < data.length) {
    try {
      at += fs.writeSync(fd, data, at, data.length - at);
    } catch (e) {
      if (e.code === "EAGAIN" || e.code === "EINTR") {
        continue;
      }
      try {
        fs.writeSync(2, "bend: a short write on a standard stream\n");
      } catch (o) {
      }
      process.exit(1);
    }
  }
}

function io_errs(message) {
  io_out(2, io_bytes(message + "\n"));
}

function io_sys() {
  if (globalThis.BEND_SYS === undefined) {
    const ffi = require("bun:ffi");
    const mac = process.platform === "darwin";
    const err = mac ? "__error" : "__errno_location";
    const sel = mac ? "select$DARWIN_EXTSN" : "select";
    const T = { i: "i32", u: "u32", U: "u64", I: "i64", p: "ptr",
      c: "cstring" };
    const vari = mac && process.arch === "arm64";
    const lib = ffi.dlopen(mac ? "libSystem.dylib" : "libc.so.6",
      Object.fromEntries(("socket:iii>i bind:ipu>i listen:ii>i connect:ipu>i"
        + " accept:ipp>i send:ipUi>I recv:ipUi>I read:ipU>I pread:ipUI>I"
        + " sendto:ipUipu>I recvfrom:ipUipp>I close:i>i setsockopt:iiipu>i"
        + " " + sel + ":ipppp>i"
        + (vari ? " fcntl:iiiiiiiii>i" : " fcntl:iii>i") + " getsockopt:iiipp>i"
        + " strerror:i>c " + err + ":>p").split(" ").map((s) => {
        const [name, args, ret] = s.split(/[:>]/);
        return [name, { args: [...args].map((a) => T[a]), returns: T[ret] }];
      }))).symbols;
    const fcntl = (fd, cmd, arg) => vari
      ? lib.fcntl(fd, cmd, 0, 0, 0, 0, 0, 0, arg)
      : lib.fcntl(fd, cmd, arg);
    globalThis.BEND_SYS = { ...lib, fcntl, select: lib[sel],
      ptr: ffi.ptr, mac,
      errno: () => ffi.read.i32(lib[err](), 0) };
  }
  return globalThis.BEND_SYS;
}

// strerror needs bun:ffi; a host without it (node) gets the bare errno.
function io_strerror(code) {
  try {
    return String(io_sys().strerror(code));
  } catch (_) {
    return "errno " + code;
  }
}

function io_fail(code) {
  return { $: "Fail",
    error: io_tup(code >>> 0, io_strerror(code)) };
}

function io_done(value) {
  return { $: "Done", value };
}

function io_tup(...xs) {
  return xs.reduceRight((snd, fst) => ({ $: "Tuple", fst, snd }));
}

function io_bytes(text) {
  return new TextEncoder().encode(text);
}

function io_text(b, n) {
  return new TextDecoder("utf-8", { ignoreBOM: true }).decode(b.subarray(0, n));
}

// Bytes cross as they are (0..255), one List cell each, with no UTF-8 in
// either direction; io_unlist answers null if a value is past 255.
function io_list(b, n) {
  let xs = { $: "Nil" };
  while (n > 0) {
    xs = { $: "Con", head: b[--n], tail: xs };
  }
  return xs;
}

function io_unlist(xs) {
  const b = [];
  for (; xs.$ === "Con"; xs = xs.tail) {
    b.push(xs.head);
  }
  return b.some((x) => x > 255) ? null : Uint8Array.from(b);
}

function io_addr(host, port) {
  const part = host.split(".");
  const deci = (p) => /^(0|[1-9]\d{0,2})$/.test(p) && Number(p) < 256;
  if (port > 65535 || part.length !== 4 || !part.every(deci)) {
    return null;
  }
  const b = new Uint8Array(16);
  const head = io_sys().mac ? [16, 2] : [2, 0];
  b.set([...head, port >> 8, port & 255, ...part.map(Number)]);
  return b;
}

function io_push(fun, arg, fresh) {
  const io = globalThis.BEND_IO;
  io.runs.push({ fun, arg });
  io.live += fresh ? 1 : 0;
}

function io_wait(io, block) {
  const soon = io.waits[0]?.at ?? Infinity;
  const ms = !block ? 0 : soon === Infinity ? -1
    : Math.max(0, Math.ceil(soon - performance.now()));
  const fds = io.waits.filter((w) => w.fd !== undefined);
  const top = fds.reduce((m, w) => Math.max(m, w.fd), 0);
  const len = (top >> 6 << 3) + 8;
  const set = new Uint8Array(2 * len);
  const at = (w) => (w.out ? len : 0) + (w.fd >> 3);
  for (const w of fds) {
    set[at(w)] |= 1 << (w.fd & 7);
  }
  const tv = new BigInt64Array([BigInt(ms / 1000 | 0),
    BigInt(ms % 1000 * 1000)]);
  const sys = io_sys();
  if (sys.select(top + 1, sys.ptr(set), sys.ptr(set, len), null,
    ms < 0 ? null : sys.ptr(tv)) < 0) {
    if (sys.errno() !== 4) {
      throw "bend: the poller failed";
    }
    set.fill(0);
  }
  const now = performance.now();
  io.waits = io.waits.filter((w) => {
    const ready = w.at <= now || w.fd !== undefined
      && set[at(w)] & 1 << (w.fd & 7);
    if (ready) {
      io_push(io_wake, w, false);
    }
    return !ready;
  });
}

function io_wake(w) {
  const x = w.more();
  return x === undefined ? undefined : w.k(x);
}

function io_park_on(fd, out, k, more, at) {
  const ws = globalThis.BEND_IO.waits;
  const i = ws.findLastIndex((w) => (w.at ?? Infinity) <= (at ?? Infinity));
  ws.splice(i + 1, 0, { fd, out, k, more, at });
}

function io_run(m) {
  const io = { runs: [], live: 0, waits: [] };
  globalThis.BEND_IO = io;
  try {
    io_push(run_loop(m()), (x) => ({ $: "Emit", value: x }), true);
    let look = 0;
    for (let n = 0;; n += 1) {
      if (io.runs.length === 0) {
        if (io.live === 0) {
          return 0;
        }
        if (io.waits.length === 0) {
          io_errs("bend: deadlock: every computation waits on a channel");
          return 1;
        }
        io_wait(io, true);
        continue;
      }
      if ((n & 63) === 0 && io.waits.length > 0) {
        const now = performance.now();
        if (now >= look || io.waits[0].at <= now) {
          look = now + 10;
          io_wait(io, false);
        }
      }
      const s = io.runs.shift();
      let op = s.fun(s.arg);
      while (op !== undefined) {
        if (op.$ === "Emit") {
          io.live -= 1;
          break;
        }
        if (op.$ === "Halt") {
          io_errs(op.message);
          return op.code;
        }
        const need = op.need?.() ?? {};
        if (need.time || need.read) {
          const more = () => op.run(...op.args, op.kont);
          io_park_on(need.read ? op.args[0] : undefined, false, op.kont, more,
            need.read ? undefined : performance.now() + Number(op.args[0]));
          break;
        }
        const x = op.run(...op.args, op.kont);
        if (x === undefined) {
          break;
        }
        op = op.kont(x);
      }
    }
  } catch (req) {
    if (req instanceof RangeError) {
      throw "bend: memory fault (machine stack overflow?)";
    }
    if (req?.$ !== "$FFI") {
      throw req;
    }
    io_errs("bend: runtime fail-stop");
    return 1;
  }
}

cli(process.argv.slice(1));
io_exit($main$, null);