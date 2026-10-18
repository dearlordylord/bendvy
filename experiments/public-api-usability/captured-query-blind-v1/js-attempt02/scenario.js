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
// Shared across independently emitted modules in the same host JS realm.
// This registry is trusted host infrastructure, not gameplay authority.
const bendvy_namespace_slot = Symbol.for("bendvy.world.namespace.v1");
if (!Object.prototype.hasOwnProperty.call(globalThis, bendvy_namespace_slot)) {
  Object.defineProperty(globalThis, bendvy_namespace_slot, {
    value: { next: 1 }, writable: false, configurable: false, enumerable: false
  });
}
function bendvy_namespace_fresh() {
  const state = globalThis[bendvy_namespace_slot];
  if (state.next >= 0xffffffff) return 0;
  return state.next++;
}
io_eff("../../../src/ecs/world-namespace.fresh", bendvy_namespace_fresh);

})();

(() => {
// IO
// ==

function io_print(text) {
  io_out(1, io_bytes(text + "\n"));
  return { $: "Unit" };
}

io_eff("IO.print", io_print);

})();

for (const k of ["../../../src/ecs/world-namespace.fresh","IO.print"]) {
  if (!(k in $0eff)) {
    throw new Error("bend: no effect registers " + k);
  }
}

// Program
// =======

function $main$() {
  return run_clo((_x_0) => {
  return $IO$bind$(($$$$047$$$047$$$047src$047ecs$047world$045io$058create$1260$({$: "Unit"})), run_clo((_x_1) => {
  return $created$(_x_1);
}), _x_0);
});
}

function $IO$bind$(_m_0, _f_0, _k_0) {
  return run_tail(_m_0, run_clo((_x_0) => {
  return run_tail(_f_0(_x_0), _k_0);
}));
}

function $$$$047$$$047$$$047src$047ecs$047world$045io$058create$1260$(_resource_0) {
  return run_clo((_x_0) => {
  return $IO$bind$((_x_1) => $$$$047$$$047$$$047src$047ecs$047world$045namespace$058fresh$(_x_1), run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047world$045io$058with_namespace$1260$(_x_2, _resource_0);
}), _x_0);
});
}

function $created$(_result_0) {
  if (_result_0.$ === "../../../src/ecs/world-io.Created") {
    const _world_0 = _result_0["world"];
    return (_x_0) => $IO$print$(run_loop($register$(($spawn$(($spawn$(_world_0, 10)), 20)))), _x_0);
  } else {
    return run_clo((_x_1) => {
  return $IO$die$(1, "world creation failed", _x_1);
});
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$045namespace$058fresh$(_k_0) {
  return { $: "$FFI", run: $0eff["../../../src/ecs/world-namespace.fresh"].run, need: $0eff["../../../src/ecs/world-namespace.fresh"].need, args: [], kont: (_k_0) };
}
function $$$$047$$$047$$$047src$047ecs$047world$045io$058with_namespace$1260$(_namespace_0, _resource_0) {
  return run_clo((_x_0) => {
  return $IO$pure$(($$$$047$$$047$$$047src$047ecs$047world$045io$058convert$1260$(($$$$047$$$047$$$047src$047ecs$047world$058create_checked$1260$(($Bool$and$((0 < _namespace_0), (_namespace_0 < 4294967295))), _namespace_0, _resource_0)))), _x_0);
});
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $register$(_world_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058add$1260$(run_clo((_x_0) => {
  return $add_growth$(_x_0);
}), run_clo((_x_1) => {
  return "water rejected";
}), ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty$1260$(_world_0)), true, "water", "garden");
}

function $spawn$(_world_0, _height_0) {
  return $spawned$(_height_0, ($$$$047$$$047$$$047src$047ecs$047world$058reserve_id$1260$(_world_0)));
}

function $IO$die$(_code_0, _msg_0, _k_0) {
  return {$: "Halt", "code": _code_0, "message": _msg_0};
}

function $IO$pure$(_x_0, _k_0) {
  return run_tail(_k_0, _x_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$045io$058convert$1260$(_created_0) {
  if (_created_0.$ === "../../../src/ecs/world.Created") {
    const _world_0 = _created_0["world"];
    return {$: "../../../src/ecs/world-io.Created", "world": _world_0};
  } else {
    const _resource_0 = _created_0["resource"];
    return {$: "../../../src/ecs/world-io.Refused", "resource": _resource_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../src/ecs/world.CreateRejected", "factory": {$: "../../../src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../src/ecs/world.Created", "factory": {$: "../../../src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058empty$()), "store": ($empty$({$: "Unit"})), "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058add$1260$(_done_0, _failed_0, _value_0, _args_0, _name_0, _slot_0) {
  const _app_0 = _value_0["app"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058register$1260$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_added$1260$(_args_0, _done_0, _x_0);
}), run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_rejected$1260$(_failed_0, _x_1);
}), _app_0, _name_0, _slot_0);
}

function $add_growth$(_app_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058add$1260$(run_clo((_x_0) => {
  return $attach$(_x_0);
}), run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return "capture rejected";
});
}), _app_0, {$: "Unit"}, "grow", {$: "Memory", "entered": 0, "total": array_new(0, 0), "sealed": run_clo((_x_3) => {
  return $seal$(array_new(0, 77), _x_3);
})});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty$1260$(_world_0) {
  return {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045composer$058empty$1260$(_world_0)), "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}};
}

function $spawned$(_height_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../src/ecs/world.Reserved") {
    const _handle_0 = _t_0["handle"];
    return $replaced$(($$$$047$$$047$$$047src$047ecs$047component$058replace$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058family$1260$(($binding$()))), ($$$$047$$$047$$$047src$047ecs$047world$058discard_status$1260$(($$$$047$$$047$$$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0)))), _handle_0, {$: "Some", "value": {$: "Plant", "height": _height_0}})));
  } else {
    return _world_0;
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058reserve_id$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058reserve_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve$(_allocator_0)));
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058empty$() {
  const _x_0 = {$: "../../../src/ecs/entity-allocator.Slot", "generation": 0, "phase": {$: "../../../src/ecs/entity-allocator.Consumed"}};
  return {$: "../../../src/ecs/entity-allocator.Allocator", "next": 1, "high": 0, "slots": array_new(0, _x_0), "capacity": 1, "depth": 0, "free": {$: "Nil"}, "order": {$: "Nil"}};
}

function $empty$(__0) {
  return $$$$047$$$047$$$047src$047ecs$047column$058empty$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058register$1260$(_done_0, _failed_0, _app_0, _name_0, _slot_0) {
  const _world_0 = _app_0["world"];
  const _owners_0 = _app_0["owners"];
  const _recipe_0 = _app_0["recipe"];
  const _debug_0 = _app_0["debug"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058defined$1260$(_done_0, _failed_0, _owners_0, _recipe_0, _debug_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_define$1260$(_world_0, _name_0, _slot_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_added$1260$(_args_0, _done_0, _result_0) {
  const _world_0 = _result_0["world"];
  const _t_0 = _result_0["owners"];
  const _owners_0 = _t_0["fst"];
  const _record_0 = _t_0["snd"];
  const _recipe_0 = _result_0["recipe"];
  const _debug_0 = _result_0["debug"];
  return run_tail(_done_0, {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": _record_0, "args": _args_0, "outputs": {$: "Nil"}}}, "recipe": _recipe_0, "debug": _debug_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_rejected$1260$(_failed_0, _result_0) {
  return run_tail(_failed_0, {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": _result_0, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058add$1260$(_done_0, _failed_0, _value_0, _args_0, _name_0, _capture_0) {
  const _app_0 = _value_0["app"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058added$1260$(_args_0, _done_0, _failed_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058register$1260$(_app_0, _name_0, _capture_0)));
}

function $attach$(_app_0) {
  return $attached$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058attach$1260$(($schema$()), _app_0, "Greenhouse", false)));
}

function $seal$(_array_0, __0) {
  return $sealed_value$({$: "Tuple", fst: _array_0, snd: _array_0[0 % _array_0.length]});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045composer$058empty$1260$(_world_0) {
  return {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": {$: "Unit"}, "recipe": {$: "../../../src/ecs/ordinary-app-recipe.Recipe"}, "debug": false};
}

function $replaced$(_result_0) {
  if (_result_0.$ === "../../../src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    return _world_0;
  } else {
    const _world_1 = _result_0["world"];
    return _world_1;
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058replace$1260$(_family_0, _world_0, _handle_0, _incoming_0) {
  return $$$$047$$$047$$$047src$047ecs$047component$058replace_allowed$1260$(($$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058family$1260$(_binding_0) {
  const _family_0 = _binding_0["family"];
  return _family_0;
}

function $binding$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058bind$1260$(($identity$()));
}

function $$$$047$$$047$$$047src$047ecs$047world$058discard_status$1260$(_observed_0) {
  const _world_0 = _observed_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047src$047ecs$047world$058activate$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058phase_checked$1260$({$: "../../../src/ecs/entity-allocator.Live"}, ($$$$047$$$047$$$047src$047ecs$047world$058handle_key$1260$(_handle_0)), ($$$$047$$$047$$$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058reserve_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, _reserved_0) {
  const _allocator_0 = _reserved_0["fst"];
  const _reservation_0 = _reserved_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047world$058reserve_result$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, _allocator_0, _reservation_0);
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve$(_allocator_0) {
  const _next_0 = _allocator_0["next"];
  const _high_0 = _allocator_0["high"];
  const _slots_0 = _allocator_0["slots"];
  const _capacity_0 = _allocator_0["capacity"];
  const _depth_0 = _allocator_0["depth"];
  const _t_0 = _allocator_0["free"];
  if (_t_0.$ === "Nil") {
    const _order_0 = _allocator_0["order"];
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve_fresh$((_next_0 < 131073), ($Bool$not$((_next_0 < _capacity_0))), {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": _slots_0, "capacity": _capacity_0, "depth": _depth_0, "free": {$: "Nil"}, "order": _order_0});
  } else {
    const _index_0 = _t_0["head"];
    const _free_0 = _t_0["tail"];
    const _order_1 = _allocator_0["order"];
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve_recycled$(_index_0, _next_0, _high_0, _capacity_0, _depth_0, _free_0, _order_1, {$: "Tuple", fst: _slots_0, snd: _slots_0[_index_0 % _slots_0.length]});
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058empty$1260$() {
  return {$: "../../../src/ecs/column.Column", "values": [{$: "None"}], "stamps": {$: "Nil"}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058defined$1260$(_done_0, _failed_0, _owners_0, _recipe_0, _debug_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-system.Rejected") {
    const _world_0 = _result_0["world"];
    return run_tail(_failed_0, {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_0, "recipe": _recipe_0, "debug": _debug_0});
  } else {
    const _world_1 = _result_0["world"];
    const _owner_0 = _result_0["owner"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058extracted$1260$(_done_0, _failed_0, _world_1, _owners_0, _debug_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045fields$058component$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_define$1260$(_world_0, _name_0, _slot_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_registered$1260$(_slot_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1263$(run_loop($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058operational$1260$(($water_query$()))))), ($$$$047$$$047$$$047src$047ecs$047system$058register$1260$(_world_0, _name_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058access$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1263$(run_loop($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058operational$1260$(($water_query$()))))))))));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058added$1260$(_args_0, _done_0, _failed_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-app-capture-query-fields.Appended") {
    const _t_0 = _result_0["app"];
    const _world_0 = _t_0["world"];
    const _t_1 = _t_0["owners"];
    const _owners_0 = _t_1["fst"];
    const _owner_0 = _t_1["snd"];
    const _recipe_0 = _t_0["recipe"];
    const _debug_0 = _t_0["debug"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058added_extracted$1260$(_args_0, _done_0, _world_0, _owners_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058fields$1260$(_owner_0)), _recipe_0, _debug_0);
  } else {
    const _app_0 = _result_0["app"];
    const _capture_0 = _result_0["capture"];
    return run_tail(_failed_0({$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": _app_0, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}), _capture_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058register$1260$(_app_0, _name_0, _capture_0) {
  const _world_0 = _app_0["world"];
  const _previous_0 = _app_0["owners"];
  const _recipe_0 = _app_0["recipe"];
  const _debug_0 = _app_0["debug"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058appended$1260$(_previous_0, _recipe_0, _debug_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058define$1260$(_world_0, _name_0, _capture_0)));
}

function $attached$(_result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-app-schedule.Attached") {
    const _app_0 = _result_0["app"];
    return $second$(($observe$(($run_result$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run$1260$(_app_0)))))));
  } else {
    return "attachment failed";
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058attach$1260$(_schema_0, _value_0, _name_0, _barrier_0) {
  const _t_0 = _value_0["app"];
  const _world_0 = _t_0["world"];
  const _owners_0 = _t_0["owners"];
  const _recipe_0 = _t_0["recipe"];
  const _debug_0 = _t_0["debug"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058planned$1260$(_schema_0, _world_0, _recipe_0, _debug_0, _name_0, _barrier_0, ($GPlan$())(_owners_0));
}

function $schema$() {
  return {$: "../../../src/ecs/ordinary-schema.Schema", "entries": {$: "Con", "head": {$: "../../../src/ecs/schema-fragments.Entry", "kind": {$: "../../../src/ecs/schema-fragments.Component"}, "key": "Plant", "name": "Plant"}, "tail": {$: "Nil"}}};
}

function $sealed_value$(_result_0) {
  const _value_0 = _result_0["snd"];
  return _value_0;
}

function $$$$047$$$047$$$047src$047ecs$047component$058replace_allowed$1260$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "../../../src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../src/ecs/world.MissingEntity"}};
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058checked$1260$(1, _world_0, _handle_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058bind$1260$(_identity_0) {
  return {$: "../../../src/ecs/ordinary-component-binding.Binding", "identity": _identity_0, "family": {$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(_identity_0))}};
}

function $identity$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058component$1260$("Plant");
}

function $$$$047$$$047$$$047src$047ecs$047world$058phase_checked$1260$(_phase_0, _key_0, _checked_0) {
  const _t_0 = _checked_0["fst"];
  const _namespace_0 = _t_0["namespace"];
  const _allocator_0 = _t_0["allocator"];
  const _store_0 = _t_0["store"];
  const _resource_0 = _t_0["resource"];
  const _events_0 = _t_0["events"];
  const _pending_0 = _t_0["pending"];
  const _registrations_0 = _t_0["registrations"];
  const _nextSystemId_0 = _t_0["nextSystemId"];
  const _clock_0 = _t_0["clock"];
  const _t_1 = _checked_0["snd"];
  if (!_t_1) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../src/ecs/world.Rejected", "error": {$: "../../../src/ecs/world.MissingEntity"}}};
  } else {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058write_phase$(_allocator_0, _key_0, _phase_0)), "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../src/ecs/world.Accepted"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058handle_key$1260$(_handle_0) {
  const _key_0 = _handle_0["key"];
  return _key_0;
}

function $$$$047$$$047$$$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058checked$1260$(0, _world_0, _handle_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058reserve_result$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, _allocator_0, _reservation_0) {
  if (_reservation_0.$ === "../../../src/ecs/entity-allocator.Exhausted") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../src/ecs/world.ReservationRejected", "error": {$: "../../../src/ecs/world.CapacityExceeded"}}};
  } else {
    const _key_0 = _reservation_0["key"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": {$: "../../../src/ecs/world.Reserved", "handle": {$: "../../../src/ecs/world.Handle", "namespace": _namespace_0, "key": _key_0}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve_fresh$(_available_0, _grow_0, _allocator_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _allocator_0, "snd": {$: "../../../src/ecs/entity-allocator.Exhausted"}};
  } else {
    if (!_grow_0) {
      const _next_0 = _allocator_0["next"];
      const _slots_0 = _allocator_0["slots"];
      const _capacity_0 = _allocator_0["capacity"];
      const _depth_0 = _allocator_0["depth"];
      const _free_0 = _allocator_0["free"];
      const _order_0 = _allocator_0["order"];
      const _x_0 = {$: "../../../src/ecs/entity-allocator.Slot", "generation": 0, "phase": {$: "../../../src/ecs/entity-allocator.Consumed"}};
      return {$: "Tuple", "fst": {$: "../../../src/ecs/entity-allocator.Allocator", "next": ((_next_0 + 1) >>> 0), "high": _next_0, "slots": (_slots_0[_next_0 % _slots_0.length] = _x_0, _slots_0), "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": ($List$append$(_order_0, {$: "Con", "head": {$: "../../../src/ecs/entity-key.EntityKey", "index": _next_0, "generation": 0}, "tail": {$: "Nil"}}))}, "snd": {$: "../../../src/ecs/entity-allocator.Reserved", "key": {$: "../../../src/ecs/entity-key.EntityKey", "index": _next_0, "generation": 0}}};
    } else {
      const _next_1 = _allocator_0["next"];
      const _slots_1 = _allocator_0["slots"];
      const _capacity_1 = _allocator_0["capacity"];
      const _depth_1 = _allocator_0["depth"];
      const _free_1 = _allocator_0["free"];
      const _order_1 = _allocator_0["order"];
      const _x_1 = {$: "../../../src/ecs/entity-allocator.Slot", "generation": 0, "phase": {$: "../../../src/ecs/entity-allocator.Consumed"}};
      const _x_2 = array_node(_slots_1, array_new(_depth_1, _x_1));
      const _x_3 = {$: "../../../src/ecs/entity-allocator.Slot", "generation": 0, "phase": {$: "../../../src/ecs/entity-allocator.Consumed"}};
      return {$: "Tuple", "fst": {$: "../../../src/ecs/entity-allocator.Allocator", "next": ((_next_1 + 1) >>> 0), "high": _next_1, "slots": (_x_2[_next_1 % _x_2.length] = _x_3, _x_2), "capacity": (Math.imul(_capacity_1, 2) >>> 0), "depth": nat_chk(_depth_1 + 1), "free": _free_1, "order": ($List$append$(_order_1, {$: "Con", "head": {$: "../../../src/ecs/entity-key.EntityKey", "index": _next_1, "generation": 0}, "tail": {$: "Nil"}}))}, "snd": {$: "../../../src/ecs/entity-allocator.Reserved", "key": {$: "../../../src/ecs/entity-key.EntityKey", "index": _next_1, "generation": 0}}};
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

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058reserve_recycled$(_index_0, _next_0, _high_0, _capacity_0, _depth_0, _free_0, _order_0, _observed_0) {
  const _slots_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _generation_0 = _t_0["generation"];
  const _x_0 = {$: "../../../src/ecs/entity-allocator.Slot", "generation": _generation_0, "phase": {$: "../../../src/ecs/entity-allocator.Consumed"}};
  return {$: "Tuple", "fst": {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": (_slots_0[_index_0 % _slots_0.length] = _x_0, _slots_0), "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": ($List$append$(_order_0, {$: "Con", "head": {$: "../../../src/ecs/entity-key.EntityKey", "index": _index_0, "generation": _generation_0}, "tail": {$: "Nil"}}))}, "snd": {$: "../../../src/ecs/entity-allocator.Reserved", "key": {$: "../../../src/ecs/entity-key.EntityKey", "index": _index_0, "generation": _generation_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058extracted$1260$(_done_0, _failed_0, _world_0, _owners_0, _debug_0, _result_0) {
  const _token_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return run_tail(_done_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045composer$058appended$1260$(_world_0, _owners_0, {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, _debug_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045fields$058component$1260$(_owner_0) {
  const _registry_0 = _owner_0["registry"];
  const _slot_0 = _owner_0["slot"];
  const _clauses_0 = _owner_0["clauses"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045fields$058component_registry$1260$(_slot_0, _clauses_0, _registry_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_registered$1260$(_slot_0, _clauses_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/system.RegistrationFailed") {
    const _world_0 = _result_0["world"];
    return {$: "../../../src/ecs/ordinary-system.Rejected", "world": _world_0};
  } else {
    const _world_1 = _result_0["world"];
    const _registry_0 = _result_0["registry"];
    return {$: "../../../src/ecs/ordinary-system.Defined", "world": _world_1, "owner": {$: "../../../src/ecs/ordinary-system.Owner", "registry": _registry_0, "slot": _slot_0, "clauses": _clauses_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1263$(_declaration_0) {
  const _clauses_0 = _declaration_0["clauses"];
  return _clauses_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058operational$1260$(_declaration_0) {
  const _operational_0 = _declaration_0["operational"];
  return run_tail(_operational_0, {$: "Unit"});
}

function $water_query$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058write$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047system$058register$1260$(_world_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047src$047ecs$047system$058register_namespace$1260$(($$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058access$1260$(_clauses_0) {
  if (_clauses_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _clauses_0["head"];
    const _name_0 = _t_0["name"];
    const _rest_0 = _clauses_0["tail"];
    return {$: "Con", "head": _name_0, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058access$1260$(_rest_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058added_extracted$1260$(_args_0, _done_0, _world_0, _owners_0, _result_0, _recipe_0, _debug_0) {
  const _owner_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return run_tail(_done_0, {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _owner_0, "fields": _fields_0}, "args": _args_0, "outputs": {$: "Nil"}}}, "recipe": _recipe_0, "debug": _debug_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058fields$1260$(_owner_0) {
  const _t_0 = _owner_0["instance"];
  const _ns_0 = _t_0["namespace"];
  const _id_0 = _t_0["id"];
  const _name_0 = _t_0["name"];
  const _access_0 = _t_0["access"];
  const _capture_0 = _t_0["local"];
  const _cursor_0 = _owner_0["cursor"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": {$: "../../../src/ecs/local.Instance", "namespace": _ns_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _capture_0}, "cursor": _cursor_0}, "snd": {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _ns_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _name_0, "clauses": ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1262$(($growth_query$()))), "kind": {$: "../../../src/ecs/ordinary-app-registration-fields.ComponentKind"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058appended$1260$(_previous_0, _recipe_0, _debug_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-capture-query.Rejected") {
    const _world_0 = _result_0["world"];
    const _capture_0 = _result_0["capture"];
    return {$: "../../../src/ecs/ordinary-app-capture-query-fields.AppendRejected", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _previous_0, "recipe": _recipe_0, "debug": _debug_0}, "capture": _capture_0};
  } else {
    const _world_1 = _result_0["world"];
    const _owner_0 = _result_0["owner"];
    return {$: "../../../src/ecs/ordinary-app-capture-query-fields.Appended", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_1, "owners": {$: "Tuple", "fst": _previous_0, "snd": _owner_0}, "recipe": _recipe_0, "debug": _debug_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058define$1260$(_world_0, _name_0, _capture_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058registered$1260$(($$$$047$$$047$$$047src$047ecs$047captures$058register$1260$(_world_0, _name_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058access$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1262$(($growth_query$()))))), _capture_0)));
}

function $second$(_result_0) {
  const _app_0 = _result_0["fst"];
  const _row_0 = _result_0["snd"];
  return $third$((_row_0 + "\n"), ($observe$(($run_result$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run$1260$(_app_0)))))));
}

function $observe$(_result_0) {
  const _app_0 = _result_0["fst"];
  const _status_0 = _result_0["snd"];
  return $observe_values$(_status_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058inspect$1260$(_app_0)));
}

function $run_result$(_result_0) {
  const _t_0 = _result_0["result"];
  if (_t_0.$ === "../../../src/ecs/ordinary-app-schedule.Finished") {
    const _app_0 = _t_0["app"];
    return {$: "Tuple", "fst": _app_0, "snd": 1};
  } else if (_t_0.$ === "../../../src/ecs/ordinary-app-schedule.Failed") {
    const _app_1 = _t_0["app"];
    const _t_1 = _t_0["error"];
    if (_t_1.$ === "../../../src/ecs/captured-schedule-composition.RightError") {
      const _t_2 = _t_1["error"];
      if (_t_2.$ === "../../../src/ecs/ordinary-app-capture-query.CallbackFailure") {
        const _t_3 = _t_2["error"];
        if (_t_3.$ === "../../../src/ecs/compose.UserError") {
          const _t_4 = _t_3["error"];
          const _t_5 = _t_4["entered"];
          if (_t_5 == 2) {
            return {$: "Tuple", "fst": _app_1, "snd": 2};
          } else {
            return {$: "Tuple", "fst": _app_1, "snd": 998};
          }
        } else {
          return {$: "Tuple", "fst": _app_1, "snd": 998};
        }
      } else {
        return {$: "Tuple", "fst": _app_1, "snd": 998};
      }
    } else {
      return {$: "Tuple", "fst": _app_1, "snd": 998};
    }
  } else if (_t_0.$ === "../../../src/ecs/ordinary-app-schedule.Rejected") {
    const _app_2 = _t_0["app"];
    return {$: "Tuple", "fst": _app_2, "snd": 997};
  } else {
    const _app_3 = _t_0["app"];
    return {$: "Tuple", "fst": _app_3, "snd": 996};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run$1260$(_value_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run_when$1260$(_value_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058planned$1260$(_schema_0, _world_0, _recipe_0, _debug_0, _name_0, _barrier_0, _result_0) {
  const _owners_0 = _result_0["fst"];
  const _selected_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058folded$1260$(_schema_0, _world_0, _recipe_0, _debug_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058initial$1260$(_barrier_0, _selected_0)), _name_0, ($GFold$())(_owners_0));
}

function $GPlan$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_plan$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047component$058replace_clock$1260$(_id_0, _incoming_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _tick_0 = _clocked_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058replace_clock_checked$1260$((_tick_0 < 4294967295), _world_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047component$058owner_present$1260$(_incoming_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _clock_0};
}

function $$$$047$$$047$$$047src$047ecs$047world$058checked$1260$(_mode_0, _world_0, _handle_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _ns_0 = _handle_0["namespace"];
  const _key_0 = _handle_0["key"];
  return $$$$047$$$047$$$047src$047ecs$047world$058checked_namespace$1260$((_namespace_0 === _ns_0), _mode_0, {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _key_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(_declaration_0) {
  const _key_0 = _declaration_0["key"];
  return _key_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058component$1260$(_key_0) {
  return {$: "../../../src/ecs/ordinary-declaration.Declaration", "key": _key_0};
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058write_phase$(_allocator_0, _key_0, _phase_0) {
  const _next_0 = _allocator_0["next"];
  const _high_0 = _allocator_0["high"];
  const _slots_0 = _allocator_0["slots"];
  const _capacity_0 = _allocator_0["capacity"];
  const _depth_0 = _allocator_0["depth"];
  const _free_0 = _allocator_0["free"];
  const _order_0 = _allocator_0["order"];
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0));
  const _x_1 = ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058phase_slot$(_key_0, _phase_0));
  return {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": (_slots_0[_x_0 % _slots_0.length] = _x_1, _slots_0), "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": _order_0};
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

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045composer$058appended$1260$(_world_0, _owners_0, _leaf_0, _debug_0) {
  return {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": {$: "Tuple", "fst": _owners_0, "snd": _leaf_0}, "recipe": {$: "../../../src/ecs/ordinary-app-recipe.Recipe"}, "debug": _debug_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045fields$058component_registry$1260$(_slot_0, _clauses_0, _registry_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-registration-fields.Token"}, "snd": {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _slot_0, "clauses": _clauses_0, "kind": {$: "../../../src/ecs/ordinary-app-registration-fields.ComponentKind"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058write$1260$() {
  return {$: "../../../src/ecs/ordinary-query-observable.Declaration", "operational": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1260$();
}), "inspection": run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045selections$058inspect_slot$1260$();
})};
}

function $$$$047$$$047$$$047src$047ecs$047system$058register_namespace$1260$(_named_0, _name_0, _access_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047system$058register_join$1260$(($$$$047$$$047$$$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _namespace_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1262$(_declaration_0) {
  const _clauses_0 = _declaration_0["clauses"];
  return _clauses_0;
}

function $growth_query$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058pair$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058registered$1260$(_result_0) {
  if (_result_0.$ === "../../../src/ecs/local.Registered") {
    const _world_0 = _result_0["world"];
    const _instance_0 = _result_0["instance"];
    return {$: "../../../src/ecs/ordinary-capture-query.Registered", "world": _world_0, "owner": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": _instance_0, "cursor": 0}};
  } else {
    const _world_1 = _result_0["world"];
    const _capture_0 = _result_0["local"];
    return {$: "../../../src/ecs/ordinary-capture-query.Rejected", "world": _world_1, "capture": _capture_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047captures$058register$1260$(_world_0, _name_0, _access_0, _local_0) {
  return $$$$047$$$047$$$047src$047ecs$047local$058register$1260$(_world_0, _name_0, _access_0, _local_0);
}

function $third$(_prefix_0, _result_0) {
  const _app_0 = _result_0["fst"];
  const _row_0 = _result_0["snd"];
  const _x_0 = (_row_0 + "\n");
  return $fourth$((_prefix_0 + _x_0), ($observe$(($run_result$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058update_owners$1260$(_app_0, false)))))))));
}

function $observe_values$(_status_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _t_1 = _t_0["app"];
  const _t_2 = _t_1["app"];
  const _schema_0 = _t_2["schema"];
  const _t_3 = _t_2["app"];
  const _world_0 = _t_3["world"];
  const _owners_0 = _t_3["owners"];
  const _recipe_0 = _t_3["recipe"];
  const _debug_0 = _t_3["debug"];
  const _selected_0 = _t_1["plan"];
  const _ns_0 = _t_1["namespace"];
  const _name_0 = _t_1["name"];
  const _steps_0 = _t_1["steps"];
  const _needs_0 = _t_1["needs"];
  const _execution_0 = _t_0["execution"];
  const _points_0 = _result_0["snd"];
  return $observe_owners$(run_clo((_x_0) => {
  return {$: "../../../src/ecs/ordinary-app-run.Application", "app": {$: "../../../src/ecs/ordinary-app-schedule.Application", "app": {$: "../../../src/ecs/ordinary-app-schema.Application", "schema": _schema_0, "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _x_0, "recipe": _recipe_0, "debug": _debug_0}}, "plan": _selected_0, "namespace": _ns_0, "name": _name_0, "steps": _steps_0, "needs": _needs_0}, "execution": _execution_0};
}), _status_0, _points_0, _owners_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058inspect$1260$(_value_0) {
  const _t_0 = _value_0["app"];
  const _t_1 = _t_0["app"];
  const _schema_0 = _t_1["schema"];
  const _t_2 = _t_1["app"];
  const _world_0 = _t_2["world"];
  const _owners_0 = _t_2["owners"];
  const _recipe_0 = _t_2["recipe"];
  const _debug_0 = _t_2["debug"];
  const _selected_0 = _t_0["plan"];
  const _namespace_0 = _t_0["namespace"];
  const _name_0 = _t_0["name"];
  const _steps_0 = _t_0["steps"];
  const _needs_0 = _t_0["needs"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058inspected$1260$(_schema_0, _owners_0, _recipe_0, _debug_0, _selected_0, _namespace_0, _name_0, _steps_0, _needs_0, ($report$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run_when$1260$(_value_0) {
  const _app_0 = _value_0["app"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058executed$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058run$1260$(_app_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058folded$1260$(_schema_0, _world_0, _recipe_0, _debug_0, _selected_0, _name_0, _result_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  const _owners_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058checked$1260$(($$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058identities_valid$(_namespace_0, _registrations_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058identities$1260$(_fields_0)), {$: "Nil"})), _schema_0, {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _owners_0, _recipe_0, _debug_0, _selected_0, _namespace_0, _name_0, ($$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058ids$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058identities$1260$(_fields_0)))));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058initial$1260$(_barrier_0, _plan_0) {
  if (!_barrier_0) {
    return _plan_0;
  } else {
    return {$: "../../../src/ecs/schedule-provision.Sequence", "left": {$: "../../../src/ecs/schedule-provision.Entry", "step": {$: "../../../src/ecs/schedule.Barrier"}, "requirements": {$: "Nil"}}, "right": _plan_0};
  }
}

function $GFold$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_fold$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_plan$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_pair$1261$(_x_0);
});
}

function $$$$047$$$047$$$047src$047ecs$047component$058replace_clock_checked$1260$(_allowed_0, _world_0, _id_0, _observed_0) {
  if (!_allowed_0) {
    const _incoming_0 = _observed_0["fst"];
    return {$: "../../../src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../src/ecs/world.CapacityExceeded"}};
  } else {
    const _incoming_1 = _observed_0["fst"];
    const _present_0 = _observed_0["snd"];
    return $$$$047$$$047$$$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _present_0, _incoming_1, ($$$$047$$$047$$$047src$047ecs$047world$058advance_clock$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058owner_present$1260$(_owner_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "None"}, "snd": false};
  } else {
    const _owner_1 = _owner_0["value"];
    return {$: "Tuple", "fst": {$: "Some", "value": _owner_1}, "snd": true};
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058checked_namespace$1260$(_allowed_0, _mode_0, _world_0, _key_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _world_0, "snd": false};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _allocator_0 = _world_0["allocator"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    return $$$$047$$$047$$$047src$047ecs$047world$058checked_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked$(_allocator_0, _key_0, _mode_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0) {
  const _index_0 = _key_0["index"];
  return _index_0;
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058phase_slot$(_key_0, _phase_0) {
  return {$: "../../../src/ecs/entity-allocator.Slot", "generation": ($$$$047$$$047$$$047src$047ecs$047entity$045key$058generation$(_key_0)), "phase": _phase_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1260$() {
  return {$: "../../../src/ecs/ordinary-query-declaration.Declaration", "grant": ($$$$047$$$047$$$047src$047ecs$047compose$058write_family$1260$()), "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058family_match$1260$(_x_0);
}), "clauses": {$: "Con", "head": {$: "../../../src/ecs/ordinary-query-declaration.Clause", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058identity$1260$(($binding$()))))), "mode": {$: "../../../src/ecs/ordinary-query-declaration.Write"}}, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045selections$058inspect_slot$1260$() {
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_slot$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047system$058register_join$1260$(_registered_0, _namespace_0, _name_0, _access_0) {
  const _world_0 = _registered_0["fst"];
  const _result_0 = _registered_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058register_checked$1260$((_nextSystemId_0 < 4294967295), {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _name_0, _access_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058pair$1260$() {
  return {$: "../../../src/ecs/ordinary-query-declaration.Declaration", "grant": {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1261$()))), "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058changed$1260$())))}, "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058both$1260$(_x_0);
}), "clauses": ($List$append$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1261$()))), ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058changed$1260$())))))};
}

function $$$$047$$$047$$$047src$047ecs$047local$058register$1260$(_world_0, _name_0, _access_0, _local_0) {
  return $$$$047$$$047$$$047src$047ecs$047local$058register_named$1260$(($$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0)), _name_0, _access_0, _local_0);
}

function $fourth$(_prefix_0, _result_0) {
  const _app_0 = _result_0["fst"];
  const _row_0 = _result_0["snd"];
  const _x_0 = (_row_0 + "\n");
  return $joined$((_prefix_0 + _x_0), ($observe$(($run_result$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058run$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058update_owners$1260$(_app_0, true)))))))));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058update_owners$1260$(_value_0, _args_0) {
  const _t_0 = _value_0["app"];
  const _t_1 = _t_0["app"];
  const _schema_0 = _t_1["schema"];
  const _t_2 = _t_1["app"];
  const _world_0 = _t_2["world"];
  const _owners_0 = _t_2["owners"];
  const _recipe_0 = _t_2["recipe"];
  const _debug_0 = _t_2["debug"];
  const _selected_0 = _t_0["plan"];
  const _namespace_0 = _t_0["namespace"];
  const _name_0 = _t_0["name"];
  const _steps_0 = _t_0["steps"];
  const _needs_0 = _t_0["needs"];
  const _execution_0 = _value_0["execution"];
  return {$: "../../../src/ecs/ordinary-app-run.Application", "app": {$: "../../../src/ecs/ordinary-app-schedule.Application", "app": {$: "../../../src/ecs/ordinary-app-schema.Application", "schema": _schema_0, "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": ($with_water$(_owners_0, _args_0)), "recipe": _recipe_0, "debug": _debug_0}}, "plan": _selected_0, "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "needs": _needs_0}, "execution": _execution_0};
}

function $observe_owners$(_rebuild_0, _status_0, _points_0, _owners_0) {
  const _t_0 = _owners_0["fst"];
  const _base_0 = _t_0["fst"];
  const _t_1 = _t_0["snd"];
  const _waterRecord_0 = _t_1["record"];
  const _waterArgs_0 = _t_1["args"];
  const _water_0 = _t_1["outputs"];
  const _t_2 = _owners_0["snd"];
  const _t_3 = _t_2["record"];
  const _t_4 = _t_3["token"];
  const _t_5 = _t_4["instance"];
  const _ns_0 = _t_5["namespace"];
  const _id_0 = _t_5["id"];
  const _name_0 = _t_5["name"];
  const _access_0 = _t_5["access"];
  const _t_6 = _t_5["local"];
  const _entered_0 = _t_6["entered"];
  const _total_0 = _t_6["total"];
  const _sealed_0 = _t_6["sealed"];
  const _cursor_0 = _t_4["cursor"];
  const _fields_0 = _t_3["fields"];
  const _args_0 = _t_2["args"];
  const _growth_0 = _t_2["outputs"];
  return $memory_seen$(run_clo((_x_0) => {
  return run_tail(_rebuild_0, {$: "Tuple", "fst": {$: "Tuple", "fst": _base_0, "snd": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": _waterRecord_0, "args": _waterArgs_0, "outputs": _water_0}}, "snd": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": {$: "../../../src/ecs/local.Instance", "namespace": _ns_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _x_0}, "cursor": _cursor_0}, "fields": _fields_0}, "args": _args_0, "outputs": _growth_0}});
}), _status_0, _points_0, _water_0, _growth_0, _cursor_0, _entered_0, _sealed_0, {$: "Tuple", fst: _total_0, snd: _total_0[0 % _total_0.length]});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058inspected$1260$(_schema_0, _owners_0, _recipe_0, _debug_0, _selected_0, _namespace_0, _name_0, _steps_0, _needs_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _value_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-run.Application", "app": {$: "../../../src/ecs/ordinary-app-schedule.Application", "app": {$: "../../../src/ecs/ordinary-app-schema.Application", "schema": _schema_0, "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_0, "recipe": _recipe_0, "debug": _debug_0}}, "plan": _selected_0, "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "needs": _needs_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}, "snd": _value_0};
}

function $report$(_world_0) {
  return $got_handles$(($$$$047$$$047$$$047src$047ecs$047world$058handles$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058executed$1260$(_result_0) {
  const _result_1 = _result_0["result"];
  const _batch_0 = _result_0["batch"];
  return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058returned$1260$(_result_1)), "batch": _batch_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058run$1260$(_value_0) {
  const _t_0 = _value_0["app"];
  const _schema_0 = _t_0["schema"];
  const _t_1 = _t_0["app"];
  const _world_0 = _t_1["world"];
  const _owners_0 = _t_1["owners"];
  const _recipe_0 = _t_1["recipe"];
  const _t_2 = _t_1["debug"];
  if (!_t_2) {
    const _plan_0 = _value_0["plan"];
    const _namespace_0 = _value_0["namespace"];
    const _name_0 = _value_0["name"];
    const _steps_0 = _value_0["steps"];
    const _needs_0 = _value_0["needs"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058start$1260$(_schema_0, _world_0, _recipe_0, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0, _owners_0, {$: "../../../src/ecs/ordinary-app-execution.Off"});
  } else {
    const _plan_1 = _value_0["plan"];
    const _namespace_1 = _value_0["namespace"];
    const _name_1 = _value_0["name"];
    const _steps_1 = _value_0["steps"];
    const _needs_1 = _value_0["needs"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058prepared$1260$(_schema_0, _world_0, _recipe_0, _plan_1, _namespace_1, _name_1, _steps_1, _needs_1, ($GFold$())(_owners_0));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058checked$1260$(_valid_0, _schema_0, _world_0, _owners_0, _recipe_0, _debug_0, _selected_0, _namespace_0, _name_0, _ids_0) {
  if (!_valid_0) {
    return {$: "../../../src/ecs/ordinary-app-schedule.Invalid", "app": {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_0, "recipe": _recipe_0, "debug": _debug_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}};
  } else {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058built$1260$(_schema_0, _world_0, _recipe_0, _debug_0, _selected_0, ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058build$1260$(_namespace_0, _name_0, _selected_0, _ids_0, _owners_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058identities_valid$(_namespace_0, _registered_0, _items_0, _seen_0) {
  if (_items_0.$ === "Nil") {
    return true;
  } else {
    const _t_0 = _items_0["head"];
    const _ns_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _rest_0 = _items_0["tail"];
    return $Bool$and$((_namespace_0 === _ns_0), ($Bool$and$(($$$$047$$$047$$$047src$047ecs$047world$058registration_list_matches$(_registered_0, _id_0, _name_0, _access_0)), ($Bool$and$(($Bool$not$(($$$$047$$$047$$$047src$047ecs$047schedule$058contains$(_seen_0, _id_0)))), ($$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058identities_valid$(_namespace_0, _registered_0, _rest_0, {$: "Con", "head": _id_0, "tail": _seen_0})))))));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058identities$1260$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _fields_0["head"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _rest_0 = _fields_0["tail"];
    return {$: "Con", "head": {$: "../../../src/ecs/captured-schedule-composition.Identity", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058identities$1260$(_rest_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058ids$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _id_0 = _t_0["id"];
    const _rest_0 = _items_0["tail"];
    return {$: "Con", "head": _id_0, "tail": ($$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058ids$(_rest_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_fold$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058fold_pair$1261$(_x_0);
});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_pair$1261$(_owners_0) {
  const _a_0 = _owners_0["fst"];
  const _b_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_left$1261$(_b_0, ($APlan$())(_a_0));
}

function $$$$047$$$047$$$047src$047ecs$047component$058replace_clock_advanced$1260$(_id_0, _incomingPresent_0, _incoming_0, _advanced_0) {
  const _world_0 = _advanced_0["fst"];
  const _tick_0 = _advanced_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058replaced$1260$(($$$$047$$$047$$$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058advance_clock$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": ($$$$047$$$047$$$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))}, "snd": ($$$$047$$$047$$$047src$047ecs$047world$058next_clock$((_clock_0 < 4294967295), _clock_0))};
}

function $$$$047$$$047$$$047src$047ecs$047world$058checked_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, _checked_0) {
  const _allocator_0 = _checked_0["fst"];
  const _valid_0 = _checked_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _valid_0};
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked$(_allocator_0, _key_0, _mode_0) {
  const _next_0 = _allocator_0["next"];
  const _high_0 = _allocator_0["high"];
  const _slots_0 = _allocator_0["slots"];
  const _capacity_0 = _allocator_0["capacity"];
  const _depth_0 = _allocator_0["depth"];
  const _free_0 = _allocator_0["free"];
  const _order_0 = _allocator_0["order"];
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0));
  const _x_1 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0));
  const _x_2 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0));
  return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked_bounds$(($Bool$and$((0 < _x_0), ($Bool$and$((_x_1 < _next_0), (_x_2 < _capacity_0))))), {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": _slots_0, "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": _order_0}, _key_0, _mode_0);
}

function $$$$047$$$047$$$047src$047ecs$047entity$045key$058generation$(_key_0) {
  const _generation_0 = _key_0["generation"];
  return _generation_0;
}

function $$$$047$$$047$$$047src$047ecs$047compose$058write_family$1260$() {
  return {$: "../../../src/ecs/capabilities.Write", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058get$1260$(_x_0);
}), "set": run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058set$1260$(_x_1, _x_2);
});
})};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058family_match$1260$(_frame_0) {
  return $$$$047$$$047$$$047src$047ecs$047compose$058selected_join$1260$({$: "../../../src/ecs/compose.Required"}, ($$$$047$$$047$$$047src$047ecs$047compose$058get$1260$(_frame_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058identity$1260$(_binding_0) {
  const _identity_0 = _binding_0["identity"];
  return _identity_0;
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_slot$1260$() {
  return {$: "../../../src/ecs/inspector-query-projection.DeclaredSelection", "matches": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_matches$1260$(_x_0, _x_1);
});
}), "project": run_clo((_x_2) => {
  return run_clo((_x_3) => {
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_read$1260$(_x_2, _x_3);
});
})};
}

function $$$$047$$$047$$$047src$047ecs$047system$058register_meta$1260$(_world_0, _result_0, _namespace_0, _name_0, _access_0) {
  if (_result_0.$ === "../../../src/ecs/world.RegistrationRejected") {
    return {$: "../../../src/ecs/system.RegistrationFailed", "world": _world_0};
  } else {
    const _id_0 = _result_0["id"];
    return {$: "../../../src/ecs/system.Registered", "world": _world_0, "registry": {$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": 0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058register_checked$1260$(_available_0, _world_0, _name_0, _access_0) {
  if (!_available_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../src/ecs/world.RegistrationRejected", "error": {$: "../../../src/ecs/world.SystemIdExhausted"}}};
  } else {
    const _namespace_0 = _world_0["namespace"];
    const _allocator_0 = _world_0["allocator"];
    const _store_0 = _world_0["store"];
    const _resource_0 = _world_0["resource"];
    const _events_0 = _world_0["events"];
    const _pending_0 = _world_0["pending"];
    const _registrations_0 = _world_0["registrations"];
    const _nextSystemId_0 = _world_0["nextSystemId"];
    const _clock_0 = _world_0["clock"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": {$: "Con", "head": {$: "../../../src/ecs/world.RegistrationMeta", "id": _nextSystemId_0, "name": _name_0, "access": _access_0}, "tail": _registrations_0}, "nextSystemId": ((_nextSystemId_0 + 1) >>> 0), "clock": _clock_0}, "snd": {$: "../../../src/ecs/world.Registered", "id": _nextSystemId_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1260$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  return _grant_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1261$() {
  return {$: "../../../src/ecs/ordinary-query-declaration.Declaration", "grant": ($$$$047$$$047$$$047src$047ecs$047compose$058write_family$1261$()), "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058family_match$1261$(_x_0);
}), "clauses": {$: "Con", "head": {$: "../../../src/ecs/ordinary-query-declaration.Clause", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($identity$()))), "mode": {$: "../../../src/ecs/ordinary-query-declaration.Write"}}, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1261$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  return _grant_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058changed$1260$() {
  return {$: "../../../src/ecs/ordinary-query-declaration.Declaration", "grant": {$: "Unit"}, "select": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_match$1260$(_x_0);
}), "clauses": {$: "Con", "head": {$: "../../../src/ecs/ordinary-query-declaration.Clause", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($identity$()))), "mode": {$: "../../../src/ecs/ordinary-query-declaration.Changed"}}, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058both$1260$(_owner_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selected_left$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058write$1261$())))(_owner_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1260$(_declaration_0) {
  const _clauses_0 = _declaration_0["clauses"];
  return _clauses_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058clauses$1261$(_declaration_0) {
  const _clauses_0 = _declaration_0["clauses"];
  return _clauses_0;
}

function $$$$047$$$047$$$047src$047ecs$047local$058register_named$1260$(_named_0, _name_0, _access_0, _local_0) {
  const _world_0 = _named_0["fst"];
  const _namespace_0 = _named_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047local$058register_result$1260$(($$$$047$$$047$$$047src$047ecs$047world$058register$1260$(_world_0, _name_0, _access_0)), _namespace_0, _name_0, _access_0, _local_0);
}

function $joined$(_prefix_0, _result_0) {
  const _app_0 = _result_0["fst"];
  const _row_0 = _result_0["snd"];
  const _x_0 = ($U32$show$(run_loop($finish_app$(_app_0))));
  const _x_1 = ("\nsealed=" + _x_0);
  const _x_2 = (_row_0 + _x_1);
  return (_prefix_0 + _x_2);
}

function $with_water$(_owners_0, _enabled_0) {
  const _t_0 = _owners_0["fst"];
  const _base_0 = _t_0["fst"];
  const _t_1 = _t_0["snd"];
  const _record_0 = _t_1["record"];
  const _outputs_0 = _t_1["outputs"];
  const _growth_0 = _owners_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _base_0, "snd": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": _record_0, "args": _enabled_0, "outputs": _outputs_0}}, "snd": _growth_0};
}

function $memory_seen$(_rebuild_0, _status_0, _points_0, _water_0, _growth_0, _cursor_0, _entered_0, _sealed_0, _result_0) {
  const _total_0 = _result_0["fst"];
  const _sum_0 = _result_0["snd"];
  const _x_0 = ($nums$(_growth_0));
  const _x_1 = ($nums$(_water_0));
  const _x_2 = ("|" + _x_0);
  const _x_3 = (_x_1 + _x_2);
  const _x_4 = ($nums$(_points_0));
  const _x_5 = ("|" + _x_3);
  const _x_6 = (_x_4 + _x_5);
  const _x_7 = ($nums$({$: "Con", "head": _status_0, "tail": {$: "Con", "head": _cursor_0, "tail": {$: "Con", "head": _entered_0, "tail": {$: "Con", "head": _sum_0, "tail": {$: "Nil"}}}}}));
  const _x_8 = ("|" + _x_6);
  return {$: "Tuple", "fst": _rebuild_0({$: "Memory", "entered": _entered_0, "total": _total_0, "sealed": _sealed_0}), "snd": (_x_7 + _x_8)};
}

function $got_handles$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _handles_0 = _result_0["snd"];
  return $world_values$(_handles_0, _world_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058handles$1260$(_world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058handles_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, run_loop($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible$(_allocator_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058returned$1260$(_result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-app-schedule.Finished") {
    const _app_0 = _result_0["app"];
    const _observations_0 = _result_0["observations"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Finished", "app": {$: "../../../src/ecs/ordinary-app-run.Application", "app": _app_0, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}, "observations": _observations_0};
  } else if (_result_0.$ === "../../../src/ecs/ordinary-app-schedule.Failed") {
    const _app_1 = _result_0["app"];
    const _error_0 = _result_0["error"];
    const _observations_1 = _result_0["observations"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Failed", "app": {$: "../../../src/ecs/ordinary-app-run.Application", "app": _app_1, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}, "error": _error_0, "observations": _observations_1};
  } else if (_result_0.$ === "../../../src/ecs/ordinary-app-schedule.Rejected") {
    const _app_2 = _result_0["app"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Rejected", "app": {$: "../../../src/ecs/ordinary-app-run.Application", "app": _app_2, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}};
  } else {
    const _app_3 = _result_0["app"];
    const _requirements_0 = _result_0["requirements"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Missing", "app": {$: "../../../src/ecs/ordinary-app-run.Application", "app": _app_3, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}, "requirements": _requirements_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058start$1260$(_schema_0, _world_0, _recipe_0, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0, _owners_0, _state_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058provisioned$1260$(_schema_0, _recipe_0, _plan_0, ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_with_barrier$1260$({$: "../../../src/ecs/schedule-provision.Provisioned", "schedule": {$: "../../../src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "owners": {$: "Tuple", "fst": _owners_0, "snd": _state_0}}, "requirements": _needs_0}, _world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058prepared$1260$(_schema_0, _world_0, _recipe_0, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0, _value_0) {
  const _owners_0 = _value_0["fst"];
  const _fields_0 = _value_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058start$1260$(_schema_0, _world_0, _recipe_0, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0, _owners_0, {$: "../../../src/ecs/ordinary-app-execution.On", "journal": {$: "../../../src/ecs/ordinary-app-execution.Journal", "catalog": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058catalog$1260$(_fields_0)), "events": {$: "Nil"}}});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058built$1260$(_schema_0, _world_0, _recipe_0, _debug_0, _selected_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/schedule-provision.Invalid") {
    const _owners_0 = _result_0["owners"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Invalid", "app": {$: "../../../src/ecs/ordinary-app-execution-recipe.Registered", "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_0, "recipe": _recipe_0, "debug": _debug_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}};
  } else {
    const _t_0 = _result_0["schedule"];
    const _t_1 = _t_0["schedule"];
    const _namespace_0 = _t_1["namespace"];
    const _name_0 = _t_1["name"];
    const _steps_0 = _t_1["steps"];
    const _owners_1 = _t_1["owners"];
    const _needs_0 = _t_0["requirements"];
    return {$: "../../../src/ecs/ordinary-app-schedule.Attached", "app": {$: "../../../src/ecs/ordinary-app-run.Application", "app": {$: "../../../src/ecs/ordinary-app-schedule.Application", "app": {$: "../../../src/ecs/ordinary-app-schema.Application", "schema": _schema_0, "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_1, "recipe": _recipe_0, "debug": _debug_0}}, "plan": _selected_0, "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "needs": _needs_0}, "execution": {$: "../../../src/ecs/ordinary-app-execution-recipe.Recipe"}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058build$1260$(_namespace_0, _name_0, _plan_0, _catalog_0, _owners_0) {
  return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058finish_build$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$058build$1260$(_namespace_0, _name_0, ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058flatten$1260$(_plan_0)), _catalog_0, _owners_0)), ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058requirements$1260$(_plan_0)))));
}

function $$$$047$$$047$$$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058registration_list_walk$(_registrations_0, _id_0, _name_0, _access_0, false);
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058contains$(_ids_0, _id_0) {
  if (_ids_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _ids_0["head"];
    const _rest_0 = _ids_0["tail"];
    const _x_0 = (_head_0 === _id_0);
    const _x_1 = ($$$$047$$$047$$$047src$047ecs$047schedule$058contains$(_rest_0, _id_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058fold_pair$1261$(_owners_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058pair$1261$(($AFold$()), run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_fields$1261$(_x_0);
}), _owners_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_left$1261$(_owner_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_right$1261$(_left_0, _before_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_plan$1261$(_owner_0)));
}

function $APlan$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_plan$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047component$058replaced$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../src/ecs/component.Swapped") {
    const _previous_0 = _t_0["previous"];
    return {$: "../../../src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0};
  } else {
    const _incoming_0 = _t_0["incoming"];
    return {$: "../../../src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../src/ecs/world.CapacityExceeded"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058swap_world$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1265$(($$$$047$$$047$$$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058next_clock$(_available_0, _clock_0) {
  if (!_available_0) {
    return _clock_0;
  } else {
    return ((_clock_0 + 1) >>> 0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked_bounds$(_allowed_0, _allocator_0, _key_0, _mode_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _allocator_0, "snd": false};
  } else {
    const _next_0 = _allocator_0["next"];
    const _high_0 = _allocator_0["high"];
    const _slots_0 = _allocator_0["slots"];
    const _capacity_0 = _allocator_0["capacity"];
    const _depth_0 = _allocator_0["depth"];
    const _free_0 = _allocator_0["free"];
    const _order_0 = _allocator_0["order"];
    const _x_0 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0));
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked_slot$(_key_0, _mode_0, _next_0, _high_0, _capacity_0, _depth_0, _free_0, _order_0, {$: "Tuple", fst: _slots_0, snd: _slots_0[_x_0 % _slots_0.length]});
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058get$1260$(_frame_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058read_join$1260$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058tx_get$1260$({$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058identity$1260$(($binding$())))))}, _tx_0, _handle_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058set$1260$(_frame_0, _replacement_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058written$1260$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058tx_set$1260$({$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058identity$1260$(($binding$())))))}, _tx_0, _handle_0, _replacement_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058selected_join$1260$(_mode_0, _observed_0) {
  const _frame_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _frame_0, "snd": ($$$$047$$$047$$$047src$047ecs$047compose$058selected_value$1260$(_mode_0, _value_0))};
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_matches$1260$(_frame_0, _target_0) {
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_matched$1260$(($$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058slot_mode$({$: "../../../src/ecs/inspector-query-families.Required"})), ($$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_presence$1260$(_frame_0, _target_0)));
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_read$1260$(_frame_0, _target_0) {
  const _world_0 = _frame_0["world"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_joined$1261$(_cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058get$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045component$045binding$058family$1260$(($binding$()))), _world_0, _target_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058write_family$1261$() {
  return {$: "../../../src/ecs/capabilities.Write", "get": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058get$1261$(_x_0);
}), "set": run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058set$1261$(_x_1, _x_2);
});
})};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058family_match$1261$(_frame_0) {
  return $$$$047$$$047$$$047src$047ecs$047compose$058selected_join$1260$({$: "../../../src/ecs/compose.Required"}, ($$$$047$$$047$$$047src$047ecs$047compose$058get$1261$(_frame_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_match$1260$(_frame_0) {
  const _t_0 = _frame_0["tx"];
  const _world_0 = _t_0["world"];
  const _undo_0 = _t_0["undo"];
  const _commands_0 = _t_0["commands"];
  const _events_0 = _t_0["events"];
  const _trace_0 = _t_0["trace"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_join$1260$(_handle_0, _error_0, _cursor_0, _undo_0, _commands_0, _events_0, _trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058lifecycle$1260$({$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($identity$())))}, _world_0, _handle_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selected_left$1260$(_observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": _owner_0, "snd": false};
  } else {
    return run_tail(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058changed$1260$()))), _owner_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1261$(_declaration_0) {
  const _select_0 = _declaration_0["select"];
  return _select_0;
}

function $$$$047$$$047$$$047src$047ecs$047local$058register_result$1260$(_registered_0, _namespace_0, _name_0, _access_0, _local_0) {
  const _world_0 = _registered_0["fst"];
  const _t_0 = _registered_0["snd"];
  if (_t_0.$ === "../../../src/ecs/world.Registered") {
    const _id_0 = _t_0["id"];
    return {$: "../../../src/ecs/local.Registered", "world": _world_0, "instance": {$: "../../../src/ecs/local.Instance", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _local_0}};
  } else {
    return {$: "../../../src/ecs/local.RegistrationRejected", "world": _world_0, "local": _local_0};
  }
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $finish_app$(_app_0) {
  const _t_0 = _app_0["app"];
  const _t_1 = _t_0["app"];
  const _t_2 = _t_1["app"];
  const _owners_0 = _t_2["owners"];
  return $finish$(_owners_0);
}

function $nums$(_values_0) {
  if (_values_0.$ === "Nil") {
    return "";
  } else {
    const _n_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    const _x_0 = ($nums$(_rest_0));
    const _x_1 = ($U32$show$(_n_0));
    const _x_2 = ("," + _x_0);
    return (_x_1 + _x_2);
  }
}

function $world_values$(_handles_0, _world_0) {
  const _ns_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _r_0 = _world_0["resource"];
  const _e_0 = _world_0["events"];
  const _p_0 = _world_0["pending"];
  const _regs_0 = _world_0["registrations"];
  const _next_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $projected$(run_clo((_x_0) => {
  return {$: "../../../src/ecs/world.World", "namespace": _ns_0, "allocator": _allocator_0, "store": _x_0, "resource": _r_0, "events": _e_0, "pending": _p_0, "registrations": _regs_0, "nextSystemId": _next_0, "clock": _clock_0};
}), ($heights$(_handles_0, _store_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058handles_join$1260$(_namespace_0, _store_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0, _observed_0) {
  const _allocator_0 = _observed_0["fst"];
  const _keys_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047world$058key_handles$1260$(_namespace_0, _keys_0))};
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible$(_allocator_0) {
  const _next_0 = _allocator_0["next"];
  const _high_0 = _allocator_0["high"];
  const _slots_0 = _allocator_0["slots"];
  const _capacity_0 = _allocator_0["capacity"];
  const _depth_0 = _allocator_0["depth"];
  const _free_0 = _allocator_0["free"];
  const _order_0 = _allocator_0["order"];
  return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible_loop$(_order_0, {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": _slots_0, "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": _order_0}, {$: "Nil"});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058provisioned$1260$(_schema_0, _recipe_0, _plan_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/schedule-provision.Executed") {
    const _result_1 = _result_0["result"];
    const _needs_0 = _result_0["requirements"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058executed$1260$(_schema_0, _recipe_0, _plan_0, _needs_0, _result_1);
  } else {
    const _t_0 = _result_0["schedule"];
    const _t_1 = _t_0["schedule"];
    const _namespace_0 = _t_1["namespace"];
    const _name_0 = _t_1["name"];
    const _steps_0 = _t_1["steps"];
    const _t_2 = _t_1["owners"];
    const _owners_0 = _t_2["fst"];
    const _t_3 = _t_2["snd"];
    if (_t_3.$ === "../../../src/ecs/ordinary-app-execution.Off") {
      const _needs_1 = _t_0["requirements"];
      const _world_0 = _result_0["world"];
      const _missing_0 = _result_0["missing"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Missing", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_0, _owners_0, _recipe_0, false, _plan_0, _namespace_0, _name_0, _steps_0, _needs_1)), "requirements": _missing_0}, "batch": {$: "../../../src/ecs/execution-trace.Disabled"}};
    } else {
      const _needs_2 = _t_0["requirements"];
      const _world_1 = _result_0["world"];
      const _missing_1 = _result_0["missing"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Missing", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_1, _owners_0, _recipe_0, true, _plan_0, _namespace_0, _name_0, _steps_0, _needs_2)), "requirements": _missing_1}, "batch": {$: "../../../src/ecs/execution-trace.Ready", "events": {$: "Con", "head": {$: "../../../src/ecs/execution-trace.ScheduleAdmissionRefused", "namespace": _namespace_0, "name": _name_0, "outcome": {$: "../../../src/ecs/execution-trace.EndMissing"}}, "tail": {$: "Nil"}}}};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_with_barrier$1260$(_schedule_0, _world_0) {
  const _schedule_1 = _schedule_0["schedule"];
  const _needs_0 = _schedule_0["requirements"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_available$1260$(($GProvide$())(_world_0), _schedule_1, _needs_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058catalog$1260$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _fields_0["head"];
    const _namespace_0 = _t_0["namespace"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _rest_0 = _fields_0["tail"];
    return {$: "Con", "head": {$: "../../../src/ecs/execution-trace.Identity", "namespace": _namespace_0, "id": _id_0, "name": {$: "Some", "value": _name_0}}, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058catalog$1260$(_rest_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058finish_build$1260$(_built_0, _needs_0) {
  if (_built_0.$ === "../../../src/ecs/schedule.Invalid") {
    const _owners_0 = _built_0["owners"];
    return {$: "../../../src/ecs/schedule-provision.Invalid", "owners": _owners_0};
  } else {
    const _schedule_0 = _built_0["schedule"];
    return {$: "../../../src/ecs/schedule-provision.Built", "schedule": {$: "../../../src/ecs/schedule-provision.Provisioned", "schedule": _schedule_0, "requirements": _needs_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058build$1260$(_namespace_0, _name_0, _steps_0, _catalog_0, _owners_0) {
  return $$$$047$$$047$$$047src$047ecs$047schedule$058build_checked$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$058valid$(_steps_0, _catalog_0, {$: "Nil"})), _namespace_0, _name_0, _steps_0, _owners_0);
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058flatten$1260$(_plan_0) {
  if (_plan_0.$ === "../../../src/ecs/schedule-provision.Empty") {
    return {$: "Nil"};
  } else if (_plan_0.$ === "../../../src/ecs/schedule-provision.Entry") {
    const _step_0 = _plan_0["step"];
    return {$: "Con", "head": _step_0, "tail": {$: "Nil"}};
  } else {
    const _left_0 = _plan_0["left"];
    const _right_0 = _plan_0["right"];
    return $List$append$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058flatten$1260$(_left_0)), ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058flatten$1260$(_right_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique$1260$(_items_0) {
  return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique_seen$1260$(_items_0, {$: "Nil"});
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058requirements$1260$(_plan_0) {
  if (_plan_0.$ === "../../../src/ecs/schedule-provision.Empty") {
    return {$: "Nil"};
  } else if (_plan_0.$ === "../../../src/ecs/schedule-provision.Entry") {
    const _needs_0 = _plan_0["requirements"];
    return _needs_0;
  } else {
    const _left_0 = _plan_0["left"];
    const _right_0 = _plan_0["right"];
    return $List$append$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058requirements$1260$(_left_0)), ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058requirements$1260$(_right_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058registration_list_walk$($0, $1, $2, $3, $4) {
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
          $4 = ($$$$047$$$047$$$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058pair$1261$(_leftFold_0, _rightFold_0, _owners_0) {
  const _left_0 = _owners_0["fst"];
  const _right_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058first$1261$(_rightFold_0, _right_0, _leftFold_0(_left_0));
}

function $AFold$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_fold$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_fields$1261$(_value_0) {
  const _t_0 = _value_0["record"];
  const _token_0 = _t_0["token"];
  const _fields_0 = _t_0["fields"];
  const _args_0 = _value_0["args"];
  const _outputs_0 = _value_0["outputs"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, "snd": {$: "Con", "head": _fields_0, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_right$1261$(_left_0, _before_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _after_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": {$: "../../../src/ecs/schedule-provision.Sequence", "left": _before_0, "right": _after_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_plan$1261$(_value_0) {
  const _t_0 = _value_0["record"];
  const _token_0 = _t_0["token"];
  const _t_1 = _t_0["fields"];
  const _namespace_0 = _t_1["namespace"];
  const _id_0 = _t_1["id"];
  const _name_0 = _t_1["name"];
  const _access_0 = _t_1["access"];
  const _cursor_0 = _t_1["cursor"];
  const _slot_0 = _t_1["slot"];
  const _clauses_0 = _t_1["clauses"];
  const _kind_0 = _t_1["kind"];
  const _args_0 = _value_0["args"];
  const _outputs_0 = _value_0["outputs"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _slot_0, "clauses": _clauses_0, "kind": _kind_0}}, "args": _args_0, "outputs": _outputs_0}, "snd": {$: "../../../src/ecs/schedule-provision.Entry", "step": {$: "../../../src/ecs/schedule.System", "id": _id_0, "condition": 0}, "requirements": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_plan$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_pair$1260$(_x_0);
});
}

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1265$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058swap_store$1260$(_id_0, _incoming_0, _incomingPresent_0, _tick_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incomingPresent_0, _tick_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$(($$$$047$$$047$$$047src$047ecs$047column$058ensure$1260$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $take$(_store_0) {
  return {$: "Tuple", "fst": {$: "Unit"}, "snd": _store_0};
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked_slot$(_key_0, _mode_0, _next_0, _high_0, _capacity_0, _depth_0, _free_0, _order_0, _observed_0) {
  const _slots_0 = _observed_0["fst"];
  const _slot_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/entity-allocator.Allocator", "next": _next_0, "high": _high_0, "slots": _slots_0, "capacity": _capacity_0, "depth": _depth_0, "free": _free_0, "order": _order_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058slot_valid$(_key_0, _mode_0, _slot_0))};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058read_join$1260$(_handle_0, _error_0, _cursor_0, _observed_0) {
  const _tx_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058tx_get$1260$(_family_0, _tx_0, _handle_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  const _trace_0 = _tx_0["trace"];
  return $$$$047$$$047$$$047src$047ecs$047component$058tx_get_join$1260$(_undo_0, _commands_0, _events_0, _trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058get$1260$(_family_0, _world_0, _handle_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058written$1260$(_handle_0, _error_0, _cursor_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/component.Written") {
    const _tx_0 = _result_0["tx"];
    return {$: "../../../src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0};
  } else if (_result_0.$ === "../../../src/ecs/component.WriteRejected") {
    const _tx_1 = _result_0["tx"];
    const _reason_0 = _result_0["error"];
    return {$: "../../../src/ecs/compose.Frame", "tx": _tx_1, "handle": _handle_0, "error": ($$$$047$$$047$$$047src$047ecs$047compose$058first_error$(_error_0, _reason_0)), "cursor": _cursor_0};
  } else {
    const _tx_2 = _result_0["tx"];
    const _reason_1 = _result_0["error"];
    return {$: "../../../src/ecs/compose.Frame", "tx": _tx_2, "handle": _handle_0, "error": ($$$$047$$$047$$$047src$047ecs$047compose$058first_error$(_error_0, _reason_1)), "cursor": _cursor_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058tx_set$1260$(_family_0, _tx_0, _handle_0, _incoming_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  const _trace_0 = _tx_0["trace"];
  return $$$$047$$$047$$$047src$047ecs$047component$058tx_set_fused$1260$(_family_0, _handle_0, _undo_0, _commands_0, _events_0, _trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058stamped_allowed$1260$(($$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0, _incoming_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058selected_value$1260$(_mode_0, _value_0) {
  if (_mode_0.$ === "../../../src/ecs/compose.Required") {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../src/ecs/compose.Present") {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../src/ecs/compose.Absent") {
    if (_value_0.$ === "../../../src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else if (_value_0.$ === "../../../src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_matched$1260$(_mode_0, _observed_0) {
  const _frame_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _frame_0, "snd": ($$$$047$$$047$$$047src$047ecs$047compose$058selected_value$1261$(_mode_0, _value_0))};
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058slot_mode$(_value_0) {
  if (_value_0.$ === "../../../src/ecs/inspector-query-families.Required") {
    return {$: "../../../src/ecs/compose.Required"};
  } else {
    return {$: "../../../src/ecs/compose.Optional"};
  }
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_presence$1260$(_frame_0, _target_0) {
  const _world_0 = _frame_0["world"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_joined$1260$(_cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058get_allowed$1261$(($$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _target_0)), _target_0)));
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_joined$1261$(_cursor_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/inspector.Frame", "world": _world_0, "cursor": _cursor_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058get$1260$(_family_0, _world_0, _handle_0) {
  return $$$$047$$$047$$$047src$047ecs$047component$058get_allowed$1260$(($$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0);
}

function $$$$047$$$047$$$047src$047ecs$047compose$058get$1261$(_frame_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058read_join$1260$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058tx_get$1260$({$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($identity$())))}, _tx_0, _handle_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058set$1261$(_frame_0, _replacement_0) {
  const _tx_0 = _frame_0["tx"];
  const _handle_0 = _frame_0["handle"];
  const _error_0 = _frame_0["error"];
  const _cursor_0 = _frame_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058written$1260$(_handle_0, _error_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047component$058tx_set$1260$({$: "../../../src/ecs/component.Family", "name": ($$$$047$$$047$$$047src$047ecs$047ordinary$045declaration$058key$1260$(($identity$())))}, _tx_0, _handle_0, _replacement_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_join$1260$(_handle_0, _error_0, _cursor_0, _undo_0, _commands_0, _events_0, _trace_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _stamp_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/compose.Frame", "tx": {$: "../../../src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0, "trace": _trace_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_selected$({$: "../../../src/ecs/compose.Changed"}, _stamp_0, _cursor_0))};
}

function $$$$047$$$047$$$047src$047ecs$047component$058lifecycle$1260$(_family_0, _world_0, _handle_0) {
  return $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_allowed$1260$(($$$$047$$$047$$$047src$047ecs$047world$058valid$1260$(_world_0, _handle_0)), _handle_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1260$(_declaration_0) {
  const _select_0 = _declaration_0["select"];
  return _select_0;
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $finish$(_owners_0) {
  const _t_0 = _owners_0["snd"];
  const _t_1 = _t_0["record"];
  const _t_2 = _t_1["token"];
  const _t_3 = _t_2["instance"];
  const _t_4 = _t_3["local"];
  const _sealed_0 = _t_4["sealed"];
  return run_tail(_sealed_0, {$: "Unit"});
}

function $projected$(_rebuild_0, _result_0) {
  const _store_0 = _result_0["fst"];
  const _values_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _rebuild_0(_store_0), "snd": _values_0};
}

function $heights$(_handles_0, _store_0) {
  if (_handles_0.$ === "Nil") {
    return {$: "Tuple", "fst": _store_0, "snd": {$: "Nil"}};
  } else {
    const _handle_0 = _handles_0["head"];
    const _rest_0 = _handles_0["tail"];
    return $heights_read$(run_clo((_x_0) => {
  return $heights$(_rest_0, _x_0);
}), ($$$$047$$$047$$$047src$047ecs$047column$058view$1260$(_store_0, ($$$$047$$$047$$$047src$047ecs$047world$058handle_index$1260$(_handle_0)))));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058key_handles$1260$(_namespace_0, _keys_0) {
  if (_keys_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _key_0 = _keys_0["head"];
    const _rest_0 = _keys_0["tail"];
    return {$: "Con", "head": {$: "../../../src/ecs/world.Handle", "namespace": _namespace_0, "key": _key_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047world$058key_handles$1260$(_namespace_0, _rest_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible_loop$(_keys_0, _allocator_0, _reversed_0) {
  if (_keys_0.$ === "Nil") {
    return {$: "Tuple", "fst": _allocator_0, "snd": ($List$reverse$(_reversed_0))};
  } else {
    const _key_0 = _keys_0["head"];
    const _rest_0 = _keys_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible_join$(_key_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible_loop$(_rest_0, _x_0, _x_1);
});
}), _reversed_0, ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058checked$(_allocator_0, _key_0, 1)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058executed$1260$(_schema_0, _recipe_0, _plan_0, _needs_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/schedule.Finished") {
    const _t_0 = _result_0["schedule"];
    const _namespace_0 = _t_0["namespace"];
    const _name_0 = _t_0["name"];
    const _steps_0 = _t_0["steps"];
    const _t_1 = _t_0["owners"];
    const _owners_0 = _t_1["fst"];
    const _t_2 = _t_1["snd"];
    if (_t_2.$ === "../../../src/ecs/ordinary-app-execution.Off") {
      const _world_0 = _result_0["world"];
      const _observations_0 = _result_0["observations"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Finished", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_0, _owners_0, _recipe_0, false, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0)), "observations": _observations_0}, "batch": {$: "../../../src/ecs/execution-trace.Disabled"}};
    } else {
      const _journal_0 = _t_2["journal"];
      const _world_1 = _result_0["world"];
      const _observations_1 = _result_0["observations"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Finished", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_1, _owners_0, _recipe_0, true, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0)), "observations": _observations_1}, "batch": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058batch$1260$(_namespace_0, _name_0, _observations_1, _journal_0, {$: "../../../src/ecs/execution-trace.EndOk"}))};
    }
  } else if (_result_0.$ === "../../../src/ecs/schedule.Failed") {
    const _t_3 = _result_0["schedule"];
    const _namespace_1 = _t_3["namespace"];
    const _name_1 = _t_3["name"];
    const _steps_1 = _t_3["steps"];
    const _t_4 = _t_3["owners"];
    const _owners_1 = _t_4["fst"];
    const _t_5 = _t_4["snd"];
    if (_t_5.$ === "../../../src/ecs/ordinary-app-execution.Off") {
      const _world_2 = _result_0["world"];
      const _error_0 = _result_0["error"];
      const _observations_2 = _result_0["observations"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Failed", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_2, _owners_1, _recipe_0, false, _plan_0, _namespace_1, _name_1, _steps_1, _needs_0)), "error": _error_0, "observations": _observations_2}, "batch": {$: "../../../src/ecs/execution-trace.Disabled"}};
    } else {
      const _journal_1 = _t_5["journal"];
      const _world_3 = _result_0["world"];
      const _error_1 = _result_0["error"];
      const _observations_3 = _result_0["observations"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Failed", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_3, _owners_1, _recipe_0, true, _plan_0, _namespace_1, _name_1, _steps_1, _needs_0)), "error": _error_1, "observations": _observations_3}, "batch": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058batch$1260$(_namespace_1, _name_1, _observations_3, _journal_1, {$: "../../../src/ecs/execution-trace.EndFailed", "error": _error_1}))};
    }
  } else {
    const _t_6 = _result_0["schedule"];
    const _namespace_2 = _t_6["namespace"];
    const _name_2 = _t_6["name"];
    const _steps_2 = _t_6["steps"];
    const _t_7 = _t_6["owners"];
    const _owners_2 = _t_7["fst"];
    const _t_8 = _t_7["snd"];
    if (_t_8.$ === "../../../src/ecs/ordinary-app-execution.Off") {
      const _world_4 = _result_0["world"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Rejected", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_4, _owners_2, _recipe_0, false, _plan_0, _namespace_2, _name_2, _steps_2, _needs_0))}, "batch": {$: "../../../src/ecs/execution-trace.Disabled"}};
    } else {
      const _world_5 = _result_0["world"];
      return {$: "../../../src/ecs/ordinary-app-execution.Run", "result": {$: "../../../src/ecs/ordinary-app-schedule.Rejected", "app": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_5, _owners_2, _recipe_0, true, _plan_0, _namespace_2, _name_2, _steps_2, _needs_0))}, "batch": {$: "../../../src/ecs/execution-trace.Ready", "events": {$: "Con", "head": {$: "../../../src/ecs/execution-trace.ScheduleAdmissionRefused", "namespace": _namespace_2, "name": _name_2, "outcome": {$: "../../../src/ecs/execution-trace.EndRejected"}}, "tail": {$: "Nil"}}}};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058restored$1260$(_schema_0, _world_0, _owners_0, _recipe_0, _debug_0, _plan_0, _namespace_0, _name_0, _steps_0, _needs_0) {
  return {$: "../../../src/ecs/ordinary-app-schedule.Application", "app": {$: "../../../src/ecs/ordinary-app-schema.Application", "schema": _schema_0, "app": {$: "../../../src/ecs/ordinary-app-composer.Registered", "world": _world_0, "owners": _owners_0, "recipe": _recipe_0, "debug": _debug_0}}, "plan": _plan_0, "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "needs": _needs_0};
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_available$1260$(_observed_0, _schedule_0, _needs_0) {
  const _world_0 = _observed_0["fst"];
  const _available_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_checked$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058missing_requirements$1260$(_needs_0, _available_0)), _schedule_0, _world_0, _needs_0);
}

function $GProvide$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_provide$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058build_checked$1260$(_allowed_0, _namespace_0, _name_0, _steps_0, _owners_0) {
  if (!_allowed_0) {
    return {$: "../../../src/ecs/schedule.Invalid", "owners": _owners_0};
  } else {
    return {$: "../../../src/ecs/schedule.Built", "schedule": {$: "../../../src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "owners": _owners_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058valid$($0, $1, $2) {
  for (;;) {
    {
      const _steps_0 = $0;
      const _catalog_0 = $1;
      const _seen_0 = $2;
      if (_steps_0.$ === "Nil") {
        return true;
      } else {
        const _t_0 = _steps_0["head"];
        if (_t_0.$ === "../../../src/ecs/schedule.Phase") {
          const _rest_0 = _steps_0["tail"];
          $0 = _rest_0;
          $1 = _catalog_0;
          $2 = _seen_0;
          continue;
        } else if (_t_0.$ === "../../../src/ecs/schedule.Barrier") {
          const _rest_1 = _steps_0["tail"];
          $0 = _rest_1;
          $1 = _catalog_0;
          $2 = _seen_0;
          continue;
        } else {
          const _id_0 = _t_0["id"];
          const _rest_2 = _steps_0["tail"];
          return $Bool$and$(($$$$047$$$047$$$047src$047ecs$047schedule$058contains$(_catalog_0, _id_0)), ($Bool$and$(($Bool$not$(($$$$047$$$047$$$047src$047ecs$047schedule$058contains$(_seen_0, _id_0)))), ($$$$047$$$047$$$047src$047ecs$047schedule$058valid$(_rest_2, _catalog_0, {$: "Con", "head": _id_0, "tail": _seen_0})))));
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique_seen$1260$(_items_0, _seen_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique_add$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058contains$1260$(_seen_0, _head_0)), _head_0, ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique_seen$1260$(_rest_0, {$: "Con", "head": _head_0, "tail": _seen_0})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058registration_meta_matches$(_meta_0, _id_0, _name_0, _access_0) {
  const _mid_0 = _meta_0["id"];
  const _mname_0 = _meta_0["name"];
  const _maccess_0 = _meta_0["access"];
  return $$$$047$$$047$$$047src$047ecs$047world$058matching_id$((_mid_0 === _id_0), _mname_0, _name_0, _maccess_0, _access_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058first$1261$(_rightFold_0, _right_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058second$1261$(_left_0, _before_0, _rightFold_0(_right_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_fold$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058fold_pair$1260$(_x_0);
});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_pair$1260$(_owners_0) {
  const _a_0 = _owners_0["fst"];
  const _b_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_left$1260$(_b_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_plan$1260$(_a_0)));
}

function $$$$047$$$047$$$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, _incoming_0, _tick_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    const _previous_0 = _result_0["previous"];
    return $$$$047$$$047$$$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, ($$$$047$$$047$$$047src$047ecs$047component$058owner_present$1260$(_previous_0)));
  } else {
    const _column_1 = _result_0["column"];
    const _incoming_1 = _result_0["incoming"];
    return {$: "Tuple", "fst": ($put$(_rest_0, _column_1)), "snd": {$: "../../../src/ecs/component.SwapRejected", "incoming": _incoming_1}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058swap$1260$(_column_0, _id_0, _incoming_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058ensure$1260$(_column_0, _target_0) {
  return $$$$047$$$047$$$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, ($Bool$and$((_target_0 > 0), (_target_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058slot_valid$(_key_0, _mode_0, _slot_0) {
  const _generation_0 = _slot_0["generation"];
  const _phase_0 = _slot_0["phase"];
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$058generation$(_key_0));
  return $Bool$and$((_x_0 === _generation_0), ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058phase_valid$(_mode_0, _phase_0)));
}

function $$$$047$$$047$$$047src$047ecs$047component$058tx_get_join$1260$(_undo_0, _commands_0, _events_0, _trace_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0, "trace": _trace_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058first_error$(_previous_0, _error_0) {
  if (_previous_0.$ === "None") {
    return {$: "Some", "value": _error_0};
  } else {
    const _previous_1 = _previous_0["value"];
    return {$: "Some", "value": _previous_1};
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058tx_set_fused$1260$(_family_0, _handle_0, _undo_0, _commands_0, _events_0, _trace_0, _observed_0) {
  const _result_0 = _observed_0["fst"];
  const _stamp_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058tx_written$1260$(_family_0, _handle_0, _undo_0, _commands_0, _events_0, _trace_0, _stamp_0, _result_0);
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_allowed$1260$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": {$: "Some", "value": _incoming_0}, "error": {$: "../../../src/ecs/world.MissingEntity"}}, "snd": {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058stamped_world$1260$(_id_0, _incoming_0, _world_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058selected_value$1261$(_mode_0, _value_0) {
  if (_mode_0.$ === "../../../src/ecs/compose.Required") {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../src/ecs/compose.Present") {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else {
      return false;
    }
  } else if (_mode_0.$ === "../../../src/ecs/compose.Absent") {
    if (_value_0.$ === "../../../src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_value_0.$ === "../../../src/ecs/component.Found") {
      return true;
    } else if (_value_0.$ === "../../../src/ecs/component.ComponentAbsent") {
      return true;
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047inspector$045query$045families$058inspect_joined$1260$(_cursor_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/inspector.Frame", "world": _world_0, "cursor": _cursor_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_allowed$1261$(_checked_0, _handle_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../src/ecs/component.MissingEntity"}};
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058get_world$1261$(_id_0, _world_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_allowed$1260$(_checked_0, _handle_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../src/ecs/component.MissingEntity"}};
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058get_world$1260$(_id_0, _world_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058lifecycle_selected$(_mode_0, _stamp_0, _cursor_0) {
  if (_mode_0.$ === "../../../src/ecs/compose.Added") {
    return $$$$047$$$047$$$047src$047ecs$047lifecycle$058added$(_stamp_0, _cursor_0);
  } else {
    return $$$$047$$$047$$$047src$047ecs$047lifecycle$058changed$(_stamp_0, _cursor_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_allowed$1260$(_checked_0, _handle_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_world$1260$(_id_0, _world_0);
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

function $heights_read$(_next_0, _result_0) {
  const _store_0 = _result_0["fst"];
  const _value_0 = _result_0["snd"];
  return $heights_join$(($point$(_value_0)), _next_0(_store_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058view$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058handle_index$1260$(_handle_0) {
  const _key_0 = _handle_0["key"];
  return $$$$047$$$047$$$047src$047ecs$047entity$045key$058index$(_key_0);
}

function $List$reverse$(_xs_0) {
  return $List$reverse$go$(_xs_0, {$: "Nil"});
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058visible_join$(_key_0, _next_0, _reversed_0, _observed_0) {
  const _allocator_0 = _observed_0["fst"];
  const _present_0 = _observed_0["snd"];
  return run_tail(_next_0(_allocator_0), ($$$$047$$$047$$$047src$047ecs$047entity$045allocator$058keep$(($Bool$not$(_present_0)), _key_0, _reversed_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058batch$1260$(_namespace_0, _name_0, _observations_0, _journal_0, _outcome_0) {
  const _events_0 = _journal_0["events"];
  return {$: "../../../src/ecs/execution-trace.Ready", "events": {$: "Con", "head": {$: "../../../src/ecs/execution-trace.ScheduleStarted", "namespace": _namespace_0, "name": _name_0}, "tail": ($List$append$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_observations_0, ($List$reverse$(_events_0)))), {$: "Con", "head": {$: "../../../src/ecs/execution-trace.ScheduleEnded", "outcome": _outcome_0}, "tail": {$: "Nil"}}))}};
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058run_checked$1260$(_missing_0, _schedule_0, _world_0, _needs_0) {
  if (_missing_0.$ === "Con") {
    const _first_0 = _missing_0["head"];
    const _rest_0 = _missing_0["tail"];
    return {$: "../../../src/ecs/schedule-provision.Missing", "schedule": {$: "../../../src/ecs/schedule-provision.Provisioned", "schedule": _schedule_0, "requirements": _needs_0}, "world": _world_0, "missing": {$: "Con", "head": _first_0, "tail": _rest_0}};
  } else {
    return {$: "../../../src/ecs/schedule-provision.Executed", "result": run_loop($$$$047$$$047$$$047src$047ecs$047schedule$058run_with_barrier$1260$(_schedule_0, _world_0)), "requirements": _needs_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058missing_requirements$1260$(_needs_0, _available_0) {
  if (_needs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _needs_0["head"];
    const _rest_0 = _needs_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058missing_next$1260$(($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058contains$1260$(_available_0, _head_0)), _head_0, ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058missing_requirements$1260$(_rest_0, _available_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_provide$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_pair$1261$(_x_0);
});
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058unique_add$1260$(_present_0, _item_0, _rest_0) {
  if (_present_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _item_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058contains$1260$(_items_0, _item_0) {
  if (_items_0.$ === "Nil") {
    return false;
  } else {
    const _head_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058same$1260$(_head_0, _item_0));
    const _x_1 = ($$$$047$$$047$$$047src$047ecs$047schedule$045provision$058contains$1260$(_rest_0, _item_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058matching_id$(_sameId_0, _metaName_0, _wantedName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameId_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047src$047ecs$047world$058matching_access$(($$$$047$$$047$$$047src$047ecs$047string$045equality$058equal$(_metaName_0, _wantedName_0)), _metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058second$1261$(_left_0, _before_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _after_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($List$append$(_before_0, _after_0))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058fold_pair$1260$(_owners_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058pair$1260$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058empty$1260$(_x_0);
}), run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_fields$1260$(_x_1);
}), _owners_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_left$1260$(_owner_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_right$1260$(_left_0, _before_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_plan$1260$(_owner_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_plan$1260$(_owner_0) {
  return {$: "Tuple", "fst": _owner_0, "snd": {$: "../../../src/ecs/schedule-provision.Empty"}};
}

function $$$$047$$$047$$$047src$047ecs$047component$058mark_swapped$1260$(_rest_0, _column_0, _id_0, _incoming_0, _tick_0, _observed_0) {
  const _previous_0 = _observed_0["fst"];
  const _wasPresent_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($put$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0)))), "snd": {$: "../../../src/ecs/component.Swapped", "previous": _previous_0}};
}

function $put$(__0, _store_0) {
  return _store_0;
}

function $$$$047$$$047$$$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../src/ecs/column.Owned") {
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

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../src/ecs/column.IndexedOrdinaryOwned") {
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

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_swap_state$1260$(_id_0, _incoming_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0), (_id_0 < _current_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$($0) {
  for (;;) {
    {
      const _carrier_0 = $0;
      if (_carrier_0.$ === "../../../src/ecs/column.IndexedPreparedOwned") {
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

function $$$$047$$$047$$$047src$047ecs$047column$058ensure_checked$1260$(_column_0, _target_0, _valid_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    if (!_valid_0) {
      return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
    }
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../src/ecs/column.Prepared", "state": _carrier_0};
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058ensure_state$1260$(_target_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
    }
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../src/ecs/column.Indexed", "state": _carrier_1};
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
    }
  } else {
    const _carrier_2 = _column_0["state"];
    if (!_valid_0) {
      return {$: "../../../src/ecs/column.PreparedIndexed", "state": _carrier_2};
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058phase_valid$(_mode_0, _phase_0) {
  if (_mode_0 == 0) {
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058metadata$(_phase_0);
  } else if ((_mode_0 & 1) == 0) {
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058pending$(_phase_0);
  } else if (_mode_0 == 1) {
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058live$(_phase_0);
  } else {
    return $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058pending$(_phase_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058tx_written$1260$(_family_0, _handle_0, _undo_0, _commands_0, _events_0, _trace_0, _stamp_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/component.Replaced") {
    const _world_0 = _result_0["world"];
    const _previous_0 = _result_0["previous"];
    return {$: "../../../src/ecs/component.Written", "tx": {$: "../../../src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp$1260$(_handle_0, _stamp_0, ($$$$047$$$047$$$047src$047ecs$047component$058restore$1260$(_family_0, _handle_0, _previous_0, _x_0)));
}), "tail": _undo_0}, "commands": _commands_0, "events": _events_0, "trace": ($$$$047$$$047$$$047src$047ecs$047component$058trace_write$1260$(_trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058family_name$1260$(_family_0)), _handle_0, {$: "../../../src/ecs/trace-facts.Attempted"}))}};
  } else {
    const _world_1 = _result_0["world"];
    const _t_0 = _result_0["incoming"];
    if (_t_0.$ === "Some") {
      const _incoming_0 = _t_0["value"];
      const _error_0 = _result_0["error"];
      return {$: "../../../src/ecs/component.WriteRejected", "tx": {$: "../../../src/ecs/transaction.Tx", "world": _world_1, "undo": _undo_0, "commands": _commands_0, "events": _events_0, "trace": ($$$$047$$$047$$$047src$047ecs$047component$058trace_refusal$1260$(_trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058family_name$1260$(_family_0)), _handle_0, _error_0))}, "incoming": _incoming_0, "error": _error_0};
    } else {
      const _error_1 = _result_0["error"];
      return {$: "../../../src/ecs/component.WriteFailure", "tx": {$: "../../../src/ecs/transaction.Tx", "world": _world_1, "undo": _undo_0, "commands": _commands_0, "events": _events_0, "trace": ($$$$047$$$047$$$047src$047ecs$047component$058trace_refusal$1260$(_trace_0, ($$$$047$$$047$$$047src$047ecs$047component$058family_name$1260$(_family_0)), _handle_0, _error_1))}, "error": _error_1};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_world$1260$(_id_0, _incoming_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047component$058stamped_replaced$1260$(($$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1262$(($$$$047$$$047$$$047src$047ecs$047component$058stamped_store$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047component$058stamped_tick$(_clock_0, (_clock_0 < 4294967295))), (_clock_0 < 4294967295), ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, ($$$$047$$$047$$$047src$047ecs$047component$058stamped_tick$(_clock_0, (_clock_0 < 4294967295))))));
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_world$1261$(_id_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1263$(($$$$047$$$047$$$047src$047ecs$047component$058get_store$1261$(_id_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_world$1260$(_id_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1260$(($$$$047$$$047$$$047src$047ecs$047component$058get_store$1260$(_id_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058added$(_stamp_0, _cursor_0) {
  const _value_0 = _stamp_0["added"];
  return (_value_0 > _cursor_0);
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058changed$(_stamp_0, _cursor_0) {
  const _value_0 = _stamp_0["changed"];
  return (_value_0 > _cursor_0);
}

function $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_world$1260$(_id_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1264$(($$$$047$$$047$$$047src$047ecs$047component$058lifecycle_store$1260$(_id_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
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

function $heights_join$(_value_0, _result_0) {
  const _store_0 = _result_0["fst"];
  const _tail_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _store_0, "snd": {$: "Con", "head": _value_0, "tail": _tail_0}};
}

function $point$(_value_0) {
  if (_value_0.$ === "Some") {
    const _n_0 = _value_0["value"];
    return _n_0;
  } else {
    return 999;
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_sized$1260$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
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

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058keep$(_same_0, _head_0, _rest_0) {
  if (_same_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _head_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_observations_0, _journal_0) {
  if (_observations_0.$ === "Nil") {
    return _journal_0;
  } else {
    const _t_0 = _observations_0["head"];
    if (_t_0.$ === "../../../src/ecs/schedule.Entered") {
      const _name_0 = _t_0["name"];
      const _rest_0 = _observations_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/execution-trace.PhaseEntered", "name": _name_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_rest_0, _journal_0))};
    } else if (_t_0.$ === "../../../src/ecs/schedule.Skipped") {
      const _id_0 = _t_0["id"];
      const _rest_1 = _observations_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/execution-trace.SystemSkipped", "id": _id_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_rest_1, _journal_0))};
    } else if (_t_0.$ === "../../../src/ecs/schedule.Applied") {
      const _rest_2 = _observations_0["tail"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merged_chunk$1260$(run_clo((_x_0) => {
  return {$: "Con", "head": {$: "../../../src/ecs/execution-trace.DeferredApplied"}, "tail": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_rest_2, _x_0))};
}), ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_chunk$1260$(_journal_0)));
    } else {
      const _rest_3 = _observations_0["tail"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merged_chunk$1260$(run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merge$1260$(_rest_3, _x_1);
}), ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk$1260$(_journal_0)));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058run_with_barrier$1260$(_schedule_0, _world_0) {
  return $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_named$1260$(_schedule_0, ($$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058missing_next$1260$(_present_0, _item_0, _next_0) {
  if (!_present_0) {
    return {$: "Con", "head": _item_0, "tail": _next_0};
  } else {
    return _next_0;
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_pair$1261$(_world_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_left$1260$(($AProvide$())(_world_0));
}

function $$$$047$$$047$$$047src$047ecs$047schedule$045provision$058same$1260$(_a_0, _b_0) {
  if (_a_0.$ === "../../../src/ecs/schedule-provision.Component") {
    const _a_1 = _a_0["id"];
    if (_b_0.$ === "../../../src/ecs/schedule-provision.Component") {
      const _b_1 = _b_0["id"];
      return (_a_1 === _b_1);
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../src/ecs/schedule-provision.Resource") {
    const _a_2 = _a_0["id"];
    if (_b_0.$ === "../../../src/ecs/schedule-provision.Resource") {
      const _b_2 = _b_0["id"];
      return (_a_2 === _b_2);
    } else {
      return false;
    }
  } else {
    const _a_3 = _a_0["id"];
    if (_b_0.$ === "../../../src/ecs/schedule-provision.Service") {
      const _b_3 = _b_0["id"];
      return (_a_3 === _b_3);
    } else {
      return false;
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058matching_access$(_sameName_0, _metaAccess_0, _wantedAccess_0) {
  if (!_sameName_0) {
    return false;
  } else {
    return $$$$047$$$047$$$047src$047ecs$047world$058access_equal$(_metaAccess_0, _wantedAccess_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047string$045equality$058equal$(_a_0, _b_0) {
  return $$$$047$$$047$$$047src$047ecs$047string$045equality$058equal_walk$(_a_0, _b_0, true);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058pair$1260$(_leftFold_0, _rightFold_0, _owners_0) {
  const _left_0 = _owners_0["fst"];
  const _right_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058first$1260$(_rightFold_0, _right_0, _leftFold_0(_left_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058empty$1260$(_unit_0) {
  return {$: "Tuple", "fst": _unit_0, "snd": {$: "Nil"}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_fields$1260$(_value_0) {
  const _t_0 = _value_0["record"];
  const _token_0 = _t_0["token"];
  const _fields_0 = _t_0["fields"];
  const _args_0 = _value_0["args"];
  const _outputs_0 = _value_0["outputs"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, "snd": {$: "Con", "head": _fields_0, "tail": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058plan_right$1260$(_left_0, _before_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _after_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": {$: "../../../src/ecs/schedule-provision.Sequence", "left": _before_0, "right": _after_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058invocation_plan$1260$(_value_0) {
  const _t_0 = _value_0["record"];
  const _token_0 = _t_0["token"];
  const _t_1 = _t_0["fields"];
  const _namespace_0 = _t_1["namespace"];
  const _id_0 = _t_1["id"];
  const _name_0 = _t_1["name"];
  const _access_0 = _t_1["access"];
  const _cursor_0 = _t_1["cursor"];
  const _slot_0 = _t_1["slot"];
  const _clauses_0 = _t_1["clauses"];
  const _kind_0 = _t_1["kind"];
  const _args_0 = _value_0["args"];
  const _outputs_0 = _value_0["outputs"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _slot_0, "clauses": _clauses_0, "kind": _kind_0}}, "args": _args_0, "outputs": _outputs_0}, "snd": {$: "../../../src/ecs/schedule-provision.Entry", "step": {$: "../../../src/ecs/schedule.System", "id": _id_0, "condition": 0}, "requirements": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058mark$1260$(_column_0, _id_0, _incoming_0, _wasPresent_0, _tick_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0))))};
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058swap_checked$1260$(_values_0, _stamps_0, _id_0, _incoming_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../src/ecs/column.Rejected", "column": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058swapped$1260$(array_rmw(_values_0, _x_0, () => _incoming_0), _stamps_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_swap$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../src/ecs/column.Rejected", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover$1260$({$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047src$047ecs$047column$058seek$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_sized$1260$(_id_0, _incoming_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_swap$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _id_0, _incoming_0, _valid_0, _same_0, _backwards_0) {
  if (!_valid_0) {
    return {$: "../../../src/ecs/column.Rejected", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "incoming": _incoming_0};
  } else {
    if (_same_0) {
      return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _incoming_0, "remaining": _remaining_0, "past": _past_0}}}, "previous": _owner_0};
    } else {
      if (_backwards_0) {
        return $$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover$1260$({$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}})));
      } else {
        const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
        const _x_1 = ((_x_0 + 1) >>> 0);
        return $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _incoming_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, _sized_0) {
  const _values_0 = _sized_0["fst"];
  const _size_0 = _sized_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058grow$1260$(17, _values_0, _stamps_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_ensure_state$1260$(_target_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, (_target_0 <= _capacity_0));
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058metadata$(_phase_0) {
  if (_phase_0.$ === "../../../src/ecs/entity-allocator.Free") {
    return false;
  } else {
    return true;
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058pending$(_phase_0) {
  if (_phase_0.$ === "../../../src/ecs/entity-allocator.Pending") {
    return true;
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047src$047ecs$047entity$045allocator$058live$(_phase_0) {
  if (_phase_0.$ === "../../../src/ecs/entity-allocator.Live") {
    return true;
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp$1260$(_handle_0, _stamp_0, _world_0) {
  const _t_0 = _handle_0["key"];
  const _id_0 = _t_0["index"];
  return $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_done$1260$(($$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_world$1260$(_id_0, _stamp_0, _world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore$1260$(_family_0, _handle_0, _incoming_0, _world_0) {
  return $$$$047$$$047$$$047src$047ecs$047component$058restore_allowed$1260$(($$$$047$$$047$$$047src$047ecs$047world$058metadata_valid$1260$(_world_0, _handle_0)), _handle_0, _incoming_0);
}

function $$$$047$$$047$$$047src$047ecs$047component$058trace_write$1260$(_state_0, _name_0, _handle_0, _result_0) {
  if (_state_0.$ === "../../../src/ecs/trace-facts.Off") {
    return {$: "../../../src/ecs/trace-facts.Off"};
  } else {
    const _facts_0 = _state_0["reverseFacts"];
    return {$: "../../../src/ecs/trace-facts.On", "reverseFacts": {$: "Con", "head": {$: "../../../src/ecs/trace-facts.Fact", "category": {$: "../../../src/ecs/trace-facts.ComponentValue"}, "key": _name_0, "operation": {$: "../../../src/ecs/trace-facts.WriteOperation"}, "subject": {$: "Some", "value": ($$$$047$$$047$$$047src$047ecs$047component$058trace_handle$1260$(_handle_0))}, "before": {$: "../../../src/ecs/trace-facts.OpaqueValue"}, "after": {$: "../../../src/ecs/trace-facts.OpaqueValue"}, "result": _result_0}, "tail": _facts_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058family_name$1260$(_family_0) {
  const _name_0 = _family_0["name"];
  return _name_0;
}

function $$$$047$$$047$$$047src$047ecs$047component$058trace_refusal$1260$(_state_0, _name_0, _handle_0, _error_0) {
  if (_state_0.$ === "../../../src/ecs/trace-facts.Off") {
    return {$: "../../../src/ecs/trace-facts.Off"};
  } else {
    const _facts_0 = _state_0["reverseFacts"];
    return {$: "../../../src/ecs/trace-facts.On", "reverseFacts": {$: "Con", "head": {$: "../../../src/ecs/trace-facts.Fact", "category": {$: "../../../src/ecs/trace-facts.ComponentValue"}, "key": _name_0, "operation": {$: "../../../src/ecs/trace-facts.WriteOperation"}, "subject": {$: "Some", "value": ($$$$047$$$047$$$047src$047ecs$047component$058trace_handle$1260$(_handle_0))}, "before": {$: "../../../src/ecs/trace-facts.OpaqueValue"}, "after": {$: "../../../src/ecs/trace-facts.OpaqueValue"}, "result": {$: "../../../src/ecs/trace-facts.Refused", "reason": ($$$$047$$$047$$$047src$047ecs$047component$058trace_error$(_error_0))}}, "tail": _facts_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_replaced$1260$(_observed_0) {
  const _world_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _t_1 = _t_0["fst"];
  if (_t_1.$ === "../../../src/ecs/component.Swapped") {
    const _previous_0 = _t_1["previous"];
    const _stamp_0 = _t_0["snd"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/component.Replaced", "world": _world_0, "previous": _previous_0}, "snd": _stamp_0};
  } else {
    const _incoming_0 = _t_1["incoming"];
    const _stamp_1 = _t_0["snd"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/component.ReplaceRejected", "world": _world_0, "incoming": _incoming_0, "error": {$: "../../../src/ecs/world.CapacityExceeded"}}, "snd": _stamp_1};
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1262$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_store$1260$(_id_0, _incoming_0, _tick_0, _allowed_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058stamped_column$1260$(_rest_0, _id_0, _incoming_0, _tick_0, _allowed_0, ($$$$047$$$047$$$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_tick$(_clock_0, _allowed_0) {
  if (!_allowed_0) {
    return _clock_0;
  } else {
    return ((_clock_0 + 1) >>> 0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1263$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_store$1261$(_id_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058get_projected$1261$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058view$1261$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1260$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_store$1260$(_id_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058get_projected$1260$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058view$1260$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1264$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_store$1260$(_id_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_join$1260$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_checked$1260$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_checked$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_sized$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_checked$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058merged_chunk$1260$(_next_0, _chunk_0) {
  const _prefix_0 = _chunk_0["fst"];
  const _remaining_0 = _chunk_0["snd"];
  return $List$append$(_prefix_0, _next_0(_remaining_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_chunk$1260$(_journal_0) {
  if (_journal_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _journal_0["head"];
    if (_t_0.$ === "../../../src/ecs/execution-trace.BarrierOperationObserved") {
      const _fact_0 = _t_0["fact"];
      const _rest_0 = _journal_0["tail"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk_more$1260$({$: "../../../src/ecs/execution-trace.BarrierOperationObserved", "fact": _fact_0}, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_chunk$1260$(_rest_0)));
    } else {
      const _rest_1 = _journal_0["tail"];
      return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Con", "head": _t_0, "tail": _rest_1}};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk$1260$(_journal_0) {
  if (_journal_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}};
  } else {
    const _t_0 = _journal_0["head"];
    if (_t_0.$ === "../../../src/ecs/execution-trace.OperationObserved") {
      const _identity_0 = _t_0["identity"];
      const _fact_0 = _t_0["fact"];
      const _rest_0 = _journal_0["tail"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk_more$1260$({$: "../../../src/ecs/execution-trace.OperationObserved", "identity": _identity_0, "fact": _fact_0}, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk$1260$(_rest_0)));
    } else {
      const _rest_1 = _journal_0["tail"];
      return {$: "Tuple", "fst": {$: "Con", "head": _t_0, "tail": {$: "Nil"}}, "snd": _rest_1};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_named$1260$(_schedule_0, _named_0) {
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_actual$1260$(_schedule_0, _world_0, _actual_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_left$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_right$1260$(_before_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_provide$1260$(_world_0)));
}

function $AProvide$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_provide$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047world$058access_equal$(_xs_0, _ys_0) {
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
      return $Bool$and$(($$$$047$$$047$$$047src$047ecs$047string$045equality$058equal$(__2, _y_0)), ($$$$047$$$047$$$047src$047ecs$047world$058access_equal$(__3, _ys_1)));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047string$045equality$058equal_walk$($0, $1, $2) {
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

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058first$1260$(_rightFold_0, _right_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058second$1260$(_left_0, _before_0, _rightFold_0(_right_0));
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_entries_0, _id_0, _stamp_0) {
  return {$: "Con", "head": {$: "../../../src/ecs/lifecycle.Entry", "id": _id_0, "stamp": _stamp_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0))};
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0) {
  if (!_incoming_0) {
    return {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
  } else {
    return $$$$047$$$047$$$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_entries_0, _id_0) {
  return $$$$047$$$047$$$047src$047ecs$047lifecycle$058get_selected$(_entries_0, _id_0, false, {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0});
}

function $$$$047$$$047$$$047src$047ecs$047column$058mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0)), _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_mark_state$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058swapped$1260$(_result_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "previous": _previous_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, _incoming_0, _column_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047src$047ecs$047column$058swap_sized$1260$(_id_0, _incoming_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_state$1260$(_id_0, _incoming_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return {$: "../../../src/ecs/column.Rejected", "column": _column_0, "incoming": _incoming_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058recover$1260$(_column_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058recover_state$1260$(($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return {$: "../../../src/ecs/column.Indexed", "state": _carrier_1};
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_state$1260$(($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../src/ecs/column.Rejected", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, _active_0) {
  if (!_active_0) {
    return _past_0;
  } else {
    return {$: "../../../src/ecs/column.HistoryCon", "id": _current_0, "value": _owner_0, "rest": _past_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_swap_checked$1260$(_id_0, _incoming_0, _metadata_0, _values_0, _valid_0) {
  if (!_valid_0) {
    return {$: "../../../src/ecs/column.Rejected", "column": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "incoming": _incoming_0};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, array_rmw(_values_0, _x_0, () => _incoming_0));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek$1260$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "../../../src/ecs/column.Rejected", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "incoming": _incoming_0};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "previous": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = _incoming_0;
            $6 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $7 = _past_0;
            $8 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": _rest_1, "past": _past_0}}}, "previous": {$: "Some", "value": _owner_1}};
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "../../../src/ecs/column.Accepted", "column": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": _incoming_0, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "previous": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _incoming_0;
                $6 = _rest_1;
                $7 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $8 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058grow$1260$($0, $1, $2, $3, $4, $5, $6) {
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
          return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0};
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047src$047ecs$047column$058absent$1260$(_depth_0)));
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

function $$$$047$$$047$$$047src$047ecs$047column$058ensure_prepared$1260$(_target_0, _column_0, _fits_0) {
  if (_fits_0) {
    return _column_0;
  } else {
    return $$$$047$$$047$$$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover$1260$(_column_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_ensure_sized$1260$(_target_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_grow$1260$(17, _values_0, _metadata_0, _size_0, ($U32$log2$(_size_0)), _target_0, (_target_0 <= _size_0));
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_done$1260$(_observed_0) {
  const _world_0 = _observed_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_world$1260$(_id_0, _stamp_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1261$(($$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_store$1260$(_id_0, _stamp_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_allowed$1260$(_checked_0, _handle_0, _incoming_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return _world_0;
  } else {
    const _t_1 = _handle_0["key"];
    const _id_0 = _t_1["index"];
    return $$$$047$$$047$$$047src$047ecs$047component$058restore_observed$1260$(($$$$047$$$047$$$047src$047ecs$047component$058restore_world$1260$(_id_0, _incoming_0, _world_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058trace_handle$1260$(_handle_0) {
  const _namespace_0 = _handle_0["namespace"];
  const _key_0 = _handle_0["key"];
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047entity$045key$045render$058show$(_key_0));
  const _x_1 = ($U32$show$(_namespace_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $$$$047$$$047$$$047src$047ecs$047component$058trace_error$(_error_0) {
  if (_error_0.$ === "../../../src/ecs/world.MissingEntity") {
    return "MissingEntity";
  } else if (_error_0.$ === "../../../src/ecs/world.CapacityExceeded") {
    return "CapacityExceeded";
  } else if (_error_0.$ === "../../../src/ecs/world.NamespaceExhausted") {
    return "NamespaceExhausted";
  } else {
    return "SystemIdExhausted";
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_column$1260$(_rest_0, _id_0, _incoming_0, _tick_0, _allowed_0, _observed_0) {
  if (!_allowed_0) {
    const _column_0 = _observed_0["fst"];
    const _stamp_0 = _observed_0["snd"];
    return {$: "Tuple", "fst": ($put$(_rest_0, _column_0)), "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/component.SwapRejected", "incoming": {$: "Some", "value": _incoming_0}}, "snd": _stamp_0}};
  } else {
    const _column_1 = _observed_0["fst"];
    const _stamp_1 = _observed_0["snd"];
    return $$$$047$$$047$$$047src$047ecs$047component$058stamped_store_join$1260$(_stamp_1, ($$$$047$$$047$$$047src$047ecs$047component$058swap_join$1260$(_rest_0, _id_0, true, _tick_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$(($$$$047$$$047$$$047src$047ecs$047column$058ensure$1260$(_column_1, _id_0)), _id_0, {$: "Some", "value": _incoming_0})))));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058lifecycle$1260$(_column_0, _id_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_projected$1261$(_rest_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($put$(_rest_0, _column_0)), "snd": ($$$$047$$$047$$$047src$047ecs$047component$058access$1261$(_value_0))};
}

function $$$$047$$$047$$$047src$047ecs$047column$058view$1261$(_column_0, _id_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058get_projected$1260$(_rest_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($put$(_rest_0, _column_0)), "snd": ($$$$047$$$047$$$047src$047ecs$047component$058access$1260$(_value_0))};
}

function $$$$047$$$047$$$047src$047ecs$047component$058lifecycle_join$1260$(_rest_0, _observed_0) {
  const _column_0 = _observed_0["fst"];
  const _stamp_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": ($put$(_rest_0, _column_0)), "snd": _stamp_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_taken$1260$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, ($view$(_owner_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_current$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($view$(_owned_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_different$1260$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058seek_view$1260$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_checked$1260$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_current$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($view$(_owned_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_different$1260$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1260$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek_view$1260$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058ran_chunk_more$1260$(_event_0, _chunk_0) {
  const _prefix_0 = _chunk_0["fst"];
  const _remaining_0 = _chunk_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _event_0, "tail": _prefix_0}, "snd": _remaining_0};
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_actual$1260$(_schedule_0, _world_0, _actual_0) {
  const _namespace_0 = _schedule_0["namespace"];
  const _name_0 = _schedule_0["name"];
  const _steps_0 = _schedule_0["steps"];
  const _owners_0 = _schedule_0["owners"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_checked$1260$((_namespace_0 === _actual_0), {$: "../../../src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _steps_0, "owners": _owners_0}, _world_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_right$1260$(_before_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _after_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": ($List$append$(_before_0, _after_0))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_provide$1260$(_world_0) {
  return {$: "Tuple", "fst": _world_0, "snd": {$: "Nil"}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_provide$1260$() {
  return run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_pair$1260$(_x_0);
});
}

function $Char$is_eq$(_a_0, _b_0) {
  const _x_0 = _a_0.codePointAt(0);
  const _x_1 = _b_0.codePointAt(0);
  return (_x_0 === _x_1);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058second$1260$(_left_0, _before_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _after_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($List$append$(_before_0, _after_0))};
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058clear$(_entries_0, _id_0) {
  return $$$$047$$$047$$$047src$047ecs$047lifecycle$058clear_reversed$(_entries_0, _id_0, {$: "Nil"});
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058written$(_wasPresent_0, _stamp_0, _tick_0) {
  if (!_wasPresent_0) {
    return {$: "../../../src/ecs/lifecycle.Stamp", "added": _tick_0, "changed": _tick_0};
  } else {
    const _added_0 = _stamp_0["added"];
    return {$: "../../../src/ecs/lifecycle.Stamp", "added": _added_0, "changed": _tick_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058get_selected$($0, $1, $2, $3) {
  for (;;) {
    {
      const _entries_0 = $0;
      const _id_0 = $1;
      const _found_0 = $2;
      const _stamp_0 = $3;
      if (_entries_0.$ === "Nil") {
        if (_found_0) {
          return _stamp_0;
        } else {
          return {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0};
        }
      } else {
        const _t_0 = _entries_0["head"];
        const _key_0 = _t_0["id"];
        const _current_0 = _t_0["stamp"];
        const _rest_0 = _entries_0["tail"];
        if (_found_0) {
          return _stamp_0;
        } else {
          $0 = _rest_0;
          $1 = _id_0;
          $2 = (_key_0 === _id_0);
          $3 = _current_0;
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))));
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)), (_id_0 <= _capacity_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_mark_got$1260$(_id_0, _incoming_0, _wasPresent_0, _tick_0, _values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047lifecycle$058after_write$(_incoming_0, _wasPresent_0, _stamp_0, _tick_0)))), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_state$1260$(_state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0) {
  return {$: "../../../src/ecs/column.Indexed", "state": {$: "../../../src/ecs/column.IndexedOrdinaryOwned", "state": {$: "../../../src/ecs/column.IndexedOrdinaryState", "values": _values_0, "metadata": _metadata_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_swapped$1260$(_metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _previous_0 = _result_0["snd"];
  return {$: "../../../src/ecs/column.Accepted", "column": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "previous": _previous_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058absent$1260$(_depth_0) {
  if (_depth_0 === 0) {
    return [{$: "None"}];
  } else {
    const _rest_0 = (_depth_0 - 1);
    return array_node(($$$$047$$$047$$$047src$047ecs$047column$058absent$1260$(_rest_0)), ($$$$047$$$047$$$047src$047ecs$047column$058absent$1260$(_rest_0)));
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

function $$$$047$$$047$$$047src$047ecs$047column$058ensure_recovered$1260$(_target_0, _column_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return $$$$047$$$047$$$047src$047ecs$047column$058ensure_sized$1260$(_target_0, _stamps_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_ensure_state$1260$(_target_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_0)));
  } else {
    return _column_0;
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_grow$1260$($0, $1, $2, $3, $4, $5, $6) {
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
          return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_enough_0) {
          return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0);
        } else {
          const _next_0 = ((_size_0 << 1) >>> 0);
          $0 = _rest_0;
          $1 = array_node(_values_0, ($$$$047$$$047$$$047src$047ecs$047column$058absent$1260$(_depth_0)));
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

function $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1261$(_observed_0, _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _store_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_stamp_store$1260$(_id_0, _stamp_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return {$: "Tuple", "fst": ($put$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058restore_stamp$1260$(_column_0, _id_0, _stamp_0)))), "snd": {$: "Unit"}};
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_observed$1260$(_observed_0) {
  const _world_0 = _observed_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_world$1260$(_id_0, _incoming_0, _world_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058with_store_finish$1261$(($$$$047$$$047$$$047src$047ecs$047component$058restore_store$1260$(_id_0, _incoming_0, ($take$(_store_0)))), _namespace_0, _allocator_0, _resource_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047entity$045key$045render$058show$(_key_0) {
  const _index_0 = _key_0["index"];
  const _generation_0 = _key_0["generation"];
  const _x_0 = ($U32$show$(_generation_0));
  const _x_1 = ($U32$show$(_index_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $$$$047$$$047$$$047src$047ecs$047component$058stamped_store_join$1260$(_stamp_0, _result_0) {
  const _store_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": _store_0, "snd": {$: "Tuple", "fst": _outcome_0, "snd": _stamp_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_stamps_0, _id_0))};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_lifecycle_state$1260$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get$(_metadata_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047component$058access$1261$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "../../../src/ecs/component.ComponentAbsent"};
  } else {
    const _value_1 = _value_0["value"];
    return {$: "../../../src/ecs/component.Found", "value": _value_1};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_sized$1261$(_id_0, _stamps_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, {$: "Tuple", fst: _values_0, snd: _values_0.length});
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_state$1261$(_id_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, ($Bool$and$((_id_0 > 0), (_id_0 <= _capacity_0))), (_id_0 === _current_0));
}

function $$$$047$$$047$$$047src$047ecs$047component$058access$1260$(_value_0) {
  if (_value_0.$ === "None") {
    return {$: "../../../src/ecs/component.ComponentAbsent"};
  } else {
    const _value_1 = _value_0["value"];
    return {$: "../../../src/ecs/component.Found", "value": _value_1};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_projected$1260$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $view$(_plant_0) {
  const _height_0 = _plant_0["height"];
  return {$: "Tuple", "fst": {$: "Plant", "height": _height_0}, "snd": _height_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1260$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047src$047ecs$047column$058viewed$1260$(($view$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return {$: "../../../src/ecs/column.Column", "values": ($$$$047$$$047$$$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), "stamps": _stamps_0};
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return {$: "../../../src/ecs/column.Column", "values": ($$$$047$$$047$$$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), "stamps": _stamps_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1260$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($view$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_taken$1260$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, ($view$(_owner_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, _active_0) {
  if (!_active_0) {
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover_past$1260$(_past_0, _values_0)))), _metadata_0);
  } else {
    const _x_0 = ((_current_0 - 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(($$$$047$$$047$$$047src$047ecs$047column$058recover_selected_rows$(_remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058recover_past$1260$(_past_0, (_values_0[_x_0 % _values_0.length] = _owner_0, _values_0))))), _metadata_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek_view$1260$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1260$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($view$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058run_barrier_checked$1260$(_allowed_0, _schedule_0, _world_0) {
  if (!_allowed_0) {
    return {$: "../../../src/ecs/schedule.Rejected", "schedule": _schedule_0, "world": _world_0};
  } else {
    const _namespace_0 = _schedule_0["namespace"];
    const _name_0 = _schedule_0["name"];
    const _steps_0 = _schedule_0["steps"];
    const _owners_0 = _schedule_0["owners"];
    return $$$$047$$$047$$$047src$047ecs$047schedule$058execute_with_barrier$1260$(_steps_0, _owners_0, _world_0, _namespace_0, _name_0, _steps_0, {$: "Nil"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_pair$1260$(_world_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058provision_left$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_provide$1261$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058clear_reversed$($0, $1, $2) {
  for (;;) {
    {
      const _entries_0 = $0;
      const _id_0 = $1;
      const _acc_0 = $2;
      if (_entries_0.$ === "Nil") {
        return $List$reverse$(_acc_0);
      } else {
        const _t_0 = _entries_0["head"];
        const _key_0 = _t_0["id"];
        const _stamp_0 = _t_0["stamp"];
        const _rest_0 = _entries_0["tail"];
        $0 = _rest_0;
        $1 = _id_0;
        $2 = ($$$$047$$$047$$$047src$047ecs$047lifecycle$058keep$((_key_0 === _id_0), {$: "../../../src/ecs/lifecycle.Entry", "id": _key_0, "stamp": _stamp_0}, _acc_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0) {
  const _added_0 = _metadata_0["added"];
  const _changed_0 = _metadata_0["changed"];
  const _capacity_0 = _metadata_0["capacity"];
  const _depth_0 = _metadata_0["depth"];
  const _exceptional_0 = _metadata_0["exceptional"];
  return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058get_checked$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0, _fits_0) {
  if (!_isnormal_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058get$(_exceptional_0, _id_0))};
  } else {
    if (!_fits_0) {
      return {$: "Tuple", "fst": {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../src/ecs/lifecycle.Stamp", "added": 0, "changed": 0}};
    } else {
      const _x_0 = ((_id_0 - 1) >>> 0);
      return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, {$: "Tuple", fst: _added_0, snd: _added_0[_x_0 % _added_0.length]});
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058normal$(_id_0) {
  return $Bool$and$((_id_0 > 0), (_id_0 <= 131072));
}

function $Bool$to_u32$(_b_0) {
  if (!_b_0) {
    return 0;
  } else {
    return 1;
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058restore_stamp$1260$(_column_0, _id_0, _stamp_0) {
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    return {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, _stamp_0))};
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047src$047ecs$047column$058unseal$1260$(_carrier_0)));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_restore_state$1260$(_id_0, _stamp_0, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_unseal$1260$(_carrier_2)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_store$1260$(_id_0, _incoming_0, _split_0) {
  const _rest_0 = _split_0["fst"];
  const _column_0 = _split_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047component$058restore_swap$1260$(_rest_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$(($$$$047$$$047$$$047src$047ecs$047column$058ensure$1260$(_column_0, _id_0)), _id_0, _incoming_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_lifecycle_got$1260$(_values_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": _stamp_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_lifecycle_got$1260$(_values_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _result_0) {
  const _metadata_0 = _result_0["fst"];
  const _stamp_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": _stamp_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_checked$1261$(_values_0, _stamps_0, _id_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_checked$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_sized$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _size_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, ($Bool$and$(($Bool$and$((_id_0 > 0), (_id_0 <= _size_0))), (_id_0 <= 131072))));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_checked$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _valid_0, _same_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    if (_same_0) {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0);
    } else {
      return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, (_id_0 < _current_0));
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058restored$1260$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058viewed$1260$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047src$047ecs$047column$058restored$1260$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$({$: "../../../src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1260$(_result_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$({$: "../../../src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058recover_selected_rows$($0, $1) {
  for (;;) {
    {
      const _rows_0 = $0;
      const _values_0 = $1;
      if (_rows_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
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

function $$$$047$$$047$$$047src$047ecs$047column$058recover_past$1260$($0, $1) {
  for (;;) {
    {
      const _past_0 = $0;
      const _values_0 = $1;
      if (_past_0.$ === "../../../src/ecs/column.HistoryNil") {
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

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058execute_with_barrier$1260$($0, $1, $2, $3, $4, $5, $6) {
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
        return {$: "../../../src/ecs/schedule.Finished", "schedule": {$: "../../../src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _all_0, "owners": _owners_0}, "world": _world_0, "observations": _observations_0};
      } else {
        const _t_0 = _steps_0["head"];
        if (_t_0.$ === "../../../src/ecs/schedule.Phase") {
          const _phase_0 = _t_0["name"];
          const _rest_0 = _steps_0["tail"];
          $0 = _rest_0;
          $1 = _owners_0;
          $2 = _world_0;
          $3 = _namespace_0;
          $4 = _name_0;
          $5 = _all_0;
          $6 = ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../src/ecs/schedule.Entered", "name": _phase_0}, "tail": {$: "Nil"}}));
          continue;
        } else if (_t_0.$ === "../../../src/ecs/schedule.Barrier") {
          const _rest_1 = _steps_0["tail"];
          return $$$$047$$$047$$$047src$047ecs$047schedule$058after_skip$1260$(run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047schedule$058execute_with_barrier$1260$(_rest_1, _x_0, _x_1, _namespace_0, _name_0, _all_0, _x_2);
});
});
}), ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_state$1260$(_owners_0, _world_0)), ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../src/ecs/schedule.Applied"}, "tail": {$: "Nil"}})));
        } else {
          const _id_0 = _t_0["id"];
          const _slot_0 = _t_0["condition"];
          const _rest_2 = _steps_0["tail"];
          return $$$$047$$$047$$$047src$047ecs$047schedule$058after_condition$1260$(run_clo((_x_3) => {
  return run_clo((_x_4) => {
  return run_clo((_x_5) => {
  return $$$$047$$$047$$$047src$047ecs$047schedule$058execute_with_barrier$1260$(_rest_2, _x_3, _x_4, _namespace_0, _name_0, _all_0, _x_5);
});
});
}), ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058always$1260$(_world_0, _slot_0)), _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_provide$1261$(_world_0) {
  return {$: "Tuple", "fst": _world_0, "snd": {$: "Nil"}};
}

function $$$$047$$$047$$$047src$047ecs$047lifecycle$058keep$(_equal_0, _entry_0, _rest_0) {
  if (_equal_0) {
    return _rest_0;
  } else {
    return {$: "Con", "head": _entry_0, "tail": _rest_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set_checked$(_id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _isnormal_0) {
  if (!_isnormal_0) {
    return {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_exceptional_0, _id_0, _stamp_0))};
  } else {
    return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058write_grow$(17, _id_0, _stamp_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, (_id_0 <= _capacity_0));
  }
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058got_added$(_id_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _observed_0) {
  const _added_0 = _observed_0["fst"];
  const _first_0 = _observed_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, {$: "Tuple", fst: _changed_0, snd: _changed_0[_x_0 % _changed_0.length]});
}

function $$$$047$$$047$$$047src$047ecs$047column$058restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _stamps_0 = _state_0["stamps"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": ($$$$047$$$047$$$047src$047ecs$047lifecycle$058set$(_stamps_0, _id_0, _stamp_0)), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0)));
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_restore_state$1260$(_id_0, _stamp_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  const _capacity_0 = _state_0["capacity"];
  const _current_0 = _state_0["current"];
  const _owner_0 = _state_0["owner"];
  const _remaining_0 = _state_0["remaining"];
  const _past_0 = _state_0["past"];
  return {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": ($$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058set$(_metadata_0, _id_0, _stamp_0)), "capacity": _capacity_0, "current": _current_0, "owner": _owner_0, "remaining": _remaining_0, "past": _past_0}}};
}

function $$$$047$$$047$$$047src$047ecs$047component$058restore_swap$1260$(_rest_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": ($put$(_rest_0, _column_0)), "snd": {$: "Unit"}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": ($put$(_rest_0, _column_1)), "snd": {$: "Unit"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_taken$1261$(_stamps_0, _id_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_current$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_different$1261$(_id_0, _values_0, _stamps_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047src$047ecs$047column$058recover_current$1260$(_values_0, _stamps_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058seek_view$1261$(_x_1, _values_0, _stamps_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_checked$1261$(_id_0, _values_0, _metadata_0, _valid_0) {
  if (!_valid_0) {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "None"};
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, array_rmw(_values_0, _x_0, () => _x_1));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_current$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0) {
  if (_owner_0.$ === "None") {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "None"}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "None"}};
  } else {
    const _owned_0 = _owner_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owned_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_different$1261$(_id_0, _values_0, _metadata_0, _capacity_0, _current_0, _owner_0, _remaining_0, _past_0, _backwards_0) {
  if (_backwards_0) {
    return $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1261$(_id_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap_recovered$1260$(_id_0, {$: "None"}, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_recover_current$1260$(_values_0, _metadata_0, _current_0, _owner_0, _remaining_0, _past_0, (_current_0 > 0))))));
  } else {
    const _x_0 = ((_capacity_0 + _capacity_0) >>> 0);
    const _x_1 = ((_x_0 + 1) >>> 0);
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek_view$1261$(_x_1, _values_0, _metadata_0, _capacity_0, _id_0, _remaining_0, ($$$$047$$$047$$$047src$047ecs$047column$058past_current$1260$(_current_0, _owner_0, _past_0, (_current_0 > 0))), {$: "../../../src/ecs/column.Inspect"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1260$(_view_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_projected_state$1260$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1260$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_restored$1260$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058after_skip$1260$(_next_0, _returned_0, _observations_0) {
  const _owners_0 = _returned_0["fst"];
  const _world_0 = _returned_0["snd"];
  return run_tail(_next_0(_owners_0)(_world_0), _observations_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_state$1260$(_owner_0, _world_0) {
  const _owners_0 = _owner_0["fst"];
  const _t_0 = _owner_0["snd"];
  if (_t_0.$ === "../../../src/ecs/ordinary-app-execution.Off") {
    return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution.Off"}}, "snd": ($$$$047$$$047$$$047src$047ecs$047world$058barrier$1260$(_world_0))};
  } else {
    const _journal_0 = _t_0["journal"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058enabled_barrier$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_recorded$1260$({$: "Tuple", "fst": _owners_0, "snd": _journal_0}, _world_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058after_condition$1260$(_next_0, _checked_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  const _world_0 = _checked_0["fst"];
  const _allowed_0 = _checked_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$058conditioned$1260$(_next_0, _allowed_0, _owners_0, _world_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045run$058always$1260$(_world_0, _id_0) {
  return {$: "Tuple", "fst": _world_0, "snd": true};
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058write_grow$($0, $1, $2, $3, $4, $5, $6, $7, $8) {
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
          return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
        } else {
          return {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
        }
      } else {
        const _rest_0 = (_fuel_0 - 1);
        if (_fits_0) {
          return $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0);
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

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058got_changed$(_added_0, _capacity_0, _depth_0, _exceptional_0, _first_0, _observed_0) {
  const _changed_0 = _observed_0["fst"];
  const _last_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": _added_0, "changed": _changed_0, "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0}, "snd": {$: "../../../src/ecs/lifecycle.Stamp", "added": _first_0, "changed": _last_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058plain_view_projected$1261$(_values_0, _stamps_0, _id_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _projection_0, _stamps_0);
}

function $$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_0) {
  return {$: "Tuple", "fst": _owner_0, "snd": true};
}

function $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058view_taken$1261$(_id_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/column.Rejected") {
    const _column_0 = _outcome_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "None"}};
  } else {
    const _column_1 = _outcome_0["column"];
    const _t_0 = _outcome_0["previous"];
    if (_t_0.$ === "None") {
      return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
    } else {
      const _owner_0 = _t_0["value"];
      return $$$$047$$$047$$$047src$047ecs$047column$058viewed$1261$(($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_0)), _column_1, _id_0);
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _stamps_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047src$047ecs$047column$058prepared_view_projected$1261$(_values_0, _stamps_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Prepared", "state": {$: "../../../src/ecs/column.Owned", "state": {$: "../../../src/ecs/column.State", "values": _values_0, "stamps": _stamps_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _stamps_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_taken$1261$(_id_0, _metadata_0, _result_0) {
  const _values_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "None") {
    return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "None"}};
  } else {
    const _owner_0 = _t_0["value"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _current_0, _remaining_0, _past_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _current_0, "owner": {$: "Some", "value": _owner_0}, "remaining": _remaining_0, "past": _past_0}}}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_seek_view$1261$($0, $1, $2, $3, $4, $5, $6, $7) {
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
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_0 = _remaining_0["id"];
          const _owner_0 = _remaining_0["owner"];
          const _rest_0 = _remaining_0["rest"];
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": 0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_0, "owner": _owner_0, "rest": _rest_0}, "past": _past_0}}}, "snd": {$: "None"}};
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_remaining_0.$ === "../../../src/ecs/owner-handoff.HandoffNil") {
          return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffNil"}, "past": _past_0}}}, "snd": {$: "None"}};
        } else {
          const _id_1 = _remaining_0["id"];
          const _owner_1 = _remaining_0["owner"];
          const _rest_1 = _remaining_0["rest"];
          if (_phase_0.$ === "../../../src/ecs/column.Inspect") {
            $0 = _more_0;
            $1 = _values_0;
            $2 = _metadata_0;
            $3 = _capacity_0;
            $4 = _target_0;
            $5 = {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1};
            $6 = _past_0;
            $7 = {$: "../../../src/ecs/column.Choice", "equal": (_target_0 === _id_1), "before": (_target_0 < _id_1)};
            continue;
          } else {
            const _t_0 = _phase_0["equal"];
            if (_t_0) {
              return $$$$047$$$047$$$047src$047ecs$047column$058indexed_prepared_view_projected$1261$(_values_0, _metadata_0, _capacity_0, _target_0, _rest_1, _past_0, ($$$$047$$$047$$$047src$047ecs$047column$058present$1260$(_owner_1)));
            } else {
              const _t_1 = _phase_0["before"];
              if (_t_1) {
                return {$: "Tuple", "fst": {$: "../../../src/ecs/column.PreparedIndexed", "state": {$: "../../../src/ecs/column.IndexedPreparedOwned", "state": {$: "../../../src/ecs/column.IndexedPreparedState", "values": _values_0, "metadata": _metadata_0, "capacity": _capacity_0, "current": _target_0, "owner": {$: "None"}, "remaining": {$: "../../../src/ecs/owner-handoff.HandoffCon", "id": _id_1, "owner": _owner_1, "rest": _rest_1}, "past": _past_0}}}, "snd": {$: "None"}};
              } else {
                $0 = _more_0;
                $1 = _values_0;
                $2 = _metadata_0;
                $3 = _capacity_0;
                $4 = _target_0;
                $5 = _rest_1;
                $6 = {$: "../../../src/ecs/column.HistoryCon", "id": _id_1, "value": {$: "Some", "value": _owner_1}, "rest": _past_0};
                $7 = {$: "../../../src/ecs/column.Inspect"};
                continue;
              }
            }
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058barrier$1260$(_world_0) {
  return $$$$047$$$047$$$047src$047ecs$047deferred$045command$058world_only$1260$(run_loop($$$$047$$$047$$$047src$047ecs$047world$058barrier_traced$1260$(_world_0, {$: "../../../src/ecs/trace-facts.Off"})));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058enabled_barrier$1260$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owners_0 = _t_0["fst"];
  const _journal_0 = _t_0["snd"];
  const _world_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution.On", "journal": _journal_0}}, "snd": _world_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_recorded$1260$(_owners_0, _world_0) {
  const _owners_1 = _owners_0["fst"];
  const _journal_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_returned$1260$(_owners_1, _journal_0, run_loop($$$$047$$$047$$$047src$047ecs$047world$058barrier_traced$1260$(_world_0, {$: "../../../src/ecs/trace-facts.On", "reverseFacts": {$: "Nil"}})));
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058conditioned$1260$(_next_0, _allowed_0, _owners_0, _world_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  if (!_allowed_0) {
    return run_tail(_next_0(_owners_0)(_world_0), ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../src/ecs/schedule.Skipped", "id": _id_0}, "tail": {$: "Nil"}})));
  } else {
    return $$$$047$$$047$$$047src$047ecs$047schedule$058after_dispatch$1260$(_next_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_state$1260$(_owners_0, _world_0, _id_0)), _namespace_0, _name_0, _all_0, _observations_0, _id_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047indexed$045lifecycle$058write_ready$(_id_0, _added_0, _changed_0, _capacity_0, _depth_0, _exceptional_0, _stamp_0) {
  const _first_0 = _stamp_0["added"];
  const _last_0 = _stamp_0["changed"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = ((_id_0 - 1) >>> 0);
  return {$: "../../../src/ecs/indexed-lifecycle.Metadata", "added": (_added_0[_x_0 % _added_0.length] = _first_0, _added_0), "changed": (_changed_0[_x_1 % _changed_0.length] = _last_0, _changed_0), "capacity": _capacity_0, "depth": _depth_0, "exceptional": _exceptional_0};
}

function $$$$047$$$047$$$047src$047ecs$047column$058restored$1261$(_result_0, _projection_0, _stamps_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/column.Column", "values": _values_0, "stamps": _stamps_0}, "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047column$058viewed$1261$(_projected_0, _column_0, _id_0) {
  const _owner_0 = _projected_0["fst"];
  const _result_0 = _projected_0["snd"];
  if (_column_0.$ === "../../../src/ecs/column.Column") {
    const _values_0 = _column_0["values"];
    const _stamps_0 = _column_0["stamps"];
    const _x_0 = ((_id_0 - 1) >>> 0);
    const _x_1 = {$: "Some", "value": _owner_0};
    return $$$$047$$$047$$$047src$047ecs$047column$058restored$1261$(array_rmw(_values_0, _x_0, () => _x_1), _result_0, _stamps_0);
  } else if (_column_0.$ === "../../../src/ecs/column.Prepared") {
    const _carrier_0 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$({$: "../../../src/ecs/column.Prepared", "state": _carrier_0}, _id_0, {$: "Some", "value": _owner_0})));
  } else if (_column_0.$ === "../../../src/ecs/column.Indexed") {
    const _carrier_1 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, {$: "Tuple", "fst": _owner_0, "snd": _result_0}, ($$$$047$$$047$$$047src$047ecs$047column$058indexed_unseal$1260$(_carrier_1)));
  } else {
    const _carrier_2 = _column_0["state"];
    return $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1261$(_result_0, ($$$$047$$$047$$$047src$047ecs$047column$058swap$1260$({$: "../../../src/ecs/column.PreparedIndexed", "state": _carrier_2}, _id_0, {$: "Some", "value": _owner_0})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _projection_0 = _result_0["snd"];
  const _x_0 = ((_id_0 - 1) >>> 0);
  const _x_1 = {$: "Some", "value": _owner_0};
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, array_rmw(_values_0, _x_0, () => _x_1));
}

function $$$$047$$$047$$$047src$047ecs$047deferred$045command$058world_only$1260$(_result_0) {
  const _world_0 = _result_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047src$047ecs$047world$058barrier_traced$1260$(_world_0, _trace_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047world$058drain_fifo_traced$1260$(_pending_0, {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Nil"}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _trace_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058barrier_returned$1260$(_owners_0, _journal_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record_barrier_operations$1260$(($$$$047$$$047$$$047src$047ecs$047trace$045facts$058facts$(_trace_0)), _journal_0))}, "snd": _world_0};
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058after_dispatch$1260$(_next_0, _result_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  const _owners_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047schedule$058after_outcome$1260$(_next_0, _outcome_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_state$1260$(_owner_0, _world_0, _id_0) {
  const _owners_0 = _owner_0["fst"];
  const _t_0 = _owner_0["snd"];
  if (_t_0.$ === "../../../src/ecs/ordinary-app-execution.Off") {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058disabled_dispatched$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_disabled$1260$(_owners_0, _world_0, _id_0)));
  } else {
    const _journal_0 = _t_0["journal"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058enabled_dispatched$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_recorded$1260$({$: "Tuple", "fst": _owners_0, "snd": _journal_0}, _world_0, _id_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058viewed_return$1261$(_view_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/column.Accepted") {
    const _column_0 = _result_0["column"];
    return {$: "Tuple", "fst": _column_0, "snd": {$: "Some", "value": _view_0}};
  } else {
    const _column_1 = _result_0["column"];
    return {$: "Tuple", "fst": _column_1, "snd": {$: "None"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_projected_state$1261$(_id_0, _result_0, _state_0) {
  const _values_0 = _state_0["values"];
  const _metadata_0 = _state_0["metadata"];
  return $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_projected$1261$(_id_0, _values_0, _metadata_0, _result_0);
}

function $$$$047$$$047$$$047src$047ecs$047column$058indexed_view_restored$1261$(_metadata_0, _projection_0, _result_0) {
  const _values_0 = _result_0["fst"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047column$058indexed_wrap$1260$(_values_0, _metadata_0)), "snd": {$: "Some", "value": _projection_0}};
}

function $$$$047$$$047$$$047src$047ecs$047world$058drain_fifo_traced$1260$(_commands_0, _world_0, _trace_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": _world_0, "snd": _trace_0};
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047world$058drain_apply$1260$(_command_0, run_loop($$$$047$$$047$$$047src$047ecs$047world$058drain_fifo_traced$1260$(_rest_0, _world_0, _trace_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record_barrier_operations$1260$($0, $1) {
  for (;;) {
    {
      const _facts_0 = $0;
      const _journal_0 = $1;
      if (_facts_0.$ === "Nil") {
        return _journal_0;
      } else {
        const _fact_0 = _facts_0["head"];
        const _rest_0 = _facts_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record$1260$({$: "../../../src/ecs/execution-trace.BarrierOperationObserved", "fact": _fact_0}, _journal_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047trace$045facts$058facts$(_state_0) {
  if (_state_0.$ === "../../../src/ecs/trace-facts.Off") {
    return {$: "Nil"};
  } else {
    const _facts_0 = _state_0["reverseFacts"];
    return $List$reverse$(_facts_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047schedule$058after_outcome$1260$(_next_0, _outcome_0, _owners_0, _namespace_0, _name_0, _all_0, _observations_0, _id_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/schedule.Failed", "schedule": {$: "../../../src/ecs/schedule.Schedule", "namespace": _namespace_0, "name": _name_0, "steps": _all_0, "owners": _owners_0}, "world": _world_0, "error": _error_0, "observations": ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../src/ecs/schedule.Ran", "id": _id_0}, "tail": {$: "Nil"}}))};
  } else {
    const _world_1 = _outcome_0["world"];
    return run_tail(_next_0(_owners_0)(_world_1), ($List$append$(_observations_0, {$: "Con", "head": {$: "../../../src/ecs/schedule.Ran", "id": _id_0}, "tail": {$: "Nil"}})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058disabled_dispatched$1260$(_result_0) {
  const _owners_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution.Off"}}, "snd": _outcome_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_disabled$1260$(_owners_0, _world_0, _id_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058disabled_outcome$1260$(($GDispatch$())(_owners_0)({$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": {$: "../../../src/ecs/trace-facts.Off"}})(_id_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058enabled_dispatched$1260$(_result_0) {
  const _t_0 = _result_0["fst"];
  const _owners_0 = _t_0["fst"];
  const _journal_0 = _t_0["snd"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/ordinary-app-execution.On", "journal": _journal_0}}, "snd": _outcome_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_recorded$1260$(_owners_0, _world_0, _id_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_id$1260$(_owners_0, _world_0, _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047world$058drain_apply$1260$(_command_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047deferred$045command$058run$1260$(_command_0, _world_0, _trace_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record$1260$(_event_0, _journal_0) {
  const _catalog_0 = _journal_0["catalog"];
  const _events_0 = _journal_0["events"];
  return {$: "../../../src/ecs/ordinary-app-execution.Journal", "catalog": _catalog_0, "events": {$: "Con", "head": _event_0, "tail": _events_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058disabled_outcome$1260$(_result_0) {
  const _owners_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../src/ecs/system.Succeeded") {
    const _t_1 = _t_0["world"];
    const _world_0 = _t_1["world"];
    const _output_0 = _t_0["output"];
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0}};
  } else {
    const _t_2 = _t_0["world"];
    const _world_1 = _t_2["world"];
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _owners_0, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": _error_0}};
  }
}

function $GDispatch$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_dispatch$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatch_id$1260$(_owners_0, _world_0, _id_0) {
  const _owners_1 = _owners_0["fst"];
  const _journal_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identified$1260$(_owners_1, _journal_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity$1260$(_journal_0, _world_0, _id_0)));
}

function $$$$047$$$047$$$047src$047ecs$047deferred$045command$058run$1260$(_command_0, _world_0, _trace_0) {
  if (_command_0.$ === "../../../src/ecs/deferred-command.Raw") {
    const _apply_0 = _command_0["apply"];
    return {$: "Tuple", "fst": _apply_0(_world_0), "snd": _trace_0};
  } else {
    const _apply_1 = _command_0["apply"];
    return run_tail(_apply_1(_trace_0), _world_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_dispatch$1260$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_pair$1261$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identified$1260$(_owners_0, _journal_0, _id_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  const _fact_0 = _t_0["fst"];
  const _before_0 = _t_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatched$1260$(_fact_0, _before_0, _journal_0, ($GDispatch$())(_owners_0)({$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": {$: "../../../src/ecs/trace-facts.On", "reverseFacts": {$: "Nil"}}})(_id_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity$1260$(_journal_0, _world_0, _id_0) {
  const _catalog_0 = _journal_0["catalog"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity_namespace$1260$(_id_0, run_loop($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058registration_name$(_catalog_0, _id_0)), ($$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_pair$1261$(_owners_0, _world_0, _id_0) {
  const _a_0 = _owners_0["fst"];
  const _b_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_folded$1261$(_b_0, _world_0, _id_0, ($AFold$())(_a_0));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058dispatched$1260$(_fact_0, _before_0, _journal_0, _result_0) {
  const _owners_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../src/ecs/system.Succeeded") {
    const _t_1 = _t_0["world"];
    const _world_0 = _t_1["world"];
    const _trace_0 = _t_1["trace"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058succeeded$1260$(_owners_0, _fact_0, _before_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record_operations$1260$(($$$$047$$$047$$$047src$047ecs$047trace$045facts$058facts$(_trace_0)), _fact_0, _journal_0)), ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_0)));
  } else {
    const _t_2 = _t_0["world"];
    const _world_1 = _t_2["world"];
    const _trace_1 = _t_2["trace"];
    const _error_0 = _t_0["error"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058failed$1260$(_owners_0, _fact_0, _before_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record_operations$1260$(($$$$047$$$047$$$047src$047ecs$047trace$045facts$058facts$(_trace_1)), _fact_0, _journal_0)), _error_0, ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_1)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity_namespace$1260$(_id_0, _name_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _namespace_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity_clock$1260$(_namespace_0, _id_0, _name_0, ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058registration_name$(_items_0, _id_0) {
  if (_items_0.$ === "Nil") {
    return {$: "None"};
  } else {
    const _t_0 = _items_0["head"];
    const _candidate_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _rest_0 = _items_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058named$((_candidate_0 === _id_0), _name_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058registration_name$(_rest_0, _id_0);
}));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_folded$1261$(_b_0, _world_0, _id_0, _result_0) {
  const _a_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_selected$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058member$1260$(_fields_0, _id_0)), _a_0, _b_0, _world_0, _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058succeeded$1260$(_owners_0, _fact_0, _before_0, _journal_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _after_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record$1260$({$: "../../../src/ecs/execution-trace.SystemCompleted", "identity": _fact_0, "before": _before_0, "after": _after_0, "status": {$: "../../../src/ecs/execution-trace.SystemOk"}}, _journal_0))}, "snd": {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record_operations$1260$($0, $1, $2) {
  for (;;) {
    {
      const _facts_0 = $0;
      const _identity_0 = $1;
      const _journal_0 = $2;
      if (_facts_0.$ === "Nil") {
        return _journal_0;
      } else {
        const _fact_0 = _facts_0["head"];
        const _rest_0 = _facts_0["tail"];
        $0 = _rest_0;
        $1 = _identity_0;
        $2 = ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record$1260$({$: "../../../src/ecs/execution-trace.OperationObserved", "identity": _identity_0, "fact": _fact_0}, _journal_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058failed$1260$(_owners_0, _fact_0, _before_0, _journal_0, _error_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _after_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _owners_0, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058record$1260$({$: "../../../src/ecs/execution-trace.SystemCompleted", "identity": _fact_0, "before": _before_0, "after": _after_0, "status": {$: "../../../src/ecs/execution-trace.SystemError", "error": _error_0}}, _journal_0))}, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058identity_clock$1260$(_namespace_0, _id_0, _name_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _clock_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/execution-trace.Identity", "namespace": _namespace_0, "id": _id_0, "name": _name_0}, "snd": _clock_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$058named$(_found_0, _name_0, _next_0) {
  if (_found_0) {
    return _name_0;
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_selected$1261$(_found_0, _a_0, _b_0, _world_0, _id_0) {
  if (_found_0) {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_returned$1261$(_b_0, ($ADispatch$())(_a_0)(_world_0)(_id_0));
  } else {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_returned$1261$(_a_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_run$1260$(_b_0, _world_0, _id_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058member$1260$(_fields_0, _id_0) {
  return $$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058member$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058identities$1260$(_fields_0)), _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_returned$1261$(_right_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_outcome$1261$(_outcome_0))};
}

function $ADispatch$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_dispatch$1260$();
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_returned$1261$(_left_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_outcome$1261$(_outcome_0))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_run$1260$(_invocation_0, _context_0, _id_0) {
  const _t_0 = _invocation_0["record"];
  const _owner_0 = _t_0["token"];
  const _fields_0 = _t_0["fields"];
  const _args_0 = _invocation_0["args"];
  const _outputs_0 = _invocation_0["outputs"];
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058registration_id$1260$(_fields_0));
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_allowed$1260$((_id_0 === _x_0), {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _owner_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, _context_0);
}

function $$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058member$(_items_0, _wanted_0) {
  if (_items_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _items_0["head"];
    const _id_0 = _t_0["id"];
    const _rest_0 = _items_0["tail"];
    const _x_0 = (_id_0 === _wanted_0);
    const _x_1 = ($$$$047$$$047$$$047src$047ecs$047captured$045schedule$045composition$058member$(_rest_0, _wanted_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_outcome$1261$(_outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Succeeded") {
    const _world_0 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0};
  } else {
    const _world_1 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": {$: "../../../src/ecs/captured-schedule-composition.LeftError", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_dispatch$1260$() {
  return run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return run_clo((_x_2) => {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_pair$1260$(_x_0, _x_1, _x_2);
});
});
});
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_outcome$1261$(_outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Succeeded") {
    const _world_0 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0};
  } else {
    const _world_1 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": {$: "../../../src/ecs/captured-schedule-composition.RightError", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_allowed$1260$(_allowed_0, _invocation_0, _context_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _invocation_0, "snd": {$: "../../../src/ecs/system.Failed", "world": _context_0, "error": {$: "../../../src/ecs/ordinary-app-capture-query.RegistrationRefused"}}};
  } else {
    const _t_0 = _invocation_0["record"];
    const _owner_0 = _t_0["token"];
    const _args_0 = _invocation_0["args"];
    const _world_0 = _context_0["world"];
    const _trace_0 = _context_0["trace"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_returned$1260$(_args_0, _trace_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058run$1260$(_owner_0, _world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058registration_id$1260$(_fields_0) {
  const _id_0 = _fields_0["id"];
  return _id_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_pair$1260$(_owners_0, _world_0, _id_0) {
  const _a_0 = _owners_0["fst"];
  const _b_0 = _owners_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_folded$1260$(_b_0, _world_0, _id_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045records$058empty$1260$(_a_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_returned$1260$(_args_0, _trace_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-capture-query.Completed") {
    const _world_0 = _result_0["world"];
    const _owner_0 = _result_0["owner"];
    const _t_0 = _result_0["result"];
    if (_t_0.$ === "Done") {
      const _outputs_0 = _t_0["value"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_extracted$1260$(_args_0, _outputs_0, {$: "../../../src/ecs/system.Succeeded", "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": _trace_0}, "output": {$: "Unit"}}, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058fields$1260$(_owner_0)));
    } else {
      const _error_0 = _t_0["error"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_extracted$1260$(_args_0, {$: "Nil"}, {$: "../../../src/ecs/system.Failed", "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": _trace_0}, "error": {$: "../../../src/ecs/ordinary-app-capture-query.CallbackFailure", "error": _error_0}}, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058fields$1260$(_owner_0)));
    }
  } else {
    const _world_1 = _result_0["world"];
    const _owner_1 = _result_0["owner"];
    const _returnedArgs_0 = _result_0["args"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_extracted$1260$(_returnedArgs_0, {$: "Nil"}, {$: "../../../src/ecs/system.Failed", "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_1, "trace": _trace_0}, "error": {$: "../../../src/ecs/ordinary-app-capture-query.RegistrationRefused"}}, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$045fields$058fields$1260$(_owner_1)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058run$1260$(_owner_0, _world_0, _args_0) {
  const _instance_0 = _owner_0["instance"];
  const _cursor_0 = _owner_0["cursor"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058returned$1260$(_cursor_0, ($$$$047$$$047$$$047src$047ecs$047captures$058run$1260$(_instance_0, _world_0, {$: "Tuple", "fst": _args_0, "snd": _cursor_0})));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_folded$1260$(_b_0, _world_0, _id_0, _result_0) {
  const _a_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_selected$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058member$1260$(_fields_0, _id_0)), _a_0, _b_0, _world_0, _id_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045capture$045query$058execution_extracted$1260$(_args_0, _outputs_0, _outcome_0, _result_0) {
  const _owner_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _owner_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, "snd": _outcome_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058returned$1260$(_cursor_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/local.Completed") {
    const _world_0 = _result_0["world"];
    const _instance_0 = _result_0["instance"];
    const _t_0 = _result_0["result"];
    if (_t_0.$ === "Done") {
      const _values_0 = _t_0["value"];
      return $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058successful$1260$(_instance_0, _values_0, ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_0)));
    } else {
      const _error_0 = _t_0["error"];
      return {$: "../../../src/ecs/ordinary-capture-query.Completed", "world": _world_0, "owner": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": _instance_0, "cursor": _cursor_0}, "result": {$: "Fail", "error": _error_0}};
    }
  } else {
    const _world_1 = _result_0["world"];
    const _instance_1 = _result_0["instance"];
    const _t_1 = _result_0["args"];
    const _args_0 = _t_1["fst"];
    return {$: "../../../src/ecs/ordinary-capture-query.Refused", "world": _world_1, "owner": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": _instance_1, "cursor": _cursor_0}, "args": _args_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047captures$058run$1260$(_instance_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047src$047ecs$047local$058run$1260$(_instance_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058dispatch_selected$1260$(_found_0, _a_0, _b_0, _world_0, _id_0) {
  if (_found_0) {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_returned$1260$(_b_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_dispatch$1260$(_a_0, _world_0, _id_0)));
  } else {
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_returned$1260$(_a_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_run$1260$(_b_0, _world_0, _id_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058successful$1260$(_instance_0, _values_0, _clocked_0) {
  const _world_0 = _clocked_0["fst"];
  const _clock_0 = _clocked_0["snd"];
  return {$: "../../../src/ecs/ordinary-capture-query.Completed", "world": _world_0, "owner": {$: "../../../src/ecs/ordinary-capture-query.Owner", "instance": _instance_0, "cursor": _clock_0}, "result": {$: "Done", "value": _values_0}};
}

function $$$$047$$$047$$$047src$047ecs$047local$058run$1260$(_instance_0, _world_0, _args_0) {
  const _namespace_0 = _instance_0["namespace"];
  const _id_0 = _instance_0["id"];
  const _name_0 = _instance_0["name"];
  const _access_0 = _instance_0["access"];
  const _local_0 = _instance_0["local"];
  const _actual_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return $$$$047$$$047$$$047src$047ecs$047local$058checked$1260$(($Bool$and$((_namespace_0 === _actual_0), ($$$$047$$$047$$$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0)))), {$: "../../../src/ecs/local.Instance", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _local_0}, {$: "../../../src/ecs/world.World", "namespace": _actual_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _args_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_returned$1260$(_right_0, _result_0) {
  const _left_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_outcome$1260$(_outcome_0))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058empty_dispatch$1260$(_owner_0, _world_0, _id_0) {
  return {$: "Tuple", "fst": _owner_0, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": {$: "Unit"}}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_returned$1260$(_left_0, _result_0) {
  const _right_0 = _result_0["fst"];
  const _outcome_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": _left_0, "snd": _right_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_outcome$1260$(_outcome_0))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_run$1260$(_owner_0, _world_0, _id_0) {
  const _t_0 = _owner_0["record"];
  const _token_0 = _t_0["token"];
  const _fields_0 = _t_0["fields"];
  const _args_0 = _owner_0["args"];
  const _outputs_0 = _owner_0["outputs"];
  const _selected_0 = _id_0;
  const _x_0 = ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058registration_id$1260$(_fields_0));
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_allowed$1260$((_selected_0 === _x_0), {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, _world_0, _selected_0);
}

function $$$$047$$$047$$$047src$047ecs$047local$058checked$1260$(_allowed_0, _instance_0, _world_0, _args_0) {
  if (!_allowed_0) {
    return {$: "../../../src/ecs/local.Refused", "world": _world_0, "instance": _instance_0, "args": _args_0};
  } else {
    const _namespace_0 = _instance_0["namespace"];
    const _id_0 = _instance_0["id"];
    const _name_0 = _instance_0["name"];
    const _access_0 = _instance_0["access"];
    const _local_0 = _instance_0["local"];
    return $$$$047$$$047$$$047src$047ecs$047local$058completed$1260$(_namespace_0, _id_0, _name_0, _access_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058runner$1260$(_world_0, _local_0, _args_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058left_outcome$1260$(_outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Succeeded") {
    const _world_0 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0};
  } else {
    const _world_1 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": {$: "../../../src/ecs/captured-schedule-composition.LeftError", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045recipe$058right_outcome$1260$(_outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Succeeded") {
    const _world_0 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0};
  } else {
    const _world_1 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": {$: "../../../src/ecs/captured-schedule-composition.RightError", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_allowed$1260$(_allowed_0, _owner_0, _world_0, _id_0) {
  if (!_allowed_0) {
    return {$: "Tuple", "fst": _owner_0, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": {$: "../../../src/ecs/ordinary-app-component.RegistrationRefused"}}};
  } else {
    const _t_0 = _owner_0["record"];
    const _token_0 = _t_0["token"];
    const _fields_0 = _t_0["fields"];
    const _args_0 = _owner_0["args"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_returned$1260$(_args_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058component$1260$(_token_0, _fields_0, _world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047local$058completed$1260$(_namespace_0, _id_0, _name_0, _access_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/local.Succeeded") {
    const _world_0 = _outcome_0["world"];
    const _local_0 = _outcome_0["local"];
    const _out_0 = _outcome_0["output"];
    return {$: "../../../src/ecs/local.Completed", "world": _world_0, "instance": {$: "../../../src/ecs/local.Instance", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _local_0}, "result": {$: "Done", "value": _out_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _local_1 = _outcome_0["local"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/local.Completed", "world": _world_1, "instance": {$: "../../../src/ecs/local.Instance", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "local": _local_1}, "result": {$: "Fail", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058runner$1260$(_world_0, _capture_0, _args_0) {
  const _args_1 = _args_0["fst"];
  const _cursor_0 = _args_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058finished$1260$(($$$$047$$$047$$$047src$047ecs$047capture$045query$058each_since$1260$(_args_1, _cursor_0, _capture_0, _world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045component$058execution_returned$1260$(_args_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/ordinary-app-registration-run.Completed") {
    const _token_0 = _result_0["token"];
    const _fields_0 = _result_0["fields"];
    const _t_0 = _result_0["outcome"];
    if (_t_0.$ === "../../../src/ecs/system.Succeeded") {
      const _world_0 = _t_0["world"];
      const _outputs_0 = _t_0["output"];
      return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, "args": _args_0, "outputs": _outputs_0}, "snd": {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": {$: "Unit"}}};
    } else {
      const _world_1 = _t_0["world"];
      const _error_0 = _t_0["error"];
      return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_0, "fields": _fields_0}, "args": _args_0, "outputs": {$: "Nil"}}, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_1, "error": {$: "../../../src/ecs/ordinary-app-component.CallbackFailure", "error": _error_0}}};
    }
  } else {
    const _token_1 = _result_0["token"];
    const _fields_1 = _result_0["fields"];
    const _world_2 = _result_0["world"];
    return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-execution-recipe.Invocation", "record": {$: "../../../src/ecs/ordinary-app-records.Record", "token": _token_1, "fields": _fields_1}, "args": _args_0, "outputs": {$: "Nil"}}, "snd": {$: "../../../src/ecs/system.Failed", "world": _world_2, "error": {$: "../../../src/ecs/ordinary-app-component.RegistrationRefused"}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058component$1260$(_token_0, _fields_0, _context_0, _args_0) {
  const _world_0 = _context_0["world"];
  const _trace_0 = _context_0["trace"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058returned$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058component_transport$1260$(_token_0, _fields_0, _trace_0, _world_0, _args_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058finished$1260$(_result_0) {
  const _world_0 = _result_0["world"];
  const _capture_0 = _result_0["capture"];
  const _t_0 = _result_0["outcome"];
  if (_t_0.$ === "../../../src/ecs/transaction.Success") {
    const _values_0 = _result_0["values"];
    return {$: "../../../src/ecs/local.Succeeded", "world": _world_0, "local": _capture_0, "output": _values_0};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../src/ecs/local.Failed", "world": _world_0, "local": _capture_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058each_since$1260$(_args_0, _cursor_0, _capture_0, _world_0) {
  return $$$$047$$$047$$$047src$047ecs$047capture$045query$058reserved$1260$(_args_0, _cursor_0, _capture_0, ($$$$047$$$047$$$047src$047ecs$047world$058handles$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058returned$1260$(_result_0) {
  const _t_0 = _result_0["fst"];
  if (_t_0.$ === "../../../src/ecs/ordinary-app-registration-run.Completed") {
    const _token_0 = _t_0["token"];
    const _fields_0 = _t_0["fields"];
    const _value_0 = _t_0["outcome"];
    const _trace_0 = _result_0["snd"];
    return {$: "../../../src/ecs/ordinary-app-registration-run.Completed", "token": _token_0, "fields": _fields_0, "outcome": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058outcome$1260$(_trace_0, _value_0))};
  } else {
    const _token_1 = _t_0["token"];
    const _fields_1 = _t_0["fields"];
    const _world_0 = _t_0["world"];
    const _args_0 = _t_0["args"];
    const _trace_1 = _result_0["snd"];
    return {$: "../../../src/ecs/ordinary-app-registration-run.RegistrationRejected", "token": _token_1, "fields": _fields_1, "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": _trace_1}, "args": _args_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058component_transport$1260$(_token_0, _fields_0, _trace_0, _world_0, _args_0) {
  const _namespace_0 = _fields_0["namespace"];
  const _id_0 = _fields_0["id"];
  const _name_0 = _fields_0["name"];
  const _access_0 = _fields_0["access"];
  const _cursor_0 = _fields_0["cursor"];
  const _slot_0 = _fields_0["slot"];
  const _clauses_0 = _fields_0["clauses"];
  const _kind_0 = _fields_0["kind"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058run_observed$1260$(_token_0, {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _slot_0, "clauses": _clauses_0, "kind": _kind_0}, _trace_0, _world_0, {$: "Tuple", "fst": _args_0, "snd": _cursor_0});
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058reserved$1260$(_args_0, _cursor_0, _capture_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _handles_0 = _result_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047capture$045query$058finished$1260$(run_loop($$$$047$$$047$$$047src$047ecs$047capture$045query$058run_handles$1260$(_handles_0, _args_0, _cursor_0, _capture_0, ($$$$047$$$047$$$047src$047ecs$047transaction$058begin$1260$(_world_0)))));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045execution$045run$058outcome$1260$(_trace_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/system.Succeeded") {
    const _world_0 = _result_0["world"];
    const _output_0 = _result_0["output"];
    return {$: "../../../src/ecs/system.Succeeded", "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_0, "trace": _trace_0}, "output": _output_0};
  } else {
    const _world_1 = _result_0["world"];
    const _error_0 = _result_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": {$: "../../../src/ecs/execution-context.Context", "world": _world_1, "trace": _trace_0}, "error": _error_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058run_observed$1260$(_token_0, _fields_0, _trace_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058restored_observed$1260$(_fields_0, _trace_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058finished$1260$(_observed_0) {
  const _capture_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _tx_0 = _t_0["fst"];
  const _t_1 = _t_0["snd"];
  const _status_0 = _t_1["fst"];
  const _values_0 = _t_1["snd"];
  return $$$$047$$$047$$$047src$047ecs$047capture$045query$058returned$1260$(_capture_0, _values_0, ($$$$047$$$047$$$047src$047ecs$047commands$058tx_finish$1260$(_tx_0, _status_0)));
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058run_handles$1260$(_handles_0, _args_0, _cursor_0, _capture_0, _tx_0) {
  if (_handles_0.$ === "Nil") {
    return {$: "Tuple", "fst": _capture_0, "snd": {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": {$: "Nil"}}}};
  } else {
    const _handle_0 = _handles_0["head"];
    const _rest_0 = _handles_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047capture$045query$058selected$1260$(_args_0, _capture_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047src$047ecs$047capture$045query$058run_handles$1260$(_rest_0, _args_0, _cursor_0, _x_0, _x_1);
});
}), ($$$$047$$$047$$$047src$047ecs$047compose$058plan_select$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058plan$1260$())))({$: "../../../src/ecs/compose.Frame", "tx": _tx_0, "handle": _handle_0, "error": {$: "None"}, "cursor": _cursor_0}));
  }
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "../../../src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}, "trace": {$: "../../../src/ecs/trace-facts.Off"}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058restored_observed$1260$(_fields_0, _trace_0, _world_0, _args_0) {
  const _namespace_0 = _fields_0["namespace"];
  const _id_0 = _fields_0["id"];
  const _name_0 = _fields_0["name"];
  const _access_0 = _fields_0["access"];
  const _cursor_0 = _fields_0["cursor"];
  const _slot_0 = _fields_0["slot"];
  const _clauses_0 = _fields_0["clauses"];
  const _kind_0 = _fields_0["kind"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058captured_observed$1260$(_slot_0, _clauses_0, _kind_0, ($$$$047$$$047$$$047src$047ecs$047system$058run_observed$1260$({$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _trace_0, _world_0, _args_0)));
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058returned$1260$(_capture_0, _values_0, _result_0) {
  const _world_0 = _result_0["world"];
  const _t_0 = _result_0["outcome"];
  if (_t_0.$ === "../../../src/ecs/transaction.Success") {
    return {$: "../../../src/ecs/capture-query.Executed", "world": _world_0, "capture": _capture_0, "outcome": {$: "../../../src/ecs/transaction.Success"}, "values": _values_0};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../src/ecs/capture-query.Executed", "world": _world_0, "capture": _capture_0, "outcome": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}, "values": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047commands$058tx_finish$1260$(_tx_0, _outcome_0) {
  return $$$$047$$$047$$$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0);
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058selected$1260$(_args_0, _capture_0, _next_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const __0 = _t_0["handle"];
  const __1 = _t_0["error"];
  const __2 = _t_0["cursor"];
  const _t_1 = _observed_0["snd"];
  if (!_t_1) {
    return run_tail(_next_0(_capture_0), _tx_0);
  } else {
    return $$$$047$$$047$$$047src$047ecs$047capture$045query$058body_returned$1260$(_next_0, ($grow$1260$(_capture_0, _args_0, {$: "../../../src/ecs/compose.Frame", "tx": _tx_0, "handle": __0, "error": __1, "cursor": __2})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058plan_select$1261$(_plan_0) {
  const _select_0 = _plan_0["select"];
  return _select_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058plan$1260$() {
  return {$: "../../../src/ecs/compose.Plan", "caps": ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1262$(($growth_query$()))), "select": ($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1262$(($growth_query$())))};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058captured_observed$1260$(_slot_0, _clauses_0, _kind_0, _result_0) {
  const _result_1 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058captured$1260$(_slot_0, _clauses_0, _kind_0, _result_1)), "snd": _trace_0};
}

function $$$$047$$$047$$$047src$047ecs$047system$058run_observed$1260$(_registry_0, _trace_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047src$047ecs$047system$058run_observed_with$1260$(_registry_0, _trace_0, _world_0, _args_0);
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058body_returned$1260$(_next_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const _internal_0 = _t_0["error"];
  const _t_1 = _observed_0["snd"];
  const _capture_0 = _t_1["fst"];
  const _t_2 = _t_1["snd"];
  const _user_0 = _t_2["fst"];
  const _value_0 = _t_2["snd"];
  return $$$$047$$$047$$$047src$047ecs$047capture$045query$058completed$1260$(_next_0, _capture_0, _tx_0, _value_0, ($$$$047$$$047$$$047src$047ecs$047compose$058outcome$1261$(_internal_0, _user_0)));
}

function $grow$1260$(_memory_0, __0, _owner_0) {
  return $grow_seen$1260$(_memory_0, run_loop($$$$047$$$047$$$047src$047ecs$047capabilities$058get$1261$(_owner_0)));
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058grant$1262$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  return _grant_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045query$045declaration$058selector$1262$(_declaration_0) {
  const _select_0 = _declaration_0["select"];
  return _select_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058captured$1260$(_slot_0, _clauses_0, _kind_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/system.Completed") {
    const _registry_0 = _result_0["registry"];
    const _outcome_0 = _result_0["outcome"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058completed$1260$(_outcome_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058returned$1260$(_slot_0, _clauses_0, _kind_0, _registry_0)));
  } else {
    const _registry_1 = _result_0["registry"];
    const _world_0 = _result_0["world"];
    const _args_0 = _result_0["args"];
    return $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058rejected$1260$(_world_0, _args_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058returned$1260$(_slot_0, _clauses_0, _kind_0, _registry_1)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047system$058run_observed_with$1260$(_registry_0, _trace_0, _world_0, _args_0) {
  return $$$$047$$$047$$$047src$047ecs$047system$058observed_named_with$1260$(_registry_0, _trace_0, ($$$$047$$$047$$$047src$047ecs$047world$058namespace$1260$(_world_0)), _args_0);
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047src$047ecs$047commands$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047src$047ecs$047commands$058publish$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047src$047ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058completed$1260$(_next_0, _capture_0, _tx_0, _value_0, _status_0) {
  if (_status_0.$ === "../../../src/ecs/transaction.Success") {
    return $$$$047$$$047$$$047src$047ecs$047capture$045query$058prepend$1260$(_value_0, _next_0(_capture_0)(_tx_0));
  } else {
    const _error_0 = _status_0["error"];
    return {$: "Tuple", "fst": _capture_0, "snd": {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}, "snd": {$: "Nil"}}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058outcome$1261$(_internal_0, _user_0) {
  if (_internal_0.$ === "Some") {
    const _error_0 = _internal_0["value"];
    return {$: "../../../src/ecs/transaction.Failure", "error": {$: "../../../src/ecs/compose.AccessError", "error": _error_0}};
  } else {
    if (_user_0.$ === "../../../src/ecs/transaction.Failure") {
      const _error_1 = _user_0["error"];
      return {$: "../../../src/ecs/transaction.Failure", "error": {$: "../../../src/ecs/compose.UserError", "error": _error_1}};
    } else {
      return {$: "../../../src/ecs/transaction.Success"};
    }
  }
}

function $grow_seen$1260$(_memory_0, _result_0) {
  const _entered_0 = _memory_0["entered"];
  const _total_0 = _memory_0["total"];
  const _sealed_0 = _memory_0["sealed"];
  const _owner_0 = _result_0["fst"];
  const _t_0 = _result_0["snd"];
  if (_t_0.$ === "../../../src/ecs/component.Found") {
    const _height_0 = _t_0["value"];
    return $accumulated$1260$(_height_0, ((_entered_0 + 1) >>> 0), _sealed_0, _owner_0, {$: "Tuple", fst: _total_0, snd: _total_0[0 % _total_0.length]});
  } else {
    return {$: "Tuple", "fst": _owner_0, "snd": {$: "Tuple", "fst": {$: "Memory", "entered": _entered_0, "total": _total_0, "sealed": _sealed_0}, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": {$: "Frost", "entered": 999}}, "snd": 999}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058get$1261$(_ctx_0) {
  return run_tail(($$$$047$$$047$$$047src$047ecs$047capabilities$058write_read_field$1260$(($write_cap$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058plan$1260$()))))))), _ctx_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058completed$1260$(_outcome_0, _result_0) {
  const _token_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return {$: "../../../src/ecs/ordinary-app-registration-run.Completed", "token": _token_0, "fields": _fields_0, "outcome": _outcome_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058returned$1260$(_slot_0, _clauses_0, _kind_0, _registry_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/ordinary-app-registration-fields.Token"}, "snd": {$: "../../../src/ecs/ordinary-app-registration-fields.Fields", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0, "slot": _slot_0, "clauses": _clauses_0, "kind": _kind_0}};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045app$045registration$045run$058rejected$1260$(_world_0, _args_0, _result_0) {
  const _token_0 = _result_0["fst"];
  const _fields_0 = _result_0["snd"];
  return {$: "../../../src/ecs/ordinary-app-registration-run.RegistrationRejected", "token": _token_0, "fields": _fields_0, "world": _world_0, "args": _args_0};
}

function $$$$047$$$047$$$047src$047ecs$047system$058observed_named_with$1260$(_registry_0, _trace_0, _named_0, _args_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  const _world_0 = _named_0["fst"];
  const _actual_0 = _named_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047system$058observed_namespace_checked_with$1260$({$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _trace_0, _world_0, _args_0, (_namespace_0 === _actual_0));
}

function $$$$047$$$047$$$047src$047ecs$047commands$058enqueue$1260$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047src$047ecs$047commands$058enqueue_list$1260$(_commands_0, _world_0);
}

function $$$$047$$$047$$$047src$047ecs$047commands$058publish$1260$(_world_0, _events_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058event_publish$1260$(_world_0, _events_0);
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058rollback$1260$($0, $1) {
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

function $$$$047$$$047$$$047src$047ecs$047capture$045query$058prepend$1260$(_value_0, _observed_0) {
  const _capture_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _tx_0 = _t_0["fst"];
  const _t_1 = _t_0["snd"];
  const _status_0 = _t_1["fst"];
  const _values_0 = _t_1["snd"];
  return {$: "Tuple", "fst": _capture_0, "snd": {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": _status_0, "snd": {$: "Con", "head": _value_0, "tail": _values_0}}}};
}

function $accumulated$1260$(_height_0, _entered_0, _sealed_0, _owner_0, _result_0) {
  const _total_0 = _result_0["fst"];
  const _sum_0 = _result_0["snd"];
  const _x_0 = ((_sum_0 + _height_0) >>> 0);
  return {$: "Tuple", "fst": run_loop($$$$047$$$047$$$047src$047ecs$047capabilities$058set$1261$(_owner_0, {$: "Plant", "height": ((_height_0 + 10) >>> 0)})), "snd": {$: "Tuple", "fst": {$: "Memory", "entered": _entered_0, "total": (_total_0[0 % _total_0.length] = _x_0, _total_0), "sealed": _sealed_0}, "snd": {$: "Tuple", "fst": ($growth_status$(_entered_0)), "snd": ((_height_0 + 10) >>> 0)}}};
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058write_read_field$1260$(_cap_0) {
  const _get_0 = _cap_0["get"];
  return _get_0;
}

function $write_cap$1260$(_caps_0) {
  const _write_0 = _caps_0["fst"];
  return _write_0;
}

function $$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1261$(_plan_0) {
  const _caps_0 = _plan_0["caps"];
  return _caps_0;
}

function $$$$047$$$047$$$047src$047ecs$047system$058observed_namespace_checked_with$1260$(_registry_0, _trace_0, _world_0, _args_0, _allowed_0) {
  const _namespace_0 = _registry_0["namespace"];
  const _id_0 = _registry_0["id"];
  const _name_0 = _registry_0["name"];
  const _access_0 = _registry_0["access"];
  const _cursor_0 = _registry_0["cursor"];
  if (!_allowed_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/system.RegistrationRejected", "registry": {$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, "world": _world_0, "args": _args_0}, "snd": _trace_0};
  } else {
    return $$$$047$$$047$$$047src$047ecs$047system$058observed_checked_with$1260$({$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _cursor_0}, _trace_0, ($$$$047$$$047$$$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0)), _args_0);
  }
}

function $$$$047$$$047$$$047src$047ecs$047commands$058enqueue_list$1260$($0, $1) {
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
        $1 = ($$$$047$$$047$$$047src$047ecs$047world$058enqueue_command$1260$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058event_publish$1260$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058set$1261$(_ctx_0, _value_0) {
  return run_tail(($$$$047$$$047$$$047src$047ecs$047capabilities$058write_field$1260$(($write_cap$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1261$(($$$$047$$$047$$$047src$047ecs$047ordinary$045capture$045query$058plan$1260$())))))))(_ctx_0), _value_0);
}

function $growth_status$(_entered_0) {
  if (_entered_0 == 2) {
    return {$: "../../../src/ecs/transaction.Failure", "error": {$: "Frost", "entered": 2}};
  } else {
    return {$: "../../../src/ecs/transaction.Success"};
  }
}

function $$$$047$$$047$$$047src$047ecs$047system$058observed_checked_with$1260$(_registry_0, _trace_0, _checked_0, _args_0) {
  const _world_0 = _checked_0["fst"];
  const _t_0 = _checked_0["snd"];
  if (!_t_0) {
    return {$: "Tuple", "fst": {$: "../../../src/ecs/system.RegistrationRejected", "registry": _registry_0, "world": _world_0, "args": _args_0}, "snd": _trace_0};
  } else {
    return $$$$047$$$047$$$047src$047ecs$047system$058observed_outcome_with$1260$(_registry_0, ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_runner_observed$1260$(_trace_0, _world_0, _args_0)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047world$058registration_matches$1260$(_world_0, _id_0, _name_0, _access_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "Tuple", "fst": {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": ($$$$047$$$047$$$047src$047ecs$047world$058registration_list_matches$(_registrations_0, _id_0, _name_0, _access_0))};
}

function $$$$047$$$047$$$047src$047ecs$047world$058enqueue_command$1260$(_world_0, _command_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, _published_0) {
  const _namespace_0 = _world_0["namespace"];
  const _allocator_0 = _world_0["allocator"];
  const _store_0 = _world_0["store"];
  const _resource_0 = _world_0["resource"];
  const _events_0 = _world_0["events"];
  const _pending_0 = _world_0["pending"];
  const _registrations_0 = _world_0["registrations"];
  const _nextSystemId_0 = _world_0["nextSystemId"];
  const _clock_0 = _world_0["clock"];
  return {$: "../../../src/ecs/world.World", "namespace": _namespace_0, "allocator": _allocator_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047src$047ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058write_field$1260$(_cap_0) {
  const _set_0 = _cap_0["set"];
  return _set_0;
}

function $$$$047$$$047$$$047src$047ecs$047system$058observed_outcome_with$1260$(_registry_0, _result_0) {
  const _outcome_0 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047system$058tracked_outcome$1260$(_registry_0, _outcome_0)), "snd": _trace_0};
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_runner_observed$1260$(_trace_0, _world_0, _args_0) {
  const _args_1 = _args_0["fst"];
  const _cursor_0 = _args_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058completed_observed$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058each_since_observed$1260$(_trace_0, _args_1, _world_0, _cursor_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058event_append$1260$(_left_0, _right_0) {
  return $$$$047$$$047$$$047src$047ecs$047world$058event_append_loop$1260$(($List$reverse$(_left_0)), _right_0);
}

function $$$$047$$$047$$$047src$047ecs$047system$058tracked_outcome$1260$(_registry_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    return $$$$047$$$047$$$047src$047ecs$047system$058tracked_clock$1260$(_registry_0, _output_0, ($$$$047$$$047$$$047src$047ecs$047world$058clock$1260$(_world_1)));
  }
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058completed_observed$1260$(_result_0) {
  const _executed_0 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058completed$1260$(_executed_0)), "snd": _trace_0};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058each_since_observed$1260$(_trace_0, _args_0, _world_0, _cursor_0) {
  return $$$$047$$$047$$$047src$047ecs$047compose$058reserved_observed$1260$(_trace_0, _args_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047world$058handles$1260$(_world_0)));
}

function $$$$047$$$047$$$047src$047ecs$047world$058event_append_loop$1260$($0, $1) {
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

function $$$$047$$$047$$$047src$047ecs$047system$058tracked_clock$1260$(_registry_0, _output_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _clock_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047system$058cursor_outcome$1260$({$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _output_0}, _registry_0, _clock_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058completed$1260$(_result_0) {
  const _world_0 = _result_0["world"];
  const _t_0 = _result_0["outcome"];
  if (_t_0.$ === "../../../src/ecs/transaction.Success") {
    const _values_0 = _result_0["values"];
    return {$: "../../../src/ecs/system.Succeeded", "world": _world_0, "output": _values_0};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": _error_0};
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058reserved_observed$1260$(_trace_0, _args_0, _cursor_0, _observed_0) {
  const _world_0 = _observed_0["fst"];
  const _handles_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058finished_observed$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058run_handles$1260$(_handles_0, _args_0, _cursor_0, ($$$$047$$$047$$$047src$047ecs$047transaction$058begin_with_trace$1260$(_world_0, _trace_0)))));
}

function $$$$047$$$047$$$047src$047ecs$047system$058cursor_outcome$1260$(_outcome_0, _registry_0, _nextCursor_0) {
  if (_outcome_0.$ === "../../../src/ecs/system.Failed") {
    const _world_0 = _outcome_0["world"];
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/system.Completed", "registry": _registry_0, "outcome": {$: "../../../src/ecs/system.Failed", "world": _world_0, "error": _error_0}};
  } else {
    const _world_1 = _outcome_0["world"];
    const _output_0 = _outcome_0["output"];
    const _namespace_0 = _registry_0["namespace"];
    const _id_0 = _registry_0["id"];
    const _name_0 = _registry_0["name"];
    const _access_0 = _registry_0["access"];
    return {$: "../../../src/ecs/system.Completed", "registry": {$: "../../../src/ecs/system.Registry", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "access": _access_0, "cursor": _nextCursor_0}, "outcome": {$: "../../../src/ecs/system.Succeeded", "world": _world_1, "output": _output_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058finished_observed$1260$(_observed_0) {
  const _tx_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _result_0 = _t_0["fst"];
  const _values_0 = _t_0["snd"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058finish_returned_observed$1260$(_values_0, ($$$$047$$$047$$$047src$047ecs$047transaction$058finish_observed$1260$(_tx_0, _result_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058run_handles$1260$(_handles_0, _args_0, _cursor_0, _tx_0) {
  return $$$$047$$$047$$$047src$047ecs$047compose$058run_handles_acc$1260$(_handles_0, _args_0, _cursor_0, {$: "Nil"}, {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": {$: "Nil"}}});
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058begin_with_trace$1260$(_world_0, _trace_0) {
  return {$: "../../../src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}, "trace": _trace_0};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058finish_returned_observed$1260$(_values_0, _result_0) {
  const _returned_0 = _result_0["fst"];
  const _trace_0 = _result_0["snd"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047compose$058finish_returned$1260$(_values_0, _returned_0)), "snd": _trace_0};
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058finish_observed$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  const _trace_0 = _tx_0["trace"];
  return {$: "Tuple", "fst": ($$$$047$$$047$$$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0)), "snd": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle$(_trace_0, ($$$$047$$$047$$$047src$047ecs$047transaction$058committed$1260$(_outcome_0))))};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058run_handles_acc$1260$($0, $1, $2, $3, $4) {
  for (;;) {
    {
      const _handles_0 = $0;
      const _args_0 = $1;
      const _cursor_0 = $2;
      const _values_0 = $3;
      const _observed_0 = $4;
      if (_handles_0.$ === "Nil") {
        const _tx_0 = _observed_0["fst"];
        const _t_0 = _observed_0["snd"];
        const _t_1 = _t_0["fst"];
        if (_t_1.$ === "../../../src/ecs/transaction.Failure") {
          const _error_0 = _t_1["error"];
          return {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}, "snd": ($List$reverse$(_values_0))}};
        } else {
          const __1 = _t_0["snd"];
          return {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": ($List$reverse$(($List$reverse$go$(__1, _values_0))))}};
        }
      } else {
        const _handle_0 = _handles_0["head"];
        const _rest_0 = _handles_0["tail"];
        const _tx_1 = _observed_0["fst"];
        const _t_2 = _observed_0["snd"];
        const _t_3 = _t_2["fst"];
        if (_t_3.$ === "../../../src/ecs/transaction.Failure") {
          const _error_1 = _t_3["error"];
          return {$: "Tuple", "fst": _tx_1, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": _error_1}, "snd": ($List$reverse$(_values_0))}};
        } else {
          const __3 = _t_2["snd"];
          $0 = _rest_0;
          $1 = _args_0;
          $2 = _cursor_0;
          $3 = ($List$reverse$go$(__3, _values_0));
          $4 = ($$$$047$$$047$$$047src$047ecs$047compose$058selected_row$1260$(_args_0, ($$$$047$$$047$$$047src$047ecs$047compose$058plan_select$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_plan$1260$())))({$: "../../../src/ecs/compose.Frame", "tx": _tx_1, "handle": _handle_0, "error": {$: "None"}, "cursor": _cursor_0})));
          continue;
        }
      }
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058finish_returned$1260$(_values_0, _returned_0) {
  const _world_0 = _returned_0["world"];
  const _t_0 = _returned_0["outcome"];
  if (_t_0.$ === "../../../src/ecs/transaction.Success") {
    return {$: "../../../src/ecs/compose.Executed", "world": _world_0, "outcome": {$: "../../../src/ecs/transaction.Success"}, "values": _values_0};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../src/ecs/compose.Executed", "world": _world_0, "outcome": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}, "values": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047src$047ecs$047commands$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047src$047ecs$047commands$058publish$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047src$047ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle$(_state_0, _committed_0) {
  if (_state_0.$ === "../../../src/ecs/trace-facts.Off") {
    return {$: "../../../src/ecs/trace-facts.Off"};
  } else {
    const _facts_0 = _state_0["reverseFacts"];
    return {$: "../../../src/ecs/trace-facts.On", "reverseFacts": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_facts_0, _committed_0))};
  }
}

function $$$$047$$$047$$$047src$047ecs$047transaction$058committed$1260$(_outcome_0) {
  if (_outcome_0.$ === "../../../src/ecs/transaction.Success") {
    return true;
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058selected_row$1260$(_args_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const __0 = _t_0["handle"];
  const __1 = _t_0["error"];
  const __2 = _t_0["cursor"];
  const _t_1 = _observed_0["snd"];
  if (!_t_1) {
    return $$$$047$$$047$$$047src$047ecs$047compose$058row_end$1260$(_tx_0);
  } else {
    return $$$$047$$$047$$$047src$047ecs$047compose$058body_returned$1260$(run_clo((_x_0) => {
  return $$$$047$$$047$$$047src$047ecs$047compose$058row_end$1260$(_x_0);
}), ($$$$047$$$047$$$047src$047ecs$047capabilities$058invoke$1260$(_args_0, {$: "../../../src/ecs/compose.Frame", "tx": _tx_0, "handle": __0, "error": __1, "cursor": __2})));
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058plan_select$1260$(_plan_0) {
  const _select_0 = _plan_0["select"];
  return _select_0;
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_plan$1260$() {
  return $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058plan_parts$1260$(run_loop($$$$047$$$047$$$047src$047ecs$047ordinary$045query$045observable$058operational$1260$(($water_query$()))));
}

function $$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_facts_0, _committed_0) {
  if (_facts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _facts_0["head"];
    if (_t_0.$ === "../../../src/ecs/trace-facts.ReaderFact") {
      const _namespace_0 = _t_0["namespace"];
      const _id_0 = _t_0["id"];
      const _name_0 = _t_0["name"];
      const _readerId_0 = _t_0["readerId"];
      const _domain_0 = _t_0["domain"];
      const _lagged_0 = _t_0["lagged"];
      const _rest_0 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.ReaderFact", "namespace": _namespace_0, "id": _id_0, "name": _name_0, "readerId": _readerId_0, "domain": _domain_0, "lagged": _lagged_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_0, _committed_0))};
    } else if (_t_0.$ === "../../../src/ecs/trace-facts.BoundaryFact") {
      const _boundary_0 = _t_0["boundary"];
      const _rest_1 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.BoundaryFact", "boundary": _boundary_0}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_1, _committed_0))};
    } else if (_t_0.$ === "../../../src/ecs/trace-facts.Fact") {
      const _category_0 = _t_0["category"];
      const _key_0 = _t_0["key"];
      const _operation_0 = _t_0["operation"];
      const _subject_0 = _t_0["subject"];
      const _before_0 = _t_0["before"];
      const _after_0 = _t_0["after"];
      const _result_0 = _t_0["result"];
      const _rest_2 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.Fact", "category": _category_0, "key": _key_0, "operation": _operation_0, "subject": _subject_0, "before": _before_0, "after": _after_0, "result": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settled_result$(_result_0, _committed_0))}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_2, _committed_0))};
    } else if (_t_0.$ === "../../../src/ecs/trace-facts.RelationFact") {
      const _identity_0 = _t_0["identity"];
      const _operation_1 = _t_0["operation"];
      const _source_0 = _t_0["source"];
      const _action_0 = _t_0["action"];
      const _result_1 = _t_0["result"];
      const _rest_3 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.RelationFact", "identity": _identity_0, "operation": _operation_1, "source": _source_0, "action": _action_0, "result": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settled_result$(_result_1, _committed_0))}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_3, _committed_0))};
    } else if (_t_0.$ === "../../../src/ecs/trace-facts.HandlerFact") {
      const _namespace_1 = _t_0["namespace"];
      const _id_1 = _t_0["id"];
      const _name_1 = _t_0["name"];
      const _ordinal_0 = _t_0["ordinal"];
      const _phase_0 = _t_0["phase"];
      const _from_0 = _t_0["from"];
      const _to_0 = _t_0["to"];
      const _result_2 = _t_0["result"];
      const _rest_4 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.HandlerFact", "namespace": _namespace_1, "id": _id_1, "name": _name_1, "ordinal": _ordinal_0, "phase": _phase_0, "from": _from_0, "to": _to_0, "result": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settled_result$(_result_2, _committed_0))}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_4, _committed_0))};
    } else {
      const _key_1 = _t_0["key"];
      const _from_1 = _t_0["from"];
      const _to_1 = _t_0["to"];
      const _result_3 = _t_0["result"];
      const _rest_5 = _facts_0["tail"];
      return {$: "Con", "head": {$: "../../../src/ecs/trace-facts.TransitionFact", "key": _key_1, "from": _from_1, "to": _to_1, "result": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settled_result$(_result_3, _committed_0))}, "tail": ($$$$047$$$047$$$047src$047ecs$047trace$045facts$058settle_facts$(_rest_5, _committed_0))};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058row_end$1260$(_tx_0) {
  return {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": {$: "Nil"}}};
}

function $$$$047$$$047$$$047src$047ecs$047compose$058body_returned$1260$(_next_0, _observed_0) {
  const _t_0 = _observed_0["fst"];
  const _tx_0 = _t_0["tx"];
  const _internal_0 = _t_0["error"];
  const _t_1 = _observed_0["snd"];
  const _user_0 = _t_1["fst"];
  const _value_0 = _t_1["snd"];
  return $$$$047$$$047$$$047src$047ecs$047compose$058completed$1260$(_next_0, _tx_0, _value_0, ($$$$047$$$047$$$047src$047ecs$047compose$058outcome$1260$(_internal_0, _user_0)));
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058invoke$1260$(_args_0, _ctx_0) {
  return $water$1260$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047src$047ecs$047ordinary$045system$058plan_parts$1260$(_declaration_0) {
  const _grant_0 = _declaration_0["grant"];
  const _select_0 = _declaration_0["select"];
  return {$: "../../../src/ecs/compose.Plan", "caps": _grant_0, "select": _select_0};
}

function $$$$047$$$047$$$047src$047ecs$047trace$045facts$058settled_result$(_result_0, _committed_0) {
  if (_result_0.$ === "../../../src/ecs/trace-facts.Attempted") {
    if (_committed_0) {
      return {$: "../../../src/ecs/trace-facts.Applied"};
    } else {
      return {$: "../../../src/ecs/trace-facts.RolledBack"};
    }
  } else {
    return _result_0;
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058completed$1260$(_next_0, _tx_0, _value_0, _result_0) {
  if (_result_0.$ === "../../../src/ecs/transaction.Success") {
    return $$$$047$$$047$$$047src$047ecs$047compose$058prepend$1260$(_value_0, _next_0(_tx_0));
  } else {
    const _error_0 = _result_0["error"];
    return {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": _error_0}, "snd": {$: "Nil"}}};
  }
}

function $$$$047$$$047$$$047src$047ecs$047compose$058outcome$1260$(_internal_0, _user_0) {
  if (_internal_0.$ === "Some") {
    const _error_0 = _internal_0["value"];
    return {$: "../../../src/ecs/transaction.Failure", "error": {$: "../../../src/ecs/compose.AccessError", "error": _error_0}};
  } else {
    if (_user_0.$ === "../../../src/ecs/transaction.Failure") {
      const _error_1 = _user_0["error"];
      return {$: "../../../src/ecs/transaction.Failure", "error": {$: "../../../src/ecs/compose.UserError", "error": _error_1}};
    } else {
      return {$: "../../../src/ecs/transaction.Success"};
    }
  }
}

function $water$1260$(_enabled_0, _owner_0) {
  return $watered$1260$(_enabled_0, run_loop($$$$047$$$047$$$047src$047ecs$047capabilities$058get$1260$(_owner_0)));
}

function $$$$047$$$047$$$047src$047ecs$047compose$058prepend$1260$(_value_0, _observed_0) {
  const _tx_0 = _observed_0["fst"];
  const _t_0 = _observed_0["snd"];
  const _outcome_0 = _t_0["fst"];
  const _values_0 = _t_0["snd"];
  return {$: "Tuple", "fst": _tx_0, "snd": {$: "Tuple", "fst": _outcome_0, "snd": {$: "Con", "head": _value_0, "tail": _values_0}}};
}

function $watered$1260$(_enabled_0, _result_0) {
  if (_enabled_0) {
    const _owner_0 = _result_0["fst"];
    const _t_0 = _result_0["snd"];
    if (_t_0.$ === "../../../src/ecs/component.Found") {
      const _height_0 = _t_0["value"];
      return {$: "Tuple", "fst": run_loop($$$$047$$$047$$$047src$047ecs$047capabilities$058set$1260$(_owner_0, {$: "Plant", "height": ((_height_0 + 1) >>> 0)})), "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": ((_height_0 + 1) >>> 0)}};
    } else {
      return {$: "Tuple", "fst": _owner_0, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": {$: "Unit"}}, "snd": 999}};
    }
  } else {
    const _owner_1 = _result_0["fst"];
    const _t_1 = _result_0["snd"];
    if (_t_1.$ === "../../../src/ecs/component.Found") {
      const _height_1 = _t_1["value"];
      return {$: "Tuple", "fst": _owner_1, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Success"}, "snd": _height_1}};
    } else {
      return {$: "Tuple", "fst": _owner_1, "snd": {$: "Tuple", "fst": {$: "../../../src/ecs/transaction.Failure", "error": {$: "Unit"}}, "snd": 999}};
    }
  }
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058get$1260$(_ctx_0) {
  return run_tail(($$$$047$$$047$$$047src$047ecs$047capabilities$058write_read_field$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_plan$1260$()))))), _ctx_0);
}

function $$$$047$$$047$$$047src$047ecs$047capabilities$058set$1260$(_ctx_0, _value_0) {
  return run_tail(($$$$047$$$047$$$047src$047ecs$047capabilities$058write_field$1260$(($$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1260$(($$$$047$$$047$$$047src$047ecs$047ordinary$045system$058observable_plan$1260$())))))(_ctx_0), _value_0);
}

function $$$$047$$$047$$$047src$047ecs$047compose$058plan_caps$1260$(_plan_0) {
  const _caps_0 = _plan_0["caps"];
  return _caps_0;
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