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
  const _x_0 = ($read_probe$1261$());
  const _x_1 = (_x_0 + "\n");
  const _x_2 = ("second-read=" + _x_1);
  const _x_3 = ($read_probe$1260$());
  const _x_4 = ("\n" + _x_2);
  const _x_5 = (_x_3 + _x_4);
  const _x_6 = ("first-read=" + _x_5);
  const _x_7 = ($binding_text$1261$(($present_binding$1261$())));
  const _x_8 = ("\n" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ("second-present=" + _x_9);
  const _x_11 = ($binding_text$1261$(($missing_binding$1261$())));
  const _x_12 = ("\n" + _x_10);
  const _x_13 = (_x_11 + _x_12);
  const _x_14 = ("second-missing=" + _x_13);
  const _x_15 = ($binding_text$1260$(($present_binding$1260$())));
  const _x_16 = ("\n" + _x_14);
  const _x_17 = (_x_15 + _x_16);
  const _x_18 = ("first-present=" + _x_17);
  const _x_19 = ($binding_text$1260$(($missing_binding$1260$())));
  const _x_20 = ("\n" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  return (_x_22) => $IO$print$(("first-missing=" + _x_21), _x_22);
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $binding_text$1260$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected") {
    const _error_0 = _result_0["error"];
    const _fragment_0 = _result_0["fragment"];
    const _x_0 = ($fragment_text$1260$(_fragment_0));
    const _x_1 = (_x_0 + "}");
    const _x_2 = ($binding_error_text$(_error_0));
    const _x_3 = (",fragment=" + _x_1);
    const _x_4 = (_x_2 + _x_3);
    return ("BindRejected{error=" + _x_4);
  } else {
    const _output_0 = _result_0["output"];
    const _x_5 = (_output_0 + "}");
    return ("Built{output=" + _x_5);
  }
}

function $missing_binding$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": {$: "Nil"}, "owners": {$: "Unit"}}, ($required$1260$()));
}

function $present_binding$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": ($required$1260$()), "owners": {$: "Unit"}}, ($required$1260$()));
}

function $binding_text$1261$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected") {
    const _error_0 = _result_0["error"];
    const _fragment_0 = _result_0["fragment"];
    const _x_0 = ($fragment_text$1261$(_fragment_0));
    const _x_1 = (_x_0 + "}");
    const _x_2 = ($binding_error_text$(_error_0));
    const _x_3 = (",fragment=" + _x_1);
    const _x_4 = (_x_2 + _x_3);
    return ("BindRejected{error=" + _x_4);
  } else {
    const _output_0 = _result_0["output"];
    const _x_5 = (_output_0 + "}");
    return ("Built{output=" + _x_5);
  }
}

function $missing_binding$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": {$: "Nil"}, "owners": {$: "Unit"}}, ($required$1261$()));
}

function $present_binding$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": ($required$1261$()), "owners": {$: "Unit"}}, ($required$1261$()));
}

function $read_probe$1260$() {
  return $world_read$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), {$: "../handle-application.Payload", "cells": array_node([100], [101]), "name": "resource", "target": {$: "None"}})));
}

function $read_probe$1261$() {
  return $world_read$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), {$: "../handle-application.Payload", "cells": array_node([100], [101]), "name": "resource", "target": {$: "None"}})));
}

function $binding_error_text$(_error_0) {
  if (_error_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.DuplicateKey") {
    const _kind_0 = _error_0["kind"];
    const _key_0 = _error_0["key"];
    const _x_0 = (_key_0 + "}");
    const _x_1 = ($kind_text$(_kind_0));
    const _x_2 = (",key=" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    return ("DuplicateKey{kind=" + _x_3);
  } else if (_error_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.DuplicateName") {
    const _kind_1 = _error_0["kind"];
    const _name_0 = _error_0["name"];
    const _x_4 = (_name_0 + "}");
    const _x_5 = ($kind_text$(_kind_1));
    const _x_6 = (",name=" + _x_4);
    const _x_7 = (_x_5 + _x_6);
    return ("DuplicateName{kind=" + _x_7);
  } else {
    const _kind_2 = _error_0["kind"];
    const _key_1 = _error_0["key"];
    const _name_1 = _error_0["name"];
    const _x_8 = (_name_1 + "}");
    const _x_9 = (",name=" + _x_8);
    const _x_10 = (_key_1 + _x_9);
    const _x_11 = ($kind_text$(_kind_2));
    const _x_12 = (",key=" + _x_10);
    const _x_13 = (_x_11 + _x_12);
    return ("UndeclaredDescriptor{kind=" + _x_13);
  }
}

function $fragment_text$1260$(_value_0) {
  const _entries_0 = _value_0["entries"];
  const _x_0 = ($entries_text$1260$(_entries_0));
  const _x_1 = (_x_0 + "],owners=Unit{}}");
  return ("Fragment{entries=[" + _x_1);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1260$(_fragment_0, _required_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_declared$1260$(_fragment_0, _required_0);
}

function $required$1260$() {
  return {$: "Con", "head": ($entry$1260$()), "tail": {$: "Nil"}};
}

function $fragment_text$1261$(_value_0) {
  const _entries_0 = _value_0["entries"];
  const _x_0 = ($entries_text$1261$(_entries_0));
  const _x_1 = (_x_0 + "],owners=Unit{}}");
  return ("Fragment{entries=[" + _x_1);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045capabilities$058provision_declared$1261$(_fragment_0, _required_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_declared$1261$(_fragment_0, _required_0);
}

function $required$1261$() {
  return {$: "Con", "head": ($entry$1261$()), "tail": {$: "Nil"}};
}

function $world_read$1260$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _world_0 = _result_0["world"];
    const _reserved_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0));
    return $reserve_and_read$1260$(_reserved_0);
  } else {
    return "creation-rejected";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": 1};
}

function $world_read$1261$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Created") {
    const _world_0 = _result_0["world"];
    const _reserved_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_world_0));
    return $reserve_and_read$1261$(_reserved_0);
  } else {
    return "creation-rejected";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $kind_text$(_kind_0) {
  if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component") {
    return "Component";
  } else if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Resource") {
    return "Resource";
  } else if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Event") {
    return "Event";
  } else if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Relation") {
    return "Relation";
  } else {
    return "Service";
  }
}

function $entries_text$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return "";
  } else {
    const _value_0 = _values_0["head"];
    const _t_0 = _values_0["tail"];
    if (_t_0.$ === "Nil") {
      return $entry_text$1260$(_value_0);
    } else {
      const _x_0 = ($entries_text$1260$(_t_0));
      const _x_1 = ($entry_text$1260$(_value_0));
      const _x_2 = (";" + _x_0);
      return (_x_1 + _x_2);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_declared$1260$(_fragment_0, _required_0) {
  const _entries_0 = _fragment_0["entries"];
  const _owners_0 = _fragment_0["owners"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_requirements$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate$1260$(_entries_0)), _required_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": _entries_0, "owners": _owners_0});
}

function $entry$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component"}, "key": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047handle$045application$058identity$1260$()))), "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047handle$045application$058identity$1260$())))};
}

function $entries_text$1261$(_values_0) {
  if (_values_0.$ === "Nil") {
    return "";
  } else {
    const _value_0 = _values_0["head"];
    const _t_0 = _values_0["tail"];
    if (_t_0.$ === "Nil") {
      return $entry_text$1261$(_value_0);
    } else {
      const _x_0 = ($entries_text$1261$(_t_0));
      const _x_1 = ($entry_text$1261$(_value_0));
      const _x_2 = (";" + _x_0);
      return (_x_1 + _x_2);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_declared$1261$(_fragment_0, _required_0) {
  const _entries_0 = _fragment_0["entries"];
  const _owners_0 = _fragment_0["owners"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_requirements$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate$1261$(_entries_0)), _required_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": _entries_0, "owners": _owners_0});
}

function $entry$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component"}, "key": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1261$(($$$$047handle$045application$058identity$1261$()))), "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1261$(($$$$047handle$045application$058identity$1261$())))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $reserve_and_read$1260$(_reserved_0) {
  const _world_0 = _reserved_0["fst"];
  const _t_0 = _reserved_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    return $spawn_and_read$1260$(_world_0);
  } else {
    return "reservation-rejected";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($$$$047handle$045application$058empty$1260$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1261$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1261$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $reserve_and_read$1261$(_reserved_0) {
  const _world_0 = _reserved_0["fst"];
  const _t_0 = _reserved_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Reserved") {
    return $spawn_and_read$1261$(_world_0);
  } else {
    return "reservation-rejected";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($$$$047handle$045application$058empty$1261$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $entry_text$1260$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _value_0["kind"];
    const _key_0 = _value_0["key"];
    const _name_0 = _value_0["name"];
    const _x_0 = (_name_0 + "}");
    const _x_1 = (",name=" + _x_0);
    const _x_2 = (_key_0 + _x_1);
    const _x_3 = ($kind_text$(_kind_0));
    const _x_4 = (",key=" + _x_2);
    const _x_5 = (_x_3 + _x_4);
    return ("Entry{kind=" + _x_5);
  } else {
    const _kind_1 = _value_0["kind"];
    const _key_1 = _value_0["key"];
    const _name_1 = _value_0["name"];
    const _persistence_0 = _value_0["persistence"];
    const _x_6 = ($persistence_text$(_persistence_0));
    const _x_7 = (_x_6 + "}");
    const _x_8 = (",persistence=" + _x_7);
    const _x_9 = (_name_1 + _x_8);
    const _x_10 = (",name=" + _x_9);
    const _x_11 = (_key_1 + _x_10);
    const _x_12 = ($kind_text$(_kind_1));
    const _x_13 = (",key=" + _x_11);
    const _x_14 = (_x_12 + _x_13);
    return ("Classified{kind=" + _x_14);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_requirements$1260$(_result_0, _required_0, _fragment_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected", "error": _error_0, "fragment": _fragment_0};
  } else {
    const _entries_0 = _fragment_0["entries"];
    const _owners_0 = _fragment_0["owners"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_checked$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1260$(_required_0, _entries_0)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": _entries_0, "owners": _owners_0});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate$1260$(_entries_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Resource"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Event"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Relation"})), {$: "Nil"})), run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Service"})), {$: "Nil"})))))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1260$(_declaration_0) {
  const _key_0 = _declaration_0["key"];
  return _key_0;
}

function $$$$047handle$045application$058identity$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058component$1260$("HandlePayload");
}

function $entry_text$1261$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _value_0["kind"];
    const _key_0 = _value_0["key"];
    const _name_0 = _value_0["name"];
    const _x_0 = (_name_0 + "}");
    const _x_1 = (",name=" + _x_0);
    const _x_2 = (_key_0 + _x_1);
    const _x_3 = ($kind_text$(_kind_0));
    const _x_4 = (",key=" + _x_2);
    const _x_5 = (_x_3 + _x_4);
    return ("Entry{kind=" + _x_5);
  } else {
    const _kind_1 = _value_0["kind"];
    const _key_1 = _value_0["key"];
    const _name_1 = _value_0["name"];
    const _persistence_0 = _value_0["persistence"];
    const _x_6 = ($persistence_text$(_persistence_0));
    const _x_7 = (_x_6 + "}");
    const _x_8 = (",persistence=" + _x_7);
    const _x_9 = (_name_1 + _x_8);
    const _x_10 = (",name=" + _x_9);
    const _x_11 = (_key_1 + _x_10);
    const _x_12 = ($kind_text$(_kind_1));
    const _x_13 = (",key=" + _x_11);
    const _x_14 = (_x_12 + _x_13);
    return ("Classified{kind=" + _x_14);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_requirements$1261$(_result_0, _required_0, _fragment_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected", "error": _error_0, "fragment": _fragment_0};
  } else {
    const _entries_0 = _fragment_0["entries"];
    const _owners_0 = _fragment_0["owners"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_checked$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1261$(_required_0, _entries_0)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Fragment", "entries": _entries_0, "owners": _owners_0});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate$1261$(_entries_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Resource"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Event"})), {$: "Nil"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Relation"})), {$: "Nil"})), run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_entries_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Service"})), {$: "Nil"})))))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1261$(_declaration_0) {
  const _key_0 = _declaration_0["key"];
  return _key_0;
}

function $$$$047handle$045application$058identity$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058component$1261$("HandlePayload");
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}}};
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
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

function $spawn_and_read$1260$(_world_0) {
  return $read_frame$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1260$(_world_0, ($first_handle$1260$()), {$: "../handle-application.Payload", "cells": array_node([7], [8]), "name": "seed", "target": {$: "None"}})), ($first_handle$1260$()));
}

function $$$$047handle$045application$058empty$1260$(_unit_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1260$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1261$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.ReservationRejected", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}}};
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
    }
  }
}

function $spawn_and_read$1261$(_world_0) {
  return $read_frame$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1261$(_world_0, ($first_handle$1261$()), {$: "../handle-application.Payload", "cells": array_node([7], [8]), "name": "seed", "target": {$: "None"}})), ($first_handle$1261$()));
}

function $$$$047handle$045application$058empty$1261$(_unit_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1261$();
}

function $persistence_text$(_kind_0) {
  if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Plain") {
    return "Plain";
  } else if (_kind_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Transient") {
    return "Transient";
  } else {
    return "Constructed";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_checked$1260$(_result_0, _fragment_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected", "error": _error_0, "fragment": _fragment_0};
  } else {
    const _owners_0 = _fragment_0["owners"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Built", "output": ($launch$(_owners_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1260$(_required_0, _entries_0) {
  if (_required_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    const _item_0 = _required_0["head"];
    const _rest_0 = _required_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_continue$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1260$(_entries_0, _item_0)), _item_0)), run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1260$(_rest_0, _entries_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058first_failure$(_first_0, _second_0) {
  if (_first_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _first_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": _error_0};
  } else {
    return _second_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(_xs_0, _seen_0) {
  if (_xs_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    const _item_0 = _xs_0["head"];
    const _rest_0 = _xs_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validation_continue$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one$1260$(_seen_0, _item_0)), run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1260$(_rest_0, {$: "Con", "head": _item_0, "tail": _seen_0});
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_xs_0, _kind_0) {
  if (_xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _itemKind_0 = _t_0["kind"];
      const _key_0 = _t_0["key"];
      const _name_0 = _t_0["name"];
      const _rest_0 = _xs_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _itemKind_0)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _itemKind_0, "key": _key_0, "name": _name_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_rest_0, _kind_0)));
    } else {
      const _itemKind_1 = _t_0["kind"];
      const _key_1 = _t_0["key"];
      const _name_1 = _t_0["name"];
      const _persistence_0 = _t_0["persistence"];
      const _rest_1 = _xs_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _itemKind_1)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Classified", "kind": _itemKind_1, "key": _key_1, "name": _name_1, "persistence": _persistence_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1260$(_rest_1, _kind_0)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058component$1260$(_key_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-declaration.Declaration", "key": _key_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bind_checked$1261$(_result_0, _fragment_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.BindRejected", "error": _error_0, "fragment": _fragment_0};
  } else {
    const _owners_0 = _fragment_0["owners"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Built", "output": ($launch$(_owners_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1261$(_required_0, _entries_0) {
  if (_required_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    const _item_0 = _required_0["head"];
    const _rest_0 = _required_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_continue$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1261$(_entries_0, _item_0)), _item_0)), run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058requirements$1261$(_rest_0, _entries_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(_xs_0, _seen_0) {
  if (_xs_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    const _item_0 = _xs_0["head"];
    const _rest_0 = _xs_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validation_continue$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one$1261$(_seen_0, _item_0)), run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validate_loop$1261$(_rest_0, {$: "Con", "head": _item_0, "tail": _seen_0});
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_xs_0, _kind_0) {
  if (_xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _itemKind_0 = _t_0["kind"];
      const _key_0 = _t_0["key"];
      const _name_0 = _t_0["name"];
      const _rest_0 = _xs_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _itemKind_0)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _itemKind_0, "key": _key_0, "name": _name_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_rest_0, _kind_0)));
    } else {
      const _itemKind_1 = _t_0["kind"];
      const _key_1 = _t_0["key"];
      const _name_1 = _t_0["name"];
      const _persistence_0 = _t_0["persistence"];
      const _rest_1 = _xs_0["tail"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _itemKind_1)), {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Classified", "kind": _itemKind_1, "key": _key_1, "name": _name_1, "persistence": _persistence_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind$1261$(_rest_1, _kind_0)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058component$1261$(_key_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-declaration.Declaration", "key": _key_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$($0, $1, $2, $3) {
  for (;;) {
    {
      const _remaining_0 = $0;
      const _capacity_0 = $1;
      const _depth_0 = $2;
      const _live_0 = $3;
      if (_remaining_0 === 0) {
        return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0};
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

function $read_frame$1260$(_world_0, _handle_0) {
  return $read_returned$1260$(($invoke_readonly$1260$(($frame_handle$1260$(($$$$047handle$045application$058frame_at$1260$(1, _world_0)), _handle_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1260$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $first_handle$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 1, "id": 1};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1261$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Reserved", "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $read_frame$1261$(_world_0, _handle_0) {
  return $read_returned$1261$(($invoke_readonly$1261$(($frame_handle$1261$(($$$$047handle$045application$058frame_at$1261$(1, _world_0)), _handle_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawn_apply$1261$(_world_0, _handle_0, _payload_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $first_handle$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 1, "id": 1};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058empty$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}};
}

function $launch$(_owners_0) {
  return "launched";
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_continue$(_result_0, _next_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": _error_0};
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check$1260$(_present_0, _item_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check_bare$1260$(_present_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_item_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1260$(_xs_0, _item_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _xs_0["head"];
    const _rest_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_equal$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_head_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_item_0))));
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1260$(_rest_0, _item_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validation_continue$1260$(_result_0, _next_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": _error_0};
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one$1260$(_seen_0, _item_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one_bare$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1260$(_seen_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_item_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1260$(_selected_0, _item_0, _rest_0) {
  if (_selected_0) {
    return {$: "Con", "head": _item_0, "tail": _rest_0};
  } else {
    return _rest_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Component") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Resource") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Resource") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Event") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Event") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Relation") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Relation") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Service") {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check$1261$(_present_0, _item_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check_bare$1261$(_present_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_item_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1261$(_xs_0, _item_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _xs_0["head"];
    const _rest_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_equal$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_head_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_item_0))));
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_present$1261$(_rest_0, _item_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058validation_continue$1261$(_result_0, _next_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid") {
    const _error_0 = _result_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": _error_0};
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one$1261$(_seen_0, _item_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one_bare$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1261$(_seen_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_item_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058filter_kind_done$1261$(_selected_0, _item_0, _rest_0) {
  if (_selected_0) {
    return {$: "Con", "head": _item_0, "tail": _rest_0};
  } else {
    return _rest_0;
  }
}

function $read_returned$1260$(_result_0) {
  const _result_1 = _result_0["snd"];
  return _result_1;
}

function $invoke_readonly$1260$(_frame_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058invoke_readonly$1260$(_frame_0, {$: "Unit"});
}

function $frame_handle$1260$(_frame_0, _handle_0) {
  const _owner_0 = _frame_0["owner"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0};
}

function $$$$047handle$045application$058frame_at$1260$(_namespace_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($$$$047handle$045application$058component_declaration$1260$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1260$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return $populate_world$1260$(_world_0, _handle_0, _payload_0);
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(true, _handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $read_returned$1261$(_result_0) {
  const _result_1 = _result_0["snd"];
  return _result_1;
}

function $invoke_readonly$1261$(_frame_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058invoke_readonly$1261$(_frame_0, {$: "Unit"});
}

function $frame_handle$1261$(_frame_0, _handle_0) {
  const _owner_0 = _frame_0["owner"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0};
}

function $$$$047handle$045application$058frame_at$1261$(_namespace_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($$$$047handle$045application$058component_declaration$1261$(_namespace_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058spawned$1261$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.Accepted") {
    return $populate_world$1261$(_world_0, _handle_0, _payload_0);
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1261$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1261$(true, _handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check_bare$1260$(_present_0, _item_0) {
  if (_present_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    if (_item_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _kind_0 = _item_0["kind"];
      const _key_0 = _item_0["key"];
      const _name_0 = _item_0["name"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.UndeclaredDescriptor", "kind": _kind_0, "key": _key_0, "name": _name_0}};
    } else {
      const _kind_1 = _item_0["kind"];
      const _key_1 = _item_0["key"];
      const _name_1 = _item_0["name"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.UndeclaredDescriptor", "kind": _kind_1, "key": _key_1, "name": _name_1}};
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _value_0["kind"];
    const _key_0 = _value_0["key"];
    const _name_0 = _value_0["name"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _kind_0, "key": _key_0, "name": _name_0};
  } else {
    const _kind_1 = _value_0["kind"];
    const _key_1 = _value_0["key"];
    const _name_1 = _value_0["name"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _kind_1, "key": _key_1, "name": _name_1};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_equal$1260$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _ak_0 = _a_0["kind"];
    const _ax_0 = _a_0["key"];
    const _an_0 = _a_0["name"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _bk_0 = _b_0["kind"];
      const _bx_0 = _b_0["key"];
      const _bn_0 = _b_0["name"];
      return $Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_ak_0, _bk_0)), ($Bool$and$(($String$eq$(_ax_0, _bx_0)), ($String$eq$(_an_0, _bn_0)))));
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one_bare$1260$(_seen_0, _item_0) {
  if (_item_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _item_0["kind"];
    const _key_0 = _item_0["key"];
    const _name_0 = _item_0["name"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_entry$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1260$(_seen_0, _kind_0, _key_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1260$(_seen_0, _kind_0, _name_0)), _kind_0, _key_0, _name_0);
  } else {
    const _kind_1 = _item_0["kind"];
    const _key_1 = _item_0["key"];
    const _name_1 = _item_0["name"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_entry$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1260$(_seen_0, _kind_1, _key_1)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1260$(_seen_0, _kind_1, _name_1)), _kind_1, _key_1, _name_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1260$(_head_0)), "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1260$(_rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058required_check_bare$1261$(_present_0, _item_0) {
  if (_present_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
  } else {
    if (_item_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _kind_0 = _item_0["kind"];
      const _key_0 = _item_0["key"];
      const _name_0 = _item_0["name"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.UndeclaredDescriptor", "kind": _kind_0, "key": _key_0, "name": _name_0}};
    } else {
      const _kind_1 = _item_0["kind"];
      const _key_1 = _item_0["key"];
      const _name_1 = _item_0["name"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.UndeclaredDescriptor", "kind": _kind_1, "key": _key_1, "name": _name_1}};
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _value_0["kind"];
    const _key_0 = _value_0["key"];
    const _name_0 = _value_0["name"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _kind_0, "key": _key_0, "name": _name_0};
  } else {
    const _kind_1 = _value_0["kind"];
    const _key_1 = _value_0["key"];
    const _name_1 = _value_0["name"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry", "kind": _kind_1, "key": _key_1, "name": _name_1};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058descriptor_equal$1261$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _ak_0 = _a_0["kind"];
    const _ax_0 = _a_0["key"];
    const _an_0 = _a_0["name"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _bk_0 = _b_0["kind"];
      const _bx_0 = _b_0["key"];
      const _bn_0 = _b_0["name"];
      return $Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_ak_0, _bk_0)), ($Bool$and$(($String$eq$(_ax_0, _bx_0)), ($String$eq$(_an_0, _bn_0)))));
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_one_bare$1261$(_seen_0, _item_0) {
  if (_item_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
    const _kind_0 = _item_0["kind"];
    const _key_0 = _item_0["key"];
    const _name_0 = _item_0["name"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_entry$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1261$(_seen_0, _kind_0, _key_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1261$(_seen_0, _kind_0, _name_0)), _kind_0, _key_0, _name_0);
  } else {
    const _kind_1 = _item_0["kind"];
    const _key_1 = _item_0["key"];
    const _name_1 = _item_0["name"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_entry$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1261$(_seen_0, _kind_1, _key_1)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1261$(_seen_0, _kind_1, _name_1)), _kind_1, _key_1, _name_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1261$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entry$1261$(_head_0)), "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1261$(_rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058invoke_readonly$1260$(_frame_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1260$(_args_0, _frame_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $$$$047handle$045application$058component_declaration$1260$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(($$$$047handle$045application$058codec$(_namespace_0)));
}

function $populate_world$1260$(_world_0, _handle_0, _payload_0) {
  return $$$$047handle$045application$058populate$1260$(_world_0, _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058invoke_readonly$1261$(_frame_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1261$(_args_0, _frame_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $$$$047handle$045application$058component_declaration$1261$(_namespace_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$(($$$$047handle$045application$058codec$(_namespace_0)));
}

function $populate_world$1261$(_world_0, _handle_0, _payload_0) {
  return $$$$047handle$045application$058populate$1261$(_world_0, _handle_0, _payload_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1261$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058check_entry$(_keyConflict_0, _nameConflict_0, _kind_0, _key_0, _name_0) {
  if (_keyConflict_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.DuplicateKey", "kind": _kind_0, "key": _key_0}};
  } else {
    if (_nameConflict_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Invalid", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.DuplicateName", "kind": _kind_0, "name": _name_0}};
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Valid"};
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1260$(_xs_0, _kind_0, _key_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1260$(_xs_0)), _kind_0, _key_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1260$(_xs_0, _kind_0, _name_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1260$(_xs_0)), _kind_0, _name_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists$1261$(_xs_0, _kind_0, _key_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1261$(_xs_0)), _kind_0, _key_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists$1261$(_xs_0, _kind_0, _name_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058bare_entries$1261$(_xs_0)), _kind_0, _name_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1260$(_args_0, _ctx_0) {
  return $read_body$1260$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047handle$045application$058codec$(_namespace_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "cells", "codec": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue", "inner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"}}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "name", "codec": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NamedCodec", "name": "target", "codec": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable", "inner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.HandleValue", "namespace": _namespace_0}}}, "tail": {$: "Nil"}}}}};
}

function $$$$047handle$045application$058populate$1260$(_world_0, _target_0, _payload_0) {
  return $$$$047handle$045application$058populated$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1260$(($$$$047handle$045application$058family$1260$()), _world_0, _target_0, {$: "Some", "value": _payload_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}}};
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
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1261$(_args_0, _ctx_0) {
  return $read_body$1261$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047handle$045application$058populate$1261$(_world_0, _target_0, _payload_0) {
  return $$$$047handle$045application$058populated$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1261$(($$$$047handle$045application$058family$1261$()), _world_0, _target_0, {$: "Some", "value": _payload_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Rejected", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}}};
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
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Accepted"}};
  }
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1260$(_xs_0, _kind_0, _key_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _other_0 = _t_0["kind"];
      const _otherKey_0 = _t_0["key"];
      const _rest_0 = _xs_0["tail"];
      const _x_0 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_0)), ($String$eq$(_key_0, _otherKey_0))));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1260$(_rest_0, _kind_0, _key_0));
      return (_x_0 || _x_1);
    } else {
      const _other_1 = _t_0["kind"];
      const _otherKey_1 = _t_0["key"];
      const _rest_1 = _xs_0["tail"];
      const _x_2 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_1)), ($String$eq$(_key_0, _otherKey_1))));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1260$(_rest_1, _kind_0, _key_0));
      return (_x_2 || _x_3);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1260$(_xs_0, _kind_0, _name_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _other_0 = _t_0["kind"];
      const _otherName_0 = _t_0["name"];
      const _rest_0 = _xs_0["tail"];
      const _x_0 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_0)), ($String$eq$(_name_0, _otherName_0))));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1260$(_rest_0, _kind_0, _name_0));
      return (_x_0 || _x_1);
    } else {
      const _other_1 = _t_0["kind"];
      const _otherName_1 = _t_0["name"];
      const _rest_1 = _xs_0["tail"];
      const _x_2 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_1)), ($String$eq$(_name_0, _otherName_1))));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1260$(_rest_1, _kind_0, _name_0));
      return (_x_2 || _x_3);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1261$(_xs_0, _kind_0, _key_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _other_0 = _t_0["kind"];
      const _otherKey_0 = _t_0["key"];
      const _rest_0 = _xs_0["tail"];
      const _x_0 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_0)), ($String$eq$(_key_0, _otherKey_0))));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1261$(_rest_0, _kind_0, _key_0));
      return (_x_0 || _x_1);
    } else {
      const _other_1 = _t_0["kind"];
      const _otherKey_1 = _t_0["key"];
      const _rest_1 = _xs_0["tail"];
      const _x_2 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_1)), ($String$eq$(_key_0, _otherKey_1))));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058key_exists_bare$1261$(_rest_1, _kind_0, _key_0));
      return (_x_2 || _x_3);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1261$(_xs_0, _kind_0, _name_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/schema-fragments.Entry") {
      const _other_0 = _t_0["kind"];
      const _otherName_0 = _t_0["name"];
      const _rest_0 = _xs_0["tail"];
      const _x_0 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_0)), ($String$eq$(_name_0, _otherName_0))));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1261$(_rest_0, _kind_0, _name_0));
      return (_x_0 || _x_1);
    } else {
      const _other_1 = _t_0["kind"];
      const _otherName_1 = _t_0["name"];
      const _rest_1 = _xs_0["tail"];
      const _x_2 = ($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058same_kind$(_kind_0, _other_1)), ($String$eq$(_name_0, _otherName_1))));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schema$045fragments$058name_exists_bare$1261$(_rest_1, _kind_0, _name_0));
      return (_x_2 || _x_3);
    }
  }
}

function $read_body$1260$(_unit_0, _owner_0) {
  return $read_text$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read$1260$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(_tx_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047handle$045application$058populated$1260$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    return _world_1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1260$(_family_0, _world_0, _handle_0, _incoming_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $$$$047handle$045application$058family$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": "HandlePayload"};
}

function $read_body$1261$(_unit_0, _owner_0) {
  return $read_text$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read$1261$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(_tx_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047handle$045application$058populated$1261$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    return _world_1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace$1261$(_family_0, _world_0, _handle_0, _incoming_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $$$$047handle$045application$058family$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": "HandlePayload"};
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

function $read_text$1260$(_observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Found") {
    const _value_0 = _t_0["value"];
    const _x_0 = run_loop($$$$047handle$045controls$058raw$(_value_0));
    const _x_1 = (_x_0 + "}");
    return {$: "Tuple", "fst": _owner_0, "snd": ("Found{value=" + _x_1)};
  } else if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.ComponentAbsent") {
    return {$: "Tuple", "fst": _owner_0, "snd": "ComponentAbsent{}"};
  } else {
    return {$: "Tuple", "fst": _owner_0, "snd": "MissingEntity{}"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read$1260$(_ctx_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_grant$1260$()))), _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1260$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1260$(_handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $read_text$1261$(_observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Found") {
    const _value_0 = _t_0["value"];
    const _x_0 = run_loop($$$$047handle$045controls$058raw$(_value_0));
    const _x_1 = (_x_0 + "}");
    return {$: "Tuple", "fst": _owner_0, "snd": ("Found{value=" + _x_1)};
  } else if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.ComponentAbsent") {
    return {$: "Tuple", "fst": _owner_0, "snd": "ComponentAbsent{}"};
  } else {
    return {$: "Tuple", "fst": _owner_0, "snd": "MissingEntity{}"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read$1261$(_ctx_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_grant$1261$()))), _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_allowed$1261$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.MissingEntity"}};
  } else {
    const _id_0 = _handle_0["id"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid$1261$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1261$(_handle_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
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

function $$$$047handle$045controls$058raw$(_value_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_value_0));
  const _x_1 = nat_chk(4 * _x_0);
  return $$$$047handle$045controls$058raw_walk$(nat_chk(1 + _x_1), {$: "Con", "head": {$: "../handle-controls.VisitRaw", "value": _value_0}, "tail": {$: "Nil"}}, {$: "Nil"});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1260$(_cap_0) {
  const _get_0 = _cap_0["get"];
  return _get_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_grant$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_grant$1260$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _tick_0 = _clocked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1260$((_tick_0 < 4294967295), _world_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_incoming_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1260$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1262$(_cap_0) {
  const _get_0 = _cap_0["get"];
  return _get_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_grant$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_grant$1261$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock$1261$(_id_0, _incoming_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _tick_0 = _clocked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1261$((_tick_0 < 4294967295), _world_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_incoming_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1261$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_join$1261$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0);
}

function $String$cmp$rec$(_h1b_0, _h2b_0, _rr_0) {
  const _t_0 = _rr_0["fst"];
  const _t1b_0 = _t_0["fst"];
  const _t2b_0 = _t_0["snd"];
  const _r_0 = _rr_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1b_0), "snd": (_h2b_0 + _t2b_0)}, "snd": _r_0};
}

function $$$$047handle$045controls$058raw_walk$(_fuel_0, _todo_0, _stack_0) {
  if (_fuel_0 === 0) {
    return "formatter-budget-error";
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $$$$047handle$045controls$058raw_step$(_todo_0, _stack_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047handle$045controls$058raw_walk$(_rest_0, _x_0, _x_1);
});
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_raw_0) {
  if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _t_0 = _raw_0["items"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _head_0 = _t_0["head"];
      const _rest_0 = _t_0["tail"];
      const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_head_0));
      const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _rest_0}));
      return nat_chk(_x_0 + _x_1);
    }
  } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
    const _t_1 = _raw_0["fields"];
    if (_t_1.$ === "Nil") {
      return 1;
    } else {
      const _t_2 = _t_1["head"];
      const _child_0 = _t_2["value"];
      const _rest_1 = _t_1["tail"];
      const _x_2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_child_0));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": _rest_1}));
      return nat_chk(_x_2 + _x_3);
    }
  } else {
    return 1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_grant$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.Read", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read$1260$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1260$(_allowed_0, _world_0, _id_0, _observed_0) {
  if (!_allowed_0) {
    const _incoming_0 = _observed_0["fst"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  } else {
    const _incoming_1 = _observed_0["fst"];
    const _present_0 = _observed_0["snd"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _present_0, _incoming_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": false};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "Tuple", "fst": {$: "Some", "value": _owner_1}, "snd": true};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0) {
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
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1260$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_grant$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.Read", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read$1261$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_checked$1261$(_allowed_0, _world_0, _id_0, _observed_0) {
  if (!_allowed_0) {
    const _incoming_0 = _observed_0["fst"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  } else {
    const _incoming_1 = _observed_0["fst"];
    const _present_0 = _observed_0["snd"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1261$(_id_0, _present_0, _incoming_1, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": false};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "Tuple", "fst": {$: "Some", "value": _owner_1}, "snd": true};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0) {
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
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1261$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $$$$047handle$045controls$058raw_step$(_todo_0, _stack_0, _next_0) {
  if (_todo_0.$ === "Nil") {
    return $$$$047handle$045controls$058raw_finished$(_stack_0);
  } else {
    const _t_0 = _todo_0["head"];
    if (_t_0.$ === "../handle-controls.VisitRaw") {
      const _value_0 = _t_0["value"];
      const _rest_0 = _todo_0["tail"];
      return run_tail(_next_0(($List$append$(($$$$047handle$045controls$058raw_expand$(_value_0)), _rest_0))), _stack_0);
    } else if (_t_0.$ === "../handle-controls.Ready") {
      const _text_0 = _t_0["text"];
      const _rest_1 = _todo_0["tail"];
      return run_tail(_next_0(_rest_1), {$: "Con", "head": _text_0, "tail": _stack_0});
    } else if (_t_0.$ === "../handle-controls.ArrayEnd") {
      const _count_0 = _t_0["count"];
      const _rest_2 = _todo_0["tail"];
      return run_tail(_next_0(_rest_2), ($$$$047handle$045controls$058array_end$(_count_0, _stack_0)));
    } else if (_t_0.$ === "../handle-controls.ObjectEnd") {
      const _count_1 = _t_0["count"];
      const _rest_3 = _todo_0["tail"];
      return run_tail(_next_0(_rest_3), ($$$$047handle$045controls$058object_end$(_count_1, _stack_0)));
    } else {
      const _name_0 = _t_0["name"];
      const _rest_4 = _todo_0["tail"];
      return run_tail(_next_0(_rest_4), ($$$$047handle$045controls$058field_end$(_name_0, _stack_0)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read$1260$(_frame_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_join$1260$(_declaration_0, _prepared_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058grant$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_query$1260$())))))({$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _incomingPresent_0, _incoming_0, _advanced_0) {
  const _world_0 = _advanced_0["fst"];
  const _tick_0 = _advanced_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1260$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1260$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read$1261$(_frame_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_join$1261$(_declaration_0, _prepared_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058grant$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_query$1261$())))))({$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replace_clock_advanced$1261$(_id_0, _incomingPresent_0, _incoming_0, _advanced_0) {
  const _world_0 = _advanced_0["fst"];
  const _tick_0 = _advanced_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058advance_clock$1261$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058live_join$1261$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $$$$047handle$045controls$058raw_finished$(_stack_0) {
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

function $$$$047handle$045controls$058raw_expand$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Missing") {
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": "missing"}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": "null"}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
    const _value_1 = _value_0["value"];
    const _x_0 = ($U32$show$(_value_1));
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("u32:" + _x_0)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
    const _magnitude_0 = _value_0["magnitude"];
    const _x_1 = ($Nat$show$(_magnitude_0));
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("integer:" + _x_1)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
    const _value_2 = _value_0["value"];
    const _x_2 = f32_show(_value_2);
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("f32:" + _x_2)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
    const _high_0 = _value_0["high"];
    const _low_0 = _value_0["low"];
    const _x_3 = ($U32$show$(_low_0));
    const _x_4 = ($U32$show$(_high_0));
    const _x_5 = (":" + _x_3);
    const _x_6 = (_x_4 + _x_5);
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("binary64:" + _x_6)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
    const _value_3 = _value_0["value"];
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("str:" + _value_3)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
    const _units_0 = _value_0["units"];
    const _x_7 = ($List$show$1260$(_units_0));
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("utf16:" + _x_7)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
    const _t_0 = _value_0["value"];
    if (_t_0) {
      return {$: "Con", "head": {$: "../handle-controls.Ready", "text": "bool:true"}, "tail": {$: "Nil"}};
    } else {
      return {$: "Con", "head": {$: "../handle-controls.Ready", "text": "bool:false"}, "tail": {$: "Nil"}};
    }
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle") {
    const _namespace_0 = _value_0["namespace"];
    const _id_0 = _value_0["id"];
    const _x_8 = ($U32$show$(_id_0));
    const _x_9 = ($U32$show$(_namespace_0));
    const _x_10 = (":" + _x_8);
    const _x_11 = (_x_9 + _x_10);
    return {$: "Con", "head": {$: "../handle-controls.Ready", "text": ("handle:" + _x_11)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _items_0 = _value_0["items"];
    return $List$append$(($$$$047handle$045controls$058raw_visits$(_items_0)), {$: "Con", "head": {$: "../handle-controls.ArrayEnd", "count": ($List$length$(_items_0))}, "tail": {$: "Nil"}});
  } else {
    const _fields_0 = _value_0["fields"];
    return $List$append$(($$$$047handle$045controls$058raw_field_visits$(_fields_0)), {$: "Con", "head": {$: "../handle-controls.ObjectEnd", "count": ($List$length$(_fields_0))}, "tail": {$: "Nil"}});
  }
}

function $$$$047handle$045controls$058array_end$(_count_0, _stack_0) {
  return $$$$047handle$045controls$058array_end_pair$(($$$$047handle$045controls$058collect_strings$(_count_0, _stack_0, {$: "Nil"})));
}

function $$$$047handle$045controls$058object_end$(_count_0, _stack_0) {
  return $$$$047handle$045controls$058object_end_pair$(($$$$047handle$045controls$058collect_strings$(_count_0, _stack_0, {$: "Nil"})));
}

function $$$$047handle$045controls$058field_end$(_name_0, _stack_0) {
  if (_stack_0.$ === "Con") {
    const _value_0 = _stack_0["head"];
    const _rest_0 = _stack_0["tail"];
    const _x_0 = (":" + _value_0);
    return {$: "Con", "head": (_name_0 + _x_0), "tail": _rest_0};
  } else {
    return {$: "Nil"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_join$1260$(_declaration_0, _prepared_0, _receipts_0, _pending_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const _handle_0 = _t_0["handle"];
  const _error_0 = _t_0["error"];
  const _cursor_0 = _t_0["cursor"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1261$(_cap_0) {
  const _get_0 = _cap_0["get"];
  return _get_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058grant$1260$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  return _grant_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_query$1260$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058read$1260$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Swapped") {
    const _previous_0 = _t_0["previous"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0};
  } else {
    const _incoming_0 = _t_0["incoming"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, ($$$$047handle$045application$058take$1260$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058next_clock$(_available_0, _clock_0) {
  if (!_available_0) {
    return _clock_0;
  } else {
    return ((_clock_0 + 1) >>> 0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058read_join$1261$(_declaration_0, _prepared_0, _receipts_0, _pending_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const _handle_0 = _t_0["handle"];
  const _error_0 = _t_0["error"];
  const _cursor_0 = _t_0["cursor"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058read_field$1263$(_cap_0) {
  const _get_0 = _cap_0["get"];
  return _get_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058grant$1261$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  return _grant_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045declaration$058readonly_query$1261$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058read$1261$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058replaced$1261$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Swapped") {
    const _previous_0 = _t_0["previous"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0};
  } else {
    const _incoming_0 = _t_0["incoming"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CapacityExceeded"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_world$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, ($$$$047handle$045application$058take$1261$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
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

function $$$$047handle$045controls$058raw_visits$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return {$: "Con", "head": {$: "../handle-controls.VisitRaw", "value": _value_0}, "tail": ($$$$047handle$045controls$058raw_visits$(_rest_0))};
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

function $$$$047handle$045controls$058raw_field_visits$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _fields_0["head"];
    const _name_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _fields_0["tail"];
    return {$: "Con", "head": {$: "../handle-controls.VisitRaw", "value": _value_0}, "tail": {$: "Con", "head": {$: "../handle-controls.FieldEnd", "name": _name_0}, "tail": ($$$$047handle$045controls$058raw_field_visits$(_rest_0))}};
  }
}

function $$$$047handle$045controls$058array_end_pair$(_result_0) {
  const _values_0 = _result_0["fst"];
  const _rest_0 = _result_0["snd"];
  const _x_0 = ($$$$047handle$045controls$058string_join$(_values_0));
  const _x_1 = (_x_0 + "]");
  return {$: "Con", "head": ("[" + _x_1), "tail": _rest_0};
}

function $$$$047handle$045controls$058collect_strings$($0, $1, $2) {
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

function $$$$047handle$045controls$058object_end_pair$(_result_0) {
  const _values_0 = _result_0["fst"];
  const _rest_0 = _result_0["snd"];
  const _x_0 = ($$$$047handle$045controls$058string_join$(_values_0));
  const _x_1 = (_x_0 + "}");
  return {$: "Con", "head": ("{" + _x_1), "tail": _rest_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058read$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Declaration", "grant": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_family$1260$()), "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058family_match$1260$(_x_0);
}), "clauses": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Clause", "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047handle$045application$058identity$1260$()))), "mode": {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Read"}}, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1261$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incomingPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1260$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $$$$047handle$045application$058take$1260$(_column_0) {
  return {$: "Tuple", "fst": {$: "Unit"}, "snd": _column_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045query$045declaration$058read$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Declaration", "grant": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_family$1261$()), "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058family_match$1261$(_x_0);
}), "clauses": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Clause", "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1261$(($$$$047handle$045application$058identity$1261$()))), "mode": {$: "../../../../../../../../../../../../bendvy/src/ecs/ordinary-query-declaration.Read"}}, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1263$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_store$1261$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1261$(_rest_0, _id_0, _incomingPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1261$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $$$$047handle$045application$058take$1261$(_column_0) {
  return {$: "Tuple", "fst": {$: "Unit"}, "snd": _column_0};
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
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

function $$$$047handle$045controls$058string_join$(_items_0) {
  if (_items_0.$ === "Nil") {
    return "";
  } else {
    const _item_0 = _items_0["head"];
    const _t_0 = _items_0["tail"];
    if (_t_0.$ === "Nil") {
      return _item_0;
    } else {
      const _x_0 = ($$$$047handle$045controls$058string_join$(_t_0));
      const _x_1 = ("," + _x_0);
      return (_item_0 + _x_1);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_family$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.Read", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1260$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058family_match$1260$(_frame_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_join$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Required"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1260$(_frame_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incoming_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _previous_0 = _result_0["previous"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1260$(_previous_0)));
  } else {
    const _column_1 = _result_0["column"];
    const _incoming_1 = _result_0["incoming"];
    return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1260$(_rest_0, _column_1)), "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.SwapRejected", "incoming": _incoming_1}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1260$(_column_0, _target_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, ($Bool$and$((_target_0 > 0), (_target_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_family$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.Read", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1261$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058family_match$1261$(_frame_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_join$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Required"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1261$(_frame_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058swap_join$1261$(_rest_0, _id_0, _incoming_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _previous_0 = _result_0["previous"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1261$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058owner_present$1261$(_previous_0)));
  } else {
    const _column_1 = _result_0["column"];
    const _incoming_1 = _result_0["incoming"];
    return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1261$(_rest_0, _column_1)), "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.SwapRejected", "incoming": _incoming_1}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure$1261$(_column_0, _target_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1261$(_column_0, _target_0, ($Bool$and$((_target_0 > 0), (_target_0 <= 131072))));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1260$(_frame_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_join$1260$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047handle$045application$058identity$1260$())))}, _tx_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_join$1260$(_mode_0, _observed_0) {
  const _frame_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _frame_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_value$1260$(_mode_0, _value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, _observed_0) {
  const _previous_0 = _observed_0["fst"];
  const _wasPresent_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1260$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0)))), "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Swapped", "previous": _previous_0}};
}

function $$$$047handle$045application$058put$1260$(_unit_0, _column_0) {
  return _column_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Owned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, _valid_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
    }
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
    }
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
    }
  } else {
    const _carrier_2 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058get$1261$(_frame_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_join$1261$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/component.Family", "name": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045declaration$058key$1261$(($$$$047handle$045application$058identity$1261$())))}, _tx_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_join$1261$(_mode_0, _observed_0) {
  const _frame_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _frame_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_value$1260$(_mode_0, _value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058mark_swapped$1261$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, _observed_0) {
  const _previous_0 = _observed_0["fst"];
  const _wasPresent_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1261$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1261$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0)))), "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Swapped", "previous": _previous_0}};
}

function $$$$047handle$045application$058put$1261$(_unit_0, _column_0) {
  return _column_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1261$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Owned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1261$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1261$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_checked$1261$(_column_0, _target_0, _valid_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
    }
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
    }
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
    }
  } else {
    const _carrier_2 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
    }
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_join$1260$(_handle_0, _error_0, _cursor_0, _observed_0) {
  const _tx_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get$1260$(_family_0, _tx_0, _handle_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get_join$1260$(_undo_0, _commands_0, _events_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get$1260$(_family_0, _world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058selected_value$1260$(_mode_0, _value_0) {
  if (_mode_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/compose.Required") {
    if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/compose.Present") {
    if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/compose.Absent") {
    if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.Found") {
      return true;
    } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1260$(17, _values_0, _stamps_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047compose$058read_join$1261$(_handle_0, _error_0, _cursor_0, _observed_0) {
  const _tx_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get$1261$(_family_0, _tx_0, _handle_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get_join$1261$(_undo_0, _commands_0, _events_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get$1261$(_family_0, _world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1261$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1261$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1261$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1261$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1261$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1261$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1261$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1261$(17, _values_0, _stamps_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1261$(_target_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_ensure_state$1261$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get_join$1260$(_undo_0, _commands_0, _events_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get$1260$(_family_0, _world_0, _handle_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_owned$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_read$(($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0))))), _id_0, _live_0)), _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_entries_0, _id_0, _stamp_0) {
  return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _id_0, "stamp": _stamp_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0) {
  if (!_incoming_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$((_key_0 === _id_0), _stamp_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$(_column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1260$($0, $1, $2, $3, $4, $5, $6) {
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
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, _column_0, _fits_0) {
  if (_fits_0) {
    return _column_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$(_column_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1260$(17, _values_0, _metadata_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058tx_get_join$1261$(_undo_0, _commands_0, _events_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get$1261$(_family_0, _world_0, _handle_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_owned$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_read$(($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0))))), _id_0, _live_0)), _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1261$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1261$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1261$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_0)));
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$(_column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1261$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1261$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1261$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1261$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058grow$1261$($0, $1, $2, $3, $4, $5, $6) {
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
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_prepared$1261$(_target_0, _column_0, _fits_0) {
  if (_fits_0) {
    return _column_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1261$(_column_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_sized$1261$(_target_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1261$(17, _values_0, _metadata_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_owned$1260$(_id_0, _observed_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.MissingEntity"}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_store$1260$(_id_0, ($$$$047handle$045application$058take$1260$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_read$(_allowed_0, _id_0, _live_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _live_0, "snd": false};
  } else {
    return {$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$((_key_0 === _id_0), {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _key_0, "stamp": _stamp_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0) {
  if (!_wasPresent_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _tick_0, "changed": _tick_0};
  } else {
    const _added_0 = _stamp_0["added"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _added_0, "changed": _tick_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$(_found_0, _stamp_0, _other_0) {
  if (_found_0) {
    return _stamp_0;
  } else {
    return _other_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)), (_id_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0) {
  if (_depth_0 === 0) {
    return [{$: "None"}];
  } else {
    const _rest_0 = (_depth_0 - 1);
    return array_node(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_rest_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_rest_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return _column_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1260$($0, $1, $2, $3, $4, $5, $6) {
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
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1260$(_depth_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_live_owned$1261$(_id_0, _observed_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/component.MissingEntity"}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_store$1261$(_id_0, ($$$$047handle$045application$058take$1261$(_store_0)))), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1261$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1261$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1261$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1261$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0) {
  if (_depth_0 === 0) {
    return [{$: "None"}];
  } else {
    const _rest_0 = (_depth_0 - 1);
    return array_node(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_rest_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_recovered$1261$(_target_0, _column_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058ensure_sized$1261$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_ensure_state$1261$(_target_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_0)));
  } else {
    return _column_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_grow$1261$($0, $1, $2, $3, $4, $5, $6) {
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
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        } else {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0);
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058absent$1261$(_depth_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1260$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_store$1260$(_id_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_projected$1260$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1260$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$(_equal_0, _entry_0, _rest_0) {
  if (_equal_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _entry_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0, _fits_0) {
  if (!_isnormal_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_exceptional_0, _id_0))};
  } else {
    if (!_fits_0) {
      return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
    } else {
      const _x_0 = ((_id_0 - 1) >>> 0);
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, {$: "Tuple", fst: _added_0, snd: _added_0[_x_0 % _added_0.length]});
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0) {
  return $Bool$and$((_id_0 > 0), (_id_0 <= 131072));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $Bool$to_u32$(_b_0) {
  if (!_b_0) {
    return 0;
  } else {
    return 1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058with_store_finish$1262$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_store$1261$(_id_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_projected$1261$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1261$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_projected$1260$(_rest_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1260$(_rest_0, _column_0)), "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058access$1260$(_value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0) {
  if (!_isnormal_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_exceptional_0, _id_0, _stamp_0))};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$(17, _id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, (_id_0 <= _capacity_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _observed_0) {
  const _added_0 = _observed_0["fst"];
  const _first_0 = _observed_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, {$: "Tuple", fst: _changed_0, snd: _changed_0[_x_0 % _changed_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$($0, $1) {
  for (;;) {
    {
      const _rows_0 = $0;
      const _values_0 = $1;
      if (_rows_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryNil") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058get_projected$1261$(_rest_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($$$$047handle$045application$058put$1261$(_rest_0, _column_0)), "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058access$1260$(_value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view$1261$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1261$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1261$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1261$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryNil") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047component$058access$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.ComponentAbsent"};
  } else {
    const _value_1 = _value_0["value"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/component.Found", "value": _value_1};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
        } else {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_fits_0) {
          return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, _observed_0) {
  const _changed_0 = _observed_0["fst"];
  const _last_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _first_0, "changed": _last_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0) {
  const _first_0 = _stamp_0["added"];
  const _last_0 = _stamp_0["changed"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = ((_id_0 - 1) >>> 0);
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": (_added_0[_x_0 % _added_0.length] = _first_0, _added_0), "changed": (_changed_0[_x_1 % _changed_0.length] = _last_0, _changed_0), "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, ($$$$047handle$045application$058project$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047handle$045application$058project$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047handle$045application$058project$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, ($$$$047handle$045application$058project$1261$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047handle$045application$058project$1261$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1261$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1261$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047handle$045application$058project$1261$(_owned_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1261$(_id_0, {$: "None"}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1261$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1261$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1261$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $$$$047handle$045application$058project$1260$(_payload_0) {
  const _cells_0 = _payload_0["cells"];
  const _name_0 = _payload_0["name"];
  const _target_0 = _payload_0["target"];
  return $$$$047handle$045application$058project_join$1260$(_name_0, _target_0, ($$$$047handle$045application$058array_project$(_cells_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1260$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1260$(($$$$047handle$045application$058project$1260$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047handle$045application$058project$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, ($$$$047handle$045application$058project$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047handle$045application$058project$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $$$$047handle$045application$058project$1261$(_payload_0) {
  const _cells_0 = _payload_0["cells"];
  const _name_0 = _payload_0["name"];
  const _target_0 = _payload_0["target"];
  return $$$$047handle$045application$058project_join$1261$(_name_0, _target_0, ($$$$047handle$045application$058array_project$(_cells_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058view_taken$1261$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1261$(($$$$047handle$045application$058project$1261$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047handle$045application$058project$1261$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, ($$$$047handle$045application$058project$1261$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047handle$045application$058project$1261$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../../../../../../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047handle$045application$058project_join$1260$(_name_0, _target_0, _observed_0) {
  const _cells_0 = _observed_0["fst"];
  const _items_0 = _observed_0["snd"];
  return $$$$047handle$045application$058project_target$1260$(_name_0, _cells_0, _items_0, _target_0);
}

function $$$$047handle$045application$058array_project$(_cells_0) {
  if (_cells_0.length === 1) {
    const _value_0 = _cells_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": _value_0}, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _cells_0.slice(0, _cells_0.length >> 1);
    const _right_0 = _cells_0.slice(_cells_0.length >> 1);
    return $$$$047handle$045application$058array_join$(($$$$047handle$045application$058array_project$(_left_0)), ($$$$047handle$045application$058array_project$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1260$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047handle$045application$058project_join$1261$(_name_0, _target_0, _observed_0) {
  const _cells_0 = _observed_0["fst"];
  const _items_0 = _observed_0["snd"];
  return $$$$047handle$045application$058project_target$1261$(_name_0, _cells_0, _items_0, _target_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed$1261$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1261$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047handle$045application$058project_target$1260$(_name_0, _cells_0, _items_0, _target_0) {
  if (_target_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "None"}}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "tail": {$: "Nil"}}}}}};
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    return {$: "Tuple", "fst": {$: "../handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "Some", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _id_0}}}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _namespace_0, "id": _id_0}}, "tail": {$: "Nil"}}}}}};
  }
}

function $$$$047handle$045application$058array_join$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1260$(_view_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047handle$045application$058project_target$1261$(_name_0, _cells_0, _items_0, _target_0) {
  if (_target_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "None"}}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"}}, "tail": {$: "Nil"}}}}}};
  } else {
    const _t_0 = _target_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    return {$: "Tuple", "fst": {$: "../handle-application.Payload", "cells": _cells_0, "name": _name_0, "target": {$: "Some", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _id_0}}}, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "cells", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _items_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "name", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": "target", "value": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _namespace_0, "id": _id_0}}, "tail": {$: "Nil"}}}}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058viewed_return$1261$(_view_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1261$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
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