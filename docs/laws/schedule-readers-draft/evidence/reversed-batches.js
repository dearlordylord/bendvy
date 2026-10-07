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
  const _x_0 = ($batch_sample$({$: "Nil"}));
  const _x_1 = ($batch_sample$({$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": 9, "values": {$: "Con", "head": {$: "Removal", "id": 3}, "tail": {$: "Con", "head": {$: "Event", "id": 7}, "tail": {$: "Con", "head": {$: "Event", "id": 2}, "tail": {$: "Nil"}}}}}, "tail": {$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": 4, "values": {$: "Con", "head": {$: "Removal", "id": 1}, "tail": {$: "Nil"}}}, "tail": {$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": 9, "values": {$: "Nil"}}, "tail": {$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": 2, "values": {$: "Con", "head": {$: "Event", "id": 7}, "tail": {$: "Con", "head": {$: "Removal", "id": 3}, "tail": {$: "Con", "head": {$: "Event", "id": 7}, "tail": {$: "Nil"}}}}}, "tail": {$: "Nil"}}}}}));
  const _x_2 = ($sample$({$: "Con", "head": {$: "Event", "id": 4294967295}, "tail": {$: "Nil"}}));
  const _x_3 = (_x_0 + _x_1);
  const _x_4 = ($sample$({$: "Con", "head": {$: "Removal", "id": 0}, "tail": {$: "Nil"}}));
  const _x_5 = (_x_2 + _x_3);
  const _x_6 = ($sample$({$: "Con", "head": {$: "Event", "id": 7}, "tail": {$: "Con", "head": {$: "Removal", "id": 9}, "tail": {$: "Con", "head": {$: "Event", "id": 2}, "tail": {$: "Con", "head": {$: "Removal", "id": 9}, "tail": {$: "Con", "head": {$: "Event", "id": 7}, "tail": {$: "Nil"}}}}}}));
  const _x_7 = (_x_4 + _x_5);
  const _x_8 = ($sample$({$: "Nil"}));
  const _x_9 = (_x_6 + _x_7);
  return (_x_10) => $IO$print$((_x_8 + _x_9), _x_10);
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $sample$(_items_0) {
  return $pair$("stable_partition", ($partition$(($$$$047$$$047$$$047src$047ecs$047reader$045domains$058split$1260$(_items_0)))), ($partition$({$: "Tuple", "fst": ($spec$058selected$1260$(_items_0)), "snd": ($spec$058rejected$1260$(_items_0))})));
}

function $batch_sample$(_items_0) {
  const _x_0 = ($pair$("filtered_batch_order", ($batches$(($$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batches$1260$(_items_0)))), ($batches$(($spec$058batches$1260$(_items_0))))));
  const _x_1 = ($pair$("retained_publication_ticks", ($List$show$1262$(($spec$058ticks$1260$(($$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batches$1260$(_items_0)))))), ($List$show$1262$(($spec$058ticks$1260$(($spec$058batches$1260$(_items_0))))))));
  return (_x_0 + _x_1);
}

function $pair$(_name_0, _a_0, _b_0) {
  const _x_0 = (_b_0 + "\n");
  const _x_1 = ("|" + _x_0);
  const _x_2 = (_a_0 + _x_1);
  const _x_3 = ("|" + _x_2);
  return (_name_0 + _x_3);
}

function $partition$(_pair_0) {
  const _a_0 = _pair_0["fst"];
  const _b_0 = _pair_0["snd"];
  const _x_0 = ($values$(_b_0));
  const _x_1 = ($values$(_a_0));
  const _x_2 = ("/" + _x_0);
  return (_x_1 + _x_2);
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058split$1260$(_values_0) {
  return $$$$047$$$047$$$047src$047ecs$047reader$045domains$058split_loop$1260$(_values_0, {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Nil"}});
}

function $spec$058selected$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return $spec$058prepend$1260$(($select$(_head_0)), _head_0, ($spec$058selected$1260$(_rest_0)));
  }
}

function $spec$058rejected$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _head_0 = _items_0["head"];
    const _rest_0 = _items_0["tail"];
    return $spec$058prepend$1260$(($Bool$not$(($select$(_head_0)))), _head_0, ($spec$058rejected$1260$(_rest_0)));
  }
}

function $batches$(_items_0) {
  return $List$show$1261$(_items_0);
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batches$1260$(_batches_0) {
  return $$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batches_loop$1260$(_batches_0, {$: "Nil"});
}

function $spec$058batches$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _tick_0 = _t_0["tick"];
    const _values_0 = _t_0["values"];
    const _rest_0 = _items_0["tail"];
    return $spec$058keep_batch$1260$(_tick_0, ($spec$058selected$1260$(_values_0)), ($spec$058batches$1260$(_rest_0)));
  }
}

function $List$show$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($Nat$show$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $spec$058ticks$1260$(_items_0) {
  if (_items_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _items_0["head"];
    const _tick_0 = _t_0["tick"];
    const _rest_0 = _items_0["tail"];
    return {$: "Con", "head": _tick_0, "tail": ($spec$058ticks$1260$(_rest_0))};
  }
}

function $values$(_items_0) {
  return $List$show$1260$(_items_0);
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058split_loop$1260$($0, $1) {
  for (;;) {
    {
      const _values_0 = $0;
      const _acc_0 = $1;
      if (_values_0.$ === "Nil") {
        return $$$$047$$$047$$$047src$047ecs$047reader$045domains$058split_reverse$1260$(_acc_0);
      } else {
        const _value_0 = _values_0["head"];
        const _rest_0 = _values_0["tail"];
        const _events_0 = _acc_0["fst"];
        const _removals_0 = _acc_0["snd"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047src$047ecs$047reader$045domains$058choose$1260$(($select$(_value_0)), _value_0, _events_0, _removals_0));
        continue;
      }
    }
  }
}

function $spec$058prepend$1260$(_keep_0, _value_0, _rest_0) {
  if (_keep_0) {
    return {$: "Con", "head": _value_0, "tail": _rest_0};
  } else {
    return _rest_0;
  }
}

function $select$(_item_0) {
  if (_item_0.$ === "Event") {
    return true;
  } else {
    return false;
  }
}

function $Bool$not$(_b_0) {
  if (!_b_0) {
    return true;
  } else {
    return false;
  }
}

function $List$show$1261$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($batch$(_h_0));
    const _x_1 = ($List$show$go$1261$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batches_loop$1260$($0, $1) {
  for (;;) {
    {
      const _batches_0 = $0;
      const _acc_0 = $1;
      if (_batches_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _t_0 = _batches_0["head"];
        const _tick_0 = _t_0["tick"];
        const _items_0 = _t_0["values"];
        const _rest_0 = _batches_0["tail"];
        $0 = _rest_0;
        $1 = ($$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batch$1260$(_tick_0, ($$$$047$$$047$$$047src$047ecs$047reader$045domains$058split$1260$(_items_0)), _acc_0));
        continue;
      }
    }
  }
}

function $spec$058keep_batch$1260$(_tick_0, _items_0, _rest_0) {
  if (_items_0.$ === "Nil") {
    return _rest_0;
  } else {
    return {$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _items_0}, "tail": _rest_0};
  }
}

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
}

function $List$show$go$1262$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($Nat$show$(_h_0));
    const _x_1 = ($List$show$go$1262$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $List$show$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($show$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return ("[" + _x_2);
  }
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058split_reverse$1260$(_pair_0) {
  const _events_0 = _pair_0["fst"];
  const _removals_0 = _pair_0["snd"];
  return {$: "Tuple", "fst": ($List$reverse$(_events_0)), "snd": ($List$reverse$(_removals_0))};
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058choose$1260$(_selected_0, _value_0, _events_0, _removals_0) {
  if (_selected_0) {
    return {$: "Tuple", "fst": {$: "Con", "head": _value_0, "tail": _events_0}, "snd": _removals_0};
  } else {
    return {$: "Tuple", "fst": _events_0, "snd": {$: "Con", "head": _value_0, "tail": _removals_0}};
  }
}

function $batch$(_item_0) {
  const _tick_0 = _item_0["tick"];
  const _items_0 = _item_0["values"];
  const _x_0 = ($values$(_items_0));
  const _x_1 = ($Nat$show$(_tick_0));
  const _x_2 = (":" + _x_0);
  return (_x_1 + _x_2);
}

function $List$show$go$1261$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($batch$(_h_0));
    const _x_1 = ($List$show$go$1261$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $$$$047$$$047$$$047src$047ecs$047reader$045domains$058event_batch$1260$(_tick_0, _filtered_0, _rest_0) {
  const _t_0 = _filtered_0["fst"];
  if (_t_0.$ === "Nil") {
    return _rest_0;
  } else {
    return {$: "Con", "head": {$: "../../../src/ecs/event-runtime.Batch", "tick": _tick_0, "values": _t_0}, "tail": _rest_0};
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

function $show$(_item_0) {
  if (_item_0.$ === "Event") {
    const _id_0 = _item_0["id"];
    const _x_0 = ($U32$show$(_id_0));
    return ("E" + _x_0);
  } else {
    const _id_1 = _item_0["id"];
    const _x_1 = ($U32$show$(_id_1));
    return ("R" + _x_1);
  }
}

function $List$show$go$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($show$(_h_0));
    const _x_1 = ($List$show$go$1260$(_t_0));
    const _x_2 = (_x_0 + _x_1);
    return (", " + _x_2);
  }
}

function $List$reverse$(_xs_0) {
  return $List$reverse$go$(_xs_0, {$: "Nil"});
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

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
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

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
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