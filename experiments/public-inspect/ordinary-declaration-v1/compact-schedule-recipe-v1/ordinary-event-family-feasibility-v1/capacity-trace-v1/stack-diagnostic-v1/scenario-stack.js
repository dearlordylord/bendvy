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
  return $detached$(($trace$058scenario$()));
}

function $detached$(_returned_0) {
  const _rows_0 = _returned_0["snd"];
  return _rows_0;
}

function $trace$058scenario$() {
  return $trace$058observed_join$(run_clo((_x_0) => {
  return $trace$058sequence$(($trace$058actions$()), _x_0);
}), ($trace$058observe$({$: "None"}, ($consumer$058setup$()))));
}

function $trace$058observed_join$(_next_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _rows_0 = _returned_0["snd"];
  return $trace$058appended$(_rows_0, _next_0(_fixture_0));
}

function $trace$058sequence$(_actions_0, _fixture_0) {
  if (_actions_0.$ === "Nil") {
    return {$: "Tuple", "fst": _fixture_0, "snd": {$: "Nil"}};
  } else {
    const _action_0 = _actions_0["head"];
    const _rest_0 = _actions_0["tail"];
    return $trace$058acted$(run_clo((_x_0) => {
  return $trace$058sequence$(_rest_0, _x_0);
}), ($trace$058ticked$(_action_0, _fixture_0)));
  }
}

function $trace$058actions$() {
  return {$: "Con", "head": {$: "consumer.ReadFirst", "slow": false, "fail": false}, "tail": {$: "Con", "head": {$: "consumer.ReadFirst", "slow": true, "fail": false}, "tail": {$: "Con", "head": {$: "consumer.ReadSecond", "fail": false}, "tail": {$: "Con", "head": {$: "consumer.Publish", "fail": false, "count": 65535}, "tail": {$: "Con", "head": {$: "consumer.Publish", "fail": false, "count": 2}, "tail": {$: "Con", "head": {$: "consumer.Frame"}, "tail": {$: "Con", "head": {$: "consumer.ReadFirst", "slow": true, "fail": false}, "tail": {$: "Con", "head": {$: "consumer.ReadFirst", "slow": false, "fail": false}, "tail": {$: "Con", "head": {$: "consumer.ReadSecond", "fail": false}, "tail": {$: "Con", "head": {$: "consumer.Frame"}, "tail": {$: "Con", "head": {$: "consumer.Frame"}, "tail": {$: "Nil"}}}}}}}}}}}};
}

function $trace$058observe$(_completion_0, _fixture_0) {
  return $trace$058flags$({$: "Con", "head": true, "tail": {$: "Nil"}}, _completion_0, _fixture_0);
}

function $consumer$058setup$() {
  return $consumer$058created$([61], ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), [51])));
}

function $trace$058appended$(_rows_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _rest_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _fixture_0, "snd": ($List$append$(_rows_0, _rest_0))};
}

function $trace$058acted$(_next_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _completion_0 = _returned_0["snd"];
  return $trace$058observed_join$(_next_0, ($trace$058observe$({$: "Some", "value": _completion_0}, _fixture_0)));
}

function $trace$058ticked$(_action_0, _fixture_0) {
  if (_action_0.$ === "consumer.Frame") {
    return $consumer$058step$({$: "consumer.Frame"}, _fixture_0);
  } else {
    return $consumer$058step$(_action_0, ($trace$058framed_fixture$(_fixture_0)));
  }
}

function $trace$058flags$(_enabled_0, _completion_0, _fixture_0) {
  if (_enabled_0.$ === "Nil") {
    return {$: "Tuple", "fst": _fixture_0, "snd": {$: "Nil"}};
  } else {
    const _flag_0 = _enabled_0["head"];
    const _rest_0 = _enabled_0["tail"];
    return $trace$058flags_join$(run_clo((_x_0) => {
  return $trace$058flags$(_rest_0, _completion_0, _x_0);
}), ($trace$058snapshot$(_flag_0, _completion_0, _fixture_0)));
  }
}

function $consumer$058created$(_sibling_0, _creation_0) {
  if (_creation_0.$ === "../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    const _factory_0 = _creation_0["factory"];
    const _resource_0 = _creation_0["resource"];
    return {$: "consumer.NoWorld", "factory": _factory_0, "resource": _resource_0, "sibling": _sibling_0};
  } else {
    const _factory_1 = _creation_0["factory"];
    const _world_0 = _creation_0["world"];
    return $consumer$058install$(_factory_1, _world_0, _sibling_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$() {
  return {$: "../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": 1};
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

function $consumer$058step$(_action_0, _fixture_0) {
  if (_action_0.$ === "consumer.Publish") {
    const _fail_0 = _action_0["fail"];
    const _count_0 = _action_0["count"];
    if (_fixture_0.$ === "consumer.Fixture") {
      const _factory_0 = _fixture_0["factory"];
      const _publisher_0 = _fixture_0["publisher"];
      const _runtime_0 = _fixture_0["runtime"];
      const _first_0 = _fixture_0["first"];
      const _firstRegistry_0 = _fixture_0["firstRegistry"];
      const _slow_0 = _fixture_0["slow"];
      const _slowRegistry_0 = _fixture_0["slowRegistry"];
      const _second_0 = _fixture_0["second"];
      const _secondRegistry_0 = _fixture_0["secondRegistry"];
      return $consumer$058publish_runtime$(_fail_0, _count_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _runtime_0);
    } else {
      return {$: "Tuple", "fst": _fixture_0, "snd": {$: "consumer.SetupUnavailable"}};
    }
  } else if (_action_0.$ === "consumer.ReadFirst") {
    const _selected_0 = _action_0["slow"];
    const _fail_1 = _action_0["fail"];
    if (_fixture_0.$ === "consumer.Fixture") {
      const _factory_1 = _fixture_0["factory"];
      const _publisher_1 = _fixture_0["publisher"];
      const _runtime_1 = _fixture_0["runtime"];
      const _first_1 = _fixture_0["first"];
      const _firstRegistry_1 = _fixture_0["firstRegistry"];
      const _slow_1 = _fixture_0["slow"];
      const _slowRegistry_1 = _fixture_0["slowRegistry"];
      const _second_1 = _fixture_0["second"];
      const _secondRegistry_1 = _fixture_0["secondRegistry"];
      return $consumer$058read_selected$(_selected_0, _fail_1, _factory_1, _publisher_1, _runtime_1, _first_1, _firstRegistry_1, _slow_1, _slowRegistry_1, _second_1, _secondRegistry_1);
    } else {
      return {$: "Tuple", "fst": _fixture_0, "snd": {$: "consumer.SetupUnavailable"}};
    }
  } else if (_action_0.$ === "consumer.ReadSecond") {
    const _fail_2 = _action_0["fail"];
    if (_fixture_0.$ === "consumer.Fixture") {
      const _factory_2 = _fixture_0["factory"];
      const _publisher_2 = _fixture_0["publisher"];
      const _runtime_2 = _fixture_0["runtime"];
      const _first_2 = _fixture_0["first"];
      const _firstRegistry_2 = _fixture_0["firstRegistry"];
      const _slow_2 = _fixture_0["slow"];
      const _slowRegistry_2 = _fixture_0["slowRegistry"];
      const _second_2 = _fixture_0["second"];
      const _secondRegistry_2 = _fixture_0["secondRegistry"];
      return $consumer$058second_returned$(_factory_2, _publisher_2, _first_2, _firstRegistry_2, _slow_2, _slowRegistry_2, ($consumer$058run_second$(_runtime_2, _second_2, _secondRegistry_2, _fail_2)));
    } else {
      return {$: "Tuple", "fst": _fixture_0, "snd": {$: "consumer.SetupUnavailable"}};
    }
  } else {
    if (_fixture_0.$ === "consumer.Fixture") {
      const _factory_3 = _fixture_0["factory"];
      const _publisher_3 = _fixture_0["publisher"];
      const _runtime_3 = _fixture_0["runtime"];
      const _first_3 = _fixture_0["first"];
      const _firstRegistry_3 = _fixture_0["firstRegistry"];
      const _slow_3 = _fixture_0["slow"];
      const _slowRegistry_3 = _fixture_0["slowRegistry"];
      const _second_3 = _fixture_0["second"];
      const _secondRegistry_3 = _fixture_0["secondRegistry"];
      return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_3, "publisher": _publisher_3, "runtime": ($setup$058next_frame$(_runtime_3)), "first": _first_3, "firstRegistry": _firstRegistry_3, "slow": _slow_3, "slowRegistry": _slowRegistry_3, "second": _second_3, "secondRegistry": _secondRegistry_3}, "snd": {$: "consumer.Framed"}};
    } else {
      return {$: "Tuple", "fst": _fixture_0, "snd": {$: "consumer.SetupUnavailable"}};
    }
  }
}

function $trace$058framed_fixture$(_fixture_0) {
  return $trace$058frame_returned$(($consumer$058step$({$: "consumer.Frame"}, _fixture_0)));
}

function $trace$058flags_join$(_next_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _row_0 = _returned_0["snd"];
  return $trace$058prepend$(_row_0, _next_0(_fixture_0));
}

function $trace$058snapshot$(_enabled_0, _completion_0, _fixture_0) {
  if (_fixture_0.$ === "consumer.Fixture") {
    const _factory_0 = _fixture_0["factory"];
    const _publisher_0 = _fixture_0["publisher"];
    const _runtime_0 = _fixture_0["runtime"];
    const _first_0 = _fixture_0["first"];
    const _firstRegistry_0 = _fixture_0["firstRegistry"];
    const _slow_0 = _fixture_0["slow"];
    const _slowRegistry_0 = _fixture_0["slowRegistry"];
    const _second_0 = _fixture_0["second"];
    const _secondRegistry_0 = _fixture_0["secondRegistry"];
    return $trace$058snapshot_runtime$(_enabled_0, _completion_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, ($setup$058inspect$(_enabled_0, _runtime_0)));
  } else {
    return $trace$058snapshot_observed$(_enabled_0, {$: "None"}, _completion_0, ($observer$058fixture$(_fixture_0)));
  }
}

function $consumer$058install$(_factory_0, _world_0, _sibling_0) {
  return $consumer$058install_runtime$(_factory_0, ($setup$058setup$(_world_0, _sibling_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": ($types$058empty$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $consumer$058publish_runtime$(_fail_0, _count_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _runtime_0) {
  const _world_0 = _runtime_0["world"];
  const _state_0 = _runtime_0["family"];
  const _tick_0 = _runtime_0["tick"];
  return $consumer$058publish_domains$(_fail_0, _count_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _world_0, _tick_0, ($setup$058publisher_domains$(_state_0)));
}

function $consumer$058read_selected$(_slowSelected_0, _fail_0, _factory_0, _publisher_0, _runtime_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0) {
  if (!_slowSelected_0) {
    return $consumer$058first_returned$(_factory_0, _publisher_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, ($consumer$058run_first$(_runtime_0, _first_0, _firstRegistry_0, _fail_0)));
  } else {
    return $consumer$058slow_returned$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _second_0, _secondRegistry_0, ($consumer$058run_first$(_runtime_0, _slow_0, _slowRegistry_0, _fail_0)));
  }
}

function $consumer$058second_returned$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _returned_0) {
  const _runtime_0 = _returned_0["runtime"];
  const _second_0 = _returned_0["reader"];
  const _secondRegistry_0 = _returned_0["registry"];
  const _completion_0 = _returned_0["completion"];
  return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": ($consumer$058second_observation$(_completion_0))};
}

function $consumer$058run_second$(_runtime_0, _reader_0, _registry_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run$1261$(_runtime_0, _reader_0, _registry_0, _fail_0);
}

function $setup$058next_frame$(_runtime_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058frame$1260$(_runtime_0);
}

function $trace$058frame_returned$(_returned_0) {
  const _fixture_0 = _returned_0["fst"];
  return _fixture_0;
}

function $trace$058prepend$(_row_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _rest_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _fixture_0, "snd": {$: "Con", "head": _row_0, "tail": _rest_0}};
}

function $trace$058snapshot_runtime$(_enabled_0, _completion_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _returned_0) {
  const _runtime_0 = _returned_0["fst"];
  const _inventory_0 = _returned_0["snd"];
  return $trace$058snapshot_observed$(_enabled_0, _inventory_0, _completion_0, ($observer$058fixture$({$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0})));
}

function $setup$058inspect$(_enabled_0, _runtime_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_enabled$1260$(_enabled_0, _runtime_0);
}

function $trace$058snapshot_observed$(_enabled_0, _inventory_0, _completion_0, _returned_0) {
  const _fixture_0 = _returned_0["fst"];
  const _text_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _fixture_0, "snd": {$: "trace.Row", "enabled": _enabled_0, "inventory": _inventory_0, "completion": _completion_0, "physical": _text_0}};
}

function $observer$058fixture$(_value_0) {
  if (_value_0.$ === "consumer.Fixture") {
    const _factory_0 = _value_0["factory"];
    const _publisher_0 = _value_0["publisher"];
    const _runtime_0 = _value_0["runtime"];
    const _first_0 = _value_0["first"];
    const _firstRegistry_0 = _value_0["firstRegistry"];
    const _slow_0 = _value_0["slow"];
    const _slowRegistry_0 = _value_0["slowRegistry"];
    const _second_0 = _value_0["second"];
    const _secondRegistry_0 = _value_0["secondRegistry"];
    return $observer$058fixture_returned$(_factory_0, ($observer$058publisher_registry$(_publisher_0)), ($observer$058observe_runtime$(_runtime_0)), ($observer$058first_reader$(_first_0)), ($observer$058first_registry$(_firstRegistry_0)), ($observer$058first_reader$(_slow_0)), ($observer$058first_registry$(_slowRegistry_0)), ($observer$058second_reader$(_second_0)), ($observer$058second_registry$(_secondRegistry_0)));
  } else {
    return {$: "Tuple", "fst": _value_0, "snd": "SetupUnavailable"};
  }
}

function $consumer$058install_runtime$(_factory_0, _runtime_0) {
  const _world_0 = _runtime_0["world"];
  const _state_0 = _runtime_0["family"];
  return $consumer$058install_domains$(_factory_0, _world_0, ($setup$058publisher_domains$(_state_0)));
}

function $setup$058setup$(_world_0, _owners_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058setup$1260$(_world_0, ($setup$058provision$()), _owners_0, 65536);
}

function $types$058empty$(__0) {
  return [41];
}

function $consumer$058publish_domains$(_fail_0, _count_0, _factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _world_0, _tick_0, _returned_0) {
  const _state_0 = _returned_0["fst"];
  const _domains_0 = _returned_0["snd"];
  return $consumer$058publisher_returned$(_factory_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _state_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1262$(_publisher_0, _world_0, {$: "consumer.PublishRequest", "domains": _domains_0, "fail": _fail_0, "count": _count_0})));
}

function $setup$058publisher_domains$(_state_0) {
  return $setup$058first_domain_returned$(($setup$058take_first$(_state_0)));
}

function $consumer$058first_returned$(_factory_0, _publisher_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _returned_0) {
  const _runtime_0 = _returned_0["runtime"];
  const _first_0 = _returned_0["reader"];
  const _firstRegistry_0 = _returned_0["registry"];
  const _completion_0 = _returned_0["completion"];
  return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": ($consumer$058first_observation$(_completion_0))};
}

function $consumer$058run_first$(_runtime_0, _reader_0, _registry_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run$1260$(_runtime_0, _reader_0, _registry_0, _fail_0);
}

function $consumer$058slow_returned$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _second_0, _secondRegistry_0, _returned_0) {
  const _runtime_0 = _returned_0["runtime"];
  const _slow_0 = _returned_0["reader"];
  const _slowRegistry_0 = _returned_0["registry"];
  const _completion_0 = _returned_0["completion"];
  return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": ($consumer$058first_observation$(_completion_0))};
}

function $consumer$058second_observation$(_completion_0) {
  if (_completion_0.$ === "../../../../../../../../bendvy/src/ecs/event-runtime.Succeeded") {
    const _reading_0 = _completion_0["output"];
    return {$: "consumer.SecondRead", "reading": _reading_0, "failed": false};
  } else if (_completion_0.$ === "../../../../../../../../bendvy/src/ecs/event-runtime.Failed") {
    const _t_0 = _completion_0["error"];
    const _reading_1 = _t_0["reading"];
    return {$: "consumer.SecondRead", "reading": _reading_1, "failed": true};
  } else {
    return {$: "consumer.Rejected"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run$1261$(_runtime_0, _reader_0, _registry_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identified$1261$(_runtime_0, _reader_0, _args_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1261$(_registry_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058frame$1260$(_runtime_0) {
  const _world_0 = _runtime_0["world"];
  const _t_0 = _runtime_0["family"];
  const _family_0 = _t_0["family"];
  const _owners_0 = _t_0["owners"];
  const _journal_0 = _t_0["journal"];
  const _tick_0 = _runtime_0["tick"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058framed_journal$1260$(_world_0, _owners_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058retained_journal$1260$(_journal_0, ($setup$058frame$())(_family_0)(_tick_0))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_enabled$1260$(_enabled_0, _runtime_0) {
  if (!_enabled_0) {
    return {$: "Tuple", "fst": _runtime_0, "snd": {$: "None"}};
  } else {
    const _world_0 = _runtime_0["world"];
    const _t_0 = _runtime_0["family"];
    const _family_0 = _t_0["family"];
    const _owners_0 = _t_0["owners"];
    const _journal_0 = _t_0["journal"];
    const _frameStart_0 = _t_0["frameStart"];
    const _tick_0 = _runtime_0["tick"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_optional$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_returned$1260$(_world_0, _owners_0, _journal_0, _frameStart_0, _tick_0, ($setup$058inventory$())(_family_0))));
  }
}

function $observer$058fixture_returned$(_factory_0, _publisher_0, _runtime_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0) {
  const _nextNamespace_0 = _factory_0["nextNamespace"];
  const _publisher_1 = _publisher_0["fst"];
  const _publisherText_0 = _publisher_0["snd"];
  const _runtime_1 = _runtime_0["fst"];
  const _runtimeText_0 = _runtime_0["snd"];
  const _first_1 = _first_0["fst"];
  const _firstText_0 = _first_0["snd"];
  const _firstRegistry_1 = _firstRegistry_0["fst"];
  const _firstRegistryText_0 = _firstRegistry_0["snd"];
  const _slow_1 = _slow_0["fst"];
  const _slowText_0 = _slow_0["snd"];
  const _slowRegistry_1 = _slowRegistry_0["fst"];
  const _slowRegistryText_0 = _slowRegistry_0["snd"];
  const _second_1 = _second_0["fst"];
  const _secondText_0 = _second_0["snd"];
  const _secondRegistry_1 = _secondRegistry_0["fst"];
  const _secondRegistryText_0 = _secondRegistry_0["snd"];
  const _x_0 = (":" + _secondRegistryText_0);
  const _x_1 = (_secondText_0 + _x_0);
  const _x_2 = ("|secondReader=" + _x_1);
  const _x_3 = (_slowRegistryText_0 + _x_2);
  const _x_4 = (":" + _x_3);
  const _x_5 = (_slowText_0 + _x_4);
  const _x_6 = ("|slowReader=" + _x_5);
  const _x_7 = (_firstRegistryText_0 + _x_6);
  const _x_8 = (":" + _x_7);
  const _x_9 = (_firstText_0 + _x_8);
  const _x_10 = ("|firstReader=" + _x_9);
  const _x_11 = (_publisherText_0 + _x_10);
  const _x_12 = ("|publisher=" + _x_11);
  const _x_13 = (_runtimeText_0 + _x_12);
  const _x_14 = ($U32$show$(_nextNamespace_0));
  const _x_15 = ("|" + _x_13);
  const _x_16 = (_x_14 + _x_15);
  return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": {$: "../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _nextNamespace_0}, "publisher": _publisher_1, "runtime": _runtime_1, "first": _first_1, "firstRegistry": _firstRegistry_1, "slow": _slow_1, "slowRegistry": _slowRegistry_1, "second": _second_1, "secondRegistry": _secondRegistry_1}, "snd": ("factory=" + _x_16)};
}

function $observer$058publisher_registry$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _id_0 = _value_0["id"];
  const _name_0 = _value_0["name"];
  const _access_0 = _value_0["access"];
  const _cursor_0 = _value_0["cursor"];
  const _x_0 = ($U32$show$(_cursor_0));
  const _x_1 = ($List$show$12613$(_access_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = (":" + _x_3);
  const _x_5 = (_name_0 + _x_4);
  const _x_6 = ($U32$show$(_id_0));
  const _x_7 = (":" + _x_5);
  const _x_8 = (_x_6 + _x_7);
  const _x_9 = ($U32$show$(_namespace_0));
  const _x_10 = (":" + _x_8);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "snd": (_x_9 + _x_10)};
}

function $observer$058observe_runtime$(_value_0) {
  const _world_0 = _value_0["world"];
  const _state_0 = _value_0["family"];
  const _tick_0 = _value_0["tick"];
  return $observer$058runtime_returned$(_tick_0, ($observer$058observe_world$(_world_0)), ($observer$058observe_state$(_state_0)));
}

function $observer$058first_reader$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _id_0 = _value_0["id"];
  const _registryId_0 = _value_0["registryId"];
  const _x_0 = ($U32$show$(_registryId_0));
  const _x_1 = ($U32$show$(_id_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($U32$show$(_namespace_0));
  const _x_5 = (":" + _x_3);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, "snd": (_x_4 + _x_5)};
}

function $observer$058first_registry$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _id_0 = _value_0["id"];
  const _name_0 = _value_0["name"];
  const _access_0 = _value_0["access"];
  const _cursor_0 = _value_0["cursor"];
  const _x_0 = ($U32$show$(_cursor_0));
  const _x_1 = ($List$show$12613$(_access_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = (":" + _x_3);
  const _x_5 = (_name_0 + _x_4);
  const _x_6 = ($U32$show$(_id_0));
  const _x_7 = (":" + _x_5);
  const _x_8 = (_x_6 + _x_7);
  const _x_9 = ($U32$show$(_namespace_0));
  const _x_10 = (":" + _x_8);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "snd": (_x_9 + _x_10)};
}

function $observer$058second_reader$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _id_0 = _value_0["id"];
  const _registryId_0 = _value_0["registryId"];
  const _x_0 = ($U32$show$(_registryId_0));
  const _x_1 = ($U32$show$(_id_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($U32$show$(_namespace_0));
  const _x_5 = (":" + _x_3);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, "snd": (_x_4 + _x_5)};
}

function $observer$058second_registry$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _id_0 = _value_0["id"];
  const _name_0 = _value_0["name"];
  const _access_0 = _value_0["access"];
  const _cursor_0 = _value_0["cursor"];
  const _x_0 = ($U32$show$(_cursor_0));
  const _x_1 = ($List$show$12613$(_access_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = (":" + _x_3);
  const _x_5 = (_name_0 + _x_4);
  const _x_6 = ($U32$show$(_id_0));
  const _x_7 = (":" + _x_5);
  const _x_8 = (_x_6 + _x_7);
  const _x_9 = ($U32$show$(_namespace_0));
  const _x_10 = (":" + _x_8);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "snd": (_x_9 + _x_10)};
}

function $consumer$058install_domains$(_factory_0, _world_0, _returned_0) {
  const _state_0 = _returned_0["fst"];
  const _domains_0 = _returned_0["snd"];
  return $consumer$058publisher_registered$(_factory_0, _state_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1262$(_world_0, "publisher", ($setup$058publisher_access$(_domains_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058setup$1260$(_world_0, _provision_0, _owners_0, _capacity_0) {
  const _domains_0 = _provision_0["domains"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": ($setup$058make$())(_domains_0)(_capacity_0), "owners": _owners_0, "journal": {$: "Nil"}, "frameStart": 0}, "tick": 0};
}

function $setup$058provision$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058branch$1261$(($setup$058pair_provision$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1262$("Unused")))));
}

function $consumer$058publisher_returned$(_factory_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _state_0, _tick_0, _returned_0) {
  if (_returned_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected") {
    const _publisher_0 = _returned_0["registry"];
    const _world_0 = _returned_0["world"];
    return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _state_0, "tick": _tick_0}, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": {$: "consumer.Rejected"}};
  } else {
    const _publisher_1 = _returned_0["registry"];
    const _outcome_0 = _returned_0["outcome"];
    return $consumer$058publisher_outcome$(_factory_0, _publisher_1, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _state_0, _tick_0, _outcome_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1262$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1262$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $setup$058first_domain_returned$(_returned_0) {
  const _state_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return $setup$058second_domain_returned$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058domain$1261$(_stream_0)), ($setup$058take_second$(_state_0)));
}

function $setup$058take_first$(_state_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058take$1260$(_state_0);
}

function $consumer$058first_observation$(_completion_0) {
  if (_completion_0.$ === "../../../../../../../../bendvy/src/ecs/event-runtime.Succeeded") {
    const _reading_0 = _completion_0["output"];
    return {$: "consumer.FirstRead", "reading": _reading_0, "failed": false};
  } else if (_completion_0.$ === "../../../../../../../../bendvy/src/ecs/event-runtime.Failed") {
    const _t_0 = _completion_0["error"];
    const _reading_1 = _t_0["reading"];
    return {$: "consumer.FirstRead", "reading": _reading_1, "failed": true};
  } else {
    return {$: "consumer.Rejected"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run$1260$(_runtime_0, _reader_0, _registry_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identified$1260$(_runtime_0, _reader_0, _args_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1260$(_registry_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identified$1261$(_runtime_0, _reader_0, _args_0, _identified_0) {
  const _world_0 = _runtime_0["world"];
  const _family_0 = _runtime_0["family"];
  const _tick_0 = _runtime_0["tick"];
  const _registry_0 = _identified_0["fst"];
  const _actual_0 = _identified_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identity$1261$(_family_0, _tick_0, _args_0, _reader_0, _registry_0, _actual_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1261$(_registry_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "snd": _id_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058framed_journal$1260$(_world_0, _owners_0, _tick_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _journal_0 = _returned_0["snd"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058events_replace$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058values$1260$(_journal_0)))), "family": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": _family_0, "owners": _owners_0, "journal": _journal_0, "frameStart": _tick_0}, "tick": _tick_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058retained_journal$1260$(_journal_0, _family_0) {
  if (_journal_0.$ === "Nil") {
    return {$: "Tuple", "fst": _family_0, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _journal_0["head"];
    const _tick_0 = _t_0["tick"];
    const _records_0 = _t_0["values"];
    const _rest_0 = _journal_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch_head$1260$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058retained_journal$1260$(_rest_0, _x_0);
}), _tick_0, ($setup$058retain$())(_family_0)(_tick_0)(_records_0));
  }
}

function $setup$058frame$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_frame$1261$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_optional$1260$(_returned_0) {
  const _runtime_0 = _returned_0["fst"];
  const _names_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _runtime_0, "snd": {$: "Some", "value": _names_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058inventory_returned$1260$(_world_0, _owners_0, _journal_0, _frameStart_0, _tick_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _names_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": _family_0, "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0}, "tick": _tick_0}, "snd": _names_0};
}

function $setup$058inventory$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory$1261$(_x_0);
});
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $List$show$12613$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058text$(_h_0));
    const _x_1 = ($List$show$go$12613$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $observer$058runtime_returned$(_tick_0, _observedWorld_0, _observedState_0) {
  const _world_0 = _observedWorld_0["fst"];
  const _worldText_0 = _observedWorld_0["snd"];
  const _state_0 = _observedState_0["fst"];
  const _stateText_0 = _observedState_0["snd"];
  const _x_0 = ("|" + _stateText_0);
  const _x_1 = (_worldText_0 + _x_0);
  const _x_2 = ($Nat$show$(_tick_0));
  const _x_3 = ("|" + _x_1);
  const _x_4 = (_x_2 + _x_3);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _state_0, "tick": _tick_0}, "snd": ("tick=" + _x_4)};
}

function $observer$058observe_world$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _nextId_0 = _value_0["nextId"];
  const _highWater_0 = _value_0["highWater"];
  const _live_0 = _value_0["live"];
  const _capacity_0 = _value_0["capacity"];
  const _depth_0 = _value_0["depth"];
  const _store_0 = _value_0["store"];
  const _resource_0 = _value_0["resource"];
  const _events_0 = _value_0["events"];
  const _pending_0 = _value_0["pending"];
  const _registrations_0 = _value_0["registrations"];
  const _nextSystemId_0 = _value_0["nextSystemId"];
  const _clock_0 = _value_0["clock"];
  return $observer$058world_returned$(_namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_array$(_live_0)), ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_array$(_store_0)), ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_array$(_resource_0)), ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058callbacks$1260$(_pending_0)));
}

function $observer$058observe_state$(_value_0) {
  const _t_0 = _value_0["family"];
  const _t_1 = _t_0["left"];
  const _first_0 = _t_1["left"];
  const _second_0 = _t_1["right"];
  const _unusedLeaf_0 = _t_0["right"];
  const _owners_0 = _value_0["owners"];
  const _journal_0 = _value_0["journal"];
  const _frameStart_0 = _value_0["frameStart"];
  return $observer$058state_returned$(_first_0, _second_0, _unusedLeaf_0, _journal_0, _frameStart_0, ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_array$(_owners_0)));
}

function $consumer$058publisher_registered$(_factory_0, _state_0, _registered_0) {
  if (_registered_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed") {
    const _world_0 = _registered_0["world"];
    return {$: "consumer.NoPublisher", "factory": _factory_0, "world": _world_0, "state": _state_0};
  } else {
    const _world_1 = _registered_0["world"];
    const _publisher_0 = _registered_0["registry"];
    return $consumer$058first$(_factory_0, _publisher_0, ($consumer$058register_first$({$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_1, "family": _state_0, "tick": 0}, "first")));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1262$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $setup$058publisher_access$(_domains_0) {
  const _first_0 = _domains_0["first"];
  const _second_0 = _domains_0["second"];
  return {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write$1260$(_first_0)))), "tail": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write$1261$(_second_0)))), "tail": {$: "Nil"}}};
}

function $setup$058make$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_make$1261$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058branch$1261$(_first_0, _second_0) {
  const _first_1 = _first_0["domains"];
  const _second_1 = _second_0["domains"];
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Provision", "domains": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Domains", "first": _first_1, "second": _second_1}};
}

function $setup$058pair_provision$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058branch$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1260$("First")))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1261$("Second")))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1262$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Provision", "domains": _domain_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1262$(_key_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Domain", "key": _key_0};
}

function $consumer$058publisher_outcome$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _state_0, _tick_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _state_0, "tick": nat_chk(_tick_0 + 1)}, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": {$: "consumer.Published", "failed": true}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _t_0 = _outcome_0["output"];
    return $consumer$058publisher_synced$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, nat_chk(_tick_0 + 1), ($consumer$058synchronize$(_world_1, _state_0, nat_chk(_tick_0 + 1))));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1262$(_registry_0, _named_0, _args_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1262$(_registry_0, _world_0, _actual_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _namespace_0};
}

function $setup$058second_domain_returned$(_first_0, _returned_0) {
  const _state_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _state_0, "snd": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Domains", "first": _first_0, "second": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058domain$1260$(_stream_0))}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058domain$1261$(_stream_0) {
  const _domain_0 = _stream_0["domain"];
  return _domain_0;
}

function $setup$058take_second$(_state_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058take$1261$(_state_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058take$1260$(_state_0) {
  const _family_0 = _state_0["family"];
  const _owners_0 = _state_0["owners"];
  const _journal_0 = _state_0["journal"];
  const _frameStart_0 = _state_0["frameStart"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058selected_state$1260$(_owners_0, _journal_0, _frameStart_0, ($setup$058first_family_take$())(_family_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identified$1260$(_runtime_0, _reader_0, _args_0, _identified_0) {
  const _world_0 = _runtime_0["world"];
  const _family_0 = _runtime_0["family"];
  const _tick_0 = _runtime_0["tick"];
  const _registry_0 = _identified_0["fst"];
  const _actual_0 = _identified_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identity$1260$(_family_0, _tick_0, _args_0, _reader_0, _registry_0, _actual_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1260$(_registry_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "snd": _id_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identity$1261$(_family_0, _tick_0, _args_0, _reader_0, _registry_0, _actual_0, _named_0) {
  const _namespace_0 = _reader_0["namespace"];
  const _id_0 = _reader_0["id"];
  const _registryId_0 = _reader_0["registryId"];
  const _world_0 = _named_0["fst"];
  const _actualNamespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_checked$1261$(($Bool$and$((_namespace_0 === _actualNamespace_0), (_registryId_0 === _actual_0))), _world_0, _family_0, {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, _registry_0, _id_0, _tick_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058events_replace$1260$(_world_0, _retained_0) {
  const _namespace_0 = _world_0["namespace"];
  const _nextId_0 = _world_0["nextId"];
  const _highWater_0 = _world_0["highWater"];
  const _live_0 = _world_0["live"];
  const _capacity_0 = _world_0["capacity"];
  const _depth_0 = _world_0["depth"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _retained_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058values$1260$(_batches_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _batches_0["head"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$12610$(_items_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058values$1260$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch_head$1260$(_rest_0, _tick_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _records_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch_returned$1260$(_tick_0, _records_0, _rest_0(_family_0));
}

function $setup$058retain$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain$1261$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_frame$1261$(_family_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_frame$1261$(_family_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory$1261$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory_join$1261$(($setup$058inventory_pair$())(_first_0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1262$(_second_0)));
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $observer$058text$(_value_0) {
  return _value_0;
}

function $List$show$go$12613$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058text$(_h_0));
    const _x_1 = ($List$show$go$12613$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
}

function $observer$058world_returned$(_namespace_0, _nextId_0, _highWater_0, _capacity_0, _depth_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _live_0, _store_0, _resource_0, _pending_0) {
  const _live_1 = _live_0["fst"];
  const _liveText_0 = _live_0["snd"];
  const _store_1 = _store_0["fst"];
  const _storeText_0 = _store_0["snd"];
  const _resource_1 = _resource_0["fst"];
  const _resourceText_0 = _resource_0["snd"];
  const _pending_1 = _pending_0["fst"];
  const _count_0 = _pending_0["snd"];
  const _x_0 = ($U32$show$(_clock_0));
  const _x_1 = ($U32$show$(_nextSystemId_0));
  const _x_2 = ("|clock=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($List$show$1267$(_registrations_0));
  const _x_5 = ("|nextSystem=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_count_0));
  const _x_8 = ("|registrations=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($List$show$1266$(_events_0));
  const _x_11 = ("|pending=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ("|events=" + _x_12);
  const _x_14 = (_resourceText_0 + _x_13);
  const _x_15 = ("|resource=" + _x_14);
  const _x_16 = (_storeText_0 + _x_15);
  const _x_17 = ($Nat$show$(_depth_0));
  const _x_18 = ("|store=" + _x_16);
  const _x_19 = (_x_17 + _x_18);
  const _x_20 = ($U32$show$(_capacity_0));
  const _x_21 = ("|depth=" + _x_19);
  const _x_22 = (_x_20 + _x_21);
  const _x_23 = ("|capacity=" + _x_22);
  const _x_24 = (_liveText_0 + _x_23);
  const _x_25 = ($U32$show$(_highWater_0));
  const _x_26 = ("|live=" + _x_24);
  const _x_27 = (_x_25 + _x_26);
  const _x_28 = ($U32$show$(_nextId_0));
  const _x_29 = ("|high=" + _x_27);
  const _x_30 = (_x_28 + _x_29);
  const _x_31 = ($U32$show$(_namespace_0));
  const _x_32 = ("|next=" + _x_30);
  const _x_33 = (_x_31 + _x_32);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": _store_1, "resource": _resource_1, "events": _events_0, "pending": _pending_1, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ("ns=" + _x_33)};
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_array$(_value_0) {
  return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1261$(_value_0);
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_array$(_value_0) {
  return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1260$(_value_0);
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058callbacks$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _head_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058callbacks_join$1260$(_head_0, ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058callbacks$1260$(_rest_0)));
  }
}

function $observer$058state_returned$(_first_0, _second_0, _unusedLeaf_0, _journal_0, _frameStart_0, _observed_0) {
  const _owners_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  const _x_0 = ($Nat$show$(_frameStart_0));
  const _x_1 = ($List$show$12612$(_journal_0));
  const _x_2 = ("|frameStart=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ("|journal=" + _x_3);
  const _x_5 = (_text_0 + _x_4);
  const _x_6 = ($observer$058stream$1262$(_unusedLeaf_0));
  const _x_7 = ("}|sibling=" + _x_5);
  const _x_8 = (_x_6 + _x_7);
  const _x_9 = ($observer$058stream$1261$(_second_0));
  const _x_10 = ("}|unused{" + _x_8);
  const _x_11 = (_x_9 + _x_10);
  const _x_12 = ($observer$058stream$1260$(_first_0));
  const _x_13 = ("}|second{" + _x_11);
  const _x_14 = (_x_12 + _x_13);
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": _second_0}, "right": _unusedLeaf_0}, "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0}, "snd": ("first{" + _x_14)};
}

function $consumer$058first$(_factory_0, _publisher_0, _registered_0) {
  if (_registered_0.$ === "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed") {
    const _runtime_0 = _registered_0["runtime"];
    return {$: "consumer.NoFirst", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0};
  } else {
    const _runtime_1 = _registered_0["runtime"];
    const _reader_0 = _registered_0["reader"];
    const _registry_0 = _registered_0["registry"];
    return $consumer$058second$(_factory_0, _publisher_0, _reader_0, _registry_0, ($consumer$058register_first$(_runtime_1, "slow")));
  }
}

function $consumer$058register_first$(_runtime_0, _name_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058register$1260$(_runtime_0, _name_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1262$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1260$(_declaration_0) {
  const _t_0 = _declaration_0["domain"];
  const _key_0 = _t_0["key"];
  const _t_1 = _declaration_0["mode"];
  if (_t_1.$ === "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read") {
    return $String$concat$({$: "Con", "head": _key_0, "tail": {$: "Con", "head": ":read", "tail": {$: "Nil"}}});
  } else {
    return $String$concat$({$: "Con", "head": _key_0, "tail": {$: "Con", "head": ":write", "tail": {$: "Nil"}}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write$1260$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": _domain_0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Write"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1261$(_declaration_0) {
  const _t_0 = _declaration_0["domain"];
  const _key_0 = _t_0["key"];
  const _t_1 = _declaration_0["mode"];
  if (_t_1.$ === "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read") {
    return $String$concat$({$: "Con", "head": _key_0, "tail": {$: "Con", "head": ":read", "tail": {$: "Nil"}}});
  } else {
    return $String$concat$({$: "Con", "head": _key_0, "tail": {$: "Con", "head": ":write", "tail": {$: "Nil"}}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write$1261$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": _domain_0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Write"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_make$1261$(_domains_0, _capacity_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_make$1261$(_domains_0, _capacity_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058branch$1260$(_first_0, _second_0) {
  const _first_1 = _first_0["domains"];
  const _second_1 = _second_0["domains"];
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Provision", "domains": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Domains", "first": _first_1, "second": _second_1}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1260$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Provision", "domains": _domain_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1260$(_key_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Domain", "key": _key_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf$1261$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-family.Provision", "domains": _domain_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058domain$1261$(_key_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Domain", "key": _key_0};
}

function $consumer$058publisher_synced$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _second_0, _secondRegistry_0, _tick_0, _returned_0) {
  const _world_0 = _returned_0["fst"];
  const _state_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _state_0, "tick": _tick_0}, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0}, "snd": {$: "consumer.Published", "failed": false}};
}

function $consumer$058synchronize$(_world_0, _state_0, _tick_0) {
  return $setup$058synchronize$(_world_0, _state_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1262$(_registry_0, _world_0, _actual_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1262$((_namespace_0 === _actual_0), {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058domain$1260$(_stream_0) {
  const _domain_0 = _stream_0["domain"];
  return _domain_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058take$1261$(_state_0) {
  const _family_0 = _state_0["family"];
  const _owners_0 = _state_0["owners"];
  const _journal_0 = _state_0["journal"];
  const _frameStart_0 = _state_0["frameStart"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058selected_state$1261$(_owners_0, _journal_0, _frameStart_0, ($setup$058second_family_take$())(_family_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058selected_state$1260$(_owners_0, _journal_0, _frameStart_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": _family_0, "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0}, "snd": _stream_0};
}

function $setup$058first_family_take$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1260$(_x_0);
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_identity$1260$(_family_0, _tick_0, _args_0, _reader_0, _registry_0, _actual_0, _named_0) {
  const _namespace_0 = _reader_0["namespace"];
  const _id_0 = _reader_0["id"];
  const _registryId_0 = _reader_0["registryId"];
  const _world_0 = _named_0["fst"];
  const _actualNamespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_checked$1260$(($Bool$and$((_namespace_0 === _actualNamespace_0), (_registryId_0 === _actual_0))), _world_0, _family_0, {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, _registry_0, _id_0, _tick_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_checked$1261$(_allowed_0, _world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _family_0, "tick": _tick_0}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Rejected", "args": _args_0}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf$1261$(_world_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, ($consumer$058take_second$(_family_0)));
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$12610$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$12610$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch_returned$1260$(_tick_0, _records_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _journal_0 = _returned_0["snd"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1265$(_records_0));
  return {$: "Tuple", "fst": _family_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch$1260$((0 < _x_0), _tick_0, _records_0, _journal_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain$1261$(_family_0, _tick_0, _records_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1261$(_records_0, _family_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_frame$1261$(_family_0, _tick_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($setup$058frame_pair$())(_first_0)(_tick_0), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1262$(_second_0, _tick_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory_join$1261$(_first_0, _second_0) {
  const _first_1 = _first_0["fst"];
  const _firstNames_0 = _first_0["snd"];
  const _second_1 = _second_0["fst"];
  const _secondNames_0 = _second_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_1, "right": _second_1}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1265$(_firstNames_0, _secondNames_0))};
}

function $setup$058inventory_pair$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory$1260$(_x_0);
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1262$(_stream_0) {
  const _retained_0 = _stream_0;
  return {$: "Tuple", "fst": _retained_0, "snd": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1262$(_retained_0)), "tail": {$: "Nil"}}};
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

function $List$show$1266$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058event$(_h_0));
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
    const _x_0 = ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058registration$(_h_0));
    const _x_1 = ($List$show$go$1267$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1261$(_value_0) {
  if (_value_0.length === 1) {
    const _value_1 = _value_0[0];
    return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058leaf$1261$(($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_value$(_value_1)));
  } else {
    const _left_0 = _value_0.slice(0, _value_0.length >> 1);
    const _right_0 = _value_0.slice(_value_0.length >> 1);
    return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058node_join$1261$(($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1261$(_left_0)), ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1261$(_right_0)));
  }
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1260$(_value_0) {
  if (_value_0.length === 1) {
    const _value_1 = _value_0[0];
    return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058leaf$1260$(($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_value$(_value_1)));
  } else {
    const _left_0 = _value_0.slice(0, _value_0.length >> 1);
    const _right_0 = _value_0.slice(_value_0.length >> 1);
    return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058node_join$1260$(($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1260$(_left_0)), ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058array$1260$(_right_0)));
  }
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058callbacks_join$1260$(_head_0, _observed_0) {
  const _rest_0 = _observed_0["fst"];
  const _count_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _head_0, "tail": _rest_0}, "snd": nat_chk(_count_0 + 1)};
}

function $observer$058stream$1260$(_value_0) {
  const _domain_0 = _value_0["domain"];
  const _batches_0 = _value_0["batches"];
  const _positions_0 = _value_0["positions"];
  const _nextReader_0 = _value_0["nextReader"];
  const _frameStart_0 = _value_0["frameStart"];
  const _boundary_0 = _value_0["boundary"];
  const _capacity_0 = _value_0["capacity"];
  const _dropped_0 = _value_0["dropped"];
  const _x_0 = ($Nat$show$(_dropped_0));
  const _x_1 = ($Nat$show$(_capacity_0));
  const _x_2 = ("|dropped=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($Nat$show$(_boundary_0));
  const _x_5 = ("|capacity=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_frameStart_0));
  const _x_8 = ("|boundary=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($U32$show$(_nextReader_0));
  const _x_11 = ("|frame=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($List$show$1269$(_positions_0));
  const _x_14 = ("|nextReader=" + _x_12);
  const _x_15 = (_x_13 + _x_14);
  const _x_16 = ($List$show$1268$(_batches_0));
  const _x_17 = ("|positions=" + _x_15);
  const _x_18 = (_x_16 + _x_17);
  const _x_19 = ($observer$058domain_key$1260$(_domain_0));
  const _x_20 = ("|batches=" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  return ("domain=" + _x_21);
}

function $observer$058stream$1261$(_value_0) {
  const _domain_0 = _value_0["domain"];
  const _batches_0 = _value_0["batches"];
  const _positions_0 = _value_0["positions"];
  const _nextReader_0 = _value_0["nextReader"];
  const _frameStart_0 = _value_0["frameStart"];
  const _boundary_0 = _value_0["boundary"];
  const _capacity_0 = _value_0["capacity"];
  const _dropped_0 = _value_0["dropped"];
  const _x_0 = ($Nat$show$(_dropped_0));
  const _x_1 = ($Nat$show$(_capacity_0));
  const _x_2 = ("|dropped=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($Nat$show$(_boundary_0));
  const _x_5 = ("|capacity=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_frameStart_0));
  const _x_8 = ("|boundary=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($U32$show$(_nextReader_0));
  const _x_11 = ("|frame=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($List$show$1269$(_positions_0));
  const _x_14 = ("|nextReader=" + _x_12);
  const _x_15 = (_x_13 + _x_14);
  const _x_16 = ($List$show$12610$(_batches_0));
  const _x_17 = ("|positions=" + _x_15);
  const _x_18 = (_x_16 + _x_17);
  const _x_19 = ($observer$058domain_key$1261$(_domain_0));
  const _x_20 = ("|batches=" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  return ("domain=" + _x_21);
}

function $observer$058stream$1262$(_value_0) {
  const _domain_0 = _value_0["domain"];
  const _batches_0 = _value_0["batches"];
  const _positions_0 = _value_0["positions"];
  const _nextReader_0 = _value_0["nextReader"];
  const _frameStart_0 = _value_0["frameStart"];
  const _boundary_0 = _value_0["boundary"];
  const _capacity_0 = _value_0["capacity"];
  const _dropped_0 = _value_0["dropped"];
  const _x_0 = ($Nat$show$(_dropped_0));
  const _x_1 = ($Nat$show$(_capacity_0));
  const _x_2 = ("|dropped=" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($Nat$show$(_boundary_0));
  const _x_5 = ("|capacity=" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($Nat$show$(_frameStart_0));
  const _x_8 = ("|boundary=" + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($U32$show$(_nextReader_0));
  const _x_11 = ("|frame=" + _x_9);
  const _x_12 = (_x_10 + _x_11);
  const _x_13 = ($List$show$1269$(_positions_0));
  const _x_14 = ("|nextReader=" + _x_12);
  const _x_15 = (_x_13 + _x_14);
  const _x_16 = ($List$show$12611$(_batches_0));
  const _x_17 = ("|positions=" + _x_15);
  const _x_18 = (_x_16 + _x_17);
  const _x_19 = ($observer$058domain_key$1262$(_domain_0));
  const _x_20 = ("|batches=" + _x_18);
  const _x_21 = (_x_19 + _x_20);
  return ("domain=" + _x_21);
}

function $List$show$12612$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1263$(_h_0));
    const _x_1 = ($List$show$go$12612$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $consumer$058second$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _registered_0) {
  if (_registered_0.$ === "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed") {
    const _runtime_0 = _registered_0["runtime"];
    return {$: "consumer.NoSlow", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0};
  } else {
    const _runtime_1 = _registered_0["runtime"];
    const _slow_0 = _registered_0["reader"];
    const _slowRegistry_0 = _registered_0["registry"];
    return $consumer$058third$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, ($consumer$058register_second$(_runtime_1, "second")));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058register$1260$(_runtime_0, _name_0) {
  const _world_0 = _runtime_0["world"];
  const _family_0 = _runtime_0["family"];
  const _tick_0 = _runtime_0["tick"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_leaf$1260$(_world_0, _tick_0, _name_0, ($consumer$058take_first$(_family_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1262$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1262$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register_checked$1260$((_nextSystemId_0 < 4294967295), {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _name_0, _access_0);
}

function $String$concat$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($String$concat$(_t_0));
    return (_h_0 + _x_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_make$1261$(_domains_0, _capacity_0) {
  const _first_0 = _domains_0["first"];
  const _second_0 = _domains_0["second"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($setup$058make_pair$())(_first_0)(_capacity_0), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1262$(_second_0, _capacity_0))};
}

function $setup$058synchronize$(_world_0, _state_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058synchronize$1260$(_world_0, _state_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1262$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    const _cursor_0 = _registry_0["cursor"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1262$({$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058selected_state$1261$(_owners_0, _journal_0, _frameStart_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": _family_0, "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0}, "snd": _stream_0};
}

function $setup$058second_family_take$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1262$(_x_0);
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1260$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1260$(_second_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1261$(_first_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_checked$1260$(_allowed_0, _world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _family_0, "tick": _tick_0}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Rejected", "args": _args_0}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf$1260$(_world_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, ($consumer$058take_first$(_family_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf$1261$(_world_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf_reading$1261$(_world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058reading$1260$(_stream_0, _id_0, _tick_0)));
}

function $consumer$058take_second$(_state_0) {
  return $setup$058take_second$(_state_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$12610$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058kept_batch$1260$(_keep_0, _tick_0, _records_0, _journal_0) {
  if (!_keep_0) {
    return _journal_0;
  } else {
    return {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _records_0}, "tail": _journal_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1265$(_items_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1265$(_items_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1261$(_records_0, _family_0, _tick_0) {
  if (_records_0.$ === "Nil") {
    return {$: "Tuple", "fst": _family_0, "snd": {$: "Nil"}};
  } else {
    const _record_0 = _records_0["head"];
    const _rest_0 = _records_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_record$1261$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1261$(_rest_0, _x_0, _tick_0);
}), _tick_0, _record_0, _family_0);
  }
}

function $setup$058frame_pair$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_frame$1260$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1262$(_stream_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1262$(_stream_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1265$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1265$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory$1260$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1260$(_first_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1261$(_second_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1262$(_stream_0) {
  const _t_0 = _stream_0["domain"];
  const _key_0 = _t_0["key"];
  return _key_0;
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

function $observer$058event$(_value_0) {
  const _a_0 = _value_0["first"];
  const _b_0 = _value_0["second"];
  const _x_0 = ($List$show$1265$(_b_0));
  const _x_1 = (_x_0 + ")");
  const _x_2 = ($List$show$1264$(_a_0));
  const _x_3 = ("," + _x_1);
  const _x_4 = (_x_2 + _x_3);
  return ("record(" + _x_4);
}

function $List$show$go$1266$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058event$(_h_0));
    const _x_1 = ($List$show$go$1266$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058registration$(_value_0) {
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

function $List$show$go$1267$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058registration$(_h_0));
    const _x_1 = ($List$show$go$1267$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058leaf$1261$(_observed_0) {
  const _value_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": [_value_0], "snd": ("leaf:" + _text_0)};
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_value$(_value_0) {
  return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_data$(_value_0);
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058node_join$1261$(_leftObserved_0, _rightObserved_0) {
  const _left_0 = _leftObserved_0["fst"];
  const _text_0 = _leftObserved_0["snd"];
  const _right_0 = _rightObserved_0["fst"];
  const _other_0 = _rightObserved_0["snd"];
  const _x_0 = (_other_0 + ")");
  const _x_1 = ("," + _x_0);
  const _x_2 = (_text_0 + _x_1);
  return {$: "Tuple", "fst": array_node(_left_0, _right_0), "snd": ("node(" + _x_2)};
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058leaf$1260$(_observed_0) {
  const _value_0 = _observed_0["fst"];
  const _text_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": [_value_0], "snd": ("leaf:" + _text_0)};
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_value$(_value_0) {
  return $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_data$(_value_0);
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058node_join$1260$(_leftObserved_0, _rightObserved_0) {
  const _left_0 = _leftObserved_0["fst"];
  const _text_0 = _leftObserved_0["snd"];
  const _right_0 = _rightObserved_0["fst"];
  const _other_0 = _rightObserved_0["snd"];
  const _x_0 = (_other_0 + ")");
  const _x_1 = ("," + _x_0);
  const _x_2 = (_text_0 + _x_1);
  return {$: "Tuple", "fst": array_node(_left_0, _right_0), "snd": ("node(" + _x_2)};
}

function $observer$058domain_key$1260$(_value_0) {
  const _key_0 = _value_0["key"];
  return _key_0;
}

function $List$show$1268$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1260$(_h_0));
    const _x_1 = ($List$show$go$1268$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1269$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058position$(_h_0));
    const _x_1 = ($List$show$go$1269$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $observer$058domain_key$1261$(_value_0) {
  const _key_0 = _value_0["key"];
  return _key_0;
}

function $List$show$12610$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1261$(_h_0));
    const _x_1 = ($List$show$go$12610$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $observer$058domain_key$1262$(_value_0) {
  const _key_0 = _value_0["key"];
  return _key_0;
}

function $List$show$12611$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1262$(_h_0));
    const _x_1 = ($List$show$go$12611$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $observer$058batch$1263$(_value_0) {
  const _tick_0 = _value_0["tick"];
  const _values_0 = _value_0["values"];
  const _x_0 = ($List$show$1266$(_values_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$12612$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1263$(_h_0));
    const _x_1 = ($List$show$go$12612$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $consumer$058third$(_factory_0, _publisher_0, _first_0, _firstRegistry_0, _slow_0, _slowRegistry_0, _registered_0) {
  if (_registered_0.$ === "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed") {
    const _runtime_0 = _registered_0["runtime"];
    return {$: "consumer.NoSecond", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_0, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0};
  } else {
    const _runtime_1 = _registered_0["runtime"];
    const _second_0 = _registered_0["reader"];
    const _secondRegistry_0 = _registered_0["registry"];
    return {$: "consumer.Fixture", "factory": _factory_0, "publisher": _publisher_0, "runtime": _runtime_1, "first": _first_0, "firstRegistry": _firstRegistry_0, "slow": _slow_0, "slowRegistry": _slowRegistry_0, "second": _second_0, "secondRegistry": _secondRegistry_0};
  }
}

function $consumer$058register_second$(_runtime_0, _name_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058register$1261$(_runtime_0, _name_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_leaf$1260$(_world_0, _tick_0, _name_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_named$1260$(_family_0, _stream_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_declaration$1260$(_stream_0)), _name_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $consumer$058take_first$(_state_0) {
  return $setup$058take_first$(_state_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1262$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/world.RegistrationRejected") {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../../../../../../bendvy/src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register_checked$1260$(_available_0, _world_0, _name_0, _access_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../bendvy/src/ecs/world.RegistrationRejected", "error": {$: "../../../../../../../../bendvy/src/ecs/world.SystemIdExhausted"}}};
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
    return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/world.RegistrationMeta", "id": _nextSystemId_0, "name": _name_0, "access": _access_0}, "tail": _registrations_0}, "nextSystemId": ((_nextSystemId_0 + 1) >>> 0), "clock": _clock_0}, "snd": {$: "../../../../../../../../bendvy/src/ecs/world.Registered", "id": _nextSystemId_0}};
  }
}

function $setup$058make_pair$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_make$1260$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1262$(_domain_0, _capacity_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1262$(_domain_0, _capacity_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058synchronize$1260$(_world_0, _state_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058synchronize_world$1260$(_state_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058events_view$1261$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1262$(_registry_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1262$(_allowed_0, _registry_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1262$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1262$(_second_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058right_take$1260$(_first_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1260$(_second_0, _returned_0) {
  const _first_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": _second_0}, "snd": _stream_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_take$1261$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1261$(_second_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_leaf$1260$(_first_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf$1260$(_world_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf_reading$1260$(_world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058reading$1261$(_stream_0, _id_0, _tick_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf_reading$1261$(_world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _returned_0) {
  const _stream_0 = _returned_0["fst"];
  const _reading_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_reading$1261$(_world_0, _family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _reading_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058reading$1260$(_stream_0, _id_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_position$1260$({$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, _id_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0)));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1265$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _acc_0 = $1;
      if (_items_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _rest_0 = _items_0["tail"];
        $0 = _rest_0;
        $1 = nat_chk(_acc_0 + 1);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_record$1261$(_rest_0, _tick_0, _record_0, _family_0) {
  const _a_0 = _record_0["first"];
  const _b_0 = _record_0["second"];
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_children$1261$(_rest_0, ($setup$058retain_pair$())(_first_0)(_tick_0)(_a_0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1262$(_second_0, _tick_0, _b_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_frame$1260$(_family_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_frame$1260$(_family_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1262$(_stream_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1262$(_domain_0, _positions_0, _nextReader_0, _tick_0, _frameStart_0, _capacity_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1262$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1262$(_batches_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058hold_boundary$(_positions_0, _frameStart_0)), _dropped_0)), _capacity_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1265$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_inventory_join$1260$(_first_0, _second_0) {
  const _first_1 = _first_0["fst"];
  const _firstNames_0 = _first_0["snd"];
  const _second_1 = _second_0["fst"];
  const _secondNames_0 = _second_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_1, "right": _second_1}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1265$(_firstNames_0, _secondNames_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1260$(_stream_0) {
  const _retained_0 = _stream_0;
  return {$: "Tuple", "fst": _retained_0, "snd": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1260$(_retained_0)), "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_inventory$1261$(_stream_0) {
  const _retained_0 = _stream_0;
  return {$: "Tuple", "fst": _retained_0, "snd": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1261$(_retained_0)), "tail": {$: "Nil"}}};
}

function $List$show$1264$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058pair$(_h_0));
    const _x_1 = ($List$show$go$1264$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1265$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058unused$(_h_0));
    const _x_1 = ($List$show$go$1265$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
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

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058bool_data$(_value_0) {
  return {$: "Tuple", "fst": _value_0, "snd": ($Bool$show$(_value_0))};
}

function $$$$047$$$047ordinary$045schema$045debug$045v1$047refusal$045preservation$045v1$047public$045successor$047consumer$047owner$045observer$058u32_data$(_value_0) {
  return {$: "Tuple", "fst": _value_0, "snd": ($U32$show$(_value_0))};
}

function $observer$058batch$1260$(_value_0) {
  const _tick_0 = _value_0["tick"];
  const _values_0 = _value_0["values"];
  const _x_0 = ($List$show$1262$(_values_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$1268$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1260$(_h_0));
    const _x_1 = ($List$show$go$1268$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $observer$058position$(_value_0) {
  const _id_0 = _value_0["id"];
  const _cursor_0 = _value_0["cursor"];
  const _registered_0 = _value_0["registeredAt"];
  const _x_0 = ($Nat$show$(_registered_0));
  const _x_1 = ($Nat$show$(_cursor_0));
  const _x_2 = (":" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($U32$show$(_id_0));
  const _x_5 = (":" + _x_3);
  return (_x_4 + _x_5);
}

function $List$show$go$1269$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058position$(_h_0));
    const _x_1 = ($List$show$go$1269$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $observer$058batch$1261$(_value_0) {
  const _tick_0 = _value_0["tick"];
  const _values_0 = _value_0["values"];
  const _x_0 = ($List$show$1263$(_values_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$12610$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1261$(_h_0));
    const _x_1 = ($List$show$go$12610$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $observer$058batch$1262$(_value_0) {
  const _tick_0 = _value_0["tick"];
  const _values_0 = _value_0["values"];
  const _x_0 = ($List$show$1265$(_values_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$12611$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058batch$1262$(_h_0));
    const _x_1 = ($List$show$go$12611$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058register$1261$(_runtime_0, _name_0) {
  const _world_0 = _runtime_0["world"];
  const _family_0 = _runtime_0["family"];
  const _tick_0 = _runtime_0["tick"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_leaf$1261$(_world_0, _tick_0, _name_0, ($consumer$058take_second$(_family_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_named$1260$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _named_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_namespace$1260$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _world_0, _namespace_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_declaration$1260$(_stream_0) {
  const _domain_0 = _stream_0["domain"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058read$1260$(_domain_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_make$1260$(_domains_0, _capacity_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_make$1260$(_domains_0, _capacity_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1262$(_domain_0, _capacity_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": {$: "Nil"}, "positions": {$: "Nil"}, "nextReader": 1, "frameStart": 0, "boundary": 0, "capacity": _capacity_0, "dropped": 0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058synchronize_world$1260$(_state_0, _tick_0, _observed_0) {
  const _family_0 = _state_0["family"];
  const _owners_0 = _state_0["owners"];
  const _journal_0 = _state_0["journal"];
  const _frameStart_0 = _state_0["frameStart"];
  const _world_0 = _observed_0["fst"];
  const _records_0 = _observed_0["snd"];
  const _published_0 = ($List$drop$(_records_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1264$(_journal_0))));
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1265$(_published_0));
  return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": ($setup$058sync$())(_family_0)(_tick_0)(_published_0), "owners": _owners_0, "journal": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1264$((0 < _x_0), _journal_0, _tick_0, _published_0)), "frameStart": _frameStart_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058events_view$1261$(_world_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1262$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1262$(_registry_0, ($consumer$058publisher_runner$(_world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_walk$(_registrations_0, _id_0, _name_0, _access_0, false);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1262$(_second_0, _returned_0) {
  const _first_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": _second_0}, "snd": _stream_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058right_take$1260$(_family_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_right$1260$(_first_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_leaf$1261$(_second_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_left$1261$(_second_0, _returned_0) {
  const _first_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": _second_0}, "snd": _stream_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_leaf$1260$(_stream_0) {
  const _retained_0 = _stream_0;
  return {$: "Tuple", "fst": _retained_0, "snd": _retained_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_leaf_reading$1260$(_world_0, _family_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _returned_0) {
  const _stream_0 = _returned_0["fst"];
  const _reading_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_reading$1260$(_world_0, _family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _reading_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058reading$1261$(_stream_0, _id_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_position$1261$({$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, _id_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_reading$1261$(_world_0, _family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _reading_0) {
  const _values_0 = _reading_0["values"];
  const _lagged_0 = _reading_0["lagged"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_result$1261$(_family_0, _stream_0, _reader_0, _id_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1261$(_registry_0, _world_0, {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Input", "values": _values_0, "lagged": _lagged_0, "args": _args_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_position$1260$(_stream_0, _id_0, _tick_0, _position_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  if (_position_0.$ === "Some") {
    const _position_1 = _position_0["value"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$(_position_1, _batches_0, _dropped_0))};
  } else {
    return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$({$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": 0, "registeredAt": _tick_0}, _batches_0, _dropped_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0) {
  if (_positions_0.$ === "Nil") {
    return {$: "None"};
  } else {
    const _position_0 = _positions_0["head"];
    const _rest_0 = _positions_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup_checked$(_position_0, _id_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_rest_0, _id_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_children$1261$(_rest_0, _first_0, _second_0) {
  const _first_1 = _first_0["fst"];
  const _firstValues_0 = _first_0["snd"];
  const _second_1 = _second_0["fst"];
  const _secondValues_0 = _second_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_tail$1261$({$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": _firstValues_0, "second": _secondValues_0}, _rest_0({$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_1, "right": _second_1}));
}

function $setup$058retain_pair$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain$1260$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1262$(_stream_0, _tick_0, _values_0) {
  const _retained_0 = _stream_0;
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1262$(_retained_0, ($Nat$is_le$(_tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1262$(_retained_0)))), _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_frame$1260$(_family_0, _tick_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1260$(_first_0, _tick_0)), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1261$(_second_0, _tick_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1262$(_domain_0, _positions_0, _nextReader_0, _frameStart_0, _boundary_0, _capacity_0, _trimmed_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1262$(_trimmed_0, _capacity_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1262$(_batches_0, _capacity_0, _dropped_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1262$(_batches_0, _boundary_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1262$(($Nat$is_le$(_tick_0, _boundary_0)), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1262$(_rest_0, _boundary_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058hold_boundary$($0, $1) {
  for (;;) {
    {
      const _positions_0 = $0;
      const _boundary_0 = $1;
      if (_positions_0.$ === "Nil") {
        return _boundary_0;
      } else {
        const _t_0 = _positions_0["head"];
        const _cursor_0 = _t_0["cursor"];
        const _rest_0 = _positions_0["tail"];
        $0 = _rest_0;
        $1 = (_boundary_0 < _cursor_0 ? _boundary_0 : _cursor_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1260$(_stream_0) {
  const _t_0 = _stream_0["domain"];
  const _key_0 = _t_0["key"];
  return _key_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058inventory$1261$(_stream_0) {
  const _t_0 = _stream_0["domain"];
  const _key_0 = _t_0["key"];
  return _key_0;
}

function $observer$058pair$(_value_0) {
  const _a_0 = _value_0["first"];
  const _b_0 = _value_0["second"];
  const _x_0 = ($List$show$1263$(_b_0));
  const _x_1 = (_x_0 + ")");
  const _x_2 = ($List$show$1262$(_a_0));
  const _x_3 = ("," + _x_1);
  const _x_4 = (_x_2 + _x_3);
  return ("pair(" + _x_4);
}

function $List$show$go$1264$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058pair$(_h_0));
    const _x_1 = ($List$show$go$1264$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $observer$058unused$(_value_0) {
  const _code_0 = _value_0["code"];
  const _x_0 = ($U32$show$(_code_0));
  return ("Unused:" + _x_0);
}

function $List$show$go$1265$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058unused$(_h_0));
    const _x_1 = ($List$show$go$1265$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
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

function $Bool$show$(_b_0) {
  if (!_b_0) {
    return "False";
  } else {
    return "True";
  }
}

function $List$show$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058first_text$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $List$show$1263$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058second_text$(_h_0));
    const _x_1 = ($List$show$go$1263$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_leaf$1261$(_world_0, _tick_0, _name_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_named$1261$(_family_0, _stream_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_declaration$1261$(_stream_0)), _name_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_namespace$1260$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _world_0, _namespace_0) {
  const __0 = _declaration_0["domain"];
  const _t_0 = _declaration_0["mode"];
  if (_t_0.$ === "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Write") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_first$(_family_0, _stream_0)), "tick": _tick_0}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_result$1260$(_family_0, _stream_0, _tick_0, _namespace_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1260$(_world_0, _name_0, {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1260$({$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": __0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read"}})), "tail": {$: "Nil"}})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058read$1260$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": _domain_0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_make$1260$(_domains_0, _capacity_0) {
  const _first_0 = _domains_0["first"];
  const _second_0 = _domains_0["second"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1260$(_first_0, _capacity_0)), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1261$(_second_0, _capacity_0))};
}

function $List$drop$($0, $1) {
  for (;;) {
    {
      const _xs_0 = $0;
      const _n_0 = $1;
      if (_xs_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _h_0 = _xs_0["head"];
        const _t_0 = _xs_0["tail"];
        if (_n_0 === 0) {
          return {$: "Con", "head": _h_0, "tail": _t_0};
        } else {
          const _p_0 = (_n_0 - 1);
          $0 = _t_0;
          $1 = _p_0;
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1264$(_batches_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1264$(_batches_0, 0);
}

function $setup$058sync$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_sync$1261$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1264$(_nonempty_0, _batches_0, _tick_0, _published_0) {
  if (!_nonempty_0) {
    return _batches_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1269$(_batches_0, {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _published_0}, "tail": {$: "Nil"}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1262$(_registry_0, _outcome_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": _outcome_0};
}

function $consumer$058publisher_runner$(_world_0, _request_0) {
  const _domains_0 = _request_0["domains"];
  const _fail_0 = _request_0["fail"];
  const _count_0 = _request_0["count"];
  return $consumer$058publish_finished$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(($setup$058staged_count$(_world_0, _domains_0, _count_0)), ($consumer$058publish_outcome$(_fail_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_list_walk$($0, $1, $2, $3, $4) {
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
          $4 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_right$1260$(_first_0, _returned_0) {
  const _second_0 = _returned_0["fst"];
  const _stream_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": _second_0}, "snd": _stream_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058selected_leaf$1261$(_stream_0) {
  const _retained_0 = _stream_0;
  return {$: "Tuple", "fst": _retained_0, "snd": _retained_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_reading$1260$(_world_0, _family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _args_0, _reading_0) {
  const _values_0 = _reading_0["values"];
  const _lagged_0 = _reading_0["lagged"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_result$1260$(_family_0, _stream_0, _reader_0, _id_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1260$(_registry_0, _world_0, {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Input", "values": _values_0, "lagged": _lagged_0, "args": _args_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_position$1261$(_stream_0, _id_0, _tick_0, _position_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  if (_position_0.$ === "Some") {
    const _position_1 = _position_0["value"];
    return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1261$(_position_1, _batches_0, _dropped_0))};
  } else {
    return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1261$({$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": 0, "registeredAt": _tick_0}, _batches_0, _dropped_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_result$1261$(_family_0, _stream_0, _reader_0, _id_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected") {
    const _registry_0 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    const _t_0 = _result_0["args"];
    const _args_0 = _t_0["args"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_second$(_family_0, _stream_0)), "tick": nat_chk(_tick_0 + 1)}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Rejected", "args": _args_0}};
  } else {
    const _registry_1 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_outcome$1261$(_family_0, _stream_0, _reader_0, _registry_1, _id_0, _tick_0, _outcome_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1261$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1261$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1260$(_position_0, _batches_0, _dropped_0) {
  const _cursor_0 = _position_0["cursor"];
  const _registered_0 = _position_0["registeredAt"];
  const _x_0 = (_cursor_0 > _registered_0 ? _cursor_0 : _registered_0);
  return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_batches_0, _cursor_0)), "lagged": (_x_0 < _dropped_0)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup_checked$(_position_0, _id_0, _fallback_0) {
  const _actual_0 = _position_0["id"];
  const _cursor_0 = _position_0["cursor"];
  const _registered_0 = _position_0["registeredAt"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058choose_position$((_actual_0 === _id_0), {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _actual_0, "cursor": _cursor_0, "registeredAt": _registered_0}, _fallback_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_tail$1261$(_record_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _rest_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _family_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_join$1261$(_record_0, _rest_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain$1260$(_family_0, _tick_0, _records_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1260$(_records_0, _family_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1262$(_stream_0, _remove_0, _values_0) {
  if (!_remove_0) {
    return {$: "Tuple", "fst": _stream_0, "snd": _values_0};
  } else {
    return {$: "Tuple", "fst": _stream_0, "snd": {$: "Nil"}};
  }
}

function $Nat$is_le$(_a_0, _b_0) {
  return $Cmp$is_le$(cmp_new(_a_0, _b_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1262$(_stream_0) {
  const _value_0 = _stream_0["dropped"];
  return _value_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1260$(_stream_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1260$(_stream_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_frame$1261$(_stream_0, _tick_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1261$(_stream_0, _tick_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1262$(_batches_0, _capacity_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1263$({$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}));
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1262$((_capacity_0 < _x_0), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1262$(_rest_0, _capacity_0, _x_1);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1262$(_remove_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_remove_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $observer$058first_text$(_value_0) {
  const _value_1 = _value_0["value"];
  const _x_0 = ($U32$show$(_value_1));
  return ("A:" + _x_0);
}

function $List$show$go$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058first_text$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $observer$058second_text$(_value_0) {
  const _value_1 = _value_0["value"];
  const _x_0 = ($Bool$show$(_value_1));
  return ("B:" + _x_0);
}

function $List$show$go$1263$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($observer$058second_text$(_h_0));
    const _x_1 = ($List$show$go$1263$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_named$1261$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _named_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_namespace$1261$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _world_0, _namespace_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058read_declaration$1261$(_stream_0) {
  const _domain_0 = _stream_0["domain"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058read$1261$(_domain_0);
}

function $consumer$058put_first$(_state_0, _stream_0) {
  return $setup$058put_first$(_state_0, _stream_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_result$1260$(_family_0, _stream_0, _tick_0, _namespace_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_first$(_family_0, _stream_0)), "tick": _tick_0}};
  } else {
    const _world_1 = _result_0["world"];
    const _registry_0 = _result_0["registry"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_identity$1260$(_world_1, _family_0, _tick_0, _namespace_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058registered$1260$(_stream_0, _tick_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1260$(_registry_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1260$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1260$(_domain_0, _capacity_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1260$(_domain_0, _capacity_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_make$1261$(_domain_0, _capacity_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1261$(_domain_0, _capacity_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1264$($0, $1) {
  for (;;) {
    {
      const _batches_0 = $0;
      const _acc_0 = $1;
      if (_batches_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _t_0 = _batches_0["head"];
        const _items_0 = _t_0["values"];
        const _rest_0 = _batches_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1265$(_items_0, _acc_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_sync$1261$(_family_0, _tick_0, _records_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_sync$1261$(_family_0, _tick_0, _records_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1269$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1269$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $consumer$058publish_finished$(_returned_0) {
  const _world_0 = _returned_0["world"];
  const _t_0 = _returned_0["outcome"];
  if (_t_0.$ === "../../../../../../../../bendvy/src/ecs/transaction.Success") {
    return {$: "../../../../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $setup$058staged_count$(_world_0, _domains_0, _count_0) {
  const _first_0 = _domains_0["first"];
  const _second_0 = _domains_0["second"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058emit$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write_grant$1261$(_second_0)), ($setup$058repeated_first$(_count_0, _first_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0)))), {$: "types.Second", "value": true});
}

function $consumer$058publish_outcome$(_fail_0) {
  if (!_fail_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/transaction.Success"};
  } else {
    return {$: "../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": {$: "types.Aborted"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0) {
  const _mid_0 = _meta_0["id"];
  const _mname_0 = _meta_0["name"];
  const _maccess_0 = _meta_0["access"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_id$((_mid_0 === _id_0), _mname_0, _name_0, _maccess_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_result$1260$(_family_0, _stream_0, _reader_0, _id_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected") {
    const _registry_0 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    const _t_0 = _result_0["args"];
    const _args_0 = _t_0["args"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_first$(_family_0, _stream_0)), "tick": nat_chk(_tick_0 + 1)}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Rejected", "args": _args_0}};
  } else {
    const _registry_1 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_outcome$1260$(_family_0, _stream_0, _reader_0, _registry_1, _id_0, _tick_0, _outcome_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run$1260$(_registry_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1260$(_registry_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058reading$1261$(_position_0, _batches_0, _dropped_0) {
  const _cursor_0 = _position_0["cursor"];
  const _registered_0 = _position_0["registeredAt"];
  const _x_0 = (_cursor_0 > _registered_0 ? _cursor_0 : _registered_0);
  return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1261$(_batches_0, _cursor_0)), "lagged": (_x_0 < _dropped_0)};
}

function $consumer$058put_second$(_state_0, _stream_0) {
  return $setup$058put_second$(_state_0, _stream_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_outcome$1261$(_family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_second$(_family_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1261$(_stream_0, _id_0, nat_chk(_tick_0 + 1), false)))), "tick": nat_chk(_tick_0 + 1)}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Failed", "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_synchronized$1261$(_reader_0, _registry_0, nat_chk(_tick_0 + 1), _output_0, ($consumer$058synchronize$(_world_1, ($consumer$058put_second$(_family_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1261$(_stream_0, _id_0, nat_chk(_tick_0 + 1), true)))), nat_chk(_tick_0 + 1))));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1261$(_registry_0, _named_0, _args_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1261$(_registry_0, _world_0, _actual_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_batches_0, _cursor_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1260$((_cursor_0 < _tick_0), _items_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1260$(_rest_0, _cursor_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058choose_position$(_found_0, _position_0, _fallback_0) {
  if (!_found_0) {
    return _fallback_0;
  } else {
    return {$: "Some", "value": _position_0};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_join$1261$(_record_0, _rest_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_head$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058nonempty_record$1261$(_record_0)), _record_0, _rest_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1260$(_records_0, _family_0, _tick_0) {
  if (_records_0.$ === "Nil") {
    return {$: "Tuple", "fst": _family_0, "snd": {$: "Nil"}};
  } else {
    const _record_0 = _records_0["head"];
    const _rest_0 = _records_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_record$1260$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_retain_loop$1260$(_rest_0, _x_0, _tick_0);
}), _tick_0, _record_0, _family_0);
  }
}

function $Cmp$is_le$(_c_0) {
  if (_c_0.$ === "GT") {
    return false;
  } else {
    return true;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1260$(_stream_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1260$(_domain_0, _positions_0, _nextReader_0, _tick_0, _frameStart_0, _capacity_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1260$(_batches_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058hold_boundary$(_positions_0, _frameStart_0)), _dropped_0)), _capacity_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058frame$1261$(_stream_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1261$(_domain_0, _positions_0, _nextReader_0, _tick_0, _frameStart_0, _capacity_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1261$(_batches_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058hold_boundary$(_positions_0, _frameStart_0)), _dropped_0)), _capacity_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1262$(_overflow_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_overflow_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1263$(_batches_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1263$(_batches_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_namespace$1261$(_family_0, _stream_0, _tick_0, _declaration_0, _name_0, _world_0, _namespace_0) {
  const __0 = _declaration_0["domain"];
  const _t_0 = _declaration_0["mode"];
  if (_t_0.$ === "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Write") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_second$(_family_0, _stream_0)), "tick": _tick_0}};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_result$1261$(_family_0, _stream_0, _tick_0, _namespace_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1261$(_world_0, _name_0, {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058access$1261$({$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": __0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read"}})), "tail": {$: "Nil"}})));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058read$1261$(_domain_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Declaration", "domain": _domain_0, "mode": {$: "../../../../../../../../bendvy/src/ecs/ordinary-event-declaration.Read"}};
}

function $setup$058put_first$(_state_0, _stream_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058put$1260$(_state_0, _stream_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_identity$1260$(_world_0, _family_0, _tick_0, _namespace_0, _returned_0, _identified_0) {
  const _stream_0 = _returned_0["fst"];
  const _id_0 = _returned_0["snd"];
  const _registry_0 = _identified_0["fst"];
  const _registryId_0 = _identified_0["snd"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Registered", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_first$(_family_0, _stream_0)), "tick": _tick_0}, "reader": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, "registry": _registry_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058registered$1260$(_stream_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": ((_nextReader_0 + 1) >>> 0), "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": _nextReader_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1260$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1260$(_domain_0, _capacity_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": {$: "Nil"}, "positions": {$: "Nil"}, "nextReader": 1, "frameStart": 0, "boundary": 0, "capacity": _capacity_0, "dropped": 0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058provision$1261$(_domain_0, _capacity_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": {$: "Nil"}, "positions": {$: "Nil"}, "nextReader": 1, "frameStart": 0, "boundary": 0, "capacity": _capacity_0, "dropped": 0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_sync$1261$(_family_0, _tick_0, _records_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($setup$058sync_pair$())(_first_0)(_tick_0)(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1261$(_records_0))), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1262$(_second_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1261$(_records_0))))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1269$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($setup$058enqueue$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($setup$058publish$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$(_undo_0, _world_0)), "outcome": {$: "../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058emit$1261$(__0, _owner_0, _event_0) {
  return $setup$058emit_second$(_owner_0, _event_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write_grant$1261$(__0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.WriteAccess"};
}

function $setup$058repeated_first$($0, $1, $2) {
  for (;;) {
    {
      const _count_0 = $0;
      const _first_0 = $1;
      const _tx_0 = $2;
      if (_count_0 === 0) {
        return _tx_0;
      } else {
        const _rest_0 = (_count_0 - 1);
        $0 = _rest_0;
        $1 = _first_0;
        $2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058emit$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write_grant$1260$(_first_0)), _tx_0, {$: "types.First", "value": 30}));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_id$(_sameId_0, _metaName_0, _wantedName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameId_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_access$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(_metaName_0, _wantedName_0)), _metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_outcome$1260$(_family_0, _stream_0, _reader_0, _registry_0, _id_0, _tick_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../bendvy/src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_first$(_family_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1260$(_stream_0, _id_0, nat_chk(_tick_0 + 1), false)))), "tick": nat_chk(_tick_0 + 1)}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Failed", "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_synchronized$1260$(_reader_0, _registry_0, nat_chk(_tick_0 + 1), _output_0, ($consumer$058synchronize$(_world_1, ($consumer$058put_first$(_family_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1260$(_stream_0, _id_0, nat_chk(_tick_0 + 1), true)))), nat_chk(_tick_0 + 1))));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace$1260$(_registry_0, _named_0, _args_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1260$(_registry_0, _world_0, _actual_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1261$(_batches_0, _cursor_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1261$((_cursor_0 < _tick_0), _items_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since$1261$(_rest_0, _cursor_0)));
  }
}

function $setup$058put_second$(_state_0, _stream_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058put$1261$(_state_0, _stream_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1261$(_stream_0, _id_0, _tick_0, _success_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed_positions$(_success_0, _positions_0, _id_0, _tick_0)), "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_synchronized$1261$(_reader_0, _registry_0, _tick_0, _output_0, _returned_0) {
  const _world_0 = _returned_0["fst"];
  const _family_0 = _returned_0["snd"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _family_0, "tick": _tick_0}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Succeeded", "output": _output_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1261$(_registry_0, _world_0, _actual_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1261$((_namespace_0 === _actual_0), {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1260$(_visible_0, _items_0, _rest_0) {
  if (!_visible_0) {
    return _rest_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1260$(_items_0, _rest_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_head$1261$(_keep_0, _record_0, _rest_0) {
  if (_keep_0) {
    return {$: "Con", "head": _record_0, "tail": _rest_0};
  } else {
    return _rest_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058nonempty_record$1261$(_record_0) {
  const _first_0 = _record_0["first"];
  const _second_0 = _record_0["second"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1264$(_first_0));
  const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1263$(_second_0));
  const _x_2 = nat_chk(_x_0 + _x_1);
  return (0 < _x_2);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_record$1260$(_rest_0, _tick_0, _record_0, _family_0) {
  const _a_0 = _record_0["first"];
  const _b_0 = _record_0["second"];
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_children$1260$(_rest_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1260$(_first_0, _tick_0, _a_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1261$(_second_0, _tick_0, _b_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1260$(_domain_0, _positions_0, _nextReader_0, _frameStart_0, _boundary_0, _capacity_0, _trimmed_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1260$(_trimmed_0, _capacity_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1260$(_batches_0, _capacity_0, _dropped_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1260$(_batches_0, _boundary_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1260$(($Nat$is_le$(_tick_0, _boundary_0)), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1260$(_rest_0, _boundary_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058trimmed$1261$(_domain_0, _positions_0, _nextReader_0, _frameStart_0, _boundary_0, _capacity_0, _trimmed_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058trim_capacity$1261$(_trimmed_0, _capacity_0) {
  const _batches_0 = _trimmed_0["batches"];
  const _dropped_0 = _trimmed_0["dropped"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1261$(_batches_0, _capacity_0, _dropped_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1261$(_batches_0, _boundary_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1261$(($Nat$is_le$(_tick_0, _boundary_0)), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_window$1261$(_rest_0, _boundary_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1263$($0, $1) {
  for (;;) {
    {
      const _batches_0 = $0;
      const _acc_0 = $1;
      if (_batches_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _t_0 = _batches_0["head"];
        const _items_0 = _t_0["values"];
        const _rest_0 = _batches_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1263$(_items_0, _acc_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_result$1261$(_family_0, _stream_0, _tick_0, _namespace_0, _result_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed") {
    const _world_0 = _result_0["world"];
    return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.RegistrationFailed", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_second$(_family_0, _stream_0)), "tick": _tick_0}};
  } else {
    const _world_1 = _result_0["world"];
    const _registry_0 = _result_0["registry"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_identity$1261$(_world_1, _family_0, _tick_0, _namespace_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058registered$1261$(_stream_0, _tick_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058identity$1261$(_registry_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register$1261$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058put$1260$(_state_0, _stream_0) {
  const _family_0 = _state_0["family"];
  const _owners_0 = _state_0["owners"];
  const _journal_0 = _state_0["journal"];
  const _frameStart_0 = _state_0["frameStart"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": ($setup$058first_family_put$())(_family_0)(_stream_0), "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1260$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $setup$058sync_pair$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_sync$1260$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1261$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _first_0 = _t_0["first"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1266$(_first_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1261$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1262$(_stream_0, _tick_0, _values_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1262$(_stream_0, _tick_0, _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1261$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _second_0 = _t_0["second"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1268$(_second_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1261$(_rest_0)));
  }
}

function $setup$058enqueue$(_world_0, _commands_0) {
  return $setup$058enqueue_loop$(_commands_0, _world_0);
}

function $setup$058publish$(_world_0, _events_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$($0, $1) {
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

function $setup$058emit_second$(_tx_0, _event_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058emit$1261$(_tx_0, ($setup$058inject_second$())(_event_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058emit$1260$(__0, _owner_0, _event_0) {
  return $setup$058emit_first$(_owner_0, _event_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045declaration$058write_grant$1260$(__0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.WriteAccess"};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058matching_access$(_sameName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameName_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(_metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(_a_0, _b_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal_walk$(_a_0, _b_0, true);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed$1260$(_stream_0, _id_0, _tick_0, _success_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed_positions$(_success_0, _positions_0, _id_0, _tick_0)), "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058run_synchronized$1260$(_reader_0, _registry_0, _tick_0, _output_0, _returned_0) {
  const _world_0 = _returned_0["fst"];
  const _family_0 = _returned_0["snd"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Ran", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": _family_0, "tick": _tick_0}, "reader": _reader_0, "registry": _registry_0, "completion": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Succeeded", "output": _output_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_value$1260$(_registry_0, _world_0, _actual_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1260$((_namespace_0 === _actual_0), {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058since_checked$1261$(_visible_0, _items_0, _rest_0) {
  if (!_visible_0) {
    return _rest_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1261$(_items_0, _rest_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045runtime$058put$1261$(_state_0, _stream_0) {
  const _family_0 = _state_0["family"];
  const _owners_0 = _state_0["owners"];
  const _journal_0 = _state_0["journal"];
  const _frameStart_0 = _state_0["frameStart"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-runtime.State", "family": ($setup$058second_family_put$())(_family_0)(_stream_0), "owners": _owners_0, "journal": _journal_0, "frameStart": _frameStart_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058completed_positions$(_success_0, _positions_0, _id_0, _tick_0) {
  if (!_success_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activate$(_positions_0, _id_0, (_tick_0 < 1 ? 0 : _tick_0 - 1));
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activate$(_positions_0, _id_0, (_tick_0 < 1 ? 0 : _tick_0 - 1))), _id_0, _tick_0, false);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    const _cursor_0 = _registry_0["cursor"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1261$({$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1260$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1260$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1264$(_items_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1264$(_items_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1263$(_items_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1263$(_items_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_children$1260$(_rest_0, _first_0, _second_0) {
  const _first_1 = _first_0["fst"];
  const _firstValues_0 = _first_0["snd"];
  const _second_1 = _second_0["fst"];
  const _secondValues_0 = _second_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_tail$1260$({$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": _firstValues_0, "second": _secondValues_0}, _rest_0({$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_1, "right": _second_1}));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1260$(_stream_0, _tick_0, _values_0) {
  const _retained_0 = _stream_0;
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1260$(_retained_0, ($Nat$is_le$(_tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1260$(_retained_0)))), _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retain$1261$(_stream_0, _tick_0, _values_0) {
  const _retained_0 = _stream_0;
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1261$(_retained_0, ($Nat$is_le$(_tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1261$(_retained_0)))), _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1260$(_batches_0, _capacity_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1261$({$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}));
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1260$((_capacity_0 < _x_0), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1260$(_rest_0, _capacity_0, _x_1);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1260$(_remove_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_remove_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1261$(_batches_0, _capacity_0, _dropped_0) {
  if (_batches_0.$ === "Nil") {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Nil"}, "dropped": _dropped_0};
  } else {
    const _t_0 = _batches_0["head"];
    const _tick_0 = _t_0["tick"];
    const _items_0 = _t_0["values"];
    const _rest_0 = _batches_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1262$({$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}));
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1261$((_capacity_0 < _x_0), _tick_0, _items_0, _rest_0, _dropped_0, run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058at_capacity$1261$(_rest_0, _capacity_0, _x_1);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058past_checked$1261$(_remove_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_remove_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1263$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _acc_0 = $1;
      if (_items_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _rest_0 = _items_0["tail"];
        $0 = _rest_0;
        $1 = nat_chk(_acc_0 + 1);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045family$045routing$058registration_identity$1261$(_world_0, _family_0, _tick_0, _namespace_0, _returned_0, _identified_0) {
  const _stream_0 = _returned_0["fst"];
  const _id_0 = _returned_0["snd"];
  const _registry_0 = _identified_0["fst"];
  const _registryId_0 = _identified_0["snd"];
  return {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Registered", "runtime": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Runtime", "world": _world_0, "family": ($consumer$058put_second$(_family_0, _stream_0)), "tick": _tick_0}, "reader": {$: "../../../../../../../../bendvy/src/ecs/event-family-routing.Reader", "namespace": _namespace_0, "id": _id_0, "registryId": _registryId_0}, "registry": _registry_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058registered$1261$(_stream_0, _tick_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": _batches_0, "positions": _positions_0, "nextReader": ((_nextReader_0 + 1) >>> 0), "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0}, "snd": _nextReader_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_namespace$1261$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
}

function $setup$058first_family_put$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1260$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/world.RegistrationRejected") {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../../../../../../bendvy/src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058node_sync$1260$(_family_0, _tick_0, _records_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_sync$1260$(_family_0, _tick_0, _records_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1266$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1266$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1262$(_stream_0, _tick_0, _values_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1263$(_values_0));
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1263$((0 < _x_0), _batches_0, _tick_0, _values_0)), "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1268$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1268$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $setup$058enqueue_loop$($0, $1) {
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
        $1 = _command_0(_world_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058emit$1261$(_tx_0, _event_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return {$: "../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": {$: "Con", "head": _event_0, "tail": _events_0}};
}

function $setup$058inject_second$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1262$(_x_0);
});
}

function $setup$058emit_first$(_tx_0, _event_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058emit$1261$(_tx_0, ($setup$058inject_first$())(_event_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(_xs_0, _ys_0) {
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
      return $Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal$(__2, _y_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058access_equal$(__3, _ys_1)));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047string$045equality$058equal_walk$($0, $1, $2) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_namespace_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    const _cursor_0 = _registry_0["cursor"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1260$({$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1261$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1261$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $setup$058second_family_put$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1262$(_x_0, _x_1);
});
});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activate$(_positions_0, _id_0, _registered_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activation$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058lookup$(_positions_0, _id_0)), _positions_0, _id_0, _registered_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(_positions_0, _id_0, _cursor_0, _dispose_0) {
  if (_positions_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _positions_0["head"];
    const _actual_0 = _t_0["id"];
    const _old_0 = _t_0["cursor"];
    const _registered_0 = _t_0["registeredAt"];
    const _rest_0 = _positions_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update_checked$((_actual_0 === _id_0), _dispose_0, _actual_0, _old_0, _registered_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update$(_rest_0, _id_0, _cursor_0, _dispose_0)), _cursor_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1261$(_registry_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1260$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1264$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _acc_0 = $1;
      if (_items_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _rest_0 = _items_0["tail"];
        $0 = _rest_0;
        $1 = nat_chk(_acc_0 + 1);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058retained_tail$1260$(_record_0, _returned_0) {
  const _family_0 = _returned_0["fst"];
  const _rest_0 = _returned_0["snd"];
  return {$: "Tuple", "fst": _family_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_join$1260$(_record_0, _rest_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1260$(_stream_0, _remove_0, _values_0) {
  if (!_remove_0) {
    return {$: "Tuple", "fst": _stream_0, "snd": _values_0};
  } else {
    return {$: "Tuple", "fst": _stream_0, "snd": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1260$(_stream_0) {
  const _value_0 = _stream_0["dropped"];
  return _value_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_retained$1261$(_stream_0, _remove_0, _values_0) {
  if (!_remove_0) {
    return {$: "Tuple", "fst": _stream_0, "snd": _values_0};
  } else {
    return {$: "Tuple", "fst": _stream_0, "snd": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058dropped$1261$(_stream_0) {
  const _value_0 = _stream_0["dropped"];
  return _value_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1260$(_overflow_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_overflow_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1261$(_batches_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1261$(_batches_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058capacity_checked$1261$(_overflow_0, _tick_0, _items_0, _rest_0, _dropped_0, _ih_0) {
  if (!_overflow_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Trimmed", "batches": {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0}, "dropped": _dropped_0};
  } else {
    return run_tail(_ih_0, (_dropped_0 > _tick_0 ? _dropped_0 : _tick_0));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size$1262$(_batches_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1262$(_batches_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_join$1261$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1261$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1260$(_family_0, _stream_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1261$(_first_0, _stream_0)), "right": _second_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058pair_sync$1260$(_family_0, _tick_0, _records_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1260$(_first_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1260$(_records_0)))), "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1261$(_second_0, _tick_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1260$(_records_0))))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1266$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1263$(_nonempty_0, _batches_0, _tick_0, _published_0) {
  if (!_nonempty_0) {
    return _batches_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1267$(_batches_0, {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _published_0}, "tail": {$: "Nil"}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1268$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, _published_0) {
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
  return {$: "../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1261$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1262$(_event_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_right$1260$(_event_0)), "tail": {$: "Nil"}}, "second": {$: "Nil"}};
}

function $setup$058inject_first$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1260$(_x_0);
});
}

function $Char$is_eq$(_a_0, _b_0) {
  const _x_0 = _a_0.codePointAt(0);
  const _x_1 = _b_0.codePointAt(0);
  return (_x_0 === _x_1);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_metadata$1260$(_registry_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1261$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1262$(_family_0, _stream_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058right_put$1260$(_first_0, _stream_0)), "right": _second_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058activation$(_position_0, _positions_0, _id_0, _registered_0) {
  if (_position_0.$ === "None") {
    return {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": 0, "registeredAt": _registered_0}, "tail": _positions_0};
  } else {
    return _positions_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058update_checked$(_found_0, _dispose_0, _id_0, _old_0, _registered_0, _rest_0, _cursor_0) {
  if (!_found_0) {
    return {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": _old_0, "registeredAt": _registered_0}, "tail": _rest_0};
  } else {
    if (!_dispose_0) {
      return {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Position", "id": _id_0, "cursor": _cursor_0, "registeredAt": _registered_0}, "tail": _rest_0};
    } else {
      return _rest_0;
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1261$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1261$(_registry_0, ($consumer$058second_runner$(_world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_join$1260$(_record_0, _rest_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_head$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058nonempty_record$1260$(_record_0)), _record_0, _rest_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1261$($0, $1) {
  for (;;) {
    {
      const _batches_0 = $0;
      const _acc_0 = $1;
      if (_batches_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _t_0 = _batches_0["head"];
        const _items_0 = _t_0["values"];
        const _rest_0 = _batches_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1261$(_items_0, _acc_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058size_loop$1262$($0, $1) {
  for (;;) {
    {
      const _batches_0 = $0;
      const _acc_0 = $1;
      if (_batches_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _t_0 = _batches_0["head"];
        const _items_0 = _t_0["values"];
        const _rest_0 = _batches_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1262$(_items_0, _acc_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058register_meta$1261$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../../../../../../bendvy/src/ecs/world.RegistrationRejected") {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../../../../../../bendvy/src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../../../../../../bendvy/src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058left_put$1261$(_family_0, _stream_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058replaced_leaf$1260$(_first_0, _stream_0)), "right": _second_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1260$(_stream_0, _tick_0, _values_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1260$(_stream_0, _tick_0, _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _first_0 = _t_0["first"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1261$(_first_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058first_values$1260$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058leaf_sync$1261$(_stream_0, _tick_0, _values_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1261$(_stream_0, _tick_0, _values_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _second_0 = _t_0["second"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1260$(_second_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058second_values$1260$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1267$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1267$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1261$(_left_0, _right_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1261$(($List$reverse$(_left_0)), _right_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_right$1260$(_event_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": {$: "Nil"}, "second": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_leaf$1261$(_event_0)), "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1260$(_event_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1261$(_event_0)), "tail": {$: "Nil"}}, "second": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058run_checked$1260$(_allowed_0, _registry_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0};
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1260$(_registry_0, ($consumer$058first_runner$(_world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058right_put$1260$(_family_0, _stream_0) {
  const _first_0 = _family_0["left"];
  const _second_0 = _family_0["right"];
  return {$: "../../../../../../../../bendvy/src/ecs/owner-product.Owner", "left": _first_0, "right": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058replaced_leaf$1261$(_second_0, _stream_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1261$(_registry_0, _outcome_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": _outcome_0};
}

function $consumer$058second_runner$(_world_0, _input_0) {
  return $consumer$058read_runner$1261$(_world_0, _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058retained_head$1260$(_keep_0, _record_0, _rest_0) {
  if (_keep_0) {
    return {$: "Con", "head": _record_0, "tail": _rest_0};
  } else {
    return _rest_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045publication$058nonempty_record$1260$(_record_0) {
  const _first_0 = _record_0["first"];
  const _second_0 = _record_0["second"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1260$(_first_0));
  const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1261$(_second_0));
  const _x_2 = nat_chk(_x_0 + _x_1);
  return (0 < _x_2);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1261$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _acc_0 = $1;
      if (_items_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _rest_0 = _items_0["tail"];
        $0 = _rest_0;
        $1 = nat_chk(_acc_0 + 1);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1262$($0, $1) {
  for (;;) {
    {
      const _items_0 = $0;
      const _acc_0 = $1;
      if (_items_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _rest_0 = _items_0["tail"];
        $0 = _rest_0;
        $1 = nat_chk(_acc_0 + 1);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058replaced_leaf$1260$(__0, _stream_0) {
  return _stream_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1260$(_stream_0, _tick_0, _values_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1260$(_values_0));
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1260$((0 < _x_0), _batches_0, _tick_0, _values_0)), "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045stream$058append$1261$(_stream_0, _tick_0, _values_0) {
  const _domain_0 = _stream_0["domain"];
  const _batches_0 = _stream_0["batches"];
  const _positions_0 = _stream_0["positions"];
  const _nextReader_0 = _stream_0["nextReader"];
  const _frameStart_0 = _stream_0["frameStart"];
  const _boundary_0 = _stream_0["boundary"];
  const _capacity_0 = _stream_0["capacity"];
  const _dropped_0 = _stream_0["dropped"];
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1261$(_values_0));
  return {$: "../../../../../../../../bendvy/src/ecs/event-stream.Stream", "domain": _domain_0, "batches": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1261$((0 < _x_0), _batches_0, _tick_0, _values_0)), "positions": _positions_0, "nextReader": _nextReader_0, "frameStart": _frameStart_0, "boundary": _boundary_0, "capacity": _capacity_0, "dropped": _dropped_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1267$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1261$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_leaf$1261$(_event_0) {
  return _event_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_left$1261$(_event_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/event-publication.Publication", "first": {$: "Con", "head": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_leaf$1260$(_event_0)), "tail": {$: "Nil"}}, "second": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047system$058complete$1260$(_registry_0, _outcome_0) {
  return {$: "../../../../../../../../bendvy/src/ecs/system.Completed", "registry": _registry_0, "outcome": _outcome_0};
}

function $consumer$058first_runner$(_world_0, _input_0) {
  return $consumer$058read_runner$1260$(_world_0, _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058replaced_leaf$1261$(__0, _stream_0) {
  return _stream_0;
}

function $consumer$058read_runner$1261$(_world_0, _input_0) {
  const _values_0 = _input_0["values"];
  const _lagged_0 = _input_0["lagged"];
  const _t_0 = _input_0["args"];
  if (!_t_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": _values_0, "lagged": _lagged_0}};
  } else {
    return {$: "../../../../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": {$: "consumer.ReadError", "reading": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": _values_0, "lagged": _lagged_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1260$(_items_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1261$(_items_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count$1261$(_items_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058count_loop$1262$(_items_0, 0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1260$(_nonempty_0, _batches_0, _tick_0, _published_0) {
  if (!_nonempty_0) {
    return _batches_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1262$(_batches_0, {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _published_0}, "tail": {$: "Nil"}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058sync_checked$1261$(_nonempty_0, _batches_0, _tick_0, _published_0) {
  if (!_nonempty_0) {
    return _batches_0;
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1263$(_batches_0, {$: "Con", "head": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _published_0}, "tail": {$: "Nil"}});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047ordinary$045event$045family$058inject_leaf$1260$(_event_0) {
  return _event_0;
}

function $consumer$058read_runner$1260$(_world_0, _input_0) {
  const _values_0 = _input_0["values"];
  const _lagged_0 = _input_0["lagged"];
  const _t_0 = _input_0["args"];
  if (!_t_0) {
    return {$: "../../../../../../../../bendvy/src/ecs/system.Succeeded", "world": _world_0, "output": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": _values_0, "lagged": _lagged_0}};
  } else {
    return {$: "../../../../../../../../bendvy/src/ecs/system.Failed", "world": _world_0, "error": {$: "consumer.ReadError", "reading": {$: "../../../../../../../../bendvy/src/ecs/event-runtime.Reading", "values": _values_0, "lagged": _lagged_0}}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1262$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1262$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append$1263$(_left_0, _right_0) {
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
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1263$(($List$reverse$(_left_0)), _right_0);
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1262$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047event$045runtime$058append_loop$1263$($0, $1) {
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
    io_errs(String(e.stack ?? e));
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
io_exit($main$, [[7,1,2,0,0,0,1,1,0,2,1,0,15,1,0,7,1,1,2,0,4,0,0,30,1,41,3,70,8,69,7,0,2,3,0,0,0,4,0,0,0,7,0,2,5,0,0,0,6,0,1,0,1,54,7,1,2,7,0,0,1,8,0,2,1,0,69,1,54,4,7,0,2,9,0,0,0,10,0,1,0,1,83,7,0,6,11,0,2,0,1,120,3,30,12,0,2,0,1,156,3,30,13,0,1,0,1,30,14,0,0,0,15,0,0,0,16,0,0,0,7,0,1,17,0,2,0,0,131,1,30,7,1,2,18,0,0,1,19,0,2,1,0,146,1,131,7,1,1,20,0,1,0,0,155,0,7,0,1,21,0,2,0,0,167,1,30,7,1,2,22,0,0,1,23,0,2,1,0,182,1,167,7,1,1,24,0,1,0,0,30],["Nil","Con","trace.Row","False","True","None","Some","Nil","Con","None","Some","consumer.FirstRead","consumer.SecondRead","consumer.Published","consumer.Rejected","consumer.Framed","consumer.SetupUnavailable","../../../../../../../../bendvy/src/ecs/event-runtime.Reading","Nil","Con","types.First","../../../../../../../../bendvy/src/ecs/event-runtime.Reading","Nil","Con","types.Second"]]);