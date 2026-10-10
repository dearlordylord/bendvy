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
  return $consumer$058report$1260$();
}

function $consumer$058report$1260$() {
  return {$: "consumer.Report", "exit": run_loop($consumer$058scenario$1260$(1)), "transition": run_loop($consumer$058scenario$1260$(2)), "enter": run_loop($consumer$058scenario$1260$(3))};
}

function $consumer$058scenario$1260$(_id_0) {
  return $consumer$058created$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058create$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()))));
}

function $consumer$058created$1260$(_id_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.ConstructionRefused") {
    return "construction-refused";
  } else {
    const _app_0 = _result_0["application"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058sequence$1260$({$: "Con", "head": run_clo((_x_0) => {
  return $consumer$058snapshot$1260$(_x_0);
}), "tail": {$: "Con", "head": run_clo((_x_1) => {
  return $consumer$058marker$1260$(_x_1);
}), "tail": {$: "Con", "head": run_clo((_x_2) => {
  return $consumer$058read$1260$(_x_2);
}), "tail": {$: "Con", "head": run_clo((_x_3) => {
  return $consumer$058retry$1260$(_id_0, _x_3);
}), "tail": {$: "Con", "head": run_clo((_x_4) => {
  return $consumer$058read$1260$(_x_4);
}), "tail": {$: "Con", "head": run_clo((_x_5) => {
  return $consumer$058snapshot$1260$(_x_5);
}), "tail": {$: "Nil"}}}}}}}, "", ($consumer$058converted$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058queue_play$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058install_reader$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058seeded$1260$(_id_0, _app_0)))))))));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058create$1260$(_factory_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058created$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058initial_resources$1260$()))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$() {
  return {$: "../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": 1};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058sequence$1260$(_actions_0, _prior_0, _app_0) {
  if (_actions_0.$ === "Nil") {
    return _prior_0;
  } else {
    const _action_0 = _actions_0["head"];
    const _rest_0 = _actions_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058continued$1260$(run_clo((_x_0) => {
  return run_clo((_x_1) => {
  const _x_2 = (_x_1 + "\n");
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058sequence$1260$(_rest_0, (_prior_0 + _x_2), _x_0);
});
}), _action_0(_app_0));
  }
}

function $consumer$058snapshot$1260$(_app_0) {
  return $consumer$058shown$1260$("snapshot", ($consumer$058observe$1260$(_app_0)));
}

function $consumer$058marker$1260$(_app_0) {
  if (_app_0.$ === "consumer.Application") {
    const _world_0 = _app_0["world"];
    const _bundle_0 = _app_0["bundle"];
    const _reader_0 = _app_0["reader"];
    return $consumer$058returned$1260$(_reader_0, ($adapter$058run$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058declare$1260$("handler-bundle-global-marker")), _bundle_0, _world_0)));
  } else {
    return {$: "Tuple", "fst": _app_0, "snd": "internal-owner-remainder"};
  }
}

function $consumer$058read$1260$(_app_0) {
  if (_app_0.$ === "consumer.Application") {
    const _world_0 = _app_0["world"];
    const _bundle_0 = _app_0["bundle"];
    const _reader_0 = _app_0["reader"];
    return $consumer$058read_returned$1260$(_bundle_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read$1260$({$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": {$: "Nil"}, "enter": {$: "Nil"}}, "readerRegistry": _reader_0})));
  } else {
    return {$: "Tuple", "fst": _app_0, "snd": "internal-owner-remainder"};
  }
}

function $consumer$058retry$1260$(_id_0, _app_0) {
  if (_id_0 == 3) {
    if (_app_0.$ === "consumer.Application") {
      const _world_0 = _app_0["world"];
      const _bundle_0 = _app_0["bundle"];
      const _reader_0 = _app_0["reader"];
      return $consumer$058marker$1260$(($consumer$058queue_taken$1260$(_bundle_0, _reader_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)))));
    } else {
      return $consumer$058marker$1260$(_app_0);
    }
  } else {
    return $consumer$058marker$1260$(_app_0);
  }
}

function $consumer$058converted$1260$(_app_0) {
  const _world_0 = _app_0["world"];
  const _t_0 = _app_0["owners"];
  const _exit_0 = _t_0["exit"];
  const _transition_0 = _t_0["transition"];
  const _enter_0 = _t_0["enter"];
  const _reader_0 = _app_0["readerRegistry"];
  return $consumer$058named$1260$(_reader_0, ($List$append$(($consumer$058wrapped$1260$({$: "../../../../../bendvy/src/ecs/machine-handler-bundle.ExitFrom", "value": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot"}}, {$: "Con", "head": 1, "tail": {$: "Con", "head": 2, "tail": {$: "Con", "head": 1, "tail": {$: "Nil"}}}}, _exit_0)), ($List$append$(($consumer$058wrapped$1260$({$: "../../../../../bendvy/src/ecs/machine-handler-bundle.TransitionPair", "from": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot"}, "to": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play"}}, {$: "Con", "head": 2, "tail": {$: "Nil"}}, _transition_0)), ($consumer$058wrapped$1260$({$: "../../../../../bendvy/src/ecs/machine-handler-bundle.EnterTo", "value": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play"}}, {$: "Con", "head": 1, "tail": {$: "Nil"}}, _enter_0)))))), ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058queue_play$1260$(_app_0) {
  const _world_0 = _app_0["world"];
  const _owners_0 = _app_0["owners"];
  const _readerRegistry_0 = _app_0["readerRegistry"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058queue_slot$1260$(_readerRegistry_0, _owners_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058install_reader$1260$(_app_0) {
  const _world_0 = _app_0["world"];
  const _owners_0 = _app_0["owners"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reader_registered$1260$(_owners_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1260$(_world_0, "reader", {$: "Con", "head": "machine:read", "tail": {$: "Nil"}})));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058seeded$1260$(_id_0, _app_0) {
  const _t_0 = _app_0["world"];
  const _ns_0 = _t_0["namespace"];
  const _next_0 = _t_0["nextId"];
  const _high_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _store_0 = _t_0["store"];
  const _t_1 = _t_0["resource"];
  const _owned_0 = _t_1["owned"];
  const _slot_0 = _t_1["slot"];
  const _stream_0 = _t_1["stream"];
  const _reader_0 = _t_1["reader"];
  const _locals_0 = _t_1["locals"];
  const _tick_0 = _t_1["tick"];
  const _prefix_0 = _t_1["prefix"];
  const _delivered_0 = _t_1["delivered"];
  const _applied_0 = _t_1["structuralApplied"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystem_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _owners_0 = _app_0["owners"];
  const _readerRegistry_0 = _app_0["readerRegistry"];
  return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": (_owned_0[1 % _owned_0.length] = _id_0, _owned_0), "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "owners": _owners_0, "readerRegistry": _readerRegistry_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058created$1260$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/world.CreateRejected") {
    const _factory_0 = _result_0["factory"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.ConstructionRefused", "factory": _factory_0};
  } else {
    const _factory_1 = _result_0["factory"];
    const _world_0 = _result_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reserved$1260$(_factory_1, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058initial_resources$1260$() {
  return {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": array_node([0], [19]), "slot": {$: "../../../../../bendvy/src/ecs/machine.Present", "current": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot"}, "pending": {$: "../../../../../bendvy/src/ecs/machine.NoPending"}, "previous": {$: "None"}, "changed": false}, "stream": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058empty$1260$()), "reader": {$: "None"}, "locals": {$: "Nil"}, "tick": 0, "prefix": {$: "Nil"}, "delivered": {$: "Nil"}, "structuralApplied": 0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058continued$1260$(_next_0, _result_0) {
  const _app_0 = _result_0["fst"];
  const _text_0 = _result_0["snd"];
  return run_tail(_next_0(_app_0), _text_0);
}

function $consumer$058shown$1260$(_label_0, _pair_0) {
  const _app_0 = _pair_0["fst"];
  const _text_0 = _pair_0["snd"];
  const _x_0 = (":" + _text_0);
  return {$: "Tuple", "fst": _app_0, "snd": (_label_0 + _x_0)};
}

function $consumer$058observe$1260$(_app_0) {
  if (_app_0.$ === "consumer.Application") {
    const _world_0 = _app_0["world"];
    const _t_0 = _app_0["bundle"];
    const _namespace_0 = _t_0["namespace"];
    const _items_0 = _t_0["entries"];
    const _reader_0 = _app_0["reader"];
    return $consumer$058observed$1260$(_namespace_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058world$1260$(_world_0)), ($consumer$058entries$1260$(_items_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058registry$1260$(_reader_0)));
  } else {
    return {$: "Tuple", "fst": _app_0, "snd": "internal-owner-remainder"};
  }
}

function $consumer$058returned$1260$(_reader_0, _result_0) {
  const _t_0 = _result_0["result"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned") {
    const _bundle_0 = _t_0["bundle"];
    const _world_0 = _t_0["world"];
    const _outcome_0 = _t_0["status"];
    const _steps_0 = _result_0["steps"];
    const _observations_0 = _result_0["observations"];
    const _x_0 = ($List$show$12610$(_observations_0));
    const _x_1 = ($List$show$1269$(_steps_0));
    const _x_2 = ("/observations=" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    const _x_4 = ($consumer$058status$(_outcome_0));
    const _x_5 = ("/steps=" + _x_3);
    const _x_6 = (_x_4 + _x_5);
    return $consumer$058shown$1260$(("marker=" + _x_6), ($consumer$058observe$1260$({$: "consumer.Application", "world": _world_0, "bundle": _bundle_0, "reader": _reader_0})));
  } else {
    const _namespace_0 = _t_0["namespace"];
    const _recovery_0 = _t_0["recovery"];
    const _world_1 = _t_0["world"];
    return {$: "Tuple", "fst": {$: "consumer.Internal", "world": _world_1, "namespace": _namespace_0, "recovery": _recovery_0, "reader": _reader_0}, "snd": "internal-owner-remainder"};
  }
}

function $adapter$058run$1260$(_declaration_0, _bundle_0, _world_0) {
  const _namespace_0 = _bundle_0["namespace"];
  const _entries_0 = _bundle_0["entries"];
  return $adapter$058named$1260$(_declaration_0, _namespace_0, _entries_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058declare$1260$(_name_0) {
  return {$: "../../../../../bendvy/src/ecs/ordinary-machine-schedule.Declaration", "name": _name_0};
}

function $consumer$058read_returned$1260$(_bundle_0, _app_0) {
  const _world_0 = _app_0["world"];
  const _t_0 = _app_0["owners"];
  const _t_1 = _t_0["exit"];
  if (_t_1.$ === "Nil") {
    const _t_2 = _t_0["transition"];
    if (_t_2.$ === "Nil") {
      const _t_3 = _t_0["enter"];
      if (_t_3.$ === "Nil") {
        const _reader_0 = _app_0["readerRegistry"];
        return $consumer$058shown$1260$("read", ($consumer$058observe$1260$({$: "consumer.Application", "world": _world_0, "bundle": _bundle_0, "reader": _reader_0})));
      } else {
        const _reader_1 = _app_0["readerRegistry"];
        return $consumer$058unexpected_read$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": {$: "Nil"}, "enter": _t_3}, _reader_1, _bundle_0);
      }
    } else {
      const _23_0 = _t_0["enter"];
      const _reader_2 = _app_0["readerRegistry"];
      return $consumer$058unexpected_read$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": _t_2, "enter": _23_0}, _reader_2, _bundle_0);
    }
  } else {
    const _22_0 = _t_0["transition"];
    const _23_1 = _t_0["enter"];
    const _reader_3 = _app_0["readerRegistry"];
    return $consumer$058unexpected_read$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _t_1, "transition": _22_0, "enter": _23_1}, _reader_3, _bundle_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read$1260$(_app_0) {
  const _world_0 = _app_0["world"];
  const _owners_0 = _app_0["owners"];
  const _t_0 = _app_0["readerRegistry"];
  if (_t_0.$ === "None") {
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": _owners_0, "readerRegistry": {$: "None"}};
  } else {
    const _registry_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read_result$1260$(_owners_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_tracked$1261$(_registry_0, _world_0, {$: "Unit"})));
  }
}

function $consumer$058queue_taken$1260$(_bundle_0, _reader_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return {$: "consumer.Application", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058queue$1260$(_slot_0, {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play"}, false)))), "bundle": _bundle_0, "reader": _reader_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058take$1260$(_world_0);
}

function $consumer$058named$1260$(_reader_0, _items_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _namespace_0 = _pair_0["snd"];
  return {$: "consumer.Application", "world": _world_0, "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _items_0}, "reader": _reader_0};
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

function $consumer$058wrapped$1260$(_select_0, _needs_0, _items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Scheduled", "selector": _select_0, "requirements": _needs_0, "entry": _head_0}, "tail": ($consumer$058wrapped$1260$(_select_0, _needs_0, _rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _namespace_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058queue_slot$1260$(_readerRegistry_0, _owners_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058queue$1260$(_slot_0, {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play"}, false)))), "owners": _owners_0, "readerRegistry": _readerRegistry_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reader_registered$1260$(_owners_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.RegistrationFailed") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": _owners_0, "readerRegistry": {$: "None"}};
  } else {
    const _world_1 = _result_0["world"];
    const _t_0 = _result_0["registry"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _cursor_0 = _t_0["cursor"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reader_installed$1260$(_world_1, _namespace_0, _id_0)), "owners": _owners_0, "readerRegistry": {$: "Some", "value": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1260$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reserved$1260$(_factory_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/world.Reserved") {
    const _handle_0 = _t_0["handle"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058activated$1260$(_factory_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0)));
  } else {
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.ConstructionRefused", "factory": _factory_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_id$1260$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$((_nextId_0 < 131073), ($Bool$not$((_nextId_0 < _capacity_0))), {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058empty_store$1260$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058empty$1260$() {
  return {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": {$: "Nil"}, "positions": {$: "Nil"}, "droppedThrough": 0, "frameStart": 0};
}

function $consumer$058observed$1260$(_namespace_0, _world_0, _bundle_0, _reader_0) {
  const _world_1 = _world_0["fst"];
  const _a_0 = _world_0["snd"];
  const _entries_0 = _bundle_0["fst"];
  const _b_0 = _bundle_0["snd"];
  const _reader_1 = _reader_0["fst"];
  const _c_0 = _reader_0["snd"];
  const _x_0 = ($List$show$1261$(_b_0));
  const _x_1 = ("/readerRegistry=" + _c_0);
  const _x_2 = (_x_0 + _x_1);
  const _x_3 = ($U32$show$(_namespace_0));
  const _x_4 = (":" + _x_2);
  const _x_5 = (_x_3 + _x_4);
  const _x_6 = ("/bundle=" + _x_5);
  return {$: "Tuple", "fst": {$: "consumer.Application", "world": _world_1, "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "reader": _reader_1}, "snd": (_a_0 + _x_6)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058world$1260$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _nextId_0 = _value_0["nextId"];
  const _highWater_0 = _value_0["highWater"];
  const _live_0 = _value_0["live"];
  const _capacity_0 = _value_0["capacity"];
  const _depth_0 = _value_0["depth"];
  const _t_0 = _value_0["store"];
  const _column_0 = _t_0["column"];
  const _resource_0 = _value_0["resource"];
  const _events_0 = _value_0["events"];
  const _pending_0 = _value_0["pending"];
  const _registrations_0 = _value_0["registrations"];
  const _nextSystemId_0 = _value_0["nextSystemId"];
  const _clock_0 = _value_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058world_join$1260$(_namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_array$(_live_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058column$1260$(_column_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058resources$1260$(_resource_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058callbacks$1260$(_pending_0)));
}

function $consumer$058entries$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _items_0["head"];
    const _select_0 = _t_0["selector"];
    const _needs_0 = _t_0["requirements"];
    const _entry_0 = _t_0["entry"];
    const _rest_0 = _items_0["tail"];
    return $consumer$058entry_observed$1260$(_select_0, _needs_0, ($consumer$058entries$1260$(_rest_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058entries$1260$({$: "Con", "head": _entry_0, "tail": {$: "Nil"}})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058registry$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": "None"};
  } else {
    const _t_0 = _value_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _cursor_0 = _t_0["cursor"];
    const _x_0 = ($U32$show$(_cursor_0));
    const _x_1 = ($List$show$1261$(_access_0));
    const _x_2 = (":cursor=" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    const _x_4 = (":" + _x_3);
    const _x_5 = (_name_0 + _x_4);
    const _x_6 = ($U32$show$(_id_0));
    const _x_7 = (":" + _x_5);
    const _x_8 = (_x_6 + _x_7);
    const _x_9 = ($U32$show$(_namespace_0));
    const _x_10 = (":" + _x_8);
    return {$: "Tuple", "fst": {$: "Some", "value": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}}, "snd": (_x_9 + _x_10)};
  }
}

function $consumer$058status$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.Completed") {
    return "completed";
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.HandlerFailed") {
    const _phase_0 = _value_0["phase"];
    const _error_0 = _value_0["error"];
    const _x_0 = ($consumer$058phase_text$(_phase_0));
    const _x_1 = (":" + _error_0);
    const _x_2 = (_x_0 + _x_1);
    return ("failed:" + _x_2);
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.MissingRequirements") {
    const _missing_0 = _value_0["missing"];
    const _x_3 = ($List$show$1263$(_missing_0));
    return ("missing:" + _x_3);
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.ForeignBundle") {
    return "foreign";
  } else {
    return "unavailable";
  }
}

function $List$show$1269$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058step$(_h_0));
    const _x_1 = ($List$show$go$1269$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$12610$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058observation$(_h_0));
    const _x_1 = ($List$show$go$12610$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $adapter$058named$1260$(_declaration_0, _namespace_0, _entries_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _actual_0 = _pair_0["snd"];
  return $adapter$058allowed$1260$(_declaration_0, (_namespace_0 === _actual_0), _namespace_0, _entries_0, _world_0);
}

function $consumer$058unexpected_read$1260$(_world_0, _owners_0, _reader_0, _bundle_0) {
  const _namespace_0 = _bundle_0["namespace"];
  const _entries_0 = _bundle_0["entries"];
  return {$: "Tuple", "fst": {$: "consumer.Internal", "world": _world_0, "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": {$: "Nil"}, "kept": {$: "Nil"}, "owners": _owners_0}, "reader": _reader_0}, "snd": "internal-reader-owner-remainder"};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read_result$1260$(_owners_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.Completed") {
    const _registry_0 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read_completed$1260$(_owners_0, _registry_0, _outcome_0);
  } else {
    const _registry_1 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": _owners_0, "readerRegistry": {$: "Some", "value": _registry_1}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_tracked$1261$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_result$1261$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1261$(_registry_0, _world_0, _args_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, _slot_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058put$1260$(_world_0, _slot_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058queue$1260$(_slot_0, _value_0, _skipSame_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "../../../../../bendvy/src/ecs/machine.Missing"};
  } else {
    const _current_0 = _slot_0["current"];
    const _previous_0 = _slot_0["previous"];
    const _changed_0 = _slot_0["changed"];
    return {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": {$: "../../../../../bendvy/src/ecs/machine.Queued", "value": _value_0, "skipSame": _skipSame_0}, "previous": _previous_0, "changed": _changed_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058take$1260$(_world_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resources_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _commands_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058take_join$1260$(_ns_0, _next_0, _high_0, _live_0, _capacity_0, _depth_0, _store_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take_resource$1260$(_resources_0)), _events_0, _commands_0, _registrations_0, _nextSystem_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058reader_installed$1260$(_world_0, _namespace_0, _id_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": {$: "Some", "value": {$: "../../../../../bendvy/src/ecs/machine-stream.Reader", "namespace": _namespace_0, "id": _id_0}}, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1260$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058activated$1260$(_factory_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/world.Accepted") {
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Constructed", "factory": _factory_0, "application": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058registered_exit$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058register$1260$(_world_0, "exit"))))};
  } else {
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.ConstructionRefused", "factory": _factory_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(true, _handle_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_available$1260$(_available_0, _grow_0, _world_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../bendvy/src/ecs/world.ReservationRejected", "error": {$: "../../../../../bendvy/src/ecs/world.CapacityExceeded"}}};
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
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$({$: "../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0}, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$(1, _capacity_1, _depth_1, _live_1)), _namespace_1, _nextId_1, _highWater_1, _store_1, _resource_1, _events_1, _pending_1, _registrations_1, _nextSystemId_1, _clock_1);
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058empty_store$1260$(__0) {
  return {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": {$: "../../../../../bendvy/src/ecs/column.Column", "values": [{$: "Some", "value": array_node([0], [7])}], "stamps": {$: "Nil"}}};
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058world_join$1260$(_namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _live_0, _column_0, _resource_0, _pending_0) {
  const _live_1 = _live_0["fst"];
  const _sl_0 = _live_0["snd"];
  const _column_1 = _column_0["fst"];
  const _sc_0 = _column_0["snd"];
  const _resource_1 = _resource_0["fst"];
  const _sr_0 = _resource_0["snd"];
  const _pending_1 = _pending_0["fst"];
  const _count_0 = _pending_0["snd"];
  const _x_0 = ($U32$show$(_clock_0));
  const _x_1 = ($U32$show$(_nextSystemId_0));
  const _x_2 = ("|clock=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($List$show$1265$(_registrations_0));
  const _x_5 = ("|nextSystemId=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_count_0));
  const _x_8 = ("|registrations=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($List$show$1264$(_events_0));
  const _x_11 = ("|pendingCount=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ("}|events=" + _x_12);
  const _x_14 = (_sr_0 + _x_13);
  const _x_15 = ("|resource={" + _x_14);
  const _x_16 = (_sc_0 + _x_15);
  const _x_17 = ($Nat$show$(_depth_0));
  const _x_18 = ("|store=" + _x_16);
  const _x_19 = (_x_17 + _x_18);
  const _x_20 = ($U32$show$(_capacity_0));
  const _x_21 = ("|depth=" + _x_19);
  const _x_22 = (_x_20 + _x_21);
  const _x_23 = ("|capacity=" + _x_22);
  const _x_24 = (_sl_0 + _x_23);
  const _x_25 = ($U32$show$(_highWater_0));
  const _x_26 = ("|live=" + _x_24);
  const _x_27 = (_x_25 + _x_26);
  const _x_28 = ($U32$show$(_nextId_0));
  const _x_29 = ("|highWater=" + _x_27);
  const _x_30 = (_x_28 + _x_29);
  const _x_31 = ($U32$show$(_namespace_0));
  const _x_32 = ("|nextId=" + _x_30);
  const _x_33 = (_x_31 + _x_32);
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": _column_1}, "resource": _resource_1, "events": _events_0, "pending": _pending_1, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ("namespace=" + _x_33)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_array$(_value_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1261$(_value_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058column$1260$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _value_0["values"];
    const _stamps_0 = _value_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058plain_column$1260$(_stamps_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1262$(_values_0)));
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _state_0 = _value_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_column$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed$1260$(_state_0)));
  } else {
    return {$: "Tuple", "fst": _value_0, "snd": "UNSUPPORTED_PREPARED_COLUMN"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058resources$1260$(_value_0) {
  const _owned_0 = _value_0["owned"];
  const _slot_0 = _value_0["slot"];
  const _t_0 = _value_0["stream"];
  const _batches_0 = _t_0["batches"];
  const _positions_0 = _t_0["positions"];
  const _dropped_0 = _t_0["droppedThrough"];
  const _frameStart_0 = _t_0["frameStart"];
  const _readerOwner_0 = _value_0["reader"];
  const _tickLocals_0 = _value_0["locals"];
  const _tick_0 = _value_0["tick"];
  const _prefix_0 = _value_0["prefix"];
  const _delivered_0 = _value_0["delivered"];
  const _applied_0 = _value_0["structuralApplied"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058resources_join$1260$(_slot_0, _batches_0, _positions_0, _dropped_0, _frameStart_0, _tick_0, _prefix_0, _delivered_0, _applied_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_owned_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058reader$1260$(_readerOwner_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058locals$(_tickLocals_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058callbacks$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _head_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058callbacks_join$1260$(_head_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058callbacks$1260$(_rest_0)));
  }
}

function $consumer$058entry_observed$1260$(_select_0, _needs_0, _tail_0, _head_0) {
  const _rest_0 = _tail_0["fst"];
  const _text_0 = _tail_0["snd"];
  const _head_1 = _head_0["fst"];
  const _shown_0 = _head_0["snd"];
  const _x_0 = ($List$show$1261$(_shown_0));
  const _x_1 = ($List$show$1263$(_needs_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($consumer$058selector$1260$(_select_0));
  const _x_5 = (":needs=" + _x_3);
  return {$: "Tuple", "fst": ($List$append$(($consumer$058wrapped$1260$(_select_0, _needs_0, _head_1)), _rest_0)), "snd": {$: "Con", "head": (_x_4 + _x_5), "tail": _text_0}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058entries$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _values_0["head"];
    const _ordinal_0 = _t_0["ordinal"];
    const _t_1 = _t_0["registry"];
    const _namespace_0 = _t_1["namespace"];
    const _id_0 = _t_1["id"];
    const _name_0 = _t_1["name"];
    const _access_0 = _t_1["access"];
    const _cursor_0 = _t_1["cursor"];
    const _rest_0 = _values_0["tail"];
    const _x_0 = ($U32$show$(_cursor_0));
    const _x_1 = ($List$show$1261$(_access_0));
    const _x_2 = (":cursor=" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    const _x_4 = (":" + _x_3);
    const _x_5 = (_name_0 + _x_4);
    const _x_6 = ($U32$show$(_id_0));
    const _x_7 = (":" + _x_5);
    const _x_8 = (_x_6 + _x_7);
    const _x_9 = ($U32$show$(_namespace_0));
    const _x_10 = (":" + _x_8);
    const _x_11 = (_x_9 + _x_10);
    const _x_12 = ($U32$show$(_ordinal_0));
    const _x_13 = (":" + _x_11);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058entries_join$1260$({$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _ordinal_0, "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}}, (_x_12 + _x_13), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058entries$1260$(_rest_0)));
  }
}

function $consumer$058phase_text$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Exit") {
    return "exit";
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Transition") {
    return "transition";
  } else {
    return "enter";
  }
}

function $List$show$1263$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($U32$show$(_h_0));
    const _x_1 = ($List$show$go$1263$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058step$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/schedule.Barrier") {
    return "Barrier";
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/schedule.Phase") {
    const _name_0 = _value_0["name"];
    return ("Phase:" + _name_0);
  } else {
    const _id_0 = _value_0["id"];
    const _condition_0 = _value_0["condition"];
    const _x_0 = ($U32$show$(_condition_0));
    const _x_1 = ($U32$show$(_id_0));
    const _x_2 = (":condition=" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    return ("System:" + _x_3);
  }
}

function $List$show$go$1269$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058step$(_h_0));
    const _x_1 = ($List$show$go$1269$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058observation$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/schedule.Applied") {
    return "Applied";
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/schedule.Entered") {
    const _name_0 = _value_0["name"];
    return ("Entered:" + _name_0);
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/schedule.Ran") {
    const _id_0 = _value_0["id"];
    const _x_0 = ($U32$show$(_id_0));
    return ("Ran:" + _x_0);
  } else {
    const _id_1 = _value_0["id"];
    const _x_1 = ($U32$show$(_id_1));
    return ("Skipped:" + _x_1);
  }
}

function $List$show$go$12610$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047consumer$058observation$(_h_0));
    const _x_1 = ($List$show$go$12610$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $adapter$058allowed$1260$(_declaration_0, _yes_0, _namespace_0, _entries_0, _world_0) {
  if (!_yes_0) {
    return {$: "adapter.MarkerResult", "result": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "world": _world_0, "status": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.ForeignBundle"}}, "steps": {$: "Nil"}, "observations": {$: "Nil"}};
  } else {
    return $adapter$058gathered$1260$(_declaration_0, _namespace_0, _world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058requirements$1260$(_entries_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058read_completed$1260$(_owners_0, _registry_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.Succeeded") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": _owners_0, "readerRegistry": {$: "Some", "value": _registry_0}};
  } else {
    const _world_1 = _result_0["world"];
    return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_1, "owners": _owners_0, "readerRegistry": {$: "Some", "value": _registry_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_result$1261$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.RegistrationRejected") {
    const _registry_0 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    const _args_0 = _result_0["args"];
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _registry_1 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_outcome$1261$(_registry_1, _outcome_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1261$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1261$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058put$1260$(_world_0, _slot_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resources_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _commands_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put_resource$1260$(_resources_0, _slot_0)), "events": _events_0, "pending": _commands_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045world$058take_join$1260$(_ns_0, _next_0, _high_0, _live_0, _capacity_0, _depth_0, _store_0, _split_0, _events_0, _commands_0, _registrations_0, _nextSystem_0, _clock_0) {
  const _resources_0 = _split_0["fst"];
  const _slot_0 = _split_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resources_0, "events": _events_0, "pending": _commands_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "snd": _slot_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take_resource$1260$(_resources_0) {
  const _owned_0 = _resources_0["owned"];
  const _slot_0 = _resources_0["slot"];
  const _stream_0 = _resources_0["stream"];
  const _reader_0 = _resources_0["reader"];
  const _locals_0 = _resources_0["locals"];
  const _tick_0 = _resources_0["tick"];
  const _prefix_0 = _resources_0["prefix"];
  const _delivered_0 = _resources_0["delivered"];
  const _applied_0 = _resources_0["structuralApplied"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "snd": _slot_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1260$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register_checked$1260$((_nextSystemId_0 < 4294967295), {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058registered_exit$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _exit_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058registered_transition$1260$(_exit_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058register$1260$(_world_0, "transition")));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058register$1260$(_world_0, _name_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058entry_registered$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1261$(_world_0, _name_0, {$: "Con", "head": "cells:write", "tail": {$: "Con", "head": "owned:write", "tail": {$: "Con", "head": "machine:write", "tail": {$: "Nil"}}}})));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_join$1260$(_value_0, _handle_0, _checked_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($Bool$and$((_namespace_0 === _ns_0), ($Bool$and$((0 < _id_0), (_id_0 < _nextId_0)))))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058reserve_finish$1260$(_grown_0, _namespace_0, _nextId_0, _highWater_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _live_0 = _grown_0["live"];
  const _capacity_0 = _grown_0["capacity"];
  const _depth_0 = _grown_0["depth"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": ((_nextId_0 + 1) >>> 0), "highWater": _nextId_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../bendvy/src/ecs/world.Reserved", "handle": {$: "../../../../../bendvy/src/ecs/world.Handle", "namespace": _namespace_0, "id": _nextId_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058grow_live$($0, $1, $2, $3) {
  for (;;) {
    {
      const _remaining_0 = $0;
      const _capacity_0 = $1;
      const _depth_0 = $2;
      const _live_0 = $3;
      if (_remaining_0 === 0) {
        return {$: "../../../../../bendvy/src/ecs/world.Growth", "live": _live_0, "capacity": _capacity_0, "depth": _depth_0};
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

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
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

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
}

function $List$show$1264$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1264$(_t_0));
    const _x_1 = ("Unit" + _x_0);
    return ("[" + _x_1);
  }
}

function $List$show$1265$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058registration$(_h_0));
    const _x_1 = ($List$show$go$1265$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1261$(_value_0) {
  if (_value_0.length === 1) {
    const _value_1 = _value_0[0];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1261$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_value$(_value_1)));
  } else {
    const _left_0 = _value_0.slice(0, _value_0.length >> 1);
    const _right_0 = _value_0.slice(_value_0.length >> 1);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1261$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1261$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1261$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058plain_column$1260$(_stamps_0, _observed_0) {
  const _values_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  const _x_0 = ($List$show$1260$(_stamps_0));
  const _x_1 = (_x_0 + "}");
  const _x_2 = (";stamps=" + _x_1);
  const _x_3 = (_text_0 + _x_2);
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": ("Column{values=" + _x_3)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1262$(_value_0) {
  if (_value_0.length === 1) {
    const _value_1 = _value_0[0];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1262$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058optional$1260$(_value_1)));
  } else {
    const _left_0 = _value_0.slice(0, _value_0.length >> 1);
    const _right_0 = _value_0.slice(_value_0.length >> 1);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1262$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1262$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1262$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_column$1260$(_observed_0) {
  const _state_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  const _x_0 = (_text_0 + "}");
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.Indexed", "state": _state_0}, "snd": ("Indexed{" + _x_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed$1260$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
    const _state_0 = _value_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_state$1260$(_state_0);
  } else {
    const _inner_0 = _value_0["inner"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed$1260$(_inner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058resources_join$1260$(_slot_0, _batches_0, _positions_0, _dropped_0, _frameStart_0, _tick_0, _prefix_0, _delivered_0, _applied_0, _owned_0, _reader_0, _locals_0) {
  const _owned_1 = _owned_0["fst"];
  const _text_0 = _owned_0["snd"];
  const _reader_1 = _reader_0["fst"];
  const _readerText_0 = _reader_0["snd"];
  const _locals_1 = _locals_0["fst"];
  const _localTexts_0 = _locals_0["snd"];
  const _x_0 = ($U32$show$(_applied_0));
  const _x_1 = ($List$show$1262$(_delivered_0));
  const _x_2 = ("|structuralApplied=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($List$show$1268$(_prefix_0));
  const _x_5 = ("|delivered=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_tick_0));
  const _x_8 = ("|prefix=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($List$show$1261$(_localTexts_0));
  const _x_11 = ("|tick=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ("|locals=" + _x_12);
  const _x_14 = (_readerText_0 + _x_13);
  const _x_15 = ($Nat$show$(_frameStart_0));
  const _x_16 = ("}|reader=" + _x_14);
  const _x_17 = (_x_15 + _x_16);
  const _x_18 = ($Nat$show$(_dropped_0));
  const _x_19 = ("|frameStart=" + _x_17);
  const _x_20 = (_x_18 + _x_19);
  const _x_21 = ($List$show$1267$(_positions_0));
  const _x_22 = ("|dropped=" + _x_20);
  const _x_23 = (_x_21 + _x_22);
  const _x_24 = ($List$show$1266$(_batches_0));
  const _x_25 = ("|positions=" + _x_23);
  const _x_26 = (_x_24 + _x_25);
  const _x_27 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058pending_skip$1260$(_slot_0));
  const _x_28 = ("|stream={batches=" + _x_26);
  const _x_29 = (_x_27 + _x_28);
  const _x_30 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058slot$1260$(_slot_0));
  const _x_31 = ("}|pendingSkip=" + _x_29);
  const _x_32 = (_x_30 + _x_31);
  const _x_33 = ("|slot={" + _x_32);
  const _x_34 = (_text_0 + _x_33);
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_1, "slot": _slot_0, "stream": {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": _batches_0, "positions": _positions_0, "droppedThrough": _dropped_0, "frameStart": _frameStart_0}, "reader": _reader_1, "locals": _locals_1, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "snd": ("owned=" + _x_34)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_value_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1260$(_value_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058reader$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": "None"};
  } else {
    const _t_0 = _value_0["value"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _x_0 = ($U32$show$(_id_0));
    const _x_1 = ($U32$show$(_namespace_0));
    const _x_2 = (":" + _x_0);
    return {$: "Tuple", "fst": {$: "Some", "value": {$: "../../../../../bendvy/src/ecs/machine-stream.Reader", "namespace": _namespace_0, "id": _id_0}}, "snd": (_x_1 + _x_2)};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058locals$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _values_0["head"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _t_1 = _t_0["cell"];
    const _owner_0 = _t_1["local"];
    const _rest_0 = _values_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058local_value$(_namespace_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_owner_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058locals$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058callbacks_join$1260$(_head_0, _observed_0) {
  const _rest_0 = _observed_0["fst"];
  const _count_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _head_0, "tail": _rest_0}, "snd": nat_chk(_count_0 + 1)};
}

function $consumer$058selector$1260$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.ExitFrom") {
    const _value_1 = _value_0["value"];
    const _x_0 = ($consumer$058state$(_value_1));
    return ("exit:" + _x_0);
  } else if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.TransitionPair") {
    const _from_0 = _value_0["from"];
    const _to_0 = _value_0["to"];
    const _x_1 = ($consumer$058state$(_to_0));
    const _x_2 = ($consumer$058state$(_from_0));
    const _x_3 = (">" + _x_1);
    const _x_4 = (_x_2 + _x_3);
    return ("transition:" + _x_4);
  } else {
    const _value_2 = _value_0["value"];
    const _x_5 = ($consumer$058state$(_value_2));
    return ("enter:" + _x_5);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058entries_join$1260$(_head_0, _text_0, _tail_0) {
  const _rest_0 = _tail_0["fst"];
  const _texts_0 = _tail_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _head_0, "tail": _rest_0}, "snd": {$: "Con", "head": _text_0, "tail": _texts_0}};
}

function $List$show$go$1263$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($U32$show$(_h_0));
    const _x_1 = ($List$show$go$1263$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $adapter$058gathered$1260$(_declaration_0, _namespace_0, _world_0, _pair_0) {
  const _entries_0 = _pair_0["fst"];
  const _needs_0 = _pair_0["snd"];
  return $adapter$058checked$1260$(_declaration_0, _namespace_0, _entries_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058collect$1260$(_needs_0, {$: "Nil"})), _world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058requirements$1260$(_entries_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _entries_0["head"];
    const _selector_0 = _t_0["selector"];
    const _needs_0 = _t_0["requirements"];
    const _entry_0 = _t_0["entry"];
    const _tail_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058requirements_join$1260$(_selector_0, _needs_0, _entry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058requirements$1260$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_outcome$1261$(_registry_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_clock$1261$(_registry_0, _output_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_1)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1261$(_registry_0, _named_0, _args_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1261$(_registry_0, _world_0, _actual_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put_resource$1260$(_resources_0, _slot_0) {
  const _owned_0 = _resources_0["owned"];
  const _stream_0 = _resources_0["stream"];
  const _reader_0 = _resources_0["reader"];
  const _locals_0 = _resources_0["locals"];
  const _tick_0 = _resources_0["tick"];
  const _prefix_0 = _resources_0["prefix"];
  const _delivered_0 = _resources_0["delivered"];
  const _applied_0 = _resources_0["structuralApplied"];
  return {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/world.RegistrationRejected") {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../../../bendvy/src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register_checked$1260$(_available_0, _world_0, _name_0, _access_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../bendvy/src/ecs/world.RegistrationRejected", "error": {$: "../../../../../bendvy/src/ecs/world.SystemIdExhausted"}}};
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
    return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/world.RegistrationMeta", "id": _nextSystemId_0, "name": _name_0, "access": _access_0}, "tail": _registrations_0}, "nextSystemId": ((_nextSystemId_0 + 1) >>> 0), "clock": _clock_0}, "snd": {$: "../../../../../bendvy/src/ecs/world.Registered", "id": _nextSystemId_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058registered_transition$1260$(_exit_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _transition_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058assembled$1260$(_exit_0, _transition_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058register$1260$(_world_0, "enter")));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058entry_registered$1260$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.RegistrationFailed") {
    const _world_0 = _result_0["world"];
    return {$: "Tuple", "fst": _world_0, "snd": {$: "Nil"}};
  } else {
    const _world_1 = _result_0["world"];
    const _t_0 = _result_0["registry"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _cursor_0 = _t_0["cursor"];
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058install_local$1260$(_world_1, _id_0)), "snd": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _id_0, "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}}, "tail": {$: "Nil"}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1261$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1261$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058set_live_checked$1260$(_allowed_0, _value_0, _world_0, _handle_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../bendvy/src/ecs/world.Rejected", "error": {$: "../../../../../bendvy/src/ecs/world.MissingEntity"}}};
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
    return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": (_live_0[_id_0 % _live_0.length] = _value_0, _live_0), "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../../../bendvy/src/ecs/world.Accepted"}};
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
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

function $List$show$go$1264$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1264$(_t_0));
    const _x_1 = ("Unit" + _x_0);
    return (", " + _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058registration$(_value_0) {
  const _id_0 = _value_0["id"];
  const _name_0 = _value_0["name"];
  const _access_0 = _value_0["access"];
  const _x_0 = ($List$show$1261$(_access_0));
  const _x_1 = (":" + _x_0);
  const _x_2 = (_name_0 + _x_1);
  const _x_3 = ($U32$show$(_id_0));
  const _x_4 = (":" + _x_2);
  return (_x_3 + _x_4);
}

function $List$show$go$1265$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058registration$(_h_0));
    const _x_1 = ($List$show$go$1265$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1261$(_observed_0) {
  const _value_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": [_value_0], "snd": ("leaf:" + _text_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_value$(_value_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_data$(_value_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1261$(_leftObserved_0, _rightObserved_0) {
  const _left_0 = _leftObserved_0["fst"];
  const _text_0 = _leftObserved_0["snd"];
  const _right_0 = _rightObserved_0["fst"];
  const _other_0 = _rightObserved_0["snd"];
  const _x_0 = (_other_0 + ")");
  const _x_1 = ("," + _x_0);
  const _x_2 = (_text_0 + _x_1);
  return {$: "Tuple", "fst": array_node(_left_0, _right_0), "snd": ("node(" + _x_2)};
}

function $List$show$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058entry$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1262$(_observed_0) {
  const _value_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": [_value_0], "snd": ("leaf:" + _text_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058optional$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": "none"};
  } else {
    const _owner_0 = _value_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058optional_done$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1262$(_leftObserved_0, _rightObserved_0) {
  const _left_0 = _leftObserved_0["fst"];
  const _text_0 = _leftObserved_0["snd"];
  const _right_0 = _rightObserved_0["fst"];
  const _other_0 = _rightObserved_0["snd"];
  const _x_0 = (_other_0 + ")");
  const _x_1 = ("," + _x_0);
  const _x_2 = (_text_0 + _x_1);
  return {$: "Tuple", "fst": array_node(_left_0, _right_0), "snd": ("node(" + _x_2)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_state$1260$(_value_0) {
  const _values_0 = _value_0["values"];
  const _meta_0 = _value_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1262$(_values_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058metadata$(_meta_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_wrap$1260$(_observed_0) {
  const _inner_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  const _x_0 = (_text_0 + ")");
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.IndexedOrdinaryWrapped", "inner": _inner_0}, "snd": ("wrapped(" + _x_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058slot$1260$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return "\"current\":null,\"pending\":null,\"previous\":null,\"changed\":false";
  } else {
    const _current_0 = _value_0["current"];
    const _next_0 = _value_0["pending"];
    const _prior_0 = _value_0["previous"];
    const _changed_0 = _value_0["changed"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058bool$(_changed_0));
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058previous$(_prior_0));
    const _x_2 = (",\"changed\":" + _x_0);
    const _x_3 = (_x_1 + _x_2);
    const _x_4 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058pending$(_next_0));
    const _x_5 = (",\"previous\":" + _x_3);
    const _x_6 = (_x_4 + _x_5);
    const _x_7 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_current_0));
    const _x_8 = (",\"pending\":" + _x_6);
    const _x_9 = (_x_7 + _x_8);
    return ("\"current\":" + _x_9);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058pending_skip$1260$(_slot_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return "Missing";
  } else {
    const _t_0 = _slot_0["pending"];
    if (_t_0.$ === "../../../../../bendvy/src/ecs/machine.NoPending") {
      return "None";
    } else {
      const _skip_0 = _t_0["skipSame"];
      return $Bool$show$(_skip_0);
    }
  }
}

function $List$show$1266$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058batch$(_h_0));
    const _x_1 = ($List$show$go$1266$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1267$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058position$(_h_0));
    const _x_1 = ($List$show$go$1267$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1268$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058quote$(_h_0));
    const _x_1 = ($List$show$go$1268$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058transition$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1260$(_value_0) {
  if (_value_0.length === 1) {
    const _value_1 = _value_0[0];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_value$(_value_1)));
  } else {
    const _left_0 = _value_0.slice(0, _value_0.length >> 1);
    const _right_0 = _value_0.slice(_value_0.length >> 1);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1260$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058array$1260$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058local_value$(_namespace_0, _id_0, _result_0, _tail_0) {
  const _owner_0 = _result_0["fst"];
  const _text_0 = _result_0["snd"];
  const _x_0 = ($U32$show$(_id_0));
  const _x_1 = (":" + _text_0);
  const _x_2 = (_x_0 + _x_1);
  const _x_3 = ($U32$show$(_namespace_0));
  const _x_4 = (":" + _x_2);
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058local_join$({$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _namespace_0, "id": _id_0, "cell": {$: "../../../../../bendvy/src/ecs/local.Cell", "local": _owner_0}}, (_x_3 + _x_4), _tail_0);
}

function $consumer$058state$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot") {
    return "Boot";
  } else if (_value_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play") {
    return "Play";
  } else {
    return "Pause";
  }
}

function $adapter$058checked$1260$(_declaration_0, _namespace_0, _entries_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _t_0 = _pair_0["snd"];
  if (_t_0.$ === "Nil") {
    return $adapter$058installed$1260$(_declaration_0, _world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058install$1260$(_declaration_0, _namespace_0, {$: "adapter.Pending", "entries": _entries_0})));
  } else {
    return {$: "adapter.MarkerResult", "result": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "world": _world_0, "status": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.MissingRequirements", "missing": _t_0}}, "steps": {$: "Nil"}, "observations": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing$1260$(_needs_0, _world_0) {
  if (_needs_0.$ === "Nil") {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "Nil"}};
  } else {
    const _value_0 = _needs_0["head"];
    const _rest_0 = _needs_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_checked$1260$(($consumer$058has$1260$(_world_0, _value_0)), _value_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing$1260$(_rest_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058collect$1260$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _prior_0 = $1;
      if (_items_0.$ === "Nil") {
        return _prior_0;
      } else {
        const _head_0 = _items_0["head"];
        const _tail_0 = _items_0["tail"];
        $0 = _tail_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058collected$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058contains$1260$(_prior_0, _head_0)), _prior_0, _head_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058requirements_join$1260$(_selector_0, _needs_0, _entry_0, _tail_0) {
  const _entries_0 = _tail_0["fst"];
  const _all_0 = _tail_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Scheduled", "selector": _selector_0, "requirements": _needs_0, "entry": _entry_0}, "tail": _entries_0}, "snd": ($List$append$(_needs_0, _all_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_clock$1261$(_registry_0, _output_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _clock_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058cursor_outcome$1261$({$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": _output_0}, _registry_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1261$(_registry_0, _world_0, _actual_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1261$((_namespace_0 === _actual_0), {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058assembled$1260$(_exit_0, _transition_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _enter_0 = _result_0["snd"];
  return {$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/application.Application", "world": _world_0, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "readerRegistry": {$: "None"}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047application$058install_local$1260$(_world_0, _id_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": ($List$append$(_locals_0, {$: "Con", "head": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _ns_0, "id": _id_0, "cell": {$: "../../../../../bendvy/src/ecs/local.Cell", "local": [0]}}, "tail": {$: "Nil"}})), "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1261$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1261$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058bool_data$(_value_0) {
  return {$: "Tuple", "fst": _value_0, "snd": ($Bool$show$(_value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058entry$(_value_0) {
  const _id_0 = _value_0["id"];
  const _value_1 = _value_0["stamp"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058stamp$(_value_1));
  const _x_1 = ($U32$show$(_id_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058entry$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058optional_done$1260$(_observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  const _x_0 = (_text_0 + ")");
  return {$: "Tuple", "fst": {$: "Some", "value": _owner_0}, "snd": ("some(" + _x_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058indexed_join$1260$(_observedValues_0, _observedMeta_0) {
  const _values_0 = _observedValues_0["fst"];
  const _sv_0 = _observedValues_0["snd"];
  const _metadata_0 = _observedMeta_0["fst"];
  const _sm_0 = _observedMeta_0["snd"];
  const _x_0 = (_sm_0 + "})");
  const _x_1 = (";metadata={" + _x_0);
  const _x_2 = (_sv_0 + _x_1);
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}, "snd": ("owned(values=" + _x_2)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058metadata$(_value_0) {
  const _added_0 = _value_0["added"];
  const _changed_0 = _value_0["changed"];
  const _capacity_0 = _value_0["capacity"];
  const _depth_0 = _value_0["depth"];
  const _exceptional_0 = _value_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058metadata_join$(_capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_added_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_array$(_changed_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot") {
    return "\"Boot\"";
  } else if (_value_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play") {
    return "\"Play\"";
  } else {
    return "\"Pause\"";
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058pending$(_value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine.NoPending") {
    return "null";
  } else {
    const _value_1 = _value_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_value_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058previous$(_value_0) {
  if (_value_0.$ === "None") {
    return "null";
  } else {
    const _value_1 = _value_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_value_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058bool$(_value_0) {
  if (!_value_0) {
    return "false";
  } else {
    return "true";
  }
}

function $Bool$show$(_b_0) {
  if (!_b_0) {
    return "False";
  } else {
    return "True";
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058batch$(_value_0) {
  const _tick_0 = _value_0["tick"];
  const _values_0 = _value_0["values"];
  const _x_0 = ($List$show$1262$(_values_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$1266$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058batch$(_h_0));
    const _x_1 = ($List$show$go$1266$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058position$(_value_0) {
  const _id_0 = _value_0["id"];
  const _cursor_0 = _value_0["cursor"];
  const _registeredAt_0 = _value_0["registeredAt"];
  const _x_0 = ($Nat$show$(_registeredAt_0));
  const _x_1 = ($Nat$show$(_cursor_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($U32$show$(_id_0));
  const _x_5 = (":" + _x_3);
  return (_x_4 + _x_5);
}

function $List$show$go$1267$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058position$(_h_0));
    const _x_1 = ($List$show$go$1267$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058quote$(_text_0) {
  const _x_0 = (_text_0 + "\"");
  return ("\"" + _x_0);
}

function $List$show$go$1268$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058quote$(_h_0));
    const _x_1 = ($List$show$go$1268$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058transition$(_event_0) {
  const _from_0 = _event_0["from"];
  const _to_0 = _event_0["to"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_to_0));
  const _x_1 = (_x_0 + "]");
  const _x_2 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058state$(_from_0));
  const _x_3 = ("," + _x_1);
  const _x_4 = (_x_2 + _x_3);
  return ("[" + _x_4);
}

function $List$show$go$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047observe$058transition$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058leaf$1260$(_observed_0) {
  const _value_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": [_value_0], "snd": ("leaf:" + _text_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_value$(_value_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_data$(_value_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058node_join$1260$(_leftObserved_0, _rightObserved_0) {
  const _left_0 = _leftObserved_0["fst"];
  const _text_0 = _leftObserved_0["snd"];
  const _right_0 = _rightObserved_0["fst"];
  const _other_0 = _rightObserved_0["snd"];
  const _x_0 = (_other_0 + ")");
  const _x_1 = ("," + _x_0);
  const _x_2 = (_text_0 + _x_1);
  return {$: "Tuple", "fst": array_node(_left_0, _right_0), "snd": ("node(" + _x_2)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047full$045observe$058local_join$(_head_0, _text_0, _tail_0) {
  const _rest_0 = _tail_0["fst"];
  const _texts_0 = _tail_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _head_0, "tail": _rest_0}, "snd": {$: "Con", "head": _text_0, "tail": _texts_0}};
}

function $adapter$058installed$1260$(_declaration_0, _world_0, _built_0) {
  if (_built_0.$ === "../../../../../bendvy/src/ecs/schedule.Built") {
    const _schedule_0 = _built_0["schedule"];
    return $adapter$058returned$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058run$1260$(_schedule_0, _world_0)));
  } else {
    const _owners_0 = _built_0["owners"];
    return {$: "adapter.MarkerResult", "result": ($adapter$058finished$1260$(0, _owners_0, _world_0, {$: "Some", "value": "invalid"})), "steps": {$: "Nil"}, "observations": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058install$1260$(_declaration_0, _namespace_0, _owners_0) {
  const _name_0 = _declaration_0["name"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058build$1260$(_namespace_0, _name_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058steps$()), {$: "Con", "head": 1, "tail": {$: "Con", "head": 2, "tail": {$: "Con", "head": 3, "tail": {$: "Con", "head": 4, "tail": {$: "Nil"}}}}}, _owners_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_checked$1260$(_pair_0, _value_0, _next_0) {
  const _world_0 = _pair_0["fst"];
  const _allowed_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_join$1260$(_allowed_0, _value_0, _next_0(_world_0));
}

function $consumer$058has$1260$(_world_0, _id_0) {
  if (_id_0 == 1) {
    return $consumer$058available$1260$(1, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)));
  } else if ((_id_0 & 1) == 1) {
    return {$: "Tuple", "fst": _world_0, "snd": false};
  } else if (_id_0 == 2) {
    return {$: "Tuple", "fst": _world_0, "snd": true};
  } else {
    return {$: "Tuple", "fst": _world_0, "snd": false};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058collected$1260$(_seen_0, _prior_0, _value_0) {
  if (_seen_0) {
    return _prior_0;
  } else {
    return $List$append$(_prior_0, {$: "Con", "head": _value_0, "tail": {$: "Nil"}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058contains$1260$(_items_0, _value_0) {
  if (_items_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _items_0["head"];
    const _tail_0 = _items_0["tail"];
    const _x_0 = (_head_0 === _value_0);
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058contains$1260$(_tail_0, _value_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058cursor_outcome$1261$(_outcome_0, _registry_0, _nextCursor_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _nextCursor_0}, "outcome": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_1, "output": _output_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    const _cursor_0 = _registry_0["cursor"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1261$({$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1261$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1261$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058stamp$(_value_0) {
  const _added_0 = _value_0["added"];
  const _changed_0 = _value_0["changed"];
  const _x_0 = ($U32$show$(_changed_0));
  const _x_1 = ($U32$show$(_added_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058metadata_join$(_capacity_0, _depth_0, _exceptional_0, _observedAdded_0, _observedChanged_0) {
  const _added_0 = _observedAdded_0["fst"];
  const _sa_0 = _observedAdded_0["snd"];
  const _changed_0 = _observedChanged_0["fst"];
  const _sc_0 = _observedChanged_0["snd"];
  const _x_0 = ($List$show$1260$(_exceptional_0));
  const _x_1 = ($Nat$show$(_depth_0));
  const _x_2 = (";exceptional=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($U32$show$(_capacity_0));
  const _x_5 = (";depth=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = (";capacity=" + _x_6);
  const _x_8 = (_sc_0 + _x_7);
  const _x_9 = (";changed=" + _x_8);
  const _x_10 = (_sa_0 + _x_9);
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": ("added=" + _x_10)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045inspect$047ordinary$045declaration$045v1$047canonical$045adoption$045v1$047detached$045v2$047owner$045observer$058u32_data$(_value_0) {
  return {$: "Tuple", "fst": _value_0, "snd": ($U32$show$(_value_0))};
}

function $adapter$058returned$1260$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/schedule.Finished") {
    const _t_0 = _result_0["schedule"];
    const _namespace_0 = _t_0["namespace"];
    const _steps_0 = _t_0["steps"];
    const _owners_0 = _t_0["owners"];
    const _world_0 = _result_0["world"];
    const _observations_0 = _result_0["observations"];
    return {$: "adapter.MarkerResult", "result": ($adapter$058finished$1260$(_namespace_0, _owners_0, _world_0, {$: "None"})), "steps": _steps_0, "observations": _observations_0};
  } else if (_result_0.$ === "../../../../../bendvy/src/ecs/schedule.Failed") {
    const _t_1 = _result_0["schedule"];
    const _namespace_1 = _t_1["namespace"];
    const _steps_1 = _t_1["steps"];
    const _owners_1 = _t_1["owners"];
    const _world_1 = _result_0["world"];
    const _error_0 = _result_0["error"];
    const _observations_1 = _result_0["observations"];
    return {$: "adapter.MarkerResult", "result": ($adapter$058finished$1260$(_namespace_1, _owners_1, _world_1, {$: "Some", "value": _error_0})), "steps": _steps_1, "observations": _observations_1};
  } else {
    const _t_2 = _result_0["schedule"];
    const _namespace_2 = _t_2["namespace"];
    const _steps_2 = _t_2["steps"];
    const _owners_2 = _t_2["owners"];
    const _world_2 = _result_0["world"];
    return {$: "adapter.MarkerResult", "result": ($adapter$058finished$1260$(_namespace_2, _owners_2, _world_2, {$: "Some", "value": "schedule-rejected"})), "steps": _steps_2, "observations": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058run$1260$(_schedule_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run$1260$(_schedule_0, _world_0);
}

function $adapter$058finished$1260$(_namespace_0, _owners_0, _world_0, _error_0) {
  if (_owners_0.$ === "adapter.Pending") {
    const _entries_0 = _owners_0["entries"];
    if (_error_0.$ === "None") {
      return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "world": _world_0, "status": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Completed"}};
    } else {
      return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "world": _world_0, "status": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.ForeignBundle"}};
    }
  } else if (_owners_0.$ === "adapter.Unavailable") {
    const _entries_1 = _owners_0["entries"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_1}, "world": _world_0, "status": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.MachineUnavailable"}};
  } else {
    const _positions_0 = _owners_0["positions"];
    const _kept_0 = _owners_0["kept"];
    const _active_0 = _owners_0["active"];
    const __1 = _owners_0["phase"];
    if (_error_0.$ === "None") {
      return $adapter$058recovered$1260$(_namespace_0, _positions_0, _kept_0, _active_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Completed"});
    } else {
      const _error_1 = _error_0["value"];
      return $adapter$058recovered$1260$(_namespace_0, _positions_0, _kept_0, _active_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.HandlerFailed", "phase": __1, "error": _error_1});
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058build$1260$(_namespace_0, _name_0, _steps_0, _catalog_0, _owners_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058build_checked$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058valid$(_steps_0, _catalog_0, {$: "Nil"})), _namespace_0, _name_0, _steps_0, _owners_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058steps$() {
  return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Barrier"}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Phase", "name": "apply"}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.System", "id": 1, "condition": 0}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Phase", "name": "exit"}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.System", "id": 2, "condition": 0}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Phase", "name": "transition"}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.System", "id": 3, "condition": 0}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Phase", "name": "enter"}, "tail": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.System", "id": 4, "condition": 0}, "tail": {$: "Nil"}}}}}}}}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_join$1260$(_allowed_0, _value_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _rest_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_selected$1260$(_allowed_0, _value_0, _rest_0))};
}

function $consumer$058available$1260$(_id_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _t_0 = _pair_0["snd"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine.Missing"})), "snd": false};
  } else {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, _t_0)), "snd": (_id_0 <= 2)};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1261$(_registry_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1261$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/world.RegistrationRejected") {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../../../bendvy/src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run$1260$(_schedule_0, _world_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_namespace$1260$(_schedule_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $adapter$058recovered$1260$(_namespace_0, _positions_0, _kept_0, _active_0, _world_0, _status_0) {
  const _handlers_0 = _active_0["handlers"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovered$1260$(_namespace_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_positions_0, _kept_0, _handlers_0)), _world_0, _status_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058build_checked$1260$(_allowed_0, _namespace_0, _name_0, _steps_0, _owners_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/schedule.Invalid", "owners": _owners_0};
  } else {
    return {$: "../../../../../bendvy/src/ecs/schedule.Built", "schedule": {$: "../../../../../bendvy/src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "owners": _owners_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058valid$($0, $1, $2) {
  for (;;) {
    {
      const _steps_0 = $0;
      const _catalog_0 = $1;
      const _seen_0 = $2;
      if (_steps_0.$ === "Nil") {
        return true;
      } else {
        const _t_0 = _steps_0["head"];
        if (_t_0.$ === "../../../../../bendvy/src/ecs/schedule.Phase") {
          const _rest_0 = _steps_0["tail"];
          $0 = _rest_0;
          $1 = _catalog_0;
          $2 = _seen_0;
          continue;
        } else if (_t_0.$ === "../../../../../bendvy/src/ecs/schedule.Barrier") {
          const _rest_1 = _steps_0["tail"];
          $0 = _rest_1;
          $1 = _catalog_0;
          $2 = _seen_0;
          continue;
        } else {
          const _id_0 = _t_0["id"];
          const _rest_2 = _steps_0["tail"];
          return $Bool$and$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058contains$(_catalog_0, _id_0)), ($Bool$and$(($Bool$not$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058contains$(_seen_0, _id_0)))), ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058valid$(_rest_2, _catalog_0, {$: "Con", "head": _id_0, "tail": _seen_0})))));
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058missing_selected$1260$(_allowed_0, _value_0, _rest_0) {
  if (_allowed_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _value_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1261$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058reader_runner$1260$(_world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_walk$(_registrations_0, _id_0, _name_0, _access_0, false);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_namespace$1260$(_schedule_0, _named_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_actual$1260$(_schedule_0, _world_0, _actual_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovered$1260$(_namespace_0, _recovery_0, _world_0, _status_0) {
  const _entries_0 = _recovery_0["entries"];
  const _t_0 = _recovery_0["positions"];
  if (_t_0.$ === "Nil") {
    const _t_1 = _recovery_0["kept"];
    if (_t_1.$ === "Nil") {
      const _t_2 = _recovery_0["owners"];
      const _t_3 = _t_2["exit"];
      if (_t_3.$ === "Nil") {
        const _t_4 = _t_2["transition"];
        if (_t_4.$ === "Nil") {
          const _t_5 = _t_2["enter"];
          if (_t_5.$ === "Nil") {
            return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Returned", "bundle": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Bundle", "namespace": _namespace_0, "entries": _entries_0}, "world": _world_0, "status": _status_0};
          } else {
            return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.InternalOwnerRemainder", "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": {$: "Nil"}, "kept": {$: "Nil"}, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": {$: "Nil"}, "enter": _t_5}}, "world": _world_0, "status": _status_0};
          }
        } else {
          const _28_0 = _t_2["enter"];
          return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.InternalOwnerRemainder", "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": {$: "Nil"}, "kept": {$: "Nil"}, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": _t_4, "enter": _28_0}}, "world": _world_0, "status": _status_0};
        }
      } else {
        const _27_0 = _t_2["transition"];
        const _28_1 = _t_2["enter"];
        return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.InternalOwnerRemainder", "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": {$: "Nil"}, "kept": {$: "Nil"}, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _t_3, "transition": _27_0, "enter": _28_1}}, "world": _world_0, "status": _status_0};
      }
    } else {
      const _25_0 = _recovery_0["owners"];
      return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.InternalOwnerRemainder", "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": {$: "Nil"}, "kept": _t_1, "owners": _25_0}, "world": _world_0, "status": _status_0};
    }
  } else {
    const _24_0 = _recovery_0["kept"];
    const _25_1 = _recovery_0["owners"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.InternalOwnerRemainder", "namespace": _namespace_0, "recovery": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": _entries_0, "positions": _t_0, "kept": _24_0, "owners": _25_1}, "world": _world_0, "status": _status_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_positions_0, _kept_0, _owners_0) {
  if (_positions_0.$ === "Nil") {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Nil"}, "positions": {$: "Nil"}, "kept": _kept_0, "owners": _owners_0};
  } else {
    const _t_0 = _positions_0["head"];
    const _selector_0 = _t_0["selector"];
    const _needs_0 = _t_0["requirements"];
    const _t_1 = _t_0["choice"];
    if (_t_1.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept") {
      const _rest_0 = _positions_0["tail"];
      if (_kept_0.$ === "Con") {
        const _head_0 = _kept_0["head"];
        const _tail_0 = _kept_0["tail"];
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovery_join$1260$(_selector_0, _needs_0, _head_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_rest_0, _tail_0, _owners_0)));
      } else {
        return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Nil"}, "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept"}}, "tail": _rest_0}, "kept": _kept_0, "owners": _owners_0};
      }
    } else if (_t_1.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedExit") {
      const _rest_1 = _positions_0["tail"];
      const _t_2 = _owners_0["exit"];
      if (_t_2.$ === "Con") {
        const _head_1 = _t_2["head"];
        const _tail_1 = _t_2["tail"];
        const _transition_0 = _owners_0["transition"];
        const _enter_0 = _owners_0["enter"];
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovery_join$1260$(_selector_0, _needs_0, _head_1, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_rest_1, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _tail_1, "transition": _transition_0, "enter": _enter_0})));
      } else {
        const _transition_1 = _owners_0["transition"];
        const _enter_1 = _owners_0["enter"];
        return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Nil"}, "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedExit"}}, "tail": _rest_1}, "kept": _kept_0, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _t_2, "transition": _transition_1, "enter": _enter_1}};
      }
    } else if (_t_1.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedTransition") {
      const _rest_2 = _positions_0["tail"];
      const _exit_0 = _owners_0["exit"];
      const _t_3 = _owners_0["transition"];
      if (_t_3.$ === "Con") {
        const _head_2 = _t_3["head"];
        const _tail_2 = _t_3["tail"];
        const _enter_2 = _owners_0["enter"];
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovery_join$1260$(_selector_0, _needs_0, _head_2, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_rest_2, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _tail_2, "enter": _enter_2})));
      } else {
        const _enter_3 = _owners_0["enter"];
        return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Nil"}, "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedTransition"}}, "tail": _rest_2}, "kept": _kept_0, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _t_3, "enter": _enter_3}};
      }
    } else {
      const _rest_3 = _positions_0["tail"];
      const _exit_1 = _owners_0["exit"];
      const _transition_2 = _owners_0["transition"];
      const _t_4 = _owners_0["enter"];
      if (_t_4.$ === "Con") {
        const _head_3 = _t_4["head"];
        const _tail_3 = _t_4["tail"];
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovery_join$1260$(_selector_0, _needs_0, _head_3, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recover$1260$(_rest_3, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_1, "transition": _transition_2, "enter": _tail_3})));
      } else {
        return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Nil"}, "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedEnter"}}, "tail": _rest_3}, "kept": _kept_0, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_1, "transition": _transition_2, "enter": _t_4}};
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058contains$(_ids_0, _id_0) {
  if (_ids_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _ids_0["head"];
    const _rest_0 = _ids_0["tail"];
    const _x_0 = (_head_0 === _id_0);
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058contains$(_rest_0, _id_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1261$(_registry_0, _outcome_0) {
  return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": _outcome_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058reader_runner$1260$(_world_0, __0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058reader_selected$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058empty$1260$()), "reader": {$: "None"}, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, _reader_0, _stream_0, _ns_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_walk$($0, $1, $2, $3, $4) {
  for (;;) {
    {
      const _registrations_0 = $0;
      const _id_0 = $1;
      const _name_0 = $2;
      const _access_0 = $3;
      const _found_0 = $4;
      if (_registrations_0.$ === "Nil") {
        if (_found_0) {
          return true;
        } else {
          return false;
        }
      } else {
        const _meta_0 = _registrations_0["head"];
        const _rest_0 = _registrations_0["tail"];
        if (_found_0) {
          return true;
        } else {
          $0 = _rest_0;
          $1 = _id_0;
          $2 = _name_0;
          $3 = _access_0;
          $4 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_actual$1260$(_schedule_0, _world_0, _actual_0) {
  const _namespace_0 = _schedule_0["namespace"];
  const _name_0 = _schedule_0["name"];
  const _steps_0 = _schedule_0["steps"];
  const _owners_0 = _schedule_0["owners"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_checked$1260$((_namespace_0 === _actual_0), {$: "../../../../../bendvy/src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "owners": _owners_0}, _world_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058recovery_join$1260$(_selector_0, _needs_0, _entry_0, _tail_0) {
  const _entries_0 = _tail_0["entries"];
  const _positions_0 = _tail_0["positions"];
  const _kept_0 = _tail_0["kept"];
  const _owners_0 = _tail_0["owners"];
  return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Recovery", "entries": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Scheduled", "selector": _selector_0, "requirements": _needs_0, "entry": _entry_0}, "tail": _entries_0}, "positions": _positions_0, "kept": _kept_0, "owners": _owners_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058reader_selected$1260$(_world_0, _reader_0, _stream_0, _ns_0, _tick_0) {
  if (_reader_0.$ === "None") {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_missing$1260$(_world_0, _stream_0);
  } else {
    const _reader_1 = _reader_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_opened$1260$(_world_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058open$1260$(_reader_1, _stream_0, _ns_0, _tick_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0) {
  const _mid_0 = _meta_0["id"];
  const _mname_0 = _meta_0["name"];
  const _maccess_0 = _meta_0["access"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_id$((_mid_0 === _id_0), _mname_0, _name_0, _maccess_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058run_checked$1260$(_allowed_0, _schedule_0, _world_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/schedule.Rejected", "schedule": _schedule_0, "world": _world_0};
  } else {
    const _namespace_0 = _schedule_0["namespace"];
    const _name_0 = _schedule_0["name"];
    const _steps_0 = _schedule_0["steps"];
    const _owners_0 = _schedule_0["owners"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058execute$1260$(_steps_0, _owners_0, _world_0, _namespace_0, _name_0, _steps_0, {$: "Nil"});
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_missing$1260$(_world_0, _stream_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/system.Failed", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": {$: "None"}, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "error": "MissingReader"};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_opened$1260$(_world_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/machine-stream.ReaderRefused") {
    const _reader_0 = _result_0["reader"];
    const _stream_0 = _result_0["stream"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_refused$1260$(_world_0, _reader_0, _stream_0);
  } else {
    const _reader_1 = _result_0["reader"];
    const _stream_1 = _result_0["stream"];
    const _t_0 = _result_0["reading"];
    const _values_0 = _t_0["values"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_finished$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058finish$1260$(_reader_1, _stream_1, _tick_0, true)), _values_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058open$1260$(_reader_0, _stream_0, _namespace_0, _tick_0) {
  const _owner_0 = _reader_0["namespace"];
  const _id_0 = _reader_0["id"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058open_checked$1260$((_owner_0 === _namespace_0), {$: "../../../../../bendvy/src/ecs/machine-stream.Reader", "namespace": _owner_0, "id": _id_0}, _stream_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_id$(_sameId_0, _metaName_0, _wantedName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameId_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_access$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(_metaName_0, _wantedName_0)), _metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058execute$1260$($0, $1, $2, $3, $4, $5, $6) {
  for (;;) {
    {
      const _steps_0 = $0;
      const _owners_0 = $1;
      const _world_0 = $2;
      const _namespace_0 = $3;
      const _name_0 = $4;
      const _all_0 = $5;
      const _observations_0 = $6;
      if (_steps_0.$ === "Nil") {
        return {$: "../../../../../bendvy/src/ecs/schedule.Finished", "schedule": {$: "../../../../../bendvy/src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _all_0, "owners": _owners_0}, "world": _world_0, "observations": _observations_0};
      } else {
        const _t_0 = _steps_0["head"];
        if (_t_0.$ === "../../../../../bendvy/src/ecs/schedule.Phase") {
          const _phase_0 = _t_0["name"];
          const _rest_0 = _steps_0["tail"];
          $0 = _rest_0;
          $1 = _owners_0;
          $2 = _world_0;
          $3 = _namespace_0;
          $4 = _name_0;
          $5 = _all_0;
          $6 = ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Entered", "name": _phase_0}, "tail": {$: "Nil"}}));
          continue;
        } else if (_t_0.$ === "../../../../../bendvy/src/ecs/schedule.Barrier") {
          const _rest_1 = _steps_0["tail"];
          $0 = _rest_1;
          $1 = _owners_0;
          $2 = run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1260$(_world_0));
          $3 = _namespace_0;
          $4 = _name_0;
          $5 = _all_0;
          $6 = ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Applied"}, "tail": {$: "Nil"}}));
          continue;
        } else {
          const _id_0 = _t_0["id"];
          const _slot_0 = _t_0["condition"];
          const _rest_2 = _steps_0["tail"];
          return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_condition$1260$(run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058execute$1260$(_rest_2, _x_0, _x_1, _namespace_0, _name_0, _all_0, _x_2);
});
});
}), ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058condition$1260$(_world_0, _slot_0)), _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_refused$1260$(_world_0, _reader_0, _stream_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/system.Failed", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": {$: "Some", "value": _reader_0}, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "error": "ForeignReader"};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058read_finished$1260$(_world_0, _pair_0, _values_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _reader_0 = _pair_0["fst"];
  const _stream_0 = _pair_0["snd"];
  return {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": {$: "Some", "value": _reader_0}, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": ($List$append$(_delivered_0, _values_0)), "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "output": {$: "Unit"}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058finish$1260$(_reader_0, _stream_0, _tick_0, _success_0) {
  const _namespace_0 = _reader_0["namespace"];
  const _id_0 = _reader_0["id"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/machine-stream.Reader", "namespace": _namespace_0, "id": _id_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058complete$1260$(_stream_0, _id_0, _tick_0, _success_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058open_checked$1260$(_allowed_0, _reader_0, _stream_0, _tick_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-stream.ReaderRefused", "reader": _reader_0, "stream": _stream_0};
  } else {
    const _namespace_0 = _reader_0["namespace"];
    const _id_0 = _reader_0["id"];
    return {$: "../../../../../bendvy/src/ecs/machine-stream.Opened", "reader": {$: "../../../../../bendvy/src/ecs/machine-stream.Reader", "namespace": _namespace_0, "id": _id_0}, "stream": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058activate$1260$(_stream_0, _id_0, _tick_0)), "reading": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058observe$1260$(_stream_0, _id_0, _tick_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_access$(_sameName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameName_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(_metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(_a_0, _b_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal_walk$(_a_0, _b_0, true);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058barrier$1260$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_pending_0, {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Nil"}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_condition$1260$(_next_0, _checked_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058conditioned$1260$(_next_0, _allowed_0, _owners_0, _world_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058condition$1260$(_world_0, __0) {
  return {$: "Tuple", "fst": _world_0, "snd": true};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058complete$1260$(_stream_0, _id_0, _tick_0, _success_0) {
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _dropped_0 = _stream_0["droppedThrough"];
  const _frameStart_0 = _stream_0["frameStart"];
  if (_success_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": _batches_0, "positions": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(_positions_0, _id_0, _tick_0, false)), "droppedThrough": _dropped_0, "frameStart": _frameStart_0};
  } else {
    return {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": _batches_0, "positions": _positions_0, "droppedThrough": _dropped_0, "frameStart": _frameStart_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058activate$1260$(_stream_0, _id_0, _tick_0) {
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _dropped_0 = _stream_0["droppedThrough"];
  const _frameStart_0 = _stream_0["frameStart"];
  return {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": _batches_0, "positions": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activate$(_positions_0, _id_0, _tick_0)), "droppedThrough": _dropped_0, "frameStart": _frameStart_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058observe$1260$(_stream_0, _id_0, _tick_0) {
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _dropped_0 = _stream_0["droppedThrough"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058observe_position$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0)), _batches_0, _dropped_0, _id_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(_xs_0, _ys_0) {
  if (_xs_0.$ === "Nil") {
    if (_ys_0.$ === "Nil") {
      return true;
    } else {
      return false;
    }
  } else {
    const __2 = _xs_0["head"];
    const __3 = _xs_0["tail"];
    if (_ys_0.$ === "Nil") {
      return false;
    } else {
      const _y_0 = _ys_0["head"];
      const _ys_1 = _ys_0["tail"];
      return $Bool$and$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(__2, _y_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(__3, _ys_1)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal_walk$($0, $1, $2) {
  for (;;) {
    {
      const _a_0 = $0;
      const _b_0 = $1;
      const _same_0 = $2;
      if (_a_0 === "") {
        if (_b_0 === "") {
          return _same_0;
        } else {
          return false;
        }
      } else {
        const __2 = (_a_0.codePointAt(0) > 0xFFFF ? _a_0.slice(0, 2) : _a_0[0]);
        const __3 = (_a_0.codePointAt(0) > 0xFFFF ? _a_0.slice(2) : _a_0.slice(1));
        if (_b_0 === "") {
          return false;
        } else {
          const _b_1 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(0, 2) : _b_0[0]);
          const _bs_0 = (_b_0.codePointAt(0) > 0xFFFF ? _b_0.slice(2) : _b_0.slice(1));
          $0 = __3;
          $1 = _bs_0;
          $2 = ($Bool$and$(_same_0, ($Char$is_eq$(__2, _b_1))));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_commands_0, _world_0) {
  if (_commands_0.$ === "Nil") {
    return _world_0;
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return run_tail(_command_0, run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058drain_fifo$1260$(_rest_0, _world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058conditioned$1260$(_next_0, _allowed_0, _owners_0, _world_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  if (!_allowed_0) {
    return run_tail(_next_0(_owners_0)(_world_0), ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Skipped", "id": _id_0}, "tail": {$: "Nil"}})));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_dispatch$1260$(_next_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058dispatch$1260$(_owners_0, _world_0, _id_0)), _namespace_0, _name_0, _all_0, _observations_0, _id_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(_positions_0, _id_0, _cursor_0, _dispose_0) {
  if (_positions_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _positions_0["head"];
    const _actual_0 = _t_0["id"];
    const _old_0 = _t_0["cursor"];
    const _registered_0 = _t_0["registeredAt"];
    const _rest_0 = _positions_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update_checked$((_actual_0 === _id_0), _dispose_0, _actual_0, _old_0, _registered_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(_rest_0, _id_0, _cursor_0, _dispose_0)), _cursor_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activate$(_positions_0, _id_0, _registered_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activation$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0)), _positions_0, _id_0, _registered_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058observe_position$1260$(_position_0, _batches_0, _dropped_0, _id_0, _tick_0) {
  if (_position_0.$ === "None") {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$({$: "../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": 0, "registeredAt": _tick_0}, _batches_0, _dropped_0);
  } else {
    const _position_1 = _position_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$(_position_1, _batches_0, _dropped_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0) {
  if (_positions_0.$ === "Nil") {
    return {$: "None"};
  } else {
    const _position_0 = _positions_0["head"];
    const _rest_0 = _positions_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup_checked$(_position_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_rest_0, _id_0)));
  }
}

function $Char$is_eq$(_a_0, _b_0) {
  const _x_0 = _a_0.codePointAt(0);
  const _x_1 = _b_0.codePointAt(0);
  return (_x_0 === _x_1);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_dispatch$1260$(_next_0, _result_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  const _owners_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_outcome$1260$(_next_0, _outcome_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045machine$045schedule$058dispatch$1260$(_owners_0, _world_0, _id_0) {
  if (_id_0 == 1) {
    return $adapter$058apply$1260$(_owners_0, _world_0);
  } else if ((_id_0 & 3) == 1) {
    return $adapter$058enter$1260$(_owners_0, _world_0);
  } else if (_id_0 == 3) {
    return $adapter$058transition$1260$(_owners_0, _world_0);
  } else if ((_id_0 & 3) == 3) {
    return $adapter$058enter$1260$(_owners_0, _world_0);
  } else if (_id_0 == 2) {
    return $adapter$058exit$1260$(_owners_0, _world_0);
  } else {
    return $adapter$058enter$1260$(_owners_0, _world_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update_checked$(_found_0, _dispose_0, _id_0, _old_0, _registered_0, _rest_0, _cursor_0) {
  if (!_found_0) {
    return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": _old_0, "registeredAt": _registered_0}, "tail": _rest_0};
  } else {
    if (!_dispose_0) {
      return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": _cursor_0, "registeredAt": _registered_0}, "tail": _rest_0};
    } else {
      return _rest_0;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activation$(_position_0, _positions_0, _id_0, _registered_0) {
  if (_position_0.$ === "None") {
    return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": 0, "registeredAt": _registered_0}, "tail": _positions_0};
  } else {
    return _positions_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$(_position_0, _batches_0, _dropped_0) {
  const _cursor_0 = _position_0["cursor"];
  const _registered_0 = _position_0["registeredAt"];
  const _x_0 = (_cursor_0 > _registered_0 ? _cursor_0 : _registered_0);
  return {$: "../../../../../bendvy/src/ecs/event-runtime.Reading", "values": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_batches_0, _cursor_0)), "lagged": (_x_0 < _dropped_0)};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup_checked$(_position_0, _id_0, _fallback_0) {
  const _actual_0 = _position_0["id"];
  const _cursor_0 = _position_0["cursor"];
  const _registered_0 = _position_0["registeredAt"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058choose_position$((_actual_0 === _id_0), {$: "../../../../../bendvy/src/ecs/event-runtime.Position", "id": _actual_0, "cursor": _cursor_0, "registeredAt": _registered_0}, _fallback_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047schedule$058after_outcome$1260$(_next_0, _outcome_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/schedule.Failed", "schedule": {$: "../../../../../bendvy/src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _all_0, "owners": _owners_0}, "world": _world_0, "error": _error_0, "observations": ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Ran", "id": _id_0}, "tail": {$: "Nil"}}))};
  } else {
    const _world_1 = _outcome_0["world"];
    return run_tail(_next_0(_owners_0)(_world_1), ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/schedule.Ran", "id": _id_0}, "tail": {$: "Nil"}})));
  }
}

function $adapter$058apply$1260$(_owners_0, _world_0) {
  if (_owners_0.$ === "adapter.Pending") {
    const _entries_0 = _owners_0["entries"];
    return $adapter$058targeted$1260$(_entries_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047bridge$058tick$1260$(_world_0)))));
  } else {
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  }
}

function $adapter$058enter$1260$(_owners_0, _world_0) {
  if (_owners_0.$ === "adapter.Selected") {
    const _positions_0 = _owners_0["positions"];
    const _kept_0 = _owners_0["kept"];
    const _active_0 = _owners_0["active"];
    return $adapter$058phase_returned$1260$(_positions_0, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Enter"}, ($phases$058enter$1260$(_active_0, _world_0)));
  } else {
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  }
}

function $adapter$058transition$1260$(_owners_0, _world_0) {
  if (_owners_0.$ === "adapter.Selected") {
    const _positions_0 = _owners_0["positions"];
    const _kept_0 = _owners_0["kept"];
    const _active_0 = _owners_0["active"];
    return $adapter$058phase_returned$1260$(_positions_0, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Transition"}, ($phases$058transition$1260$(_active_0, _world_0)));
  } else {
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  }
}

function $adapter$058exit$1260$(_owners_0, _world_0) {
  if (_owners_0.$ === "adapter.Selected") {
    const _positions_0 = _owners_0["positions"];
    const _kept_0 = _owners_0["kept"];
    const _active_0 = _owners_0["active"];
    return $adapter$058phase_returned$1260$(_positions_0, _kept_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Exit"}, ($phases$058exit$1260$(_active_0, _world_0)));
  } else {
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_batches_0, _cursor_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1260$((_cursor_0 < _tick_0), _items_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_rest_0, _cursor_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058choose_position$(_found_0, _position_0, _fallback_0) {
  if (!_found_0) {
    return _fallback_0;
  } else {
    return {$: "Some", "value": _position_0};
  }
}

function $adapter$058targeted$1260$(_entries_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _t_0 = _pair_0["snd"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "Tuple", "fst": {$: "adapter.Unavailable", "entries": _entries_0}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine.Missing"})), "output": {$: "Unit"}}};
  } else {
    const _current_0 = _t_0["current"];
    const _t_1 = _t_0["pending"];
    if (_t_1.$ === "../../../../../bendvy/src/ecs/machine.NoPending") {
      const _previous_0 = _t_0["previous"];
      return {$: "Tuple", "fst": {$: "adapter.Pending", "entries": _entries_0}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": {$: "../../../../../bendvy/src/ecs/machine.NoPending"}, "previous": _previous_0, "changed": false})), "output": {$: "Unit"}}};
    } else {
      const _to_0 = _t_1["value"];
      const _skip_0 = _t_1["skipSame"];
      const _previous_1 = _t_0["previous"];
      const __1 = _t_0["changed"];
      return $adapter$058selected$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": {$: "../../../../../bendvy/src/ecs/machine.Queued", "value": _to_0, "skipSame": _skip_0}, "previous": _previous_1, "changed": __1})), ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058partition$1260$(_entries_0, _current_0, _to_0)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047bridge$058tick$1260$(_world_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": nat_chk(_tick_0 + 1), "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $adapter$058phase_returned$1260$(_positions_0, _kept_0, _phase_0, _result_0) {
  const _active_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "adapter.Selected", "positions": _positions_0, "kept": _kept_0, "active": _active_0, "phase": _phase_0}, "snd": _outcome_0};
}

function $phases$058enter$1260$(_owners_0, _world_0) {
  const _t_0 = _owners_0["handlers"];
  const _exit_0 = _t_0["exit"];
  const _transition_0 = _t_0["transition"];
  const _enter_0 = _t_0["enter"];
  const _t_1 = _owners_0["intent"];
  if (_t_1.$ === "phases.Idle") {
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Idle"}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  } else {
    const _from_0 = _t_1["from"];
    const _to_0 = _t_1["to"];
    const _skipSame_0 = _t_1["skipSame"];
    return $phases$058entered$1260$(_exit_0, _transition_0, {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058run_phase$1260$(_enter_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Enter"}, _from_0, _to_0, {$: "None"})));
  }
}

function $phases$058transition$1260$(_owners_0, _world_0) {
  const _t_0 = _owners_0["handlers"];
  const _exit_0 = _t_0["exit"];
  const _transition_0 = _t_0["transition"];
  const _enter_0 = _t_0["enter"];
  const _t_1 = _owners_0["intent"];
  if (_t_1.$ === "phases.Idle") {
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Idle"}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  } else {
    const _from_0 = _t_1["from"];
    const _to_0 = _t_1["to"];
    const _skipSame_0 = _t_1["skipSame"];
    return $phases$058transitioned$1260$(_exit_0, _enter_0, _from_0, _to_0, _skipSame_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058run_phase$1260$(_transition_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Transition"}, _from_0, _to_0, {$: "None"})));
  }
}

function $phases$058exit$1260$(_owners_0, _world_0) {
  const _t_0 = _owners_0["handlers"];
  const _exit_0 = _t_0["exit"];
  const _transition_0 = _t_0["transition"];
  const _enter_0 = _t_0["enter"];
  const _t_1 = _owners_0["intent"];
  if (_t_1.$ === "phases.Idle") {
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Idle"}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  } else {
    const _from_0 = _t_1["from"];
    const _to_0 = _t_1["to"];
    const _skipSame_0 = _t_1["skipSame"];
    return $phases$058exited$1260$(_transition_0, _enter_0, _from_0, _to_0, _skipSame_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058run_phase$1260$(_exit_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Exit"}, _from_0, _to_0, {$: "None"})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1260$(_visible_0, _items_0, _rest_0) {
  if (!_visible_0) {
    return _rest_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1261$(_items_0, _rest_0);
  }
}

function $adapter$058selected$1260$(_world_0, _partition_0) {
  const _positions_0 = _partition_0["positions"];
  const _kept_0 = _partition_0["kept"];
  const _handlers_0 = _partition_0["owners"];
  return $adapter$058applied$1260$(_positions_0, _kept_0, ($phases$058captured$1260$(_handlers_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058partition$1260$(_entries_0, _from_0, _to_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Partition", "positions": {$: "Nil"}, "kept": {$: "Nil"}, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Nil"}, "transition": {$: "Nil"}, "enter": {$: "Nil"}}};
  } else {
    const _t_0 = _entries_0["head"];
    const _selector_0 = _t_0["selector"];
    const _needs_0 = _t_0["requirements"];
    const _entry_0 = _t_0["entry"];
    const _tail_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058placed$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058choose$1260$(_selector_0, _from_0, _to_0)), _selector_0, _needs_0, _entry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058partition$1260$(_tail_0, _from_0, _to_0)));
  }
}

function $phases$058entered$1260$(_exit_0, _transition_0, _intent_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Complete") {
    const _enter_0 = _result_0["entries"];
    const _world_0 = _result_0["world"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": _intent_0}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  } else {
    const _enter_1 = _result_0["entries"];
    const _world_1 = _result_0["world"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_1}, "intent": _intent_0}, "snd": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_1, "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058run_phase$1260$(_entries_0, _world_0, _phase_0, _from_0, _to_0, _error_0) {
  if (_entries_0.$ === "Nil") {
    if (_error_0.$ === "Some") {
      const _error_1 = _error_0["value"];
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Failed", "entries": {$: "Nil"}, "world": _world_0, "error": _error_1};
    } else {
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Complete", "entries": {$: "Nil"}, "world": _world_0};
    }
  } else {
    const _t_0 = _entries_0["head"];
    const _ordinal_0 = _t_0["ordinal"];
    const _registry_0 = _t_0["registry"];
    const _rest_0 = _entries_0["tail"];
    if (_error_0.$ === "Some") {
      const _error_2 = _error_0["value"];
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Failed", "entries": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _ordinal_0, "registry": _registry_0}, "tail": _rest_0}, "world": _world_0, "error": _error_2};
    } else {
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058entry_result$1260$(_ordinal_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_tracked$1260$(_registry_0, _world_0, {$: "../../../../../bendvy/src/ecs/machine-handlers.Invocation", "phase": _phase_0, "ordinal": _ordinal_0, "from": _from_0, "to": _to_0})), run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058run_phase$1260$(_rest_0, _x_0, _phase_0, _from_0, _to_0, _x_1);
});
}));
    }
  }
}

function $phases$058transitioned$1260$(_exit_0, _enter_0, _from_0, _to_0, _skipSame_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Complete") {
    const _transition_0 = _result_0["entries"];
    const _world_0 = _result_0["world"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($phases$058committed$1260$(_from_0, _to_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)))), "output": {$: "Unit"}}};
  } else {
    const _transition_1 = _result_0["entries"];
    const _world_1 = _result_0["world"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_1, "enter": _enter_0}, "intent": {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": ($phases$058requeued$1260$(_to_0, _skipSame_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_1)))), "error": _error_0}};
  }
}

function $phases$058exited$1260$(_transition_0, _enter_0, _from_0, _to_0, _skipSame_0, _result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Complete") {
    const _exit_0 = _result_0["entries"];
    const _world_0 = _result_0["world"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_0, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
  } else {
    const _exit_1 = _result_0["entries"];
    const _world_1 = _result_0["world"];
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_1, "transition": _transition_0, "enter": _enter_0}, "intent": {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": ($phases$058requeued$1260$(_to_0, _skipSame_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_1)))), "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1261$(_left_0, _right_0) {
  if (_left_0.$ === "Nil") {
    if (_right_0.$ === "Nil") {
      return {$: "Nil"};
    } else {
      return _right_0;
    }
  } else {
    if (_right_0.$ === "Nil") {
      return _left_0;
    } else {
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1261$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $adapter$058applied$1260$(_positions_0, _kept_0, _result_0) {
  const _active_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "adapter.Selected", "positions": _positions_0, "kept": _kept_0, "active": _active_0, "phase": {$: "../../../../../bendvy/src/ecs/machine-handlers.Exit"}}, "snd": _outcome_0};
}

function $phases$058captured$1260$(_handlers_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return $phases$058prepared$1260$(_handlers_0, _world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepare$1260$(_slot_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058snapshot$1260$(_slot_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058placed$1260$(_choice_0, _selector_0, _needs_0, _entry_0, _tail_0) {
  if (_choice_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept") {
    const _positions_0 = _tail_0["positions"];
    const _kept_0 = _tail_0["kept"];
    const _owners_0 = _tail_0["owners"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Partition", "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept"}}, "tail": _positions_0}, "kept": {$: "Con", "head": _entry_0, "tail": _kept_0}, "owners": _owners_0};
  } else if (_choice_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedExit") {
    const _positions_1 = _tail_0["positions"];
    const _kept_1 = _tail_0["kept"];
    const _t_0 = _tail_0["owners"];
    const _exit_0 = _t_0["exit"];
    const _transition_0 = _t_0["transition"];
    const _enter_0 = _t_0["enter"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Partition", "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedExit"}}, "tail": _positions_1}, "kept": _kept_1, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": {$: "Con", "head": _entry_0, "tail": _exit_0}, "transition": _transition_0, "enter": _enter_0}};
  } else if (_choice_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedTransition") {
    const _positions_2 = _tail_0["positions"];
    const _kept_2 = _tail_0["kept"];
    const _t_1 = _tail_0["owners"];
    const _exit_1 = _t_1["exit"];
    const _transition_1 = _t_1["transition"];
    const _enter_1 = _t_1["enter"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Partition", "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedTransition"}}, "tail": _positions_2}, "kept": _kept_2, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_1, "transition": {$: "Con", "head": _entry_0, "tail": _transition_1}, "enter": _enter_1}};
  } else {
    const _positions_3 = _tail_0["positions"];
    const _kept_3 = _tail_0["kept"];
    const _t_2 = _tail_0["owners"];
    const _exit_2 = _t_2["exit"];
    const _transition_2 = _t_2["transition"];
    const _enter_2 = _t_2["enter"];
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Partition", "positions": {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Position", "selector": _selector_0, "requirements": _needs_0, "choice": {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedEnter"}}, "tail": _positions_3}, "kept": _kept_3, "owners": {$: "../../../../../bendvy/src/ecs/machine-handlers.Owners", "exit": _exit_2, "transition": _transition_2, "enter": {$: "Con", "head": _entry_0, "tail": _enter_2}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058choose$1260$(_selector_0, _from_0, _to_0) {
  if (_selector_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.ExitFrom") {
    const _value_0 = _selector_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058exit_choice$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_value_0, _from_0)));
  } else if (_selector_0.$ === "../../../../../bendvy/src/ecs/machine-handler-bundle.TransitionPair") {
    const _old_0 = _selector_0["from"];
    const _new_0 = _selector_0["to"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058transition_choice$(($Bool$and$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_old_0, _from_0)), ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_new_0, _to_0)))));
  } else {
    const _value_1 = _selector_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058enter_choice$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_value_1, _to_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058entry_result$1260$(_ordinal_0, _observed_0, _next_0) {
  if (_observed_0.$ === "../../../../../bendvy/src/ecs/system.Completed") {
    const _registry_0 = _observed_0["registry"];
    const _outcome_0 = _observed_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058entry_outcome$1260$(_ordinal_0, _registry_0, _outcome_0, _next_0);
  } else {
    const _registry_1 = _observed_0["registry"];
    const _world_0 = _observed_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepend$1260$({$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _ordinal_0, "registry": _registry_1}, _next_0(_world_0)({$: "Some", "value": "HandlerRegistrationRejected"}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_tracked$1260$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_result$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1260$(_registry_0, _world_0, _args_0)));
}

function $phases$058committed$1260$(_from_0, _to_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return $phases$058published$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058committed$1260$(_slot_0, _from_0, _to_0)))), {$: "../../../../../bendvy/src/ecs/machine.Transition", "from": _from_0, "to": _to_0});
}

function $phases$058requeued$1260$(_to_0, _skipSame_0, _pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058queue$1260$(_slot_0, _to_0, _skipSame_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1261$($0, $1) {
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

function $phases$058prepared$1260$(_handlers_0, _world_0, _value_0) {
  if (_value_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Idle") {
    const _slot_0 = _value_0["slot"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": _handlers_0, "intent": {$: "phases.Idle"}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, _slot_0)), "output": {$: "Unit"}}};
  } else {
    const _slot_1 = _value_0["slot"];
    const _t_0 = _value_0["transition"];
    const _from_0 = _t_0["from"];
    const _to_0 = _t_0["to"];
    const _skipSame_0 = _value_0["skipSame"];
    return {$: "Tuple", "fst": {$: "phases.Owners", "handlers": _handlers_0, "intent": {$: "phases.Ready", "from": _from_0, "to": _to_0, "skipSame": _skipSame_0}}, "snd": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, _slot_1)), "output": {$: "Unit"}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepare$1260$(_slot_0, _captured_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    if (_captured_0.$ === "../../../../../bendvy/src/ecs/machine.Unscheduled") {
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Idle", "slot": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058clear_changed$1260$({$: "../../../../../bendvy/src/ecs/machine.Missing"}))};
    } else {
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Idle", "slot": {$: "../../../../../bendvy/src/ecs/machine.Missing"}};
    }
  } else {
    const _current_0 = _slot_0["current"];
    const __2 = _slot_0["pending"];
    const _previous_0 = _slot_0["previous"];
    const __3 = _slot_0["changed"];
    if (_captured_0.$ === "../../../../../bendvy/src/ecs/machine.Unscheduled") {
      return {$: "../../../../../bendvy/src/ecs/machine-handlers.Idle", "slot": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058clear_changed$1260$({$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": __2, "previous": _previous_0, "changed": __3}))};
    } else {
      const _value_0 = _captured_0["value"];
      const _skipSame_0 = _captured_0["skipSame"];
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058choose$1260$(($Bool$and$(_skipSame_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_current_0, _value_0)))), _current_0, _value_0, _previous_0, _skipSame_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058snapshot$1260$(_slot_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "../../../../../bendvy/src/ecs/machine.Unscheduled"};
  } else {
    const _pending_0 = _slot_0["pending"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058snapshot_pending$1260$(_pending_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058exit_choice$(_yes_0) {
  if (_yes_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedExit"};
  } else {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047types$058same$(_left_0, _right_0) {
  if (_left_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot") {
    if (_right_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Boot") {
      return true;
    } else {
      return false;
    }
  } else if (_left_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play") {
    if (_right_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_right_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Pause") {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058transition_choice$(_yes_0) {
  if (_yes_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedTransition"};
  } else {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handler$045bundle$058enter_choice$(_yes_0) {
  if (_yes_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.SelectedEnter"};
  } else {
    return {$: "../../../../../bendvy/src/ecs/machine-handler-bundle.Kept"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058entry_outcome$1260$(_ordinal_0, _registry_0, _outcome_0, _next_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepend$1260$({$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _ordinal_0, "registry": _registry_0}, _next_0(_world_0)({$: "Some", "value": _error_0}));
  } else {
    const _world_1 = _outcome_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepend$1260$({$: "../../../../../bendvy/src/ecs/machine-handlers.Entry", "ordinal": _ordinal_0, "registry": _registry_0}, _next_0(_world_1)({$: "None"}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058prepend$1260$(_head_0, _tail_0) {
  if (_tail_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Complete") {
    const _entries_0 = _tail_0["entries"];
    const _world_0 = _tail_0["world"];
    return {$: "../../../../../bendvy/src/ecs/machine-handlers.Complete", "entries": {$: "Con", "head": _head_0, "tail": _entries_0}, "world": _world_0};
  } else {
    const _entries_1 = _tail_0["entries"];
    const _world_1 = _tail_0["world"];
    const _error_0 = _tail_0["error"];
    return {$: "../../../../../bendvy/src/ecs/machine-handlers.Failed", "entries": {$: "Con", "head": _head_0, "tail": _entries_1}, "world": _world_1, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_result$1260$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/system.RegistrationRejected") {
    const _registry_0 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    const _args_0 = _result_0["args"];
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _registry_1 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_outcome$1260$(_registry_1, _outcome_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1260$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1260$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $phases$058published$1260$(_world_0, _event_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047bridge$058published$1260$(_world_0, _event_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058committed$1260$(_slot_0, _from_0, _to_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "../../../../../bendvy/src/ecs/machine.Missing"};
  } else {
    const _pending_0 = _slot_0["pending"];
    return {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _to_0, "pending": _pending_0, "previous": {$: "Some", "value": _from_0}, "changed": true};
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058clear_changed$1260$(_slot_0) {
  if (_slot_0.$ === "../../../../../bendvy/src/ecs/machine.Missing") {
    return {$: "../../../../../bendvy/src/ecs/machine.Missing"};
  } else {
    const _current_0 = _slot_0["current"];
    const _pending_0 = _slot_0["pending"];
    const _previous_0 = _slot_0["previous"];
    return {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": _pending_0, "previous": _previous_0, "changed": false};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045handlers$058choose$1260$(_skip_0, _current_0, _value_0, _previous_0, _skipSame_0) {
  if (_skip_0) {
    return {$: "../../../../../bendvy/src/ecs/machine-handlers.Idle", "slot": {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": {$: "../../../../../bendvy/src/ecs/machine.NoPending"}, "previous": _previous_0, "changed": false}};
  } else {
    return {$: "../../../../../bendvy/src/ecs/machine-handlers.Ready", "slot": {$: "../../../../../bendvy/src/ecs/machine.Present", "current": _current_0, "pending": {$: "../../../../../bendvy/src/ecs/machine.NoPending"}, "previous": {$: "Some", "value": _current_0}, "changed": false}, "transition": {$: "../../../../../bendvy/src/ecs/machine.Transition", "from": _current_0, "to": _value_0}, "skipSame": _skipSame_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058snapshot_pending$1260$(_pending_0) {
  if (_pending_0.$ === "../../../../../bendvy/src/ecs/machine.NoPending") {
    return {$: "../../../../../bendvy/src/ecs/machine.Unscheduled"};
  } else {
    const _value_0 = _pending_0["value"];
    const _skipSame_0 = _pending_0["skipSame"];
    return {$: "../../../../../bendvy/src/ecs/machine.Scheduled", "value": _value_0, "skipSame": _skipSame_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_outcome$1260$(_registry_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_clock$1260$(_registry_0, _output_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058clock$1260$(_world_1)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1260$(_registry_0, _named_0, _args_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1260$(_registry_0, _world_0, _actual_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047bridge$058published$1260$(_world_0, _event_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058publish$1260$(_stream_0, _tick_0, _event_0)), "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058tracked_clock$1260$(_registry_0, _output_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _clock_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058cursor_outcome$1260$({$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": _output_0}, _registry_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1260$(_registry_0, _world_0, _actual_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1260$((_namespace_0 === _actual_0), {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$045stream$058publish$1260$(_stream_0, _tick_0, _event_0) {
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _dropped_0 = _stream_0["droppedThrough"];
  const _frameStart_0 = _stream_0["frameStart"];
  return {$: "../../../../../bendvy/src/ecs/machine-stream.Stream", "batches": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1260$(_batches_0, {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": {$: "Con", "head": _event_0, "tail": {$: "Nil"}}}, "tail": {$: "Nil"}})), "positions": _positions_0, "droppedThrough": _dropped_0, "frameStart": _frameStart_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058cursor_outcome$1260$(_outcome_0, _registry_0, _nextCursor_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": {$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _nextCursor_0}, "outcome": {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_1, "output": _output_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    const _cursor_0 = _registry_0["cursor"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1260$({$: "../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1260$(_left_0, _right_0) {
  if (_left_0.$ === "Nil") {
    if (_right_0.$ === "Nil") {
      return {$: "Nil"};
    } else {
      return _right_0;
    }
  } else {
    if (_right_0.$ === "Nil") {
      return _left_0;
    } else {
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1260$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1260$(_registry_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1260$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1260$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058runner$1260$(_world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1260$(_registry_0, _outcome_0) {
  return {$: "../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": _outcome_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058runner$1260$(_world_0, _invocation_0) {
  const _phase_0 = _invocation_0["phase"];
  const _ordinal_0 = _invocation_0["ordinal"];
  const _from_0 = _invocation_0["from"];
  const _to_0 = _invocation_0["to"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058invoked$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_world$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058touch_local$1260$(_world_0, _ordinal_0)), _ordinal_0)), {$: "../../../../../bendvy/src/ecs/machine-handlers.Invocation", "phase": _phase_0, "ordinal": _ordinal_0, "from": _from_0, "to": _to_0});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058invoked$1260$(_observed_0, _invocation_0) {
  const _t_0 = _observed_0["fst"];
  const _ns_0 = _t_0["namespace"];
  const _next_0 = _t_0["nextId"];
  const _high_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _store_0 = _t_0["store"];
  const _t_1 = _t_0["resource"];
  const _owned_0 = _t_1["owned"];
  const _slot_0 = _t_1["slot"];
  const _stream_0 = _t_1["stream"];
  const _reader_0 = _t_1["reader"];
  const _locals_0 = _t_1["locals"];
  const _tick_0 = _t_1["tick"];
  const _prefix_0 = _t_1["prefix"];
  const _delivered_0 = _t_1["delivered"];
  const _applied_0 = _t_1["structuralApplied"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystem_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _count_0 = _observed_0["snd"];
  const _phase_0 = _invocation_0["phase"];
  const _to_0 = _invocation_0["to"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058selected_failure$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": [0], "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, _count_0, _phase_0, _to_0, {$: "Tuple", fst: _owned_0, snd: _owned_0[1 % _owned_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_world$1260$(_world_0, _id_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_world_join$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": {$: "Nil"}, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempts$(_locals_0, _ns_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058touch_local$1260$(_world_0, _id_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058locals_increment$(_locals_0, _ns_0, _id_0)), "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058selected_failure$1260$(_world_0, _count_0, _phase_0, _to_0, _pair_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _owned_0 = _pair_0["fst"];
  const _selected_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058phase_body$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, _count_0, _selected_0, _phase_0, _to_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_world_join$1260$(_world_0, _pair_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _locals_0 = _pair_0["fst"];
  const _count_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "snd": _count_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempts$(_items_0, _namespace_0, _id_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _t_0 = _items_0["head"];
    const _owner_0 = _t_0["namespace"];
    const _key_0 = _t_0["id"];
    const _cell_0 = _t_0["cell"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_selected$(($Bool$and$((_owner_0 === _namespace_0), (_key_0 === _id_0))), _owner_0, _key_0, _cell_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempts$(_rest_0, _namespace_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058locals_increment$(_items_0, _namespace_0, _id_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _owner_0 = _t_0["namespace"];
    const _key_0 = _t_0["id"];
    const _cell_0 = _t_0["cell"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_selected$(($Bool$and$((_owner_0 === _namespace_0), (_key_0 === _id_0))), _owner_0, _key_0, _cell_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058locals_increment$(_rest_0, _namespace_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058phase_body$1260$(_world_0, _count_0, _selected_0, _phase_0, _to_0) {
  if (_phase_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Exit") {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay$1260$(_world_0, 1, "exit", ($Bool$and$((_selected_0 === 1), (_count_0 === 1))));
  } else if (_phase_0.$ === "../../../../../bendvy/src/ecs/machine-handlers.Transition") {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay$1260$(_world_0, 10, "transition", ($Bool$and$((_selected_0 === 2), (_count_0 === 1))));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058entered$1260$(_to_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay$1260$(_world_0, 100, "enter", ($Bool$and$((_selected_0 === 3), (_count_0 === 1))))));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_selected$(_yes_0, _namespace_0, _id_0, _cell_0, _tail_0) {
  if (!_yes_0) {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_join$({$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _namespace_0, "id": _id_0, "cell": _cell_0}, _tail_0);
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_observed$(_namespace_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_count$(_cell_0)), _tail_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_selected$(_yes_0, _namespace_0, _id_0, _cell_0, _rest_0) {
  if (_yes_0) {
    return {$: "Con", "head": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _namespace_0, "id": _id_0, "cell": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_increment$(_cell_0))}, "tail": _rest_0};
  } else {
    return {$: "Con", "head": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _namespace_0, "id": _id_0, "cell": _cell_0}, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay$1260$(_world_0, _amount_0, _name_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058finished$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay_body$({$: "../../../../../bendvy/experiments/public-machines/handler-schedule-composition-v1/systems.Work", "resource": {$: "../../../../../bendvy/src/ecs/capabilities.ValueWrite", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_read$1260$(_x_0);
}), "set": run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_write$1260$(_x_1, _x_2);
});
})}, "component": {$: "../../../../../bendvy/src/ecs/capabilities.Action", "run": run_clo((_x_3) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058change_component$1260$(_x_3, _amount_0);
})}, "deferred": {$: "../../../../../bendvy/src/ecs/capabilities.Action", "run": run_clo((_x_4) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_x_4, run_clo((_x_5) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058structural$1260$(_x_5);
}));
})}}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0)), _amount_0)), _name_0, _fail_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058entered$1260$(_to_0, _result_0) {
  if (_to_0.$ === "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Play") {
    if (_result_0.$ === "../../../../../bendvy/src/ecs/system.Succeeded") {
      const _world_0 = _result_0["world"];
      const _output_0 = _result_0["output"];
      return {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058queue_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058take$1260$(_world_0)))), "output": _output_0};
    } else {
      return _result_0;
    }
  } else {
    return _result_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_join$(_head_0, _tail_0) {
  const _rest_0 = _tail_0["fst"];
  const _value_0 = _tail_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _head_0, "tail": _rest_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058attempt_observed$(_namespace_0, _id_0, _observed_0, _tail_0) {
  const _cell_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  const _rest_0 = _tail_0["fst"];
  return {$: "Tuple", "fst": {$: "Con", "head": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.LocalOwner", "namespace": _namespace_0, "id": _id_0, "cell": _cell_0}, "tail": _rest_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_count$(_cell_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047local$058read_cell$1260$(_cell_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_increment$(_cell_0) {
  const _owner_0 = _cell_0["local"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_incremented$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047local$058projected$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058increment$(_owner_0, 1)))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058finished$1260$(_tx_0, _name_0, _fail_0) {
  if (_fail_0) {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058committed_prefix$1260$(_name_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, {$: "../../../../../bendvy/src/ecs/transaction.Failure", "error": "once"})));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058committed_prefix$1260$(_name_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, {$: "../../../../../bendvy/src/ecs/transaction.Success"})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay_body$(_caps_0, _owner_0, _amount_0) {
  const _resource_0 = _caps_0["resource"];
  const _component_0 = _caps_0["component"];
  const _deferred_0 = _caps_0["deferred"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058act$(run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058act$(run_loop($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay_write$(_resource_0, _owner_0, _amount_0)), _component_0)), _deferred_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_read$1260$(_frame_0) {
  const _world_0 = _frame_0["world"];
  const _undo_0 = _frame_0["undo"];
  const _commands_0 = _frame_0["commands"];
  const _events_0 = _frame_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_read_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_read$1260$(_world_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_write$1260$(_frame_0, _amount_0) {
  const _world_0 = _frame_0["world"];
  const _undo_0 = _frame_0["undo"];
  const _commands_0 = _frame_0["commands"];
  const _events_0 = _frame_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_join$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058change_resource$1260$(_world_0, _amount_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058change_component$1260$(_tx_0, _amount_0) {
  const _t_0 = _tx_0["world"];
  const _ns_0 = _t_0["namespace"];
  const _next_0 = _t_0["nextId"];
  const _high_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _t_1 = _t_0["store"];
  const _column_0 = _t_1["column"];
  const _resources_0 = _t_0["resource"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystem_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _emitted_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058component_stamp$1260$({$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": {$: "../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}}}, "resource": _resources_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "undo": _undo_0, "commands": _commands_0, "events": _emitted_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1260$(_column_0, 1)), _amount_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058stage$1260$(_tx_0, _command_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": {$: "Con", "head": _command_0, "tail": _commands_0}, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058structural$1260$(_world_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": ((_applied_0 + 1) >>> 0)}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058queue_join$1260$(_pair_0) {
  const _world_0 = _pair_0["fst"];
  const _slot_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045handlers$047remaining$045core$045v1$047world$058put$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047machine$058queue$1260$(_slot_0, {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Pause"}, false)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047local$058read_cell$1260$(_cell_0) {
  const _local_0 = _cell_0["local"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047local$058projected$1260$({$: "Tuple", fst: _local_0, snd: _local_0[0 % _local_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058local_incremented$(_pair_0) {
  const _cell_0 = _pair_0["fst"];
  return _cell_0;
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047local$058projected$1260$(_result_0) {
  const _local_0 = _result_0["fst"];
  const _value_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/local.Cell", "local": _local_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058increment$(_owner_0, _amount_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058projected$({$: "Tuple", fst: _owner_0, snd: _owner_0[0 % _owner_0.length]}, _amount_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058committed_prefix$1260$(_name_0, _result_0) {
  const _world_0 = _result_0["world"];
  const _t_0 = _result_0["outcome"];
  if (_t_0.$ === "../../../../../bendvy/src/ecs/transaction.Failure") {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0};
  } else {
    return {$: "../../../../../bendvy/src/ecs/system.Succeeded", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058prefix$1260$(_world_0, _name_0)), "output": {$: "Unit"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058act$(_owner_0, _cap_0) {
  const _apply_0 = _cap_0["run"];
  return run_tail(_apply_0, _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058gameplay_write$(_cap_0, _owner_0, _amount_0) {
  const _write_0 = _cap_0["set"];
  return run_tail(_write_0(_owner_0), _amount_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_read_join$1260$(_pair_0, _undo_0, _commands_0, _events_0) {
  const _world_0 = _pair_0["fst"];
  const _value_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_read$1260$(_world_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_read_world$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": [0], "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, {$: "Tuple", fst: _owned_0, snd: _owned_0[0 % _owned_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_tx_join$1260$(_changed_0, _oldUndo_0, _oldCommands_0, _oldEvents_0) {
  const _world_0 = _changed_0["world"];
  const _undo_0 = _changed_0["undo"];
  return {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": ($List$append$(_undo_0, _oldUndo_0)), "commands": _oldCommands_0, "events": _oldEvents_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058change_resource$1260$(_world_0, _amount_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_changed$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": [0], "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058increment$(_owned_0, _amount_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058component_stamp$1260$(_tx_0, _pair_0, _amount_0, _clock_0) {
  const _column_0 = _pair_0["fst"];
  const _stamp_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058component_written$1260$(_tx_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058changed_taken$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, 1, {$: "None"})), _amount_0)), _stamp_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058projected$(_pair_0, _amount_0) {
  const _owner_0 = _pair_0["fst"];
  const _old_0 = _pair_0["snd"];
  const _x_0 = ((_old_0 + _amount_0) >>> 0);
  return {$: "Tuple", "fst": (_owner_0[0 % _owner_0.length] = _x_0, _owner_0), "snd": _old_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058prefix$1260$(_world_0, _name_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prior_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": ($List$append$(_prior_0, {$: "Con", "head": _name_0, "tail": {$: "Nil"}})), "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058discard_unit_events$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_read_world$1260$(_world_0, _pair_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _owned_0 = _pair_0["fst"];
  const _value_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058resource_changed$1260$(_world_0, _pair_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _owned_0 = _pair_0["fst"];
  const _old_0 = _pair_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058add_undo$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": _owned_0, "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0})), run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_resource$1260$(_x_0, _old_0);
}));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058component_written$1260$(_tx_0, _pair_0, _stamp_0, _oldClock_0) {
  const _t_0 = _tx_0["world"];
  const _ns_0 = _t_0["namespace"];
  const _next_0 = _t_0["nextId"];
  const _high_0 = _t_0["highWater"];
  const _live_0 = _t_0["live"];
  const _capacity_0 = _t_0["capacity"];
  const _depth_0 = _t_0["depth"];
  const _resources_0 = _t_0["resource"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystem_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _emitted_0 = _tx_0["events"];
  const _column_0 = _pair_0["fst"];
  const _t_1 = _pair_0["snd"];
  if (_t_1.$ === "Some") {
    const _old_0 = _t_1["value"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058add_undo$1260$({$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, 1, true, true, ((_clock_0 + 1) >>> 0)))}, "resource": _resources_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": ((_clock_0 + 1) >>> 0)}, "undo": _undo_0, "commands": _commands_0, "events": _emitted_0}, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_component$1260$(_x_0, _old_0, _stamp_0, _oldClock_0);
}));
  } else {
    return {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": _column_0}, "resource": _resources_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, "undo": _undo_0, "commands": _commands_0, "events": _emitted_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058changed_taken$1260$(_result_0, _amount_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _t_0 = _result_0["previous"];
    if (_t_0.$ === "Some") {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058changed_owner$1260$(_column_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058increment$(_owner_0, _amount_0)));
    } else {
      return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
    }
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$((_key_0 === _id_0), _stamp_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../bendvy/src/ecs/column.Owned") {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned") {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058enqueue$1260$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058enqueue_all$1260$(_commands_0, _world_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058discard_unit_events$1260$(_world_0, __0) {
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058add_undo$1260$(_tx_0, _inverse_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": _inverse_0, "tail": _undo_0}, "commands": _commands_0, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_resource$1260$(_world_0, _value_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _t_0 = _world_0["resource"];
  const _owned_0 = _t_0["owned"];
  const _slot_0 = _t_0["slot"];
  const _stream_0 = _t_0["stream"];
  const _reader_0 = _t_0["reader"];
  const _locals_0 = _t_0["locals"];
  const _tick_0 = _t_0["tick"];
  const _prefix_0 = _t_0["prefix"];
  const _delivered_0 = _t_0["delivered"];
  const _applied_0 = _t_0["structuralApplied"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Resources", "owned": (_owned_0[0 % _owned_0.length] = _value_0, _owned_0), "slot": _slot_0, "stream": _stream_0, "reader": _reader_0, "locals": _locals_0, "tick": _tick_0, "prefix": _prefix_0, "delivered": _delivered_0, "structuralApplied": _applied_0}, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_component$1260$(_world_0, _value_0, _stamp_0, _oldClock_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _t_0 = _world_0["store"];
  const _column_0 = _t_0["column"];
  const _resources_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_component_result$1260$({$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": {$: "../../../../../bendvy/src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}}}, "resource": _resources_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _clock_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_taken$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, 1, {$: "None"})), _value_0)), _stamp_0, _oldClock_0);
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058changed_owner$1260$(_column_0, _pair_0) {
  const _owner_0 = _pair_0["fst"];
  const _old_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restored_swap$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, 1, {$: "Some", "value": _owner_0})))), "snd": {$: "Some", "value": _old_0}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058choose$(_found_0, _stamp_0, _other_0) {
  if (_found_0) {
    return _stamp_0;
  } else {
    return _other_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)), (_id_0 <= _capacity_0));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": _stamp_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058enqueue_all$1260$($0, $1) {
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
        $1 = ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_entries_0, _id_0, _stamp_0) {
  return {$: "Con", "head": {$: "../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _id_0, "stamp": _stamp_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0))};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0) {
  if (!_incoming_0) {
    return {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_component_result$1260$(_world_0, _pair_0, _stamp_0, _oldClock_0) {
  const _ns_0 = _world_0["namespace"];
  const _next_0 = _world_0["nextId"];
  const _high_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _resources_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystem_0 = _world_0["nextSystemId"];
  const _column_0 = _pair_0["fst"];
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _ns_0, "nextId": _next_0, "highWater": _high_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": {$: "../../../../../bendvy/experiments/public-handlers/remaining-core-v1/types.Store", "column": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restore_stamp$1260$(_column_0, 1, _stamp_0))}, "resource": _resources_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystem_0, "clock": _oldClock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restore_taken$1260$(_result_0, _value_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _t_0 = _result_0["previous"];
    if (_t_0.$ === "Some") {
      const _owner_0 = _t_0["value"];
      return {$: "Tuple", "fst": ($$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restored_swap$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap$1260$(_column_0, 1, {$: "Some", "value": (_owner_0[0 % _owner_0.length] = _value_0, _owner_0)})))), "snd": {$: "Some", "value": {$: "Unit"}}};
    } else {
      return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
    }
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045machines$047handler$045schedule$045composition$045v1$047systems$058restored_swap$1260$(_result_0) {
  if (_result_0.$ === "../../../../../bendvy/src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return _column_0;
  } else {
    const _column_1 = _result_0["column"];
    return _column_1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$({$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../../../bendvy/src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0) {
  return {$: "../../../../../bendvy/src/ecs/column.Indexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0, _fits_0) {
  if (!_isnormal_0) {
    return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058get$(_exceptional_0, _id_0))};
  } else {
    if (!_fits_0) {
      return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
    } else {
      const _x_0 = ((_id_0 - 1) >>> 0);
      return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, {$: "Tuple", fst: _added_0, snd: _added_0[_x_0 % _added_0.length]});
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0) {
  return $Bool$and$((_id_0 > 0), (_id_0 <= 131072));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0) {
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
  return {$: "../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0) {
  if (_entries_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _entries_0["head"];
    const _key_0 = _t_0["id"];
    const _stamp_0 = _t_0["stamp"];
    const _rest_0 = _entries_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$((_key_0 === _id_0), {$: "../../../../../bendvy/src/ecs/lifecycle.Entry", "id": _key_0, "stamp": _stamp_0}, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058clear$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0) {
  if (!_wasPresent_0) {
    return {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _tick_0, "changed": _tick_0};
  } else {
    const _added_0 = _stamp_0["added"];
    return {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _added_0, "changed": _tick_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restore_stamp$1260$(_column_0, _id_0, _stamp_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, _stamp_0))};
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swapped$1260$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover$1260$(_column_0) {
  if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../../../bendvy/src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../../../bendvy/src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../../../bendvy/src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../../../bendvy/src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../../../bendvy/src/ecs/column.Rejected", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../../../bendvy/src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../../../bendvy/src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../../../bendvy/src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../../../bendvy/src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../../../bendvy/src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _observed_0) {
  const _added_0 = _observed_0["fst"];
  const _first_0 = _observed_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, {$: "Tuple", fst: _changed_0, snd: _changed_0[_x_0 % _changed_0.length]});
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058keep$(_equal_0, _entry_0, _rest_0) {
  if (_equal_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _entry_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../bendvy/src/ecs/column.Prepared", "state": {$: "../../../../../bendvy/src/ecs/column.Owned", "state": {$: "../../../../../bendvy/src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, _stamp_0)), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0)));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_prepared_restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../../../bendvy/src/ecs/column.PreparedIndexed", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../../../bendvy/src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0)), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../../../bendvy/src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, _observed_0) {
  const _changed_0 = _observed_0["fst"];
  const _last_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../../../bendvy/src/ecs/lifecycle.Stamp", "added": _first_0, "changed": _last_0}};
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0) {
  if (!_isnormal_0) {
    return {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047lifecycle$058set$(_exceptional_0, _id_0, _stamp_0))};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$(17, _id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, (_id_0 <= _capacity_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../../../bendvy/src/ecs/column.Column", "values": ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_grow$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
          return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
        } else {
          return {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_fits_0) {
          return $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_selected_rows$($0, $1) {
  for (;;) {
    {
      const _rows_0 = $0;
      const _values_0 = $1;
      if (_rows_0.$ === "../../../../../bendvy/src/ecs/owner-handoff.HandoffNil") {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047column$058recover_past$1260$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../../../bendvy/src/ecs/column.HistoryNil") {
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

function $$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0) {
  const _first_0 = _stamp_0["added"];
  const _last_0 = _stamp_0["changed"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = ((_id_0 - 1) >>> 0);
  return {$: "../../../../../bendvy/src/ecs/indexed-lifecycle.Metadata", "added": (_added_0[_x_0 % _added_0.length] = _first_0, _added_0), "changed": (_changed_0[_x_1 % _changed_0.length] = _last_0, _changed_0), "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
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
io_exit($main$, [[7,0,1,0,0,3,0,0,13,1,13,2,13,4],["consumer.Report"]]);