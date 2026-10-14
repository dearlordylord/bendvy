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
// Program
// =======

function $main$() {
  return {$: "Candidate", "first": ($cases$1260$()), "second": ($cases$1261$())};
}

function $cases$1260$() {
  return {$: "Cases", "invalidCodec": ($fallible$045composition$045v1$047request$045fixture$058run$1260$({$: "ecs/bundle-requests.Spawn"}, {$: "ecs/decode-data.Text", "value": "wrong"})), "acceptedCodec": ($fallible$045composition$045v1$047request$045fixture$058run$1260$({$: "ecs/bundle-requests.Spawn"}, {$: "ecs/decode-data.Number", "value": 7}))};
}

function $cases$1261$() {
  return {$: "Cases", "invalidCodec": ($fallible$045composition$045v1$047request$045fixture$058run$1261$({$: "ecs/bundle-requests.Spawn"}, {$: "ecs/decode-data.Text", "value": "wrong"})), "acceptedCodec": ($fallible$045composition$045v1$047request$045fixture$058run$1261$({$: "ecs/bundle-requests.Spawn"}, {$: "ecs/decode-data.Number", "value": 7}))};
}

function $fallible$045composition$045v1$047request$045fixture$058run$1260$(_operation_0, _raw_0) {
  return $fallible$045composition$045v1$047request$045fixture$058created$1260$(_operation_0, _raw_0, ($ecs$047world$058create$1260$(($ecs$047world$058factory$()), ($fixture$058owned$({$: "ecs/decode-data.Number", "value": 100})))));
}

function $fallible$045composition$045v1$047request$045fixture$058run$1261$(_operation_0, _raw_0) {
  return $fallible$045composition$045v1$047request$045fixture$058created$1261$(_operation_0, _raw_0, ($ecs$047world$058create$1261$(($ecs$047world$058factory$()), ($fixture$058owned$({$: "ecs/decode-data.Number", "value": 100})))));
}

function $fallible$045composition$045v1$047request$045fixture$058created$1260$(_operation_0, _raw_0, _value_0) {
  if (_value_0.$ === "ecs/world.CreateRejected") {
    return {$: "fallible-composition-v1/request-fixture.CreateRejected"};
  } else {
    const _world_0 = _value_0["world"];
    return $fallible$045composition$045v1$047request$045fixture$058in_world$1260$(_operation_0, _raw_0, _world_0);
  }
}

function $ecs$047world$058create$1260$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $ecs$047world$058create_checked$1260$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $ecs$047world$058factory$() {
  return {$: "ecs/world.Factory", "nextNamespace": 1};
}

function $fixture$058owned$(_raw_0) {
  return {$: "fixture.Owner", "raw": _raw_0, "original": _raw_0, "words": array_node([81], [82]), "flags": array_node([false], [true])};
}

function $fallible$045composition$045v1$047request$045fixture$058created$1261$(_operation_0, _raw_0, _value_0) {
  if (_value_0.$ === "ecs/world.CreateRejected") {
    return {$: "fallible-composition-v1/request-fixture.CreateRejected"};
  } else {
    const _world_0 = _value_0["world"];
    return $fallible$045composition$045v1$047request$045fixture$058in_world$1261$(_operation_0, _raw_0, _world_0);
  }
}

function $ecs$047world$058create$1261$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $ecs$047world$058create_checked$1261$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $fallible$045composition$045v1$047request$045fixture$058in_world$1260$(_operation_0, _raw_0, _world_0) {
  return $fallible$045composition$045v1$047request$045fixture$058in_world_snapshotted$1260$(_operation_0, _raw_0, ($fixture$058snapshot$1260$(_world_0)));
}

function $ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "ecs/world.CreateRejected", "factory": {$: "ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "ecs/world.Created", "factory": {$: "ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": {$: "Unit"}, "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $fallible$045composition$045v1$047request$045fixture$058in_world$1261$(_operation_0, _raw_0, _world_0) {
  return $fallible$045composition$045v1$047request$045fixture$058in_world_snapshotted$1261$(_operation_0, _raw_0, ($fixture$058snapshot$1261$(_world_0)));
}

function $ecs$047world$058create_checked$1261$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "ecs/world.CreateRejected", "factory": {$: "ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "ecs/world.Created", "factory": {$: "ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": {$: "Unit"}, "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $fallible$045composition$045v1$047request$045fixture$058in_world_snapshotted$1260$(_operation_0, _raw_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _before_0 = _value_0["snd"];
  return $fallible$045composition$045v1$047request$045fixture$058in_world_with_before$1260$(_operation_0, _raw_0, _before_0, _world_0);
}

function $fixture$058snapshot$1260$(_world_0) {
  return $fixture$058snapshot_resource$1260$(($ecs$047world$058observe_resource$1260$(_world_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058in_world_snapshotted$1261$(_operation_0, _raw_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _before_0 = _value_0["snd"];
  return $fallible$045composition$045v1$047request$045fixture$058in_world_with_before$1261$(_operation_0, _raw_0, _before_0, _world_0);
}

function $fixture$058snapshot$1261$(_world_0) {
  return $fixture$058snapshot_resource$1261$(($ecs$047world$058observe_resource$1261$(_world_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058in_world_with_before$1260$(_operation_0, _raw_0, _before_0, _world_0) {
  return $fallible$045composition$045v1$047request$045fixture$058returned$1260$(_before_0, run_loop($ecs$047capabilities$058invoke_owned$1266$({$: "ecs/decode-fallible-constructed-requests.Input", "operation": _operation_0, "raw": ($fixture$058input$(_raw_0))}, ($ecs$047decode$045local$058begin_frame$1260$(_world_0, ($ecs$047persistence$045declaration$058constructed$1260$({$: "ecs/decode-data.Integer"})))))));
}

function $fixture$058snapshot_resource$1260$(_value_0) {
  const _t_0 = _value_0["fst"];
  const _namespace_0 = _t_0["namespace"];
  const _nextId_0 = _t_0["nextId"];
  const _highWater_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _store_0 = _t_0["store"];
  const _resource_0 = _t_0["resource"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystemId_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _view_0 = _value_0["snd"];
  return $fixture$058snapshot_live$1260$({$: "fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _store_0, _resource_0, _pending_0, _view_0, ($fixture$058array$1260$(_live_0)));
}

function $ecs$047world$058observe_resource$1260$(_world_0) {
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
  return $ecs$047world$058observe_resource_finish$1260$(($fixture$058view$(_resource_0)), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $fallible$045composition$045v1$047request$045fixture$058in_world_with_before$1261$(_operation_0, _raw_0, _before_0, _world_0) {
  return $fallible$045composition$045v1$047request$045fixture$058returned$1261$(_before_0, run_loop($ecs$047capabilities$058invoke_owned$1267$({$: "ecs/decode-fallible-constructed-requests.Input", "operation": _operation_0, "raw": ($fixture$058input$(_raw_0))}, ($ecs$047decode$045local$058begin_frame$1261$(_world_0, ($ecs$047persistence$045declaration$058constructed$1262$({$: "ecs/decode-data.Integer"})))))));
}

function $fixture$058snapshot_resource$1261$(_value_0) {
  const _t_0 = _value_0["fst"];
  const _namespace_0 = _t_0["namespace"];
  const _nextId_0 = _t_0["nextId"];
  const _highWater_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _store_0 = _t_0["store"];
  const _resource_0 = _t_0["resource"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystemId_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _view_0 = _value_0["snd"];
  return $fixture$058snapshot_live$1261$({$: "fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _store_0, _resource_0, _pending_0, _view_0, ($fixture$058array$1260$(_live_0)));
}

function $ecs$047world$058observe_resource$1261$(_world_0) {
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
  return $ecs$047world$058observe_resource_finish$1261$(($fixture$058view$(_resource_0)), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $fallible$045composition$045v1$047request$045fixture$058returned$1260$(_before_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "ecs/decode-fallible-constructed-requests.Accepted") {
    const _t_2 = _t_1["target"];
    const _namespace_0 = _t_2["namespace"];
    const _id_0 = _t_2["id"];
    const _spawned_0 = _t_1["spawned"];
    const _canonical_0 = _t_1["canonical"];
    const _undo_0 = _t_1["undo"];
    return $fallible$045composition$045v1$047request$045fixture$058finished$1260$(_before_0, 1, {$: "fallible-composition-v1/request-fixture.Accepted", "namespace": _namespace_0, "id": _id_0, "spawned": _spawned_0, "canonical": _canonical_0}, {$: "Some", "value": _undo_0}, ($ecs$047decode$045requests$058finish$1260$(_owner_0, {$: "ecs/transaction.Failure", "error": {$: "Unit"}})));
  } else {
    const _raw_0 = _t_1["owner"];
    const _error_0 = _t_1["error"];
    return $fallible$045composition$045v1$047request$045fixture$058finished$1260$(_before_0, 0, ($fallible$045composition$045v1$047request$045fixture$058refusal$(_error_0, _raw_0)), {$: "None"}, ($ecs$047decode$045requests$058finish$1260$(_owner_0, {$: "ecs/transaction.Failure", "error": {$: "Unit"}})));
  }
}

function $ecs$047capabilities$058invoke_owned$1266$(_args_0, _ctx_0) {
  return $fallible$045composition$045v1$047request$045fixture$058body$1260$(_args_0, _ctx_0);
}

function $fixture$058input$(_raw_0) {
  return {$: "fixture.Input", "raw": _raw_0, "words": array_node([71], [72]), "flags": array_node([true], [false])};
}

function $ecs$047decode$045local$058begin_frame$1260$(_world_0, _codec_0) {
  return {$: "ecs/decode-frame.Frame", "owner": ($ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0)), "handle": {$: "ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $ecs$047persistence$045declaration$058constructed$1260$(_codec_0) {
  return {$: "ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $fixture$058snapshot_live$1260$(_meta_0, _store_0, _resource_0, _pending_0, _view_0, _live_0) {
  const _namespace_0 = _meta_0["namespace"];
  const _nextId_0 = _meta_0["nextId"];
  const _highWater_0 = _meta_0["highWater"];
  const _capacity_0 = _meta_0["capacity"];
  const _depth_0 = _meta_0["depth"];
  const _events_0 = _meta_0["events"];
  const _registrations_0 = _meta_0["registrations"];
  const _nextSystemId_0 = _meta_0["nextSystemId"];
  const _clock_0 = _meta_0["clock"];
  const _live_1 = _live_0["fst"];
  const _values_0 = _live_0["snd"];
  return $fixture$058snapshot_pending$1260$({$: "fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _view_0, _values_0, ($ecs$047world$058pending_count$1260$({$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0})));
}

function $fixture$058array$1260$(_owner_0) {
  if (_owner_0.length === 1) {
    const _value_0 = _owner_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": _value_0, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _owner_0.slice(0, _owner_0.length >> 1);
    const _right_0 = _owner_0.slice(_owner_0.length >> 1);
    return $fixture$058joined$1260$(($fixture$058array$1260$(_left_0)), ($fixture$058array$1260$(_right_0)));
  }
}

function $ecs$047world$058observe_resource_finish$1260$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _resource_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $fixture$058view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _original_0 = _value_0["original"];
  const _values_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $fixture$058words$(_raw_0, _original_0, _flags_0, ($fixture$058array$1261$(_values_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058returned$1261$(_before_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _owner_0 = _t_0["owner"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "ecs/decode-fallible-constructed-requests.Accepted") {
    const _t_2 = _t_1["target"];
    const _namespace_0 = _t_2["namespace"];
    const _id_0 = _t_2["id"];
    const _spawned_0 = _t_1["spawned"];
    const _canonical_0 = _t_1["canonical"];
    const _undo_0 = _t_1["undo"];
    return $fallible$045composition$045v1$047request$045fixture$058finished$1261$(_before_0, 1, {$: "fallible-composition-v1/request-fixture.Accepted", "namespace": _namespace_0, "id": _id_0, "spawned": _spawned_0, "canonical": _canonical_0}, {$: "Some", "value": _undo_0}, ($ecs$047decode$045requests$058finish$1261$(_owner_0, {$: "ecs/transaction.Failure", "error": {$: "Unit"}})));
  } else {
    const _raw_0 = _t_1["owner"];
    const _error_0 = _t_1["error"];
    return $fallible$045composition$045v1$047request$045fixture$058finished$1261$(_before_0, 0, ($fallible$045composition$045v1$047request$045fixture$058refusal$(_error_0, _raw_0)), {$: "None"}, ($ecs$047decode$045requests$058finish$1261$(_owner_0, {$: "ecs/transaction.Failure", "error": {$: "Unit"}})));
  }
}

function $ecs$047capabilities$058invoke_owned$1267$(_args_0, _ctx_0) {
  return $fallible$045composition$045v1$047request$045fixture$058body$1261$(_args_0, _ctx_0);
}

function $ecs$047decode$045local$058begin_frame$1261$(_world_0, _codec_0) {
  return {$: "ecs/decode-frame.Frame", "owner": ($ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0)), "handle": {$: "ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $ecs$047persistence$045declaration$058constructed$1262$(_codec_0) {
  return {$: "ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $fixture$058snapshot_live$1261$(_meta_0, _store_0, _resource_0, _pending_0, _view_0, _live_0) {
  const _namespace_0 = _meta_0["namespace"];
  const _nextId_0 = _meta_0["nextId"];
  const _highWater_0 = _meta_0["highWater"];
  const _capacity_0 = _meta_0["capacity"];
  const _depth_0 = _meta_0["depth"];
  const _events_0 = _meta_0["events"];
  const _registrations_0 = _meta_0["registrations"];
  const _nextSystemId_0 = _meta_0["nextSystemId"];
  const _clock_0 = _meta_0["clock"];
  const _live_1 = _live_0["fst"];
  const _values_0 = _live_0["snd"];
  return $fixture$058snapshot_pending$1261$({$: "fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _view_0, _values_0, ($ecs$047world$058pending_count$1261$({$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0})));
}

function $ecs$047world$058observe_resource_finish$1261$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _resource_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $fallible$045composition$045v1$047request$045fixture$058finished$1260$(_before_0, _prepared_0, _result_0, _reverse_0, _value_0) {
  if (_reverse_0.$ === "Some") {
    const _reverse_1 = _reverse_0["value"];
    if (_value_0.$ === "ecs/bundle-batch.Failed") {
      const _world_0 = _value_0["world"];
      const _packets_0 = _value_0["payloads"];
      const _error_0 = _value_0["error"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1260$(_before_0, _prepared_0, _result_0, ($fallible$045composition$045v1$047request$045fixture$058recover$(_reverse_1, _packets_0)), {$: "ecs/transaction.Failure", "error": _error_0}, ($fixture$058snapshot$1260$(_world_0)));
    } else {
      const _world_1 = _value_0["world"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1260$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Success"}, ($fixture$058snapshot$1260$(_world_1)));
    }
  } else {
    if (_value_0.$ === "ecs/bundle-batch.Failed") {
      const _world_2 = _value_0["world"];
      const _error_1 = _value_0["error"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1260$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Failure", "error": _error_1}, ($fixture$058snapshot$1260$(_world_2)));
    } else {
      const _world_3 = _value_0["world"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1260$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Success"}, ($fixture$058snapshot$1260$(_world_3)));
    }
  }
}

function $ecs$047decode$045requests$058finish$1260$(_owner_0, _outcome_0) {
  const _batch_0 = _owner_0["batch"];
  return $ecs$047bundle$045batch$058finish$1260$(_batch_0, _outcome_0);
}

function $fallible$045composition$045v1$047request$045fixture$058refusal$(_error_0, _owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "fallible-composition-v1/request-fixture.Refused", "owner": {$: "None"}, "error": _error_0};
  } else {
    const _owner_1 = _owner_0["value"];
    return $fallible$045composition$045v1$047request$045fixture$058refusal_view$(_error_0, ($fixture$058input_view$(_owner_1)));
  }
}

function $fallible$045composition$045v1$047request$045fixture$058body$1260$(_input_0, _ctx_0) {
  return $ecs$047capabilities$058owned_request$1266$(_ctx_0, _input_0);
}

function $ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0) {
  return {$: "ecs/decode-requests.Owner", "batch": ($ecs$047bundle$045batch$058begin$1260$(($ecs$047transaction$058begin$1260$(_world_0)))), "declaration": _codec_0};
}

function $fixture$058snapshot_pending$1260$(_meta_0, _view_0, _live_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _pending_0 = _value_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": {$: "fixture.Snapshot", "meta": _meta_0, "live": _live_0, "store": {$: "Unit"}, "resource": _view_0, "pending": _pending_0}};
}

function $ecs$047world$058pending_count$1260$(_world_0) {
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
  return $ecs$047world$058pending_count_join$1260$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($ecs$047world$058pending_length$1260$(_pending_0)));
}

function $fixture$058joined$1260$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $fixture$058words$(_raw_0, _original_0, _flags_0, _value_0) {
  const _words_0 = _value_0["fst"];
  const _list_0 = _value_0["snd"];
  return $fixture$058flagged$(_raw_0, _original_0, _words_0, _list_0, ($fixture$058array$1260$(_flags_0)));
}

function $fixture$058array$1261$(_owner_0) {
  if (_owner_0.length === 1) {
    const _value_0 = _owner_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": _value_0, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _owner_0.slice(0, _owner_0.length >> 1);
    const _right_0 = _owner_0.slice(_owner_0.length >> 1);
    return $fixture$058joined$1261$(($fixture$058array$1261$(_left_0)), ($fixture$058array$1261$(_right_0)));
  }
}

function $fallible$045composition$045v1$047request$045fixture$058finished$1261$(_before_0, _prepared_0, _result_0, _reverse_0, _value_0) {
  if (_reverse_0.$ === "Some") {
    const _reverse_1 = _reverse_0["value"];
    if (_value_0.$ === "ecs/bundle-batch.Failed") {
      const _world_0 = _value_0["world"];
      const _packets_0 = _value_0["payloads"];
      const _error_0 = _value_0["error"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1261$(_before_0, _prepared_0, _result_0, ($fallible$045composition$045v1$047request$045fixture$058recover$(_reverse_1, _packets_0)), {$: "ecs/transaction.Failure", "error": _error_0}, ($fixture$058snapshot$1261$(_world_0)));
    } else {
      const _world_1 = _value_0["world"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1261$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Success"}, ($fixture$058snapshot$1261$(_world_1)));
    }
  } else {
    if (_value_0.$ === "ecs/bundle-batch.Failed") {
      const _world_2 = _value_0["world"];
      const _error_1 = _value_0["error"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1261$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Failure", "error": _error_1}, ($fixture$058snapshot$1261$(_world_2)));
    } else {
      const _world_3 = _value_0["world"];
      return $fallible$045composition$045v1$047request$045fixture$058observed$1261$(_before_0, _prepared_0, _result_0, {$: "Nil"}, {$: "ecs/transaction.Success"}, ($fixture$058snapshot$1261$(_world_3)));
    }
  }
}

function $ecs$047decode$045requests$058finish$1261$(_owner_0, _outcome_0) {
  const _batch_0 = _owner_0["batch"];
  return $ecs$047bundle$045batch$058finish$1261$(_batch_0, _outcome_0);
}

function $fallible$045composition$045v1$047request$045fixture$058body$1261$(_input_0, _ctx_0) {
  return $ecs$047capabilities$058owned_request$1268$(_ctx_0, _input_0);
}

function $ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0) {
  return {$: "ecs/decode-requests.Owner", "batch": ($ecs$047bundle$045batch$058begin$1261$(($ecs$047transaction$058begin$1261$(_world_0)))), "declaration": _codec_0};
}

function $fixture$058snapshot_pending$1261$(_meta_0, _view_0, _live_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _pending_0 = _value_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": {$: "fixture.Snapshot", "meta": _meta_0, "live": _live_0, "store": {$: "Unit"}, "resource": _view_0, "pending": _pending_0}};
}

function $ecs$047world$058pending_count$1261$(_world_0) {
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
  return $ecs$047world$058pending_count_join$1261$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($ecs$047world$058pending_length$1261$(_pending_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058observed$1260$(_before_0, _prepared_0, _result_0, _recovered_0, _completion_0, _value_0) {
  const _after_0 = _value_0["snd"];
  return {$: "fallible-composition-v1/request-fixture.Report", "before": _before_0, "after": _after_0, "prepared": _prepared_0, "result": _result_0, "recovered": _recovered_0, "completion": _completion_0};
}

function $fallible$045composition$045v1$047request$045fixture$058recover$(_reverse_0, _packets_0) {
  if (_packets_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _packets_0["head"];
    return $List$append$(($fallible$045composition$045v1$047request$045fixture$058reversed$(_reverse_0, _head_0)), {$: "Nil"});
  }
}

function $ecs$047bundle$045batch$058finish$1260$(_batch_0, _outcome_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  if (_outcome_0.$ === "ecs/transaction.Success") {
    return $ecs$047bundle$045batch$058committed$1260$(($ecs$047commands$058tx_finish$1260$(run_loop($ecs$047bundle$045batch$058stage$1260$(($List$reverse$(_prepared_0)), _tx_0)), {$: "ecs/transaction.Success"})));
  } else {
    const _error_0 = _outcome_0["error"];
    return $ecs$047bundle$045batch$058failed$1260$(($ecs$047bundle$045batch$058originals$1260$(($List$reverse$(_prepared_0)))), _error_0, ($ecs$047commands$058tx_finish$1260$(_tx_0, {$: "ecs/transaction.Failure", "error": _error_0})));
  }
}

function $fallible$045composition$045v1$047request$045fixture$058refusal_view$(_error_0, _value_0) {
  const _view_0 = _value_0["snd"];
  return {$: "fallible-composition-v1/request-fixture.Refused", "owner": {$: "Some", "value": _view_0}, "error": _error_0};
}

function $fixture$058input_view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $fixture$058input_words$(_raw_0, _flags_0, ($fixture$058array$1261$(_words_0)));
}

function $ecs$047capabilities$058owned_request$1266$(_ctx_0, _input_0) {
  return run_tail(($ecs$047capabilities$058owned_request_field$1264$(($fallible$045composition$045v1$047request$045fixture$058grants$1260$())))(_ctx_0), _input_0);
}

function $ecs$047bundle$045batch$058begin$1260$(_tx_0) {
  return {$: "ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $ecs$047world$058pending_count_join$1260$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _counted_0) {
  const _pending_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _count_0};
}

function $ecs$047world$058pending_length$1260$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return $ecs$047world$058pending_prepend$1260$(_command_0, ($ecs$047world$058pending_length$1260$(_rest_0)));
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

function $fixture$058flagged$(_raw_0, _original_0, _words_0, _list_0, _value_0) {
  const _flags_0 = _value_0["fst"];
  const _values_0 = _value_0["snd"];
  return {$: "Tuple", "fst": {$: "fixture.Owner", "raw": _raw_0, "original": _original_0, "words": _words_0, "flags": _flags_0}, "snd": {$: "fixture.View", "raw": _raw_0, "original": _original_0, "words": _list_0, "flags": _values_0}};
}

function $fixture$058joined$1261$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $fallible$045composition$045v1$047request$045fixture$058observed$1261$(_before_0, _prepared_0, _result_0, _recovered_0, _completion_0, _value_0) {
  const _after_0 = _value_0["snd"];
  return {$: "fallible-composition-v1/request-fixture.Report", "before": _before_0, "after": _after_0, "prepared": _prepared_0, "result": _result_0, "recovered": _recovered_0, "completion": _completion_0};
}

function $ecs$047bundle$045batch$058finish$1261$(_batch_0, _outcome_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  if (_outcome_0.$ === "ecs/transaction.Success") {
    return $ecs$047bundle$045batch$058committed$1261$(($ecs$047commands$058tx_finish$1261$(run_loop($ecs$047bundle$045batch$058stage$1261$(($List$reverse$(_prepared_0)), _tx_0)), {$: "ecs/transaction.Success"})));
  } else {
    const _error_0 = _outcome_0["error"];
    return $ecs$047bundle$045batch$058failed$1261$(($ecs$047bundle$045batch$058originals$1261$(($List$reverse$(_prepared_0)))), _error_0, ($ecs$047commands$058tx_finish$1261$(_tx_0, {$: "ecs/transaction.Failure", "error": _error_0})));
  }
}

function $ecs$047capabilities$058owned_request$1268$(_ctx_0, _input_0) {
  return run_tail(($ecs$047capabilities$058owned_request_field$1266$(($fallible$045composition$045v1$047request$045fixture$058grants$1261$())))(_ctx_0), _input_0);
}

function $ecs$047bundle$045batch$058begin$1261$(_tx_0) {
  return {$: "ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $ecs$047transaction$058begin$1261$(_world_0) {
  return {$: "ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $ecs$047world$058pending_count_join$1261$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _counted_0) {
  const _pending_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _count_0};
}

function $ecs$047world$058pending_length$1261$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return $ecs$047world$058pending_prepend$1261$(_command_0, ($ecs$047world$058pending_length$1261$(_rest_0)));
  }
}

function $fallible$045composition$045v1$047request$045fixture$058reversed$(_reverse_0, _packet_0) {
  const _t_0 = _packet_0["owner"];
  if (_t_0.$ === "None") {
    return {$: "Nil"};
  } else {
    const _owner_0 = _t_0["value"];
    return {$: "Con", "head": ($fallible$045composition$045v1$047request$045fixture$058reversed_join$(($fixture$058input_view$(_reverse_0(_owner_0))))), "tail": {$: "Nil"}};
  }
}

function $ecs$047bundle$045batch$058committed$1260$(_observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "ecs/bundle-batch.Committed", "world": _world_0};
}

function $ecs$047commands$058tx_finish$1260$(_tx_0, _outcome_0) {
  return $ecs$047transaction$058finish$1260$(_tx_0, _outcome_0);
}

function $ecs$047bundle$045batch$058stage$1260$(_prepared_0, _tx_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047bundle$045batch$058staged$1260$(_prepared_0, ($List$reverse$(_commands_0)), 0, {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Nil"}, "events": _events_0});
}

function $List$reverse$(_xs_0) {
  return $List$reverse$go$(_xs_0, {$: "Nil"});
}

function $ecs$047bundle$045batch$058failed$1260$(_payloads_0, _error_0, _observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "ecs/bundle-batch.Failed", "world": _world_0, "payloads": _payloads_0, "error": _error_0};
}

function $ecs$047bundle$045batch$058originals$1260$($0) {
  for (;;) {
    {
      const _prepared_0 = $0;
      if (_prepared_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          continue;
        } else {
          const _payload_0 = _t_0["payload"];
          const _tail_1 = _prepared_0["tail"];
          return {$: "Con", "head": _payload_0, "tail": ($ecs$047bundle$045batch$058originals$1260$(_tail_1))};
        }
      }
    }
  }
}

function $fixture$058input_words$(_raw_0, _flags_0, _value_0) {
  const _words_0 = _value_0["fst"];
  const _list_0 = _value_0["snd"];
  return $fixture$058input_flagged$(_raw_0, _words_0, _list_0, ($fixture$058array$1260$(_flags_0)));
}

function $ecs$047capabilities$058owned_request_field$1264$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $fallible$045composition$045v1$047request$045fixture$058grants$1260$() {
  return $ecs$047decode$045fallible$045constructed$045requests$058grant$1260$();
}

function $ecs$047world$058pending_prepend$1260$(_command_0, _counted_0) {
  const _commands_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": ((_count_0 + 1) >>> 0)};
}

function $ecs$047bundle$045batch$058committed$1261$(_observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "ecs/bundle-batch.Committed", "world": _world_0};
}

function $ecs$047commands$058tx_finish$1261$(_tx_0, _outcome_0) {
  return $ecs$047transaction$058finish$1261$(_tx_0, _outcome_0);
}

function $ecs$047bundle$045batch$058stage$1261$(_prepared_0, _tx_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047bundle$045batch$058staged$1261$(_prepared_0, ($List$reverse$(_commands_0)), 0, {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Nil"}, "events": _events_0});
}

function $ecs$047bundle$045batch$058failed$1261$(_payloads_0, _error_0, _observed_0) {
  const _world_0 = _observed_0["world"];
  return {$: "ecs/bundle-batch.Failed", "world": _world_0, "payloads": _payloads_0, "error": _error_0};
}

function $ecs$047bundle$045batch$058originals$1261$($0) {
  for (;;) {
    {
      const _prepared_0 = $0;
      if (_prepared_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "ecs/bundle-batch.ReservationReceipt") {
          const _tail_0 = _prepared_0["tail"];
          $0 = _tail_0;
          continue;
        } else {
          const _payload_0 = _t_0["payload"];
          const _tail_1 = _prepared_0["tail"];
          return {$: "Con", "head": _payload_0, "tail": ($ecs$047bundle$045batch$058originals$1261$(_tail_1))};
        }
      }
    }
  }
}

function $ecs$047capabilities$058owned_request_field$1266$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $fallible$045composition$045v1$047request$045fixture$058grants$1261$() {
  return $ecs$047decode$045fallible$045constructed$045requests$058grant$1261$();
}

function $ecs$047world$058pending_prepend$1261$(_command_0, _counted_0) {
  const _commands_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": ((_count_0 + 1) >>> 0)};
}

function $fallible$045composition$045v1$047request$045fixture$058reversed_join$(_value_0) {
  const _view_0 = _value_0["snd"];
  return _view_0;
}

function $ecs$047transaction$058finish$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $ecs$047bundle$045batch$058staged$1260$($0, $1, $2, $3) {
  for (;;) {
    {
      const _prepared_0 = $0;
      const _commands_0 = $1;
      const _current_0 = $2;
      const _tx_0 = $3;
      if (_prepared_0.$ === "Nil") {
        return $ecs$047bundle$045batch$058remaining$1260$(_commands_0, _tx_0);
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "ecs/bundle-batch.ReservationReceipt") {
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
          return $ecs$047bundle$045batch$058staged_after$1260$(_target_1, _payload_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047bundle$045batch$058staged$1260$(_tail_1, _x_0, _position_0, _x_1);
});
}), ($ecs$047bundle$045batch$058preceding$1260$((_position_0 < _current_0 ? 0 : _position_0 - _current_0), _commands_0, _tx_0)));
        }
      }
    }
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

function $fixture$058input_flagged$(_raw_0, _words_0, _list_0, _value_0) {
  const _flags_0 = _value_0["fst"];
  const _values_0 = _value_0["snd"];
  return {$: "Tuple", "fst": {$: "fixture.Input", "raw": _raw_0, "words": _words_0, "flags": _flags_0}, "snd": {$: "fixture.InputView", "raw": _raw_0, "words": _list_0, "flags": _values_0}};
}

function $ecs$047decode$045fallible$045constructed$045requests$058grant$1260$() {
  return {$: "ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047decode$045fallible$045constructed$045requests$058apply$1260$(_x_0, _x_1);
});
})};
}

function $ecs$047transaction$058finish$1261$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $ecs$047bundle$045batch$058staged$1261$($0, $1, $2, $3) {
  for (;;) {
    {
      const _prepared_0 = $0;
      const _commands_0 = $1;
      const _current_0 = $2;
      const _tx_0 = $3;
      if (_prepared_0.$ === "Nil") {
        return $ecs$047bundle$045batch$058remaining$1261$(_commands_0, _tx_0);
      } else {
        const _t_0 = _prepared_0["head"];
        if (_t_0.$ === "ecs/bundle-batch.ReservationReceipt") {
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
          return $ecs$047bundle$045batch$058staged_after$1261$(_target_1, _payload_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047bundle$045batch$058staged$1261$(_tail_1, _x_0, _position_0, _x_1);
});
}), ($ecs$047bundle$045batch$058preceding$1261$((_position_0 < _current_0 ? 0 : _position_0 - _current_0), _commands_0, _tx_0)));
        }
      }
    }
  }
}

function $ecs$047decode$045fallible$045constructed$045requests$058grant$1261$() {
  return {$: "ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047decode$045fallible$045constructed$045requests$058apply$1261$(_x_0, _x_1);
});
})};
}

function $ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "ecs/transaction.Success") {
    const _committed_0 = ($ecs$047commands$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "ecs/transaction.Returned", "world": ($ecs$047commands$058publish$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "ecs/transaction.Returned", "world": ($ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "ecs/transaction.Failure", "error": _error_0}};
  }
}

function $ecs$047bundle$045batch$058remaining$1260$($0, $1) {
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
        $1 = ($ecs$047transaction$058stage$1260$(_tx_0, _command_0));
        continue;
      }
    }
  }
}

function $ecs$047bundle$045batch$058staged_after$1260$(_target_0, _payload_0, _next_0, _result_0) {
  const _after_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return run_tail(_next_0(_after_0), ($ecs$047bundle$045delivery$058enqueue$1260$(_before_0, _target_0, _payload_0)));
}

function $ecs$047bundle$045batch$058preceding$1260$($0, $1, $2) {
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
          $2 = ($ecs$047transaction$058stage$1260$(_tx_0, _command_0));
          continue;
        }
      }
    }
  }
}

function $ecs$047decode$045fallible$045constructed$045requests$058apply$1260$(_ctx_0, _input_0) {
  const _operation_0 = _input_0["operation"];
  const _raw_0 = _input_0["raw"];
  return $ecs$047decode$045fallible$045constructed$045requests$058constructed$1260$(_ctx_0, _operation_0, ($ecs$047decode$045construction$058fallible_construct$1260$(($fallible$045composition$045v1$047request$045fixture$058factory$1260$()), _raw_0)));
}

function $ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "ecs/transaction.Success") {
    const _committed_0 = ($ecs$047commands$058enqueue$1261$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "ecs/transaction.Returned", "world": ($ecs$047commands$058publish$1261$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "ecs/transaction.Returned", "world": ($ecs$047transaction$058rollback$1261$(_undo_0, _world_0)), "outcome": {$: "ecs/transaction.Failure", "error": _error_0}};
  }
}

function $ecs$047bundle$045batch$058remaining$1261$($0, $1) {
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
        $1 = ($ecs$047transaction$058stage$1261$(_tx_0, _command_0));
        continue;
      }
    }
  }
}

function $ecs$047bundle$045batch$058staged_after$1261$(_target_0, _payload_0, _next_0, _result_0) {
  const _after_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return run_tail(_next_0(_after_0), ($ecs$047bundle$045delivery$058enqueue$1261$(_before_0, _target_0, _payload_0)));
}

function $ecs$047bundle$045batch$058preceding$1261$($0, $1, $2) {
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
          $2 = ($ecs$047transaction$058stage$1261$(_tx_0, _command_0));
          continue;
        }
      }
    }
  }
}

function $ecs$047decode$045fallible$045constructed$045requests$058apply$1261$(_ctx_0, _input_0) {
  const _operation_0 = _input_0["operation"];
  const _raw_0 = _input_0["raw"];
  return $ecs$047decode$045fallible$045constructed$045requests$058constructed$1261$(_ctx_0, _operation_0, ($ecs$047decode$045construction$058fallible_construct$1261$(($fallible$045composition$045v1$047request$045fixture$058factory$1261$()), _raw_0)));
}

function $ecs$047commands$058enqueue$1260$(_world_0, _commands_0) {
  return $ecs$047commands$058enqueue_list$1260$(_commands_0, _world_0);
}

function $ecs$047commands$058publish$1260$(_world_0, _events_0) {
  return $ecs$047world$058event_publish$1260$(_world_0, _events_0);
}

function $ecs$047transaction$058rollback$1260$($0, $1) {
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

function $ecs$047transaction$058stage$1260$(_tx_0, _command_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": _command_0, "tail": _commands_0}, "events": _events_0};
}

function $ecs$047bundle$045delivery$058enqueue$1260$(_tx_0, _handle_0, _payload_0) {
  return $ecs$047transaction$058stage$1260$(_tx_0, run_clo((_x_0) => {
  return $ecs$047bundle$045delivery$058apply$1260$(_x_0, _handle_0, _payload_0);
}));
}

function $ecs$047decode$045fallible$045constructed$045requests$058constructed$1260$(_ctx_0, _operation_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-construction.Invalid") {
    const _owner_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "ecs/decode-fallible-constructed-requests.Construction", "error": _error_0}}};
  } else {
    const _owner_1 = _result_0["cooked"];
    const _undo_0 = _result_0["undo"];
    return $ecs$047decode$045fallible$045constructed$045requests$058returned$1260$(_undo_0, run_loop($ecs$047capabilities$058owned_request$1267$(_ctx_0, {$: "ecs/decode-requests.Input", "operation": _operation_0, "owner": _owner_1})));
  }
}

function $ecs$047decode$045construction$058fallible_construct$1260$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $ecs$047decode$045construction$058fallible_checked$1260$(($ecs$047decode$058decode_owner$1260$(_inputCodec_0, _input_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058factory$1260$() {
  return $ecs$047decode$045construction$058fallible_factory$1260$(($ecs$047persistence$045declaration$058constructed$1260$({$: "ecs/decode-data.Integer"})));
}

function $ecs$047commands$058enqueue$1261$(_world_0, _commands_0) {
  return $ecs$047commands$058enqueue_list$1261$(_commands_0, _world_0);
}

function $ecs$047commands$058publish$1261$(_world_0, _events_0) {
  return $ecs$047world$058event_publish$1261$(_world_0, _events_0);
}

function $ecs$047transaction$058rollback$1261$($0, $1) {
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

function $ecs$047transaction$058stage$1261$(_tx_0, _command_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": _command_0, "tail": _commands_0}, "events": _events_0};
}

function $ecs$047bundle$045delivery$058enqueue$1261$(_tx_0, _handle_0, _payload_0) {
  return $ecs$047transaction$058stage$1261$(_tx_0, run_clo((_x_0) => {
  return $ecs$047bundle$045delivery$058apply$1261$(_x_0, _handle_0, _payload_0);
}));
}

function $ecs$047decode$045fallible$045constructed$045requests$058constructed$1261$(_ctx_0, _operation_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-construction.Invalid") {
    const _owner_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "ecs/decode-fallible-constructed-requests.Construction", "error": _error_0}}};
  } else {
    const _owner_1 = _result_0["cooked"];
    const _undo_0 = _result_0["undo"];
    return $ecs$047decode$045fallible$045constructed$045requests$058returned$1261$(_undo_0, run_loop($ecs$047capabilities$058owned_request$1269$(_ctx_0, {$: "ecs/decode-requests.Input", "operation": _operation_0, "owner": _owner_1})));
  }
}

function $ecs$047decode$045construction$058fallible_construct$1261$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $ecs$047decode$045construction$058fallible_checked$1260$(($ecs$047decode$058decode_owner$1260$(_inputCodec_0, _input_0)));
}

function $fallible$045composition$045v1$047request$045fixture$058factory$1261$() {
  return $ecs$047decode$045construction$058fallible_factory$1261$(($ecs$047persistence$045declaration$058constructed$1262$({$: "ecs/decode-data.Integer"})));
}

function $ecs$047commands$058enqueue_list$1260$($0, $1) {
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
        $1 = ($ecs$047world$058enqueue$1260$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $ecs$047world$058event_publish$1260$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $ecs$047world$058event_publish_nonempty$1260$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $ecs$047bundle$045delivery$058apply$1260$(_world_0, _handle_0, _payload_0) {
  return $ecs$047bundle$045delivery$058apply_checked$1260$(($ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $ecs$047decode$045fallible$045constructed$045requests$058returned$1260$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "ecs/decode-requests.Accepted") {
    const _target_0 = _t_0["target"];
    const _spawned_0 = _t_0["spawned"];
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "ecs/decode-fallible-constructed-requests.Accepted", "target": _target_0, "spawned": _spawned_0, "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": ($ecs$047decode$045fallible$045constructed$045requests$058refused$1260$(_undo_0, _owner_0, _error_0))};
  }
}

function $ecs$047capabilities$058owned_request$1267$(_ctx_0, _input_0) {
  return run_tail(($ecs$047capabilities$058owned_request_field$1265$(($ecs$047decode$045frame$058request_grant$1260$())))(_ctx_0), _input_0);
}

function $ecs$047decode$045construction$058fallible_checked$1260$(_receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "ecs/decode-data.Rejected") {
    return $ecs$047decode$045construction$058custom_result$1260$(($fallible$045composition$045v1$047business$058build$(_owner_0, {$: "ecs/decode-data.Array", "items": {$: "Nil"}})));
  } else {
    const _canonical_0 = _t_0["value"];
    return $ecs$047decode$045construction$058custom_result$1260$(($fallible$045composition$045v1$047business$058build$(_owner_0, _canonical_0)));
  }
}

function $ecs$047decode$058decode_owner$1260$(_codec_0, _owner_0) {
  return $ecs$047decode$058decode_projected$1260$(_codec_0, ($fixture$058incoming$(_owner_0)));
}

function $ecs$047decode$045construction$058fallible_factory$1260$(_declaration_0) {
  return {$: "ecs/decode-construction.FallibleFactory", "declaration": _declaration_0, "inputCodec": ($ecs$047persistence$045declaration$058codec$1260$(_declaration_0))};
}

function $ecs$047commands$058enqueue_list$1261$($0, $1) {
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
        $1 = ($ecs$047world$058enqueue$1261$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $ecs$047world$058event_publish$1261$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $ecs$047world$058event_publish_nonempty$1261$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $ecs$047bundle$045delivery$058apply$1261$(_world_0, _handle_0, _payload_0) {
  return $ecs$047bundle$045delivery$058apply_checked$1261$(($ecs$047world$058valid$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $ecs$047decode$045fallible$045constructed$045requests$058returned$1261$(_undo_0, _result_0) {
  const _ctx_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "ecs/decode-requests.Accepted") {
    const _target_0 = _t_0["target"];
    const _spawned_0 = _t_0["spawned"];
    const _canonical_0 = _t_0["canonical"];
    return {$: "Tuple", "fst": _ctx_0, "snd": {$: "ecs/decode-fallible-constructed-requests.Accepted", "target": _target_0, "spawned": _spawned_0, "canonical": _canonical_0, "undo": _undo_0}};
  } else {
    const _owner_0 = _t_0["owner"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _ctx_0, "snd": ($ecs$047decode$045fallible$045constructed$045requests$058refused$1261$(_undo_0, _owner_0, _error_0))};
  }
}

function $ecs$047capabilities$058owned_request$1269$(_ctx_0, _input_0) {
  return run_tail(($ecs$047capabilities$058owned_request_field$1267$(($ecs$047decode$045frame$058request_grant$1261$())))(_ctx_0), _input_0);
}

function $ecs$047decode$045construction$058fallible_factory$1261$(_declaration_0) {
  return {$: "ecs/decode-construction.FallibleFactory", "declaration": _declaration_0, "inputCodec": ($ecs$047persistence$045declaration$058codec$1262$(_declaration_0))};
}

function $ecs$047world$058enqueue$1260$(_world_0, _command_0) {
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
  return {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $ecs$047world$058event_publish_nonempty$1260$(_world_0, _published_0) {
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
  return {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $ecs$047bundle$045delivery$058apply_checked$1260$(_observed_0, _handle_0, _payload_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1260$(_world_0, _payload_0, {$: "ecs/world.MissingEntity"});
  } else {
    return $ecs$047bundle$045delivery$058deliver$1260$(($fallible$045composition$045v1$047request$045fixture$058attempt$1260$(_world_0, _handle_0, _payload_0)));
  }
}

function $ecs$047world$058valid$1260$(_world_0, _handle_0) {
  return $ecs$047world$058valid_join$1260$(_handle_0, ($ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $ecs$047decode$045fallible$045constructed$045requests$058refused$1260$(_undo_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "None"}, "error": {$: "ecs/decode-fallible-constructed-requests.Operation", "error": _error_0}};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "Some", "value": _undo_0(_owner_1)}, "error": {$: "ecs/decode-fallible-constructed-requests.Operation", "error": _error_0}};
  }
}

function $ecs$047capabilities$058owned_request_field$1265$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $ecs$047decode$045frame$058request_grant$1260$() {
  return {$: "ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047decode$045frame$058request$1260$(_x_0, _x_1);
});
})};
}

function $ecs$047decode$045construction$058custom_result$1260$(_result_0) {
  if (_result_0.$ === "ecs/bundle-construction.Invalid") {
    const _owner_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return {$: "ecs/bundle-construction.Invalid", "raw": _owner_0, "error": {$: "ecs/decode-construction.Constructor", "error": _error_0}};
  } else {
    const _owner_1 = _result_0["cooked"];
    const _undo_0 = _result_0["undo"];
    return {$: "ecs/bundle-construction.Constructed", "cooked": _owner_1, "undo": _undo_0};
  }
}

function $fallible$045composition$045v1$047business$058build$(_input_0, _canonical_0) {
  return {$: "ecs/bundle-construction.Invalid", "raw": _input_0, "error": {$: "fallible-composition-v1/business.Denied", "code": 403}};
}

function $ecs$047decode$058decode_projected$1260$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, ($ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $fixture$058incoming$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "Tuple", "fst": {$: "fixture.Input", "raw": _raw_0, "words": _words_0, "flags": _flags_0}, "snd": _raw_0};
}

function $ecs$047persistence$045declaration$058codec$1260$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $ecs$047world$058enqueue$1261$(_world_0, _command_0) {
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
  return {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $ecs$047world$058event_publish_nonempty$1261$(_world_0, _published_0) {
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
  return {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $ecs$047bundle$045delivery$058apply_checked$1261$(_observed_0, _handle_0, _payload_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1261$(_world_0, _payload_0, {$: "ecs/world.MissingEntity"});
  } else {
    return $ecs$047bundle$045delivery$058deliver$1261$(($fallible$045composition$045v1$047request$045fixture$058attempt$1261$(_world_0, _handle_0, _payload_0)));
  }
}

function $ecs$047world$058valid$1261$(_world_0, _handle_0) {
  return $ecs$047world$058valid_join$1261$(_handle_0, ($ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
}

function $ecs$047decode$045fallible$045constructed$045requests$058refused$1261$(_undo_0, _owner_0, _error_0) {
  if (_owner_0.$ === "None") {
    return {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "None"}, "error": {$: "ecs/decode-fallible-constructed-requests.Operation", "error": _error_0}};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "ecs/decode-fallible-constructed-requests.Refused", "owner": {$: "Some", "value": _undo_0(_owner_1)}, "error": {$: "ecs/decode-fallible-constructed-requests.Operation", "error": _error_0}};
  }
}

function $ecs$047capabilities$058owned_request_field$1267$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $ecs$047decode$045frame$058request_grant$1261$() {
  return {$: "ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $ecs$047decode$045frame$058request$1261$(_x_0, _x_1);
});
})};
}

function $ecs$047persistence$045declaration$058codec$1262$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $ecs$047world$058event_append$1260$(_left_0, _right_0) {
  return $ecs$047world$058event_append_loop$1260$(($List$reverse$(_left_0)), _right_0);
}

function $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1260$(_world_0, _packet_0, _error_0) {
  return _world_0;
}

function $ecs$047bundle$045delivery$058deliver$1260$(_result_0) {
  if (_result_0.$ === "ecs/bundle-delivery.Delivered") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1260$(_world_1, _payload_0, _error_0);
  }
}

function $fallible$045composition$045v1$047request$045fixture$058attempt$1260$(_world_0, _target_0, _packet_0) {
  return {$: "ecs/bundle-delivery.Undelivered", "world": _world_0, "payload": _packet_0, "error": {$: "ecs/world.MissingEntity"}};
}

function $ecs$047world$058valid_join$1260$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0);
}

function $ecs$047world$058metadata_valid$1260$(_world_0, _handle_0) {
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
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $ecs$047decode$045frame$058request$1260$(_frame_0, _input_0) {
  const _owner_0 = _frame_0["owner"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $ecs$047decode$045frame$058request_join$1260$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($ecs$047decode$045requests$058request$1260$(_owner_0, _input_0)));
}

function $ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, ($ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, {$: "ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
}

function $ecs$047decode$045size$058budget$(_codec_0, _raw_0) {
  const _x_0 = ($ecs$047decode$045size$058raw_size$(_raw_0));
  const _x_1 = ($ecs$047decode$045size$058codec_size$(_codec_0));
  const _x_2 = nat_chk(_x_0 + 1);
  const _x_3 = nat_chk(_x_1 * _x_2);
  return nat_chk(4 * _x_3);
}

function $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1261$(_world_0, _packet_0, _error_0) {
  return _world_0;
}

function $ecs$047bundle$045delivery$058deliver$1261$(_result_0) {
  if (_result_0.$ === "ecs/bundle-delivery.Delivered") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return $fallible$045composition$045v1$047request$045fixture$058delivery_recover$1261$(_world_1, _payload_0, _error_0);
  }
}

function $fallible$045composition$045v1$047request$045fixture$058attempt$1261$(_world_0, _target_0, _packet_0) {
  return {$: "ecs/bundle-delivery.Undelivered", "world": _world_0, "payload": _packet_0, "error": {$: "ecs/world.MissingEntity"}};
}

function $ecs$047world$058valid_join$1261$(_handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0);
}

function $ecs$047world$058metadata_valid$1261$(_world_0, _handle_0) {
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
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $ecs$047decode$045frame$058request$1261$(_frame_0, _input_0) {
  const _owner_0 = _frame_0["owner"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  const _receipts_0 = _frame_0["receipts"];
  const _pending_0 = _frame_0["pending"];
  return $ecs$047decode$045frame$058request_join$1261$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($ecs$047decode$045requests$058request$1261$(_owner_0, _input_0)));
}

function $ecs$047world$058event_append_loop$1260$($0, $1) {
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

function $ecs$047world$058valid_checked$1260$(_allowed_0, _world_0, _handle_0) {
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
    return $ecs$047world$058live_join$1260$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $ecs$047decode$045frame$058request_join$1260$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _output_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _output_0};
}

function $ecs$047decode$045requests$058request$1260$(_frame_0, _input_0) {
  const _batch_0 = _frame_0["batch"];
  const _declaration_0 = _frame_0["declaration"];
  const _operation_0 = _input_0["operation"];
  const _owner_0 = _input_0["owner"];
  return $ecs$047decode$045requests$058validated$1260$(_declaration_0, _batch_0, _operation_0, ($ecs$047persistence$045declaration$058validate$1262$(_declaration_0, _owner_0)));
}

function $ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "ecs/decode-data.Accepted", "value": ($ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($ecs$047decode$045data$058validate$(_fuel_0, {$: "ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
}

function $ecs$047decode$045size$058codec_size$(_codec_0) {
  if (_codec_0.$ === "ecs/decode-data.Nullable") {
    const _inner_0 = _codec_0["inner"];
    const _x_0 = ($ecs$047decode$045size$058codec_size$(_inner_0));
    return nat_chk(1 + _x_0);
  } else if (_codec_0.$ === "ecs/decode-data.ArrayValue") {
    const _inner_1 = _codec_0["inner"];
    const _x_1 = ($ecs$047decode$045size$058codec_size$(_inner_1));
    return nat_chk(1 + _x_1);
  } else if (_codec_0.$ === "ecs/decode-data.Struct") {
    const _t_0 = _codec_0["fields"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _t_1 = _t_0["head"];
      const _child_0 = _t_1["codec"];
      const _rest_0 = _t_0["tail"];
      const _x_2 = ($ecs$047decode$045size$058codec_size$(_child_0));
      const _x_3 = ($ecs$047decode$045size$058codec_size$({$: "ecs/decode-data.Struct", "fields": _rest_0}));
      const _x_4 = nat_chk(_x_2 + _x_3);
      return nat_chk(1 + _x_4);
    }
  } else {
    return 1;
  }
}

function $ecs$047decode$045size$058raw_size$(_raw_0) {
  if (_raw_0.$ === "ecs/decode-data.Array") {
    const _t_0 = _raw_0["items"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _head_0 = _t_0["head"];
      const _rest_0 = _t_0["tail"];
      const _x_0 = ($ecs$047decode$045size$058raw_size$(_head_0));
      const _x_1 = ($ecs$047decode$045size$058raw_size$({$: "ecs/decode-data.Array", "items": _rest_0}));
      return nat_chk(_x_0 + _x_1);
    }
  } else if (_raw_0.$ === "ecs/decode-data.Object") {
    const _t_1 = _raw_0["fields"];
    if (_t_1.$ === "Nil") {
      return 1;
    } else {
      const _t_2 = _t_1["head"];
      const _child_0 = _t_2["value"];
      const _rest_1 = _t_1["tail"];
      const _x_2 = ($ecs$047decode$045size$058raw_size$(_child_0));
      const _x_3 = ($ecs$047decode$045size$058raw_size$({$: "ecs/decode-data.Object", "fields": _rest_1}));
      return nat_chk(_x_2 + _x_3);
    }
  } else {
    return 1;
  }
}

function $ecs$047world$058valid_checked$1261$(_allowed_0, _world_0, _handle_0) {
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
    return $ecs$047world$058live_join$1261$({$: "Tuple", fst: _live_0, snd: _live_0[_id_0 % _live_0.length]}, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
  }
}

function $ecs$047decode$045frame$058request_join$1261$(_handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _output_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/decode-frame.Frame", "owner": _owner_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": _output_0};
}

function $ecs$047decode$045requests$058request$1261$(_frame_0, _input_0) {
  const _batch_0 = _frame_0["batch"];
  const _declaration_0 = _frame_0["declaration"];
  const _operation_0 = _input_0["operation"];
  const _owner_0 = _input_0["owner"];
  return $ecs$047decode$045requests$058validated$1261$(_declaration_0, _batch_0, _operation_0, ($ecs$047persistence$045declaration$058validate$1263$(_declaration_0, _owner_0)));
}

function $ecs$047world$058live_join$1260$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $ecs$047decode$045requests$058validated$1260$(_declaration_0, _batch_0, _operation_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $ecs$047decode$045requests$058enqueue$1260$(_declaration_0, _batch_0, _operation_0, _canonical_0, ($fixture$058project$(_owner_0)));
  }
}

function $ecs$047persistence$045declaration$058validate$1262$(_declaration_0, _owner_0) {
  return $ecs$047decode$058decode_owner$1261$(($ecs$047persistence$045declaration$058codec$1260$(_declaration_0)), _owner_0);
}

function $ecs$047decode$045data$058canonical$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _codec_0 = $1;
      const _raw_0 = $2;
      if (_fuel_0 === 0) {
        return _raw_0;
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_codec_0.$ === "ecs/decode-data.Nullable") {
          const _inner_0 = _codec_0["inner"];
          if (_raw_0.$ === "ecs/decode-data.Null") {
            return {$: "ecs/decode-data.Null"};
          } else {
            $0 = _more_0;
            $1 = _inner_0;
            $2 = _raw_0;
            continue;
          }
        } else if (_codec_0.$ === "ecs/decode-data.ArrayValue") {
          const __0 = _codec_0["inner"];
          if (_raw_0.$ === "ecs/decode-data.Array") {
            const _t_0 = _raw_0["items"];
            if (_t_0.$ === "Nil") {
              return {$: "ecs/decode-data.Array", "items": {$: "Nil"}};
            } else {
              const _head_0 = _t_0["head"];
              const _tail_0 = _t_0["tail"];
              return $ecs$047decode$045data$058canonical_array_join$(($ecs$047decode$045data$058canonical$(_more_0, __0, _head_0)), ($ecs$047decode$045data$058canonical$(_more_0, {$: "ecs/decode-data.ArrayValue", "inner": __0}, {$: "ecs/decode-data.Array", "items": _tail_0})));
            }
          } else {
            return _raw_0;
          }
        } else if (_codec_0.$ === "ecs/decode-data.Struct") {
          const _t_1 = _codec_0["fields"];
          if (_t_1.$ === "Nil") {
            if (_raw_0.$ === "ecs/decode-data.Object") {
              return {$: "ecs/decode-data.Object", "fields": {$: "Nil"}};
            } else {
              return _raw_0;
            }
          } else {
            const _t_2 = _t_1["head"];
            const _name_0 = _t_2["name"];
            const _codec_1 = _t_2["codec"];
            const _rest_0 = _t_1["tail"];
            if (_raw_0.$ === "ecs/decode-data.Object") {
              const _values_0 = _raw_0["fields"];
              return $ecs$047decode$045data$058canonical_struct_join$(_name_0, ($ecs$047decode$045data$058canonical$(_more_0, _codec_1, run_loop($ecs$047decode$045data$058field$(_name_0, _values_0)))), ($ecs$047decode$045data$058canonical$(_more_0, {$: "ecs/decode-data.Struct", "fields": _rest_0}, {$: "ecs/decode-data.Object", "fields": _values_0})));
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

function $ecs$047decode$045data$058validate$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _step_0 = $1;
      const _original_0 = $2;
      if (_fuel_0 === 0) {
        if (_step_0.$ === "ecs/decode-data.Stop") {
          const _error_0 = _step_0["error"];
          return {$: "ecs/decode-data.Rejected", "error": _error_0};
        } else {
          const _t_0 = _step_0["work"];
          if (_t_0.$ === "Nil") {
            return {$: "ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_1 = _t_0["head"];
            const _path_0 = _t_1["path"];
            return {$: "ecs/decode-data.Rejected", "error": {$: "ecs/decode-data.FuelExhausted", "path": _path_0}};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_step_0.$ === "ecs/decode-data.Stop") {
          const _error_1 = _step_0["error"];
          return {$: "ecs/decode-data.Rejected", "error": _error_1};
        } else {
          const _t_2 = _step_0["work"];
          if (_t_2.$ === "Nil") {
            return {$: "ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_3 = _t_2["head"];
            const _codec_0 = _t_3["codec"];
            const _raw_0 = _t_3["raw"];
            const _path_1 = _t_3["path"];
            const _rest_0 = _t_2["tail"];
            $0 = _more_0;
            $1 = ($ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_1, _rest_0));
            $2 = _original_0;
            continue;
          }
        }
      }
    }
  }
}

function $ecs$047world$058live_join$1261$(_checked_0, _namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _checked_0["fst"];
  const _found_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _found_0};
}

function $ecs$047decode$045requests$058validated$1261$(_declaration_0, _batch_0, _operation_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": {$: "Some", "value": _owner_0}, "error": {$: "ecs/decode-requests.Validation", "error": _error_0}}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $ecs$047decode$045requests$058enqueue$1261$(_declaration_0, _batch_0, _operation_0, _canonical_0, ($fixture$058project$(_owner_0)));
  }
}

function $ecs$047persistence$045declaration$058validate$1263$(_declaration_0, _owner_0) {
  return $ecs$047decode$058decode_owner$1261$(($ecs$047persistence$045declaration$058codec$1262$(_declaration_0)), _owner_0);
}

function $ecs$047decode$045requests$058enqueue$1260$(_declaration_0, _batch_0, _operation_0, _canonical_0, _projected_0) {
  const _owner_0 = _projected_0["fst"];
  const _original_0 = _projected_0["snd"];
  return $ecs$047decode$045requests$058enqueue_packet$1260$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0);
}

function $fixture$058project$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _original_0 = _value_0["original"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "Tuple", "fst": {$: "fixture.Owner", "raw": _raw_0, "original": _original_0, "words": _words_0, "flags": _flags_0}, "snd": _raw_0};
}

function $ecs$047decode$058decode_owner$1261$(_codec_0, _owner_0) {
  return $ecs$047decode$058decode_projected$1261$(_codec_0, ($fixture$058project$(_owner_0)));
}

function $ecs$047decode$045data$058canonical_array_join$(_head_0, _tail_0) {
  if (_tail_0.$ === "ecs/decode-data.Array") {
    const _values_0 = _tail_0["items"];
    return {$: "ecs/decode-data.Array", "items": {$: "Con", "head": _head_0, "tail": _values_0}};
  } else {
    return _tail_0;
  }
}

function $ecs$047decode$045data$058canonical_struct_join$(_name_0, _head_0, _tail_0) {
  if (_tail_0.$ === "ecs/decode-data.Object") {
    const _fields_0 = _tail_0["fields"];
    return {$: "ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "ecs/decode-data.Field", "name": _name_0, "value": _head_0}, "tail": _fields_0}};
  } else {
    return _tail_0;
  }
}

function $ecs$047decode$045data$058field$(_name_0, _fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "ecs/decode-data.Missing"};
  } else {
    const _t_0 = _fields_0["head"];
    const _key_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _fields_0["tail"];
    return $ecs$047decode$045data$058field_choose$(($String$eq$(_name_0, _key_0)), _value_0, run_clo((_x_0) => {
  return $ecs$047decode$045data$058field$(_name_0, _rest_0);
}));
  }
}

function $ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_0, _rest_0) {
  if (_codec_0.$ === "ecs/decode-data.Integer") {
    if (_raw_0.$ === "ecs/decode-data.Number") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "ecs/decode-data.SignedInteger") {
      const __1 = _raw_0["negative"];
      const _magnitude_0 = _raw_0["magnitude"];
      const _x_0 = ($Nat$div$(_magnitude_0, nat_chk(65536 * 65536)));
      return $ecs$047decode$045data$058choose_checked$((_x_0 < 2097152), _path_0, "integer", {$: "ecs/decode-data.SignedInteger", "negative": __1, "magnitude": _magnitude_0}, _rest_0);
    } else if (_raw_0.$ === "ecs/decode-data.Float") {
      const _value_0 = _raw_0["value"];
      const _x_1 = Math.fround(Math.floor(_value_0));
      const _x_2 = Math.fround(Math.abs(_value_0));
      return $ecs$047decode$045data$058choose_checked$(($Bool$and$((_x_1 === _value_0), (_x_2 < 9007199254740992))), _path_0, "integer", {$: "ecs/decode-data.Float", "value": _value_0}, _rest_0);
    } else if (_raw_0.$ === "ecs/decode-data.Binary64") {
      const _high_0 = _raw_0["high"];
      const _low_0 = _raw_0["low"];
      return $ecs$047decode$045data$058choose_checked$(($ecs$047decode$045data$058binary_integer$(_high_0, _low_0)), _path_0, "integer", {$: "ecs/decode-data.Binary64", "high": _high_0, "low": _low_0}, _rest_0);
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "integer", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.FiniteNumber") {
    if (_raw_0.$ === "ecs/decode-data.Number") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "ecs/decode-data.SignedInteger") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "ecs/decode-data.Float") {
      const _value_1 = _raw_0["value"];
      const _x_3 = Math.fround(Math.abs(_value_1));
      const _x_4 = 3.4028234663852886e+38;
      return $ecs$047decode$045data$058choose_checked$((_x_3 <= _x_4), _path_0, "finite number", {$: "ecs/decode-data.Float", "value": _value_1}, _rest_0);
    } else if (_raw_0.$ === "ecs/decode-data.Binary64") {
      const _high_1 = _raw_0["high"];
      const __5 = _raw_0["low"];
      const _x_5 = ($ecs$047decode$045data$058binary64_exponent$(_high_1));
      return $ecs$047decode$045data$058choose_checked$((_x_5 < 2047), _path_0, "finite number", {$: "ecs/decode-data.Binary64", "high": _high_1, "low": __5}, _rest_0);
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "finite number", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.StringValue") {
    if (_raw_0.$ === "ecs/decode-data.Text") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "ecs/decode-data.Utf16Text") {
      const _units_0 = _raw_0["units"];
      return $ecs$047decode$045data$058choose_checked$(($ecs$047decode$045utf16$058valid$(_units_0)), _path_0, "string", {$: "ecs/decode-data.Utf16Text", "units": _units_0}, _rest_0);
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "string", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.BoolValue") {
    if (_raw_0.$ === "ecs/decode-data.Boolean") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "boolean", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.Literal") {
    const _value_2 = _codec_0["value"];
    return $ecs$047decode$045data$058choose_checked$(($ecs$047decode$045data$058equal$(_value_2, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "ecs/decode-data.LiteralValues") {
    const _values_0 = _codec_0["values"];
    return $ecs$047decode$045data$058choose_checked$(($ecs$047decode$045data$058alternatives$(_values_0, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "ecs/decode-data.LiteralRendered") {
    const _values_1 = _codec_0["values"];
    const _expected_0 = _codec_0["expected"];
    return $ecs$047decode$045data$058choose_checked$(($ecs$047decode$045data$058alternatives$(_values_1, _raw_0)), _path_0, _expected_0, _raw_0, _rest_0);
  } else if (_codec_0.$ === "ecs/decode-data.Nullable") {
    const __8 = _codec_0["inner"];
    if (_raw_0.$ === "ecs/decode-data.Null") {
      return {$: "ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "ecs/decode-data.Work", "codec": __8, "raw": _raw_0, "path": _path_0}, "tail": _rest_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.ArrayValue") {
    const _inner_0 = _codec_0["inner"];
    if (_raw_0.$ === "ecs/decode-data.Array") {
      const _items_0 = _raw_0["items"];
      return {$: "ecs/decode-data.Continue", "work": ($ecs$047decode$045data$058array_work$(_inner_0, _items_0, _path_0, 0, _rest_0))};
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "array", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "ecs/decode-data.Struct") {
    const _fields_0 = _codec_0["fields"];
    if (_raw_0.$ === "ecs/decode-data.Object") {
      const _values_2 = _raw_0["fields"];
      return {$: "ecs/decode-data.Continue", "work": ($ecs$047decode$045data$058struct_work$(_fields_0, _values_2, _path_0, _rest_0))};
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "object", "actual": _raw_0}};
    }
  } else {
    const _ns_0 = _codec_0["namespace"];
    if (_raw_0.$ === "ecs/decode-data.Handle") {
      const _actual_0 = _raw_0["namespace"];
      const _id_0 = _raw_0["id"];
      return $ecs$047decode$045data$058choose_checked$(($Bool$and$((_ns_0 === _actual_0), (_id_0 > 0))), _path_0, "same-world handle", {$: "ecs/decode-data.Handle", "namespace": _actual_0, "id": _id_0}, _rest_0);
    } else {
      return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": "same-world handle", "actual": _raw_0}};
    }
  }
}

function $ecs$047decode$045requests$058enqueue$1261$(_declaration_0, _batch_0, _operation_0, _canonical_0, _projected_0) {
  const _owner_0 = _projected_0["fst"];
  const _original_0 = _projected_0["snd"];
  return $ecs$047decode$045requests$058enqueue_packet$1261$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0);
}

function $ecs$047decode$045requests$058enqueue_packet$1260$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0) {
  if (_operation_0.$ === "ecs/bundle-requests.Insert") {
    const _target_0 = _operation_0["target"];
    return $ecs$047decode$045requests$058inserted$1260$(_declaration_0, _target_0, _canonical_0, ($ecs$047bundle$045batch$058insert$1260$(_batch_0, _target_0, {$: "ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  } else {
    return $ecs$047decode$045requests$058spawned$1260$(_declaration_0, _canonical_0, ($ecs$047bundle$045batch$058spawn$1260$(_batch_0, {$: "ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  }
}

function $ecs$047decode$058decode_projected$1261$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, ($ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $ecs$047decode$045data$058field_choose$(_equal_0, _value_0, _next_0) {
  if (_equal_0) {
    return _value_0;
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}

function $ecs$047decode$045data$058choose_checked$(_valid_0, _path_0, _expected_0, _raw_0, _rest_0) {
  if (_valid_0) {
    return {$: "ecs/decode-data.Continue", "work": _rest_0};
  } else {
    return {$: "ecs/decode-data.Stop", "error": {$: "ecs/decode-data.Invalid", "path": _path_0, "expected": _expected_0, "actual": _raw_0}};
  }
}

function $Nat$div$(_a_0, _b_0) {
  return $Pair$fst$(nat_divmod(_a_0, _b_0));
}

function $ecs$047decode$045data$058binary_integer$(_high_0, _low_0) {
  const _x_0 = ($ecs$047decode$045data$058binary64_exponent$(_high_0));
  return $ecs$047decode$045data$058binary_integer_checked$(($ecs$047decode$045data$058binary_numeric$(_high_0, _low_0)), (_x_0 < 1076));
}

function $ecs$047decode$045data$058binary64_exponent$(_high_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  return (2048 === 0 ? _x_0 : _x_0 % 2048);
}

function $ecs$047decode$045utf16$058valid$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    const _unit_0 = _units_0["head"];
    const _tail_0 = _units_0["tail"];
    return $Bool$and$((_unit_0 <= 65535), ($ecs$047decode$045utf16$058valid$(_tail_0)));
  }
}

function $ecs$047decode$045data$058equal$(_a_0, _b_0) {
  if (_a_0.$ === "ecs/decode-data.Null") {
    if (_b_0.$ === "ecs/decode-data.Null") {
      return true;
    } else {
      return $ecs$047decode$045data$058same_numeric$(($ecs$047decode$045data$058numeric$({$: "ecs/decode-data.Null"})), ($ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "ecs/decode-data.Text") {
    const _a_1 = _a_0["value"];
    if (_b_0.$ === "ecs/decode-data.Text") {
      const _b_1 = _b_0["value"];
      return $String$eq$(_a_1, _b_1);
    } else if (_b_0.$ === "ecs/decode-data.Utf16Text") {
      const _b_2 = _b_0["units"];
      return $ecs$047decode$045utf16$058checked$(($ecs$047decode$045utf16$058text$(_a_1)), _b_2);
    } else {
      return $ecs$047decode$045data$058same_numeric$(($ecs$047decode$045data$058numeric$({$: "ecs/decode-data.Text", "value": _a_1})), ($ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "ecs/decode-data.Utf16Text") {
    const _a_2 = _a_0["units"];
    if (_b_0.$ === "ecs/decode-data.Utf16Text") {
      const _b_3 = _b_0["units"];
      return $ecs$047decode$045utf16$058checked$(_a_2, _b_3);
    } else if (_b_0.$ === "ecs/decode-data.Text") {
      const _b_4 = _b_0["value"];
      return $ecs$047decode$045utf16$058checked$(_a_2, ($ecs$047decode$045utf16$058text$(_b_4)));
    } else {
      return $ecs$047decode$045data$058same_numeric$(($ecs$047decode$045data$058numeric$({$: "ecs/decode-data.Utf16Text", "units": _a_2})), ($ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "ecs/decode-data.Boolean") {
    const _a_3 = _a_0["value"];
    if (_b_0.$ === "ecs/decode-data.Boolean") {
      const _b_5 = _b_0["value"];
      return $ecs$047decode$045data$058same_bool$(_a_3, _b_5);
    } else {
      return $ecs$047decode$045data$058same_numeric$(($ecs$047decode$045data$058numeric$({$: "ecs/decode-data.Boolean", "value": _a_3})), ($ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else {
    return $ecs$047decode$045data$058same_numeric$(($ecs$047decode$045data$058numeric$(_a_0)), ($ecs$047decode$045data$058numeric$(_b_0)));
  }
}

function $ecs$047decode$045data$058alternatives$(_values_0, _raw_0) {
  if (_values_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _values_0["head"];
    const _tail_0 = _values_0["tail"];
    const _x_0 = ($ecs$047decode$045data$058equal$(_value_0, _raw_0));
    const _x_1 = ($ecs$047decode$045data$058alternatives$(_tail_0, _raw_0));
    return (_x_0 || _x_1);
  }
}

function $ecs$047decode$045data$058array_work$(_codec_0, _items_0, _path_0, _index_0, _rest_0) {
  if (_items_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _value_0 = _items_0["head"];
    const _tail_0 = _items_0["tail"];
    const _x_0 = ($U32$show$(_index_0));
    const _x_1 = (_x_0 + "]");
    const _x_2 = ("[" + _x_1);
    return {$: "Con", "head": {$: "ecs/decode-data.Work", "codec": _codec_0, "raw": _value_0, "path": (_path_0 + _x_2)}, "tail": ($ecs$047decode$045data$058array_work$(_codec_0, _tail_0, _path_0, ((_index_0 + 1) >>> 0), _rest_0))};
  }
}

function $ecs$047decode$045data$058struct_work$(_fields_0, _values_0, _path_0, _rest_0) {
  if (_fields_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _t_0 = _fields_0["head"];
    const _name_0 = _t_0["name"];
    const _codec_0 = _t_0["codec"];
    const _tail_0 = _fields_0["tail"];
    const _x_0 = ("." + _name_0);
    return {$: "Con", "head": {$: "ecs/decode-data.Work", "codec": _codec_0, "raw": run_loop($ecs$047decode$045data$058field$(_name_0, _values_0)), "path": (_path_0 + _x_0)}, "tail": ($ecs$047decode$045data$058struct_work$(_tail_0, _values_0, _path_0, _rest_0))};
  }
}

function $ecs$047decode$045requests$058enqueue_packet$1261$(_declaration_0, _batch_0, _operation_0, _owner_0, _original_0, _canonical_0) {
  if (_operation_0.$ === "ecs/bundle-requests.Insert") {
    const _target_0 = _operation_0["target"];
    return $ecs$047decode$045requests$058inserted$1261$(_declaration_0, _target_0, _canonical_0, ($ecs$047bundle$045batch$058insert$1261$(_batch_0, _target_0, {$: "ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  } else {
    return $ecs$047decode$045requests$058spawned$1261$(_declaration_0, _canonical_0, ($ecs$047bundle$045batch$058spawn$1261$(_batch_0, {$: "ecs/decode-requests.Packet", "owner": {$: "Some", "value": _owner_0}, "original": _original_0, "canonical": _canonical_0})));
  }
}

function $ecs$047decode$045requests$058inserted$1260$(_declaration_0, _target_0, _canonical_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Accepted", "target": _target_0, "spawned": false, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $ecs$047bundle$045batch$058insert$1260$(_batch_0, _target_0, _payload_0) {
  const _t_0 = _batch_0["tx"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _prepared_0 = _batch_0["prepared"];
  return $ecs$047bundle$045batch$058checked$1260$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($ecs$047world$058valid$1260$(_world_0, _target_0)));
}

function $ecs$047decode$045requests$058spawned$1260$(_declaration_0, _canonical_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Spawned") {
    const _batch_0 = _result_0["batch"];
    const _target_0 = _result_0["target"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Accepted", "target": _target_0, "spawned": true, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $ecs$047bundle$045batch$058spawn$1260$(_batch_0, _payload_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  return $ecs$047bundle$045batch$058spawn_reserved$1260$(_prepared_0, _payload_0, ($ecs$047commands$058tx_spawn$1260$(_tx_0, {$: "Unit"})));
}

function $ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, ($ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, {$: "ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
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

function $ecs$047decode$045data$058binary_integer_checked$(_result_0, _small_0) {
  return $Bool$and$(_small_0, ($ecs$047decode$045data$058binary_integer_normal$(_result_0)));
}

function $ecs$047decode$045data$058binary_numeric$(_high_0, _low_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_1 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_2 = (2048 === 0 ? _x_1 : _x_1 % 2048);
  const _x_3 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_4 = (2048 === 0 ? _x_3 : _x_3 % 2048);
  return $ecs$047decode$045data$058binary_parts$((_high_0 >= 2147483648), (2048 === 0 ? _x_0 : _x_0 % 2048), (1048576 === 0 ? _high_0 : _high_0 % 1048576), _low_0, (_x_2 === 2047), (_x_4 === 0));
}

function $ecs$047decode$045data$058same_numeric$(_a_0, _b_0) {
  if (_a_0.$ === "ecs/decode-data.Finite") {
    const _an_0 = _a_0["negative"];
    const _ah_0 = _a_0["high"];
    const _al_0 = _a_0["low"];
    const _ae_0 = _a_0["exponent"];
    if (_b_0.$ === "ecs/decode-data.Finite") {
      const _bn_0 = _b_0["negative"];
      const _bh_0 = _b_0["high"];
      const _bl_0 = _b_0["low"];
      const _be_0 = _b_0["exponent"];
      return $Bool$and$(($Bool$and$(($Bool$and$(($ecs$047decode$045data$058same_bool$(_an_0, _bn_0)), (_ah_0 === _bh_0))), (_al_0 === _bl_0))), (_ae_0 === _be_0));
    } else {
      return false;
    }
  } else if (_a_0.$ === "ecs/decode-data.Infinity") {
    const _a_1 = _a_0["negative"];
    if (_b_0.$ === "ecs/decode-data.Infinity") {
      const _b_1 = _b_0["negative"];
      return $ecs$047decode$045data$058same_bool$(_a_1, _b_1);
    } else {
      return false;
    }
  } else if (_a_0.$ === "ecs/decode-data.NaN") {
    if (_b_0.$ === "ecs/decode-data.NaN") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function $ecs$047decode$045data$058numeric$(_raw_0) {
  if (_raw_0.$ === "ecs/decode-data.Number") {
    const _value_0 = _raw_0["value"];
    return $ecs$047decode$045data$058normalize$(64, false, 0, _value_0, 1074);
  } else if (_raw_0.$ === "ecs/decode-data.SignedInteger") {
    const _negative_0 = _raw_0["negative"];
    const _value_1 = _raw_0["magnitude"];
    const _x_0 = ($Nat$div$(_value_1, nat_chk(65536 * 65536)));
    const _x_1 = ($Nat$mod$(_value_1, nat_chk(65536 * 65536)));
    return $ecs$047decode$045data$058normalize$(64, _negative_0, (_x_0 >>> 0), (_x_1 >>> 0), 1074);
  } else if (_raw_0.$ === "ecs/decode-data.Float") {
    const _value_2 = _raw_0["value"];
    return $ecs$047decode$045data$058float_numeric$(f32_bits(_value_2));
  } else if (_raw_0.$ === "ecs/decode-data.Binary64") {
    const _high_0 = _raw_0["high"];
    const _low_0 = _raw_0["low"];
    return $ecs$047decode$045data$058binary_numeric$(_high_0, _low_0);
  } else {
    return {$: "ecs/decode-data.NotNumber"};
  }
}

function $ecs$047decode$045utf16$058checked$(_left_0, _right_0) {
  return $Bool$and$(($Bool$and$(($ecs$047decode$045utf16$058valid$(_left_0)), ($ecs$047decode$045utf16$058valid$(_right_0)))), ($ecs$047decode$045utf16$058equal$(_left_0, _right_0)));
}

function $ecs$047decode$045utf16$058text$(_value_0) {
  if (_value_0 === "") {
    return {$: "Nil"};
  } else {
    const _t_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(0, 2) : _value_0[0]);
    const _tail_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(2) : _value_0.slice(1));
    const _x_0 = _t_0.codePointAt(0);
    return $ecs$047decode$045utf16$058scalar$(_t_0.codePointAt(0), ($ecs$047decode$045utf16$058text$(_tail_0)), (_x_0 < 65536));
  }
}

function $ecs$047decode$045data$058same_bool$(_a_0, _b_0) {
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

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $ecs$047decode$045requests$058inserted$1261$(_declaration_0, _target_0, _canonical_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Accepted", "target": _target_0, "spawned": false, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $ecs$047bundle$045batch$058insert$1261$(_batch_0, _target_0, _payload_0) {
  const _t_0 = _batch_0["tx"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _prepared_0 = _batch_0["prepared"];
  return $ecs$047bundle$045batch$058checked$1261$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($ecs$047world$058valid$1261$(_world_0, _target_0)));
}

function $ecs$047decode$045requests$058spawned$1261$(_declaration_0, _canonical_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Spawned") {
    const _batch_0 = _result_0["batch"];
    const _target_0 = _result_0["target"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_0, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Accepted", "target": _target_0, "spawned": true, "canonical": _canonical_0}};
  } else {
    const _batch_1 = _result_0["batch"];
    const _t_0 = _result_0["payload"];
    const _owner_0 = _t_0["owner"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/decode-requests.Owner", "batch": _batch_1, "declaration": _declaration_0}, "snd": {$: "ecs/decode-requests.Refused", "owner": _owner_0, "error": {$: "ecs/decode-requests.Entity", "error": _error_0}}};
  }
}

function $ecs$047bundle$045batch$058spawn$1261$(_batch_0, _payload_0) {
  const _tx_0 = _batch_0["tx"];
  const _prepared_0 = _batch_0["prepared"];
  return $ecs$047bundle$045batch$058spawn_reserved$1261$(_prepared_0, _payload_0, ($ecs$047commands$058tx_spawn$1261$(_tx_0, {$: "Unit"})));
}

function $ecs$047bundle$045batch$058checked$1260$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $ecs$047bundle$045batch$058receipt_checked$1260$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058receipt_find$1260$(_prepared_0, _target_0)));
  } else {
    return $ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1260$(_commands_0)));
  }
}

function $ecs$047bundle$045batch$058spawn_reserved$1260$(_prepared_0, _payload_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "ecs/world.Reserved") {
    const _target_0 = _t_1["handle"];
    return $ecs$047bundle$045batch$058spawn_positioned$1260$(_target_0, ($ecs$047bundle$045batch$058positioned$1260$({$: "Con", "head": {$: "ecs/bundle-batch.ReservationReceipt", "target": _target_0}, "tail": _prepared_0}, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1260$(_commands_0)))));
  } else {
    const _error_0 = _t_1["error"];
    return {$: "ecs/bundle-batch.SpawnRefused", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": _error_0};
  }
}

function $ecs$047commands$058tx_spawn$1260$(_tx_0, _payload_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047commands$058spawn_join$1260$(($ecs$047world$058reserve_id$1260$(_world_0)), _undo_0, _commands_0, _events_0, _payload_0);
}

function $ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "ecs/decode-data.Accepted", "value": ($ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($ecs$047decode$045data$058validate$(_fuel_0, {$: "ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
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

function $ecs$047decode$045data$058binary_integer_normal$(_result_0) {
  if (_result_0.$ === "ecs/decode-data.Finite") {
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

function $ecs$047decode$045data$058binary_parts$(_negative_0, _exponent_0, _high_0, _low_0, _special_0, _zero_0) {
  if (_special_0) {
    return $ecs$047decode$045data$058numeric_special$(_negative_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))));
  } else {
    if (_zero_0) {
      return $ecs$047decode$045data$058normalize$(64, _negative_0, _high_0, _low_0, 0);
    } else {
      return $ecs$047decode$045data$058normalize$(64, _negative_0, ((_high_0 + 1048576) >>> 0), _low_0, ((_exponent_0 - 1) >>> 0));
    }
  }
}

function $ecs$047decode$045data$058normalize$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0) {
  const _x_0 = (2 === 0 ? _low_0 : _low_0 % 2);
  return $ecs$047decode$045data$058normalize_checked$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))), (_x_0 === 0));
}

function $Nat$mod$(_a_0, _b_0) {
  return $Pair$snd$(nat_divmod(_a_0, _b_0));
}

function $ecs$047decode$045data$058float_numeric$(_bits_0) {
  const _x_0 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_1 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_2 = (256 === 0 ? _x_1 : _x_1 % 256);
  const _x_3 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_4 = (256 === 0 ? _x_3 : _x_3 % 256);
  return $ecs$047decode$045data$058float_parts$(_bits_0, (256 === 0 ? _x_0 : _x_0 % 256), (8388608 === 0 ? _bits_0 : _bits_0 % 8388608), (_x_2 === 255), (_x_4 === 0));
}

function $ecs$047decode$045utf16$058equal$(_left_0, _right_0) {
  if (_left_0.$ === "Nil") {
    return $ecs$047decode$045utf16$058empty$(_right_0);
  } else {
    const _head_0 = _left_0["head"];
    const _tail_0 = _left_0["tail"];
    return $ecs$047decode$045utf16$058compared$(_head_0, _right_0, run_clo((_x_0) => {
  return $ecs$047decode$045utf16$058equal$(_tail_0, _x_0);
}));
  }
}

function $ecs$047decode$045utf16$058scalar$(_code_0, _rest_0, _bmp_0) {
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

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $ecs$047bundle$045batch$058checked$1261$(_prepared_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return $ecs$047bundle$045batch$058receipt_checked$1261$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058receipt_find$1261$(_prepared_0, _target_0)));
  } else {
    return $ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1261$(_commands_0)));
  }
}

function $ecs$047bundle$045batch$058spawn_reserved$1261$(_prepared_0, _payload_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _t_1 = _result_0["snd"];
  if (_t_1.$ === "ecs/world.Reserved") {
    const _target_0 = _t_1["handle"];
    return $ecs$047bundle$045batch$058spawn_positioned$1261$(_target_0, ($ecs$047bundle$045batch$058positioned$1261$({$: "Con", "head": {$: "ecs/bundle-batch.ReservationReceipt", "target": _target_0}, "tail": _prepared_0}, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1261$(_commands_0)))));
  } else {
    const _error_0 = _t_1["error"];
    return {$: "ecs/bundle-batch.SpawnRefused", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": _error_0};
  }
}

function $ecs$047commands$058tx_spawn$1261$(_tx_0, _payload_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $ecs$047commands$058spawn_join$1261$(($ecs$047world$058reserve_id$1261$(_world_0)), _undo_0, _commands_0, _events_0, _payload_0);
}

function $ecs$047bundle$045batch$058receipt_checked$1260$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _result_0) {
  const _prepared_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (!_t_0) {
    return {$: "ecs/bundle-batch.Refused", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": {$: "ecs/world.MissingEntity"}};
  } else {
    return $ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1260$(_commands_0)));
  }
}

function $ecs$047bundle$045batch$058receipt_find$1260$(_prepared_0, _target_0) {
  if (_prepared_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": false};
  } else {
    const _t_0 = _prepared_0["head"];
    if (_t_0.$ === "ecs/bundle-batch.Prepared") {
      const _handle_0 = _t_0["target"];
      const _payload_0 = _t_0["payload"];
      const _position_0 = _t_0["position"];
      const _tail_0 = _prepared_0["tail"];
      return $ecs$047bundle$045batch$058receipt_join$1260$({$: "ecs/bundle-batch.Prepared", "target": _handle_0, "payload": _payload_0, "position": _position_0}, false, ($ecs$047bundle$045batch$058receipt_find$1260$(_tail_0, _target_0)));
    } else {
      const _t_1 = _t_0["target"];
      const _ns_0 = _t_1["namespace"];
      const _id_0 = _t_1["id"];
      const _tail_1 = _prepared_0["tail"];
      const _otherNs_0 = _target_0["namespace"];
      const _otherId_0 = _target_0["id"];
      return $ecs$047bundle$045batch$058receipt_join$1260$({$: "ecs/bundle-batch.ReservationReceipt", "target": {$: "ecs/world.Handle", "namespace": _ns_0, "id": _id_0}}, ($Bool$and$((_ns_0 === _otherNs_0), (_id_0 === _otherId_0))), ($ecs$047bundle$045batch$058receipt_find$1260$(_tail_1, {$: "ecs/world.Handle", "namespace": _otherNs_0, "id": _otherId_0})));
    }
  }
}

function $ecs$047bundle$045batch$058positioned$1260$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _position_0 = _result_0["snd"];
  return {$: "ecs/bundle-batch.Inserted", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": {$: "Con", "head": {$: "ecs/bundle-batch.Prepared", "target": _target_0, "payload": _payload_0, "position": _position_0}, "tail": _prepared_0}}};
}

function $ecs$047bundle$045batch$058count_commands$1260$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $ecs$047bundle$045batch$058counted$1260$(_command_0, ($ecs$047bundle$045batch$058count_commands$1260$(_tail_0)));
  }
}

function $ecs$047bundle$045batch$058spawn_positioned$1260$(_target_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "ecs/bundle-batch.Spawned", "batch": _batch_0, "target": _target_0};
  } else {
    const _batch_1 = _result_0["batch"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return {$: "ecs/bundle-batch.SpawnRefused", "batch": _batch_1, "payload": _payload_0, "error": _error_0};
  }
}

function $ecs$047commands$058spawn_join$1260$(_reserved_0, _undo_0, _commands_0, _events_0, _payload_0) {
  const _world_0 = _reserved_0["fst"];
  const _reservation_0 = _reserved_0["snd"];
  return $ecs$047commands$058spawn_reserved$1260$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0);
}

function $ecs$047world$058reserve_id$1260$(_world_0) {
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
  return $ecs$047world$058reserve_available$1260$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
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

function $ecs$047decode$045data$058numeric_special$(_negative_0, _infinite_0) {
  if (_infinite_0) {
    return {$: "ecs/decode-data.Infinity", "negative": _negative_0};
  } else {
    return {$: "ecs/decode-data.NaN"};
  }
}

function $ecs$047decode$045data$058normalize_checked$($0, $1, $2, $3, $4, $5, $6) {
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
          return {$: "ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          } else {
            return {$: "ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_zero_0) {
          return {$: "ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
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

function $ecs$047decode$045data$058float_parts$(_bits_0, _exponent_0, _fraction_0, _special_0, _zero_0) {
  if (_special_0) {
    return $ecs$047decode$045data$058numeric_special$((_bits_0 >= 2147483648), (_fraction_0 === 0));
  } else {
    if (_zero_0) {
      return $ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, _fraction_0, 925);
    } else {
      return $ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, ((_fraction_0 + 8388608) >>> 0), ((_exponent_0 + 924) >>> 0));
    }
  }
}

function $ecs$047decode$045utf16$058empty$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    return false;
  }
}

function $ecs$047decode$045utf16$058compared$(_head_0, _other_0, _next_0) {
  if (_other_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _other_0["head"];
    const _tail_0 = _other_0["tail"];
    return $Bool$and$((_head_0 === _value_0), _next_0(_tail_0));
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

function $ecs$047bundle$045batch$058receipt_checked$1261$(_world_0, _undo_0, _commands_0, _events_0, _target_0, _payload_0, _result_0) {
  const _prepared_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (!_t_0) {
    return {$: "ecs/bundle-batch.Refused", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": _prepared_0}, "payload": _payload_0, "error": {$: "ecs/world.MissingEntity"}};
  } else {
    return $ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, ($ecs$047bundle$045batch$058count_commands$1261$(_commands_0)));
  }
}

function $ecs$047bundle$045batch$058receipt_find$1261$(_prepared_0, _target_0) {
  if (_prepared_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": false};
  } else {
    const _t_0 = _prepared_0["head"];
    if (_t_0.$ === "ecs/bundle-batch.Prepared") {
      const _handle_0 = _t_0["target"];
      const _payload_0 = _t_0["payload"];
      const _position_0 = _t_0["position"];
      const _tail_0 = _prepared_0["tail"];
      return $ecs$047bundle$045batch$058receipt_join$1261$({$: "ecs/bundle-batch.Prepared", "target": _handle_0, "payload": _payload_0, "position": _position_0}, false, ($ecs$047bundle$045batch$058receipt_find$1261$(_tail_0, _target_0)));
    } else {
      const _t_1 = _t_0["target"];
      const _ns_0 = _t_1["namespace"];
      const _id_0 = _t_1["id"];
      const _tail_1 = _prepared_0["tail"];
      const _otherNs_0 = _target_0["namespace"];
      const _otherId_0 = _target_0["id"];
      return $ecs$047bundle$045batch$058receipt_join$1261$({$: "ecs/bundle-batch.ReservationReceipt", "target": {$: "ecs/world.Handle", "namespace": _ns_0, "id": _id_0}}, ($Bool$and$((_ns_0 === _otherNs_0), (_id_0 === _otherId_0))), ($ecs$047bundle$045batch$058receipt_find$1261$(_tail_1, {$: "ecs/world.Handle", "namespace": _otherNs_0, "id": _otherId_0})));
    }
  }
}

function $ecs$047bundle$045batch$058positioned$1261$(_prepared_0, _world_0, _undo_0, _events_0, _target_0, _payload_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _position_0 = _result_0["snd"];
  return {$: "ecs/bundle-batch.Inserted", "batch": {$: "ecs/bundle-batch.Batch", "tx": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "prepared": {$: "Con", "head": {$: "ecs/bundle-batch.Prepared", "target": _target_0, "payload": _payload_0, "position": _position_0}, "tail": _prepared_0}}};
}

function $ecs$047bundle$045batch$058count_commands$1261$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $ecs$047bundle$045batch$058counted$1261$(_command_0, ($ecs$047bundle$045batch$058count_commands$1261$(_tail_0)));
  }
}

function $ecs$047bundle$045batch$058spawn_positioned$1261$(_target_0, _result_0) {
  if (_result_0.$ === "ecs/bundle-batch.Inserted") {
    const _batch_0 = _result_0["batch"];
    return {$: "ecs/bundle-batch.Spawned", "batch": _batch_0, "target": _target_0};
  } else {
    const _batch_1 = _result_0["batch"];
    const _payload_0 = _result_0["payload"];
    const _error_0 = _result_0["error"];
    return {$: "ecs/bundle-batch.SpawnRefused", "batch": _batch_1, "payload": _payload_0, "error": _error_0};
  }
}

function $ecs$047commands$058spawn_join$1261$(_reserved_0, _undo_0, _commands_0, _events_0, _payload_0) {
  const _world_0 = _reserved_0["fst"];
  const _reservation_0 = _reserved_0["snd"];
  return $ecs$047commands$058spawn_reserved$1261$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0);
}

function $ecs$047world$058reserve_id$1261$(_world_0) {
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
  return $ecs$047world$058reserve_available$1261$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $ecs$047bundle$045batch$058receipt_join$1260$(_entry_0, _seen_0, _result_0) {
  const _tail_0 = _result_0["fst"];
  const _found_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _entry_0, "tail": _tail_0}, "snd": (_seen_0 || _found_0)};
}

function $ecs$047bundle$045batch$058counted$1260$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $ecs$047commands$058spawn_reserved$1260$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0) {
  if (_reservation_0.$ === "ecs/world.ReservationRejected") {
    const _error_0 = _reservation_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": {$: "ecs/world.ReservationRejected", "error": _error_0}};
  } else {
    const _handle_0 = _reservation_0["handle"];
    return {$: "Tuple", "fst": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": run_clo((_x_0) => {
  return $ecs$047commands$058spawn_apply$1260$(_x_0, _handle_0, _payload_0);
}), "tail": _commands_0}, "events": _events_0}, "snd": {$: "ecs/world.Reserved", "handle": _handle_0}};
  }
}

function $ecs$047world$058reserve_available$1260$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "ecs/world.ReservationRejected", "error": {$: "ecs/world.CapacityExceeded"}}};
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
      return $ecs$047world$058reserve_finish$1260$({$: "ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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
      return $ecs$047world$058reserve_finish$1260$(($ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
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

function $String$cmp$rec$(_h1b_0, _h2b_0, _rr_0) {
  const _t_0 = _rr_0["fst"];
  const _t1b_0 = _t_0["fst"];
  const _t2b_0 = _t_0["snd"];
  const _r_0 = _rr_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1b_0), "snd": (_h2b_0 + _t2b_0)}, "snd": _r_0};
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

function $ecs$047bundle$045batch$058receipt_join$1261$(_entry_0, _seen_0, _result_0) {
  const _tail_0 = _result_0["fst"];
  const _found_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _entry_0, "tail": _tail_0}, "snd": (_seen_0 || _found_0)};
}

function $ecs$047bundle$045batch$058counted$1261$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $ecs$047commands$058spawn_reserved$1261$(_reservation_0, _world_0, _undo_0, _commands_0, _events_0, _payload_0) {
  if (_reservation_0.$ === "ecs/world.ReservationRejected") {
    const _error_0 = _reservation_0["error"];
    return {$: "Tuple", "fst": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": {$: "ecs/world.ReservationRejected", "error": _error_0}};
  } else {
    const _handle_0 = _reservation_0["handle"];
    return {$: "Tuple", "fst": {$: "ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": run_clo((_x_0) => {
  return $ecs$047commands$058spawn_apply$1261$(_x_0, _handle_0, _payload_0);
}), "tail": _commands_0}, "events": _events_0}, "snd": {$: "ecs/world.Reserved", "handle": _handle_0}};
  }
}

function $ecs$047world$058reserve_available$1261$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "ecs/world.ReservationRejected", "error": {$: "ecs/world.CapacityExceeded"}}};
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
      return $ecs$047world$058reserve_finish$1261$({$: "ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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
      return $ecs$047world$058reserve_finish$1261$(($ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
    }
  }
}

function $ecs$047commands$058spawn_apply$1260$(_world_0, _handle_0, _payload_0) {
  return $ecs$047commands$058spawned$1260$(($ecs$047world$058activate$1260$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $ecs$047world$058reserve_finish$1260$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "ecs/world.Reserved", "handle": {$: "ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $ecs$047world$058grow_live$($0, $1, $2, $3) {
  for (;;) {
    {
      const _remaining_0 = $0;
      const _capacity_0 = $1;
      const _depth_0 = $2;
      const _live_0 = $3;
      if (_remaining_0 === 0) {
        return {$: "ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0};
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

function $ecs$047commands$058spawn_apply$1261$(_world_0, _handle_0, _payload_0) {
  return $ecs$047commands$058spawned$1261$(($ecs$047world$058activate$1261$(_world_0, _handle_0)), _handle_0, _payload_0);
}

function $ecs$047world$058reserve_finish$1261$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "ecs/world.Reserved", "handle": {$: "ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $ecs$047commands$058spawned$1260$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "ecs/world.Accepted") {
    return _world_0;
  } else {
    return _world_0;
  }
}

function $ecs$047world$058activate$1260$(_world_0, _handle_0) {
  return $ecs$047world$058set_live_join$1260$(true, _handle_0, ($ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $ecs$047commands$058spawned$1261$(_activated_0, _handle_0, _payload_0) {
  const _world_0 = _activated_0["fst"];
  const _t_0 = _activated_0["snd"];
  if (_t_0.$ === "ecs/world.Accepted") {
    return _world_0;
  } else {
    return _world_0;
  }
}

function $ecs$047world$058activate$1261$(_world_0, _handle_0) {
  return $ecs$047world$058set_live_join$1261$(true, _handle_0, ($ecs$047world$058metadata_valid$1261$(_world_0, _handle_0)));
}

function $ecs$047world$058set_live_join$1260$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $ecs$047world$058set_live_join$1261$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "ecs/world.Rejected", "error": {$: "ecs/world.MissingEntity"}}};
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
    return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "ecs/world.Accepted"}};
  }
}

function $ecs$047world$058set_live_checked$1261$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "ecs/world.Rejected", "error": {$: "ecs/world.MissingEntity"}}};
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
    return {$: "Tuple", "fst": {$: "ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "ecs/world.Accepted"}};
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
io_exit($main$, [[7,0,1,0,0,2,0,0,11,90,11,7,0,1,1,0,2,0,0,22,45,22,7,0,2,2,0,6,0,1,45,16,45,31,88,32,349,43,490,44,518,3,0,0,0,7,0,1,4,0,5,0,0,62,9,155,10,181,10,188,14,87,7,0,1,5,0,9,0,0,87,1,87,2,87,3,87,4,88,5,89,6,111,7,87,8,87,0,2,7,1,2,6,0,0,1,7,0,2,1,0,104,1,89,7,1,1,8,0,0,0,7,1,2,9,0,0,1,10,0,2,1,0,126,1,111,7,1,1,11,0,3,0,0,87,1,139,2,140,4,7,1,2,12,0,0,1,13,0,2,1,0,139,1,140,7,1,2,14,0,0,1,15,0,2,1,0,170,1,155,7,1,2,16,0,0,0,17,0,0,0,7,0,1,18,0,0,0,7,0,1,19,0,4,0,0,203,1,203,2,292,3,155,7,1,12,20,0,0,0,21,0,0,0,22,0,1,0,0,87,23,0,2,0,0,280,1,88,24,0,1,0,0,291,25,0,2,0,0,87,1,87,26,0,1,0,0,139,27,0,1,0,0,292,28,0,1,0,0,280,29,0,2,0,0,87,1,87,30,0,1,0,0,308,31,0,1,0,0,323,7,0,2,32,0,0,0,33,0,0,0,1,7,1,2,34,0,0,1,35,0,2,1,0,307,1,292,0,7,1,2,36,0,0,1,37,0,2,1,0,203,1,308,7,1,2,38,0,0,1,39,0,2,1,0,338,1,323,7,1,1,40,0,2,0,0,139,1,203,7,0,2,41,0,4,0,1,87,2,87,3,280,4,203,42,0,2,0,1,372,5,398,7,0,2,43,0,0,0,44,0,1,0,1,385,7,0,1,45,0,3,0,0,203,1,292,2,155,7,0,2,46,0,1,0,1,413,47,0,1,0,1,456,7,0,2,48,0,1,0,1,428,49,0,1,0,1,447,7,0,2,50,0,3,0,1,139,2,139,3,203,51,0,1,0,1,139,7,0,1,52,0,1,0,0,87,7,0,2,53,0,1,0,1,428,54,0,1,0,1,471,7,0,4,55,0,0,0,56,0,0,0,57,0,0,0,58,0,0,0,7,1,2,59,0,0,1,60,0,2,1,0,505,1,490,7,1,1,61,0,3,0,0,203,1,292,2,155,7,0,2,62,0,0,0,63,0,1,0,1,181],["Candidate","Cases","fallible-composition-v1/request-fixture.Report","fallible-composition-v1/request-fixture.CreateRejected","fixture.Snapshot","fixture.Meta","Nil","Con","Unit","Nil","Con","ecs/world.RegistrationMeta","Nil","Con","Nil","Con","False","True","Unit","fixture.View","ecs/decode-data.Missing","ecs/decode-data.Null","ecs/decode-data.Number","ecs/decode-data.SignedInteger","ecs/decode-data.Float","ecs/decode-data.Binary64","ecs/decode-data.Text","ecs/decode-data.Utf16Text","ecs/decode-data.Boolean","ecs/decode-data.Handle","ecs/decode-data.Array","ecs/decode-data.Object","False","True","Nil","Con","Nil","Con","Nil","Con","ecs/decode-data.Field","fallible-composition-v1/request-fixture.Accepted","fallible-composition-v1/request-fixture.Refused","None","Some","fixture.InputView","ecs/decode-fallible-constructed-requests.Construction","ecs/decode-fallible-constructed-requests.Operation","ecs/decode-construction.Validation","ecs/decode-construction.Constructor","ecs/decode-data.Invalid","ecs/decode-data.FuelExhausted","fallible-composition-v1/business.Denied","ecs/decode-requests.Validation","ecs/decode-requests.Entity","ecs/world.MissingEntity","ecs/world.CapacityExceeded","ecs/world.NamespaceExhausted","ecs/world.SystemIdExhausted","Nil","Con","fixture.InputView","ecs/transaction.Success","ecs/transaction.Failure"]]);