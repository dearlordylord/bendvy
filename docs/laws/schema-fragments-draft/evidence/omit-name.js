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
  const _x_0 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_1 = (_x_0 + "]");
  const _x_2 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_3 = ("," + _x_1);
  const _x_4 = (_x_2 + _x_3);
  const _x_5 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_6 = (_x_5 + "]");
  const _x_7 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_8 = ("," + _x_6);
  const _x_9 = (_x_7 + _x_8);
  const _x_10 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_11 = (_x_10 + "]");
  const _x_12 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_13 = ("," + _x_11);
  const _x_14 = (_x_12 + _x_13);
  const _x_15 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_16 = (_x_15 + "]");
  const _x_17 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_18 = ("," + _x_16);
  const _x_19 = (_x_17 + _x_18);
  const _x_20 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_21 = (_x_20 + "]");
  const _x_22 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_23 = ("," + _x_21);
  const _x_24 = (_x_22 + _x_23);
  const _x_25 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_26 = (_x_25 + "]");
  const _x_27 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_28 = ("," + _x_26);
  const _x_29 = (_x_27 + _x_28);
  const _x_30 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_31 = (_x_30 + "]");
  const _x_32 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_33 = ("," + _x_31);
  const _x_34 = (_x_32 + _x_33);
  const _x_35 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_36 = (_x_35 + "]");
  const _x_37 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_38 = ("," + _x_36);
  const _x_39 = (_x_37 + _x_38);
  const _x_40 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_41 = (_x_40 + "]");
  const _x_42 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_43 = ("," + _x_41);
  const _x_44 = (_x_42 + _x_43);
  const _x_45 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_46 = (_x_45 + "]");
  const _x_47 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_48 = ("," + _x_46);
  const _x_49 = (_x_47 + _x_48);
  const _x_50 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_51 = (_x_50 + "]");
  const _x_52 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_53 = ("," + _x_51);
  const _x_54 = (_x_52 + _x_53);
  const _x_55 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_56 = (_x_55 + "]");
  const _x_57 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_58 = ("," + _x_56);
  const _x_59 = (_x_57 + _x_58);
  const _x_60 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_61 = (_x_60 + "]");
  const _x_62 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_63 = ("," + _x_61);
  const _x_64 = (_x_62 + _x_63);
  const _x_65 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_66 = (_x_65 + "]");
  const _x_67 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_68 = ("," + _x_66);
  const _x_69 = (_x_67 + _x_68);
  const _x_70 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_71 = (_x_70 + "]");
  const _x_72 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_73 = ("," + _x_71);
  const _x_74 = (_x_72 + _x_73);
  const _x_75 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_76 = (_x_75 + "]");
  const _x_77 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_78 = ("," + _x_76);
  const _x_79 = (_x_77 + _x_78);
  const _x_80 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_81 = (_x_80 + "]");
  const _x_82 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_83 = ("," + _x_81);
  const _x_84 = (_x_82 + _x_83);
  const _x_85 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_86 = (_x_85 + "]");
  const _x_87 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_88 = ("," + _x_86);
  const _x_89 = (_x_87 + _x_88);
  const _x_90 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_91 = (_x_90 + "]");
  const _x_92 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_93 = ("," + _x_91);
  const _x_94 = (_x_92 + _x_93);
  const _x_95 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_96 = (_x_95 + "]");
  const _x_97 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_98 = ("," + _x_96);
  const _x_99 = (_x_97 + _x_98);
  const _x_100 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_101 = (_x_100 + "]");
  const _x_102 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_103 = ("," + _x_101);
  const _x_104 = (_x_102 + _x_103);
  const _x_105 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_106 = (_x_105 + "]");
  const _x_107 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_108 = ("," + _x_106);
  const _x_109 = (_x_107 + _x_108);
  const _x_110 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_111 = (_x_110 + "]");
  const _x_112 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_113 = ("," + _x_111);
  const _x_114 = (_x_112 + _x_113);
  const _x_115 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_116 = (_x_115 + "]");
  const _x_117 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_118 = ("," + _x_116);
  const _x_119 = (_x_117 + _x_118);
  const _x_120 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_121 = (_x_120 + "]");
  const _x_122 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_123 = ("," + _x_121);
  const _x_124 = (_x_122 + _x_123);
  const _x_125 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_126 = (_x_125 + "]");
  const _x_127 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_128 = ("," + _x_126);
  const _x_129 = (_x_127 + _x_128);
  const _x_130 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_131 = (_x_130 + "]");
  const _x_132 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_133 = ("," + _x_131);
  const _x_134 = (_x_132 + _x_133);
  const _x_135 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_136 = (_x_135 + "]");
  const _x_137 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_138 = ("," + _x_136);
  const _x_139 = (_x_137 + _x_138);
  const _x_140 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_141 = (_x_140 + "]");
  const _x_142 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_143 = ("," + _x_141);
  const _x_144 = (_x_142 + _x_143);
  const _x_145 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_146 = (_x_145 + "]");
  const _x_147 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_148 = ("," + _x_146);
  const _x_149 = (_x_147 + _x_148);
  const _x_150 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_151 = (_x_150 + "]");
  const _x_152 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_153 = ("," + _x_151);
  const _x_154 = (_x_152 + _x_153);
  const _x_155 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_156 = (_x_155 + "]");
  const _x_157 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_158 = ("," + _x_156);
  const _x_159 = (_x_157 + _x_158);
  const _x_160 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_161 = (_x_160 + "]");
  const _x_162 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_163 = ("," + _x_161);
  const _x_164 = (_x_162 + _x_163);
  const _x_165 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_166 = (_x_165 + "]");
  const _x_167 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_168 = ("," + _x_166);
  const _x_169 = (_x_167 + _x_168);
  const _x_170 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_171 = (_x_170 + "]");
  const _x_172 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_173 = ("," + _x_171);
  const _x_174 = (_x_172 + _x_173);
  const _x_175 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_176 = (_x_175 + "]");
  const _x_177 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_178 = ("," + _x_176);
  const _x_179 = (_x_177 + _x_178);
  const _x_180 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_181 = (_x_180 + "]");
  const _x_182 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_183 = ("," + _x_181);
  const _x_184 = (_x_182 + _x_183);
  const _x_185 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_186 = (_x_185 + "]");
  const _x_187 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_188 = ("," + _x_186);
  const _x_189 = (_x_187 + _x_188);
  const _x_190 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_191 = (_x_190 + "]");
  const _x_192 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_193 = ("," + _x_191);
  const _x_194 = (_x_192 + _x_193);
  const _x_195 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_196 = (_x_195 + "]");
  const _x_197 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_198 = ("," + _x_196);
  const _x_199 = (_x_197 + _x_198);
  const _x_200 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_201 = (_x_200 + "]");
  const _x_202 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_203 = ("," + _x_201);
  const _x_204 = (_x_202 + _x_203);
  const _x_205 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_206 = (_x_205 + "]");
  const _x_207 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_208 = ("," + _x_206);
  const _x_209 = (_x_207 + _x_208);
  const _x_210 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_211 = (_x_210 + "]");
  const _x_212 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_213 = ("," + _x_211);
  const _x_214 = (_x_212 + _x_213);
  const _x_215 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_216 = (_x_215 + "]");
  const _x_217 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_218 = ("," + _x_216);
  const _x_219 = (_x_217 + _x_218);
  const _x_220 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_221 = (_x_220 + "]");
  const _x_222 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_223 = ("," + _x_221);
  const _x_224 = (_x_222 + _x_223);
  const _x_225 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_226 = (_x_225 + "]");
  const _x_227 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_228 = ("," + _x_226);
  const _x_229 = (_x_227 + _x_228);
  const _x_230 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_231 = (_x_230 + "]");
  const _x_232 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_233 = ("," + _x_231);
  const _x_234 = (_x_232 + _x_233);
  const _x_235 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_236 = (_x_235 + "]");
  const _x_237 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_238 = ("," + _x_236);
  const _x_239 = (_x_237 + _x_238);
  const _x_240 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_241 = (_x_240 + "]");
  const _x_242 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_243 = ("," + _x_241);
  const _x_244 = (_x_242 + _x_243);
  const _x_245 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_246 = (_x_245 + "]");
  const _x_247 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_248 = ("," + _x_246);
  const _x_249 = (_x_247 + _x_248);
  const _x_250 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_251 = (_x_250 + "]");
  const _x_252 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_253 = ("," + _x_251);
  const _x_254 = (_x_252 + _x_253);
  const _x_255 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_256 = (_x_255 + "]");
  const _x_257 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_258 = ("," + _x_256);
  const _x_259 = (_x_257 + _x_258);
  const _x_260 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_261 = (_x_260 + "]");
  const _x_262 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_263 = ("," + _x_261);
  const _x_264 = (_x_262 + _x_263);
  const _x_265 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_266 = (_x_265 + "]");
  const _x_267 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_268 = ("," + _x_266);
  const _x_269 = (_x_267 + _x_268);
  const _x_270 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_271 = (_x_270 + "]");
  const _x_272 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_273 = ("," + _x_271);
  const _x_274 = (_x_272 + _x_273);
  const _x_275 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_276 = (_x_275 + "]");
  const _x_277 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_278 = ("," + _x_276);
  const _x_279 = (_x_277 + _x_278);
  const _x_280 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_281 = (_x_280 + "]");
  const _x_282 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_283 = ("," + _x_281);
  const _x_284 = (_x_282 + _x_283);
  const _x_285 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_286 = (_x_285 + "]");
  const _x_287 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_288 = ("," + _x_286);
  const _x_289 = (_x_287 + _x_288);
  const _x_290 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_291 = (_x_290 + "]");
  const _x_292 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_293 = ("," + _x_291);
  const _x_294 = (_x_292 + _x_293);
  const _x_295 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_296 = (_x_295 + "]");
  const _x_297 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_298 = ("," + _x_296);
  const _x_299 = (_x_297 + _x_298);
  const _x_300 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_301 = (_x_300 + "]");
  const _x_302 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_303 = ("," + _x_301);
  const _x_304 = (_x_302 + _x_303);
  const _x_305 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_306 = (_x_305 + "]");
  const _x_307 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_308 = ("," + _x_306);
  const _x_309 = (_x_307 + _x_308);
  const _x_310 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_311 = (_x_310 + "]");
  const _x_312 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_313 = ("," + _x_311);
  const _x_314 = (_x_312 + _x_313);
  const _x_315 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_316 = (_x_315 + "]");
  const _x_317 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_318 = ("," + _x_316);
  const _x_319 = (_x_317 + _x_318);
  const _x_320 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_321 = (_x_320 + "]");
  const _x_322 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_323 = ("," + _x_321);
  const _x_324 = (_x_322 + _x_323);
  const _x_325 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_326 = (_x_325 + "]");
  const _x_327 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_328 = ("," + _x_326);
  const _x_329 = (_x_327 + _x_328);
  const _x_330 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_331 = (_x_330 + "]");
  const _x_332 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_333 = ("," + _x_331);
  const _x_334 = (_x_332 + _x_333);
  const _x_335 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_336 = (_x_335 + "]");
  const _x_337 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_338 = ("," + _x_336);
  const _x_339 = (_x_337 + _x_338);
  const _x_340 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_341 = (_x_340 + "]");
  const _x_342 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_343 = ("," + _x_341);
  const _x_344 = (_x_342 + _x_343);
  const _x_345 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_346 = (_x_345 + "]");
  const _x_347 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_348 = ("," + _x_346);
  const _x_349 = (_x_347 + _x_348);
  const _x_350 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_351 = (_x_350 + "]");
  const _x_352 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_353 = ("," + _x_351);
  const _x_354 = (_x_352 + _x_353);
  const _x_355 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_356 = (_x_355 + "]");
  const _x_357 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_358 = ("," + _x_356);
  const _x_359 = (_x_357 + _x_358);
  const _x_360 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_361 = (_x_360 + "]");
  const _x_362 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_363 = ("," + _x_361);
  const _x_364 = (_x_362 + _x_363);
  const _x_365 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_366 = (_x_365 + "]");
  const _x_367 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_368 = ("," + _x_366);
  const _x_369 = (_x_367 + _x_368);
  const _x_370 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_371 = (_x_370 + "]");
  const _x_372 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_373 = ("," + _x_371);
  const _x_374 = (_x_372 + _x_373);
  const _x_375 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_376 = (_x_375 + "]");
  const _x_377 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_378 = ("," + _x_376);
  const _x_379 = (_x_377 + _x_378);
  const _x_380 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_381 = (_x_380 + "]");
  const _x_382 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_383 = ("," + _x_381);
  const _x_384 = (_x_382 + _x_383);
  const _x_385 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_386 = (_x_385 + "]");
  const _x_387 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_388 = ("," + _x_386);
  const _x_389 = (_x_387 + _x_388);
  const _x_390 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_391 = (_x_390 + "]");
  const _x_392 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_393 = ("," + _x_391);
  const _x_394 = (_x_392 + _x_393);
  const _x_395 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_396 = (_x_395 + "]");
  const _x_397 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_398 = ("," + _x_396);
  const _x_399 = (_x_397 + _x_398);
  const _x_400 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_401 = (_x_400 + "]");
  const _x_402 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_403 = ("," + _x_401);
  const _x_404 = (_x_402 + _x_403);
  const _x_405 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_406 = (_x_405 + "]");
  const _x_407 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "B"}))));
  const _x_408 = ("," + _x_406);
  const _x_409 = (_x_407 + _x_408);
  const _x_410 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_411 = (_x_410 + "]");
  const _x_412 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "A"}))));
  const _x_413 = ("," + _x_411);
  const _x_414 = (_x_412 + _x_413);
  const _x_415 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_416 = (_x_415 + "]");
  const _x_417 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "b", "name": "B"}))));
  const _x_418 = ("," + _x_416);
  const _x_419 = (_x_417 + _x_418);
  const _x_420 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_421 = (_x_420 + "]");
  const _x_422 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "A"}))));
  const _x_423 = ("," + _x_421);
  const _x_424 = (_x_422 + _x_423);
  const _x_425 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_426 = (_x_425 + "]");
  const _x_427 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "a", "name": "B"}))));
  const _x_428 = ("," + _x_426);
  const _x_429 = (_x_427 + _x_428);
  const _x_430 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_431 = (_x_430 + "]");
  const _x_432 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "A"}))));
  const _x_433 = ("," + _x_431);
  const _x_434 = (_x_432 + _x_433);
  const _x_435 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_436 = (_x_435 + "]");
  const _x_437 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Resource"}, "key": "b", "name": "B"}))));
  const _x_438 = ("," + _x_436);
  const _x_439 = (_x_437 + _x_438);
  const _x_440 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_441 = (_x_440 + "]");
  const _x_442 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "A"}))));
  const _x_443 = ("," + _x_441);
  const _x_444 = (_x_442 + _x_443);
  const _x_445 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_446 = (_x_445 + "]");
  const _x_447 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "a", "name": "B"}))));
  const _x_448 = ("," + _x_446);
  const _x_449 = (_x_447 + _x_448);
  const _x_450 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_451 = (_x_450 + "]");
  const _x_452 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "A"}))));
  const _x_453 = ("," + _x_451);
  const _x_454 = (_x_452 + _x_453);
  const _x_455 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_456 = (_x_455 + "]");
  const _x_457 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Event"}, "key": "b", "name": "B"}))));
  const _x_458 = ("," + _x_456);
  const _x_459 = (_x_457 + _x_458);
  const _x_460 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_461 = (_x_460 + "]");
  const _x_462 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "A"}))));
  const _x_463 = ("," + _x_461);
  const _x_464 = (_x_462 + _x_463);
  const _x_465 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_466 = (_x_465 + "]");
  const _x_467 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "a", "name": "B"}))));
  const _x_468 = ("," + _x_466);
  const _x_469 = (_x_467 + _x_468);
  const _x_470 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_471 = (_x_470 + "]");
  const _x_472 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "A"}))));
  const _x_473 = ("," + _x_471);
  const _x_474 = (_x_472 + _x_473);
  const _x_475 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_476 = (_x_475 + "]");
  const _x_477 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Relation"}, "key": "b", "name": "B"}))));
  const _x_478 = ("," + _x_476);
  const _x_479 = (_x_477 + _x_478);
  const _x_480 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_481 = (_x_480 + "]");
  const _x_482 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}))));
  const _x_483 = ("," + _x_481);
  const _x_484 = (_x_482 + _x_483);
  const _x_485 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_486 = (_x_485 + "]");
  const _x_487 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "B"}))));
  const _x_488 = ("," + _x_486);
  const _x_489 = (_x_487 + _x_488);
  const _x_490 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_491 = (_x_490 + "]");
  const _x_492 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "A"}))));
  const _x_493 = ("," + _x_491);
  const _x_494 = (_x_492 + _x_493);
  const _x_495 = ($validation_show$(($model$058classify$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_496 = (_x_495 + "]");
  const _x_497 = ($validation_show$(($core$058check_one$1260$({$: "Con", "head": {$: "core.Entry", "kind": {$: "core.Service"}, "key": "a", "name": "A"}, "tail": {$: "Nil"}}, {$: "core.Entry", "kind": {$: "core.Service"}, "key": "b", "name": "B"}))));
  const _x_498 = ("," + _x_496);
  const _x_499 = (_x_497 + _x_498);
  const _x_500 = ($validation_show$(($model$058classify$({$: "Nil"}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_501 = (_x_500 + "]");
  const _x_502 = ($validation_show$(($core$058check_one$1260$({$: "Nil"}, {$: "core.Entry", "kind": {$: "core.Component"}, "key": "a", "name": "A"}))));
  const _x_503 = ("," + _x_501);
  const _x_504 = (_x_502 + _x_503);
  return (_x_505) => $IO$print$(($List$show$1260$({$: "Con", "head": ("[" + _x_4), "tail": {$: "Con", "head": ("[" + _x_9), "tail": {$: "Con", "head": ("[" + _x_14), "tail": {$: "Con", "head": ("[" + _x_19), "tail": {$: "Con", "head": ("[" + _x_24), "tail": {$: "Con", "head": ("[" + _x_29), "tail": {$: "Con", "head": ("[" + _x_34), "tail": {$: "Con", "head": ("[" + _x_39), "tail": {$: "Con", "head": ("[" + _x_44), "tail": {$: "Con", "head": ("[" + _x_49), "tail": {$: "Con", "head": ("[" + _x_54), "tail": {$: "Con", "head": ("[" + _x_59), "tail": {$: "Con", "head": ("[" + _x_64), "tail": {$: "Con", "head": ("[" + _x_69), "tail": {$: "Con", "head": ("[" + _x_74), "tail": {$: "Con", "head": ("[" + _x_79), "tail": {$: "Con", "head": ("[" + _x_84), "tail": {$: "Con", "head": ("[" + _x_89), "tail": {$: "Con", "head": ("[" + _x_94), "tail": {$: "Con", "head": ("[" + _x_99), "tail": {$: "Con", "head": ("[" + _x_104), "tail": {$: "Con", "head": ("[" + _x_109), "tail": {$: "Con", "head": ("[" + _x_114), "tail": {$: "Con", "head": ("[" + _x_119), "tail": {$: "Con", "head": ("[" + _x_124), "tail": {$: "Con", "head": ("[" + _x_129), "tail": {$: "Con", "head": ("[" + _x_134), "tail": {$: "Con", "head": ("[" + _x_139), "tail": {$: "Con", "head": ("[" + _x_144), "tail": {$: "Con", "head": ("[" + _x_149), "tail": {$: "Con", "head": ("[" + _x_154), "tail": {$: "Con", "head": ("[" + _x_159), "tail": {$: "Con", "head": ("[" + _x_164), "tail": {$: "Con", "head": ("[" + _x_169), "tail": {$: "Con", "head": ("[" + _x_174), "tail": {$: "Con", "head": ("[" + _x_179), "tail": {$: "Con", "head": ("[" + _x_184), "tail": {$: "Con", "head": ("[" + _x_189), "tail": {$: "Con", "head": ("[" + _x_194), "tail": {$: "Con", "head": ("[" + _x_199), "tail": {$: "Con", "head": ("[" + _x_204), "tail": {$: "Con", "head": ("[" + _x_209), "tail": {$: "Con", "head": ("[" + _x_214), "tail": {$: "Con", "head": ("[" + _x_219), "tail": {$: "Con", "head": ("[" + _x_224), "tail": {$: "Con", "head": ("[" + _x_229), "tail": {$: "Con", "head": ("[" + _x_234), "tail": {$: "Con", "head": ("[" + _x_239), "tail": {$: "Con", "head": ("[" + _x_244), "tail": {$: "Con", "head": ("[" + _x_249), "tail": {$: "Con", "head": ("[" + _x_254), "tail": {$: "Con", "head": ("[" + _x_259), "tail": {$: "Con", "head": ("[" + _x_264), "tail": {$: "Con", "head": ("[" + _x_269), "tail": {$: "Con", "head": ("[" + _x_274), "tail": {$: "Con", "head": ("[" + _x_279), "tail": {$: "Con", "head": ("[" + _x_284), "tail": {$: "Con", "head": ("[" + _x_289), "tail": {$: "Con", "head": ("[" + _x_294), "tail": {$: "Con", "head": ("[" + _x_299), "tail": {$: "Con", "head": ("[" + _x_304), "tail": {$: "Con", "head": ("[" + _x_309), "tail": {$: "Con", "head": ("[" + _x_314), "tail": {$: "Con", "head": ("[" + _x_319), "tail": {$: "Con", "head": ("[" + _x_324), "tail": {$: "Con", "head": ("[" + _x_329), "tail": {$: "Con", "head": ("[" + _x_334), "tail": {$: "Con", "head": ("[" + _x_339), "tail": {$: "Con", "head": ("[" + _x_344), "tail": {$: "Con", "head": ("[" + _x_349), "tail": {$: "Con", "head": ("[" + _x_354), "tail": {$: "Con", "head": ("[" + _x_359), "tail": {$: "Con", "head": ("[" + _x_364), "tail": {$: "Con", "head": ("[" + _x_369), "tail": {$: "Con", "head": ("[" + _x_374), "tail": {$: "Con", "head": ("[" + _x_379), "tail": {$: "Con", "head": ("[" + _x_384), "tail": {$: "Con", "head": ("[" + _x_389), "tail": {$: "Con", "head": ("[" + _x_394), "tail": {$: "Con", "head": ("[" + _x_399), "tail": {$: "Con", "head": ("[" + _x_404), "tail": {$: "Con", "head": ("[" + _x_409), "tail": {$: "Con", "head": ("[" + _x_414), "tail": {$: "Con", "head": ("[" + _x_419), "tail": {$: "Con", "head": ("[" + _x_424), "tail": {$: "Con", "head": ("[" + _x_429), "tail": {$: "Con", "head": ("[" + _x_434), "tail": {$: "Con", "head": ("[" + _x_439), "tail": {$: "Con", "head": ("[" + _x_444), "tail": {$: "Con", "head": ("[" + _x_449), "tail": {$: "Con", "head": ("[" + _x_454), "tail": {$: "Con", "head": ("[" + _x_459), "tail": {$: "Con", "head": ("[" + _x_464), "tail": {$: "Con", "head": ("[" + _x_469), "tail": {$: "Con", "head": ("[" + _x_474), "tail": {$: "Con", "head": ("[" + _x_479), "tail": {$: "Con", "head": ("[" + _x_484), "tail": {$: "Con", "head": ("[" + _x_489), "tail": {$: "Con", "head": ("[" + _x_494), "tail": {$: "Con", "head": ("[" + _x_499), "tail": {$: "Con", "head": ("[" + _x_504), "tail": {$: "Nil"}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})), _x_505);
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $List$show$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "[]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1260$(_t_0));
    const _x_1 = (_h_0 + _x_0);
    return ("[" + _x_1);
  }
}

function $validation_show$(_value_0) {
  if (_value_0.$ === "core.Valid") {
    return "[0,0,\"\",\"\"]";
  } else {
    const _t_0 = _value_0["error"];
    if (_t_0.$ === "core.DuplicateKey") {
      const _k_0 = _t_0["kind"];
      const _key_0 = _t_0["key"];
      const _x_0 = (_key_0 + "\",\"\"]");
      const _x_1 = ($U32$show$(($model$058kind_code$(_k_0))));
      const _x_2 = (",\"" + _x_0);
      const _x_3 = (_x_1 + _x_2);
      return ("[1," + _x_3);
    } else if (_t_0.$ === "core.DuplicateName") {
      const _k_1 = _t_0["kind"];
      const _name_0 = _t_0["name"];
      const _x_4 = (_name_0 + "\"]");
      const _x_5 = ($U32$show$(($model$058kind_code$(_k_1))));
      const _x_6 = (",\"\",\"" + _x_4);
      const _x_7 = (_x_5 + _x_6);
      return ("[2," + _x_7);
    } else {
      const _k_2 = _t_0["kind"];
      const _key_1 = _t_0["key"];
      const _name_1 = _t_0["name"];
      const _x_8 = (_name_1 + "\"]");
      const _x_9 = ("\",\"" + _x_8);
      const _x_10 = (_key_1 + _x_9);
      const _x_11 = ($U32$show$(($model$058kind_code$(_k_2))));
      const _x_12 = (",\"" + _x_10);
      const _x_13 = (_x_11 + _x_12);
      return ("[3," + _x_13);
    }
  }
}

function $core$058check_one$1260$(_seen_0, _item_0) {
  const _kind_0 = _item_0["kind"];
  const _key_0 = _item_0["key"];
  const _name_0 = _item_0["name"];
  return $core$058check_entry$(($core$058key_exists$1260$(_seen_0, _kind_0, _key_0)), ($core$058name_exists$1260$(_seen_0, _kind_0, _name_0)), _kind_0, _key_0, _name_0);
}

function $model$058classify$(_seen_0, _item_0) {
  const _kind_0 = _item_0["kind"];
  const _key_0 = _item_0["key"];
  const _name_0 = _item_0["name"];
  return $model$058classified$(($model$058key_member$(_seen_0, _kind_0, _key_0)), ($model$058name_member$(_seen_0, _kind_0, _name_0)), _kind_0, _key_0, _name_0);
}

function $List$show$go$1260$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return "]";
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($List$show$go$1260$(_t_0));
    const _x_1 = (_h_0 + _x_0);
    return (", " + _x_1);
  }
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $model$058kind_code$(_kind_0) {
  if (_kind_0.$ === "core.Component") {
    return 0;
  } else if (_kind_0.$ === "core.Resource") {
    return 1;
  } else if (_kind_0.$ === "core.Event") {
    return 2;
  } else if (_kind_0.$ === "core.Relation") {
    return 3;
  } else {
    return 4;
  }
}

function $core$058check_entry$(_keyConflict_0, _nameConflict_0, _kind_0, _key_0, _name_0) {
  if (_keyConflict_0) {
    return {$: "core.Invalid", "error": {$: "core.DuplicateKey", "kind": _kind_0, "key": _key_0}};
  } else {
    if (_nameConflict_0) {
      return {$: "core.Valid"};
    } else {
      return {$: "core.Valid"};
    }
  }
}

function $core$058key_exists$1260$(_xs_0, _kind_0, _key_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    const _other_0 = _t_0["kind"];
    const _otherKey_0 = _t_0["key"];
    const _rest_0 = _xs_0["tail"];
    const _x_0 = ($Bool$and$(($core$058same_kind$(_kind_0, _other_0)), ($String$eq$(_key_0, _otherKey_0))));
    const _x_1 = ($core$058key_exists$1260$(_rest_0, _kind_0, _key_0));
    return (_x_0 || _x_1);
  }
}

function $core$058name_exists$1260$(_xs_0, _kind_0, _name_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    const _other_0 = _t_0["kind"];
    const _otherName_0 = _t_0["name"];
    const _rest_0 = _xs_0["tail"];
    const _x_0 = ($Bool$and$(($core$058same_kind$(_kind_0, _other_0)), ($String$eq$(_name_0, _otherName_0))));
    const _x_1 = ($core$058name_exists$1260$(_rest_0, _kind_0, _name_0));
    return (_x_0 || _x_1);
  }
}

function $model$058classified$(_key_0, _name_0, _kind_0, _k_0, _n_0) {
  if (_key_0) {
    return {$: "core.Invalid", "error": {$: "core.DuplicateKey", "kind": _kind_0, "key": _k_0}};
  } else {
    if (_name_0) {
      return {$: "core.Invalid", "error": {$: "core.DuplicateName", "kind": _kind_0, "name": _n_0}};
    } else {
      return {$: "core.Valid"};
    }
  }
}

function $model$058key_member$(_xs_0, _kind_0, _key_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    const _k_0 = _t_0["kind"];
    const _x_0 = _t_0["key"];
    const _rest_0 = _xs_0["tail"];
    const _x_1 = ($Bool$and$(($model$058same_kind$(_kind_0, _k_0)), ($String$eq$(_key_0, _x_0))));
    const _x_2 = ($model$058key_member$(_rest_0, _kind_0, _key_0));
    return (_x_1 || _x_2);
  }
}

function $model$058name_member$(_xs_0, _kind_0, _name_0) {
  if (_xs_0.$ === "Nil") {
    return false;
  } else {
    const _t_0 = _xs_0["head"];
    const _k_0 = _t_0["kind"];
    const _n_0 = _t_0["name"];
    const _rest_0 = _xs_0["tail"];
    const _x_0 = ($Bool$and$(($model$058same_kind$(_kind_0, _k_0)), ($String$eq$(_name_0, _n_0))));
    const _x_1 = ($model$058name_member$(_rest_0, _kind_0, _name_0));
    return (_x_0 || _x_1);
  }
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $core$058same_kind$(_a_0, _b_0) {
  if (_a_0.$ === "core.Component") {
    if (_b_0.$ === "core.Component") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "core.Resource") {
    if (_b_0.$ === "core.Resource") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "core.Event") {
    if (_b_0.$ === "core.Event") {
      return true;
    } else {
      return false;
    }
  } else if (_a_0.$ === "core.Relation") {
    if (_b_0.$ === "core.Relation") {
      return true;
    } else {
      return false;
    }
  } else {
    if (_b_0.$ === "core.Service") {
      return true;
    } else {
      return false;
    }
  }
}

function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}

function $model$058same_kind$(_a_0, _b_0) {
  const _x_0 = ($model$058kind_code$(_a_0));
  const _x_1 = ($model$058kind_code$(_b_0));
  return (_x_0 === _x_1);
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

function $String$cmp$rec$(_h1b_0, _h2b_0, _rr_0) {
  const _t_0 = _rr_0["fst"];
  const _t1b_0 = _t_0["fst"];
  const _t2b_0 = _t_0["snd"];
  const _r_0 = _rr_0["snd"];
  return {$: "Tuple", "fst": {$: "Tuple", "fst": (_h1b_0 + _t1b_0), "snd": (_h2b_0 + _t2b_0)}, "snd": _r_0};
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