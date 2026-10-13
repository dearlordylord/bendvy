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
  return (_x_0) => $IO$print$(run_loop($format$058output$(($cases$058entries$()))), _x_0);
}

function $IO$print$(_text_0, _k_0) {
  return { $: "$FFI", run: $0eff["IO.print"].run, need: $0eff["IO.print"].need, args: [(_text_0)], kont: (_k_0) };
}
function $format$058output$(_values_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058encode$({$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058entries$(_values_0))});
}

function $cases$058entries$() {
  return $List$append$(($cases$058schema_rows$1260$("First")), ($cases$058schema_rows$1261$("Second")));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058encode$(_value_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058serialize$(100000, {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Visit", "value": _value_0}, "tail": {$: "Nil"}}, {$: "Nil"});
}

function $format$058entries$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": ($format$058entry$(_value_0)), "tail": ($format$058entries$(_rest_0))};
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

function $cases$058schema_rows$1260$(_schema_0) {
  return $List$append$(($cases$058constructors$1260$(_schema_0)), ($cases$058resources$1260$(_schema_0)));
}

function $cases$058schema_rows$1261$(_schema_0) {
  return $List$append$(($cases$058constructors$1261$(_schema_0)), ($cases$058resources$1261$(_schema_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058serialize$(_fuel_0, _pending_0, _acc_0) {
  if (_fuel_0 === 0) {
    return "SERIALIZATION_INCOMPLETE";
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058serialize_step$(_pending_0, _acc_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058serialize$(_rest_0, _x_0, _x_1);
});
}));
  }
}

function $format$058entry$(_value_0) {
  if (_value_0.$ === "cases.Constructed") {
    const _schema_0 = _value_0["schema"];
    const _label_0 = _value_0["label"];
    const _value_1 = _value_0["value"];
    return $format$058record$("ConstructedCase", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "schema", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _schema_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "label", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _label_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": ($format$058constructed$(_value_1))}, "tail": {$: "Nil"}}}});
  } else {
    const _schema_1 = _value_0["schema"];
    const _label_1 = _value_0["label"];
    const _value_2 = _value_0["value"];
    return $format$058record$("ResourceCase", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "schema", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _schema_1}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "label", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _label_1}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": ($format$058resource_report$(_value_2))}, "tail": {$: "Nil"}}}});
  }
}

function $cases$058constructors$1260$(_schema_0) {
  return {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-number-u32", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 7})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-number-signed", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger", "negative": false, "magnitude": 7})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-f32", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-f32-infinity", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": Math.fround(1 / 0)})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-binary64", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 1072693248, "low": 0})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "finite-binary64-infinity", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 2146435072, "low": 0})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "boolean-true", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": true})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "boolean-wrong-kind", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 1})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "literal-values-number-float", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 1}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alternate"}, "tail": {$: "Nil"}}}}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 1})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "literal-values-mismatch", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 1}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alternate"}, "tail": {$: "Nil"}}}}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 2})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "literal-rendered-text-utf16", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 97, "tail": {$: "Con", "head": 108, "tail": {$: "Con", "head": 112, "tail": {$: "Con", "head": 104, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "literal-rendered-custom-error", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 98, "tail": {$: "Con", "head": 101, "tail": {$: "Con", "head": 116, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "utf16-string-lone-surrogate", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65, "tail": {$: "Con", "head": 55296, "tail": {$: "Nil"}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1260$(_schema_0, "utf16-string-out-of-range", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65536, "tail": {$: "Nil"}}})), "tail": {$: "Nil"}}}}}}}}}}}}}}};
}

function $cases$058resources$1260$(_schema_0) {
  return {$: "Con", "head": ($cases$058resource$1260$(_schema_0, "resource-f32-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5}, false)), "tail": {$: "Con", "head": ($cases$058resource$1260$(_schema_0, "resource-binary64-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 1072693248, "low": 0}, false)), "tail": {$: "Con", "head": ($cases$058resource$1261$(_schema_0, "resource-boolean-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": true}, false)), "tail": {$: "Con", "head": ($cases$058resource$1262$(_schema_0, "resource-literal-rendered-refused", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 98, "tail": {$: "Con", "head": 101, "tail": {$: "Con", "head": 116, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}}, false)), "tail": {$: "Con", "head": ($cases$058resource$1263$(_schema_0, "resource-utf16-refused", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65536, "tail": {$: "Nil"}}}, false)), "tail": {$: "Con", "head": ($cases$058resource$1260$(_schema_0, "resource-f32-aborted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5}, true)), "tail": {$: "Nil"}}}}}}};
}

function $cases$058constructors$1261$(_schema_0) {
  return {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-number-u32", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 7})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-number-signed", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger", "negative": false, "magnitude": 7})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-f32", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-f32-infinity", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": Math.fround(1 / 0)})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-binary64", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 1072693248, "low": 0})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "finite-binary64-infinity", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 2146435072, "low": 0})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "boolean-true", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": true})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "boolean-wrong-kind", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 1})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "literal-values-number-float", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 1}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alternate"}, "tail": {$: "Nil"}}}}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 1})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "literal-values-mismatch", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 1}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alternate"}, "tail": {$: "Nil"}}}}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 2})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "literal-rendered-text-utf16", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 97, "tail": {$: "Con", "head": 108, "tail": {$: "Con", "head": 112, "tail": {$: "Con", "head": 104, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "literal-rendered-custom-error", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 98, "tail": {$: "Con", "head": 101, "tail": {$: "Con", "head": 116, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "utf16-string-lone-surrogate", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65, "tail": {$: "Con", "head": 55296, "tail": {$: "Nil"}}}})), "tail": {$: "Con", "head": ($cases$058constructor$1261$(_schema_0, "utf16-string-out-of-range", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65536, "tail": {$: "Nil"}}})), "tail": {$: "Nil"}}}}}}}}}}}}}}};
}

function $cases$058resources$1261$(_schema_0) {
  return {$: "Con", "head": ($cases$058resource$1264$(_schema_0, "resource-f32-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5}, false)), "tail": {$: "Con", "head": ($cases$058resource$1264$(_schema_0, "resource-binary64-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": 1072693248, "low": 0}, false)), "tail": {$: "Con", "head": ($cases$058resource$1265$(_schema_0, "resource-boolean-accepted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": true}, false)), "tail": {$: "Con", "head": ($cases$058resource$1266$(_schema_0, "resource-literal-rendered-refused", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 98, "tail": {$: "Con", "head": 101, "tail": {$: "Con", "head": 116, "tail": {$: "Con", "head": 97, "tail": {$: "Nil"}}}}}}, false)), "tail": {$: "Con", "head": ($cases$058resource$1267$(_schema_0, "resource-utf16-refused", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": {$: "Con", "head": 65536, "tail": {$: "Nil"}}}, false)), "tail": {$: "Con", "head": ($cases$058resource$1264$(_schema_0, "resource-f32-aborted", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": 2.5}, true)), "tail": {$: "Nil"}}}}}}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058serialize_step$(_pending_0, _acc_0, _next_0) {
  if (_pending_0.$ === "Nil") {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058reversed_string$(_acc_0, "");
  } else {
    const _t_0 = _pending_0["head"];
    if (_t_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Visit") {
      const _value_0 = _t_0["value"];
      const _rest_0 = _pending_0["tail"];
      return run_tail(_next_0(($List$append$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058tokens$(_value_0)), _rest_0))), _acc_0);
    } else {
      const _text_0 = _t_0["text"];
      const _rest_1 = _pending_0["tail"];
      return run_tail(_next_0(_rest_1), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058chars$(_text_0, _acc_0)));
    }
  }
}

function $format$058record$(_tag_0, _fields_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058record$(_tag_0, _fields_0);
}

function $format$058constructed$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Constructed") {
    const _owner_0 = _value_0["owner"];
    const _recovered_0 = _value_0["recovered"];
    return $format$058record$("Constructed", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "owner", "value": ($format$058view$(_owner_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "recovered", "value": ($format$058input_view$(_recovered_0))}, "tail": {$: "Nil"}}});
  } else {
    const _input_0 = _value_0["input"];
    const _error_0 = _value_0["error"];
    return $format$058record$("Rejected", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "input", "value": ($format$058input_view$(_input_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "error", "value": ($format$058error_value$(_error_0))}, "tail": {$: "Nil"}}});
  }
}

function $format$058resource_report$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.ResourceReport") {
    const _before_0 = _value_0["before"];
    const _after_0 = _value_0["after"];
    const _result_0 = _value_0["result"];
    const _outcome_0 = _value_0["outcome"];
    const _pending_0 = _value_0["pending"];
    const _undoCount_0 = _value_0["undoCount"];
    return $format$058record$("ResourceReport", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "before", "value": ($format$058snapshot$(_before_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "after", "value": ($format$058snapshot$(_after_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "result", "value": ($format$058resource_result$(_result_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "outcome", "value": ($format$058outcome_value$(_outcome_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "pending", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _pending_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "undoCount", "value": ($format$058nat$(_undoCount_0))}, "tail": {$: "Nil"}}}}}}});
  } else {
    return $format$058record$("CreateRefused", {$: "Nil"});
  }
}

function $cases$058constructor$1260$(_schema_0, _label_0, _codec_0, _raw_0) {
  return {$: "cases.Constructed", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058construct$1260$(_codec_0, _raw_0))};
}

function $cases$058resource$1260$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1264$(_raw_0, _fail_0))};
}

function $cases$058resource$1261$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1265$(_raw_0, _fail_0))};
}

function $cases$058resource$1262$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1266$(_raw_0, _fail_0))};
}

function $cases$058resource$1263$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1267$(_raw_0, _fail_0))};
}

function $cases$058constructor$1261$(_schema_0, _label_0, _codec_0, _raw_0) {
  return {$: "cases.Constructed", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058construct$1261$(_codec_0, _raw_0))};
}

function $cases$058resource$1264$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1268$(_raw_0, _fail_0))};
}

function $cases$058resource$1265$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1269$(_raw_0, _fail_0))};
}

function $cases$058resource$1266$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$12610$(_raw_0, _fail_0))};
}

function $cases$058resource$1267$(_schema_0, _label_0, _raw_0, _fail_0) {
  return {$: "cases.Resource", "schema": _schema_0, "label": _label_0, "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$12611$(_raw_0, _fail_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058reversed_string$($0, $1) {
  for (;;) {
    {
      const _chars_0 = $0;
      const _acc_0 = $1;
      if (_chars_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _head_0 = _chars_0["head"];
        const _tail_0 = _chars_0["tail"];
        $0 = _tail_0;
        $1 = (_head_0 + _acc_0);
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058tokens$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Null") {
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": "null"}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number") {
    const _value_1 = _value_0["value"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ($U32$show$(_value_1))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text") {
    const _value_2 = _value_0["value"];
    const _x_0 = (_value_2 + "\"");
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ("\"" + _x_0)}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Truth") {
    const _value_3 = _value_0["value"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058boolean$(_value_3))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items") {
    const _values_0 = _value_0["values"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": "["}, "tail": ($List$append$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058array_tokens$(_values_0)), {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": "]"}, "tail": {$: "Nil"}}))};
  } else {
    const _fields_0 = _value_0["fields"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": "{"}, "tail": ($List$append$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058object_tokens$(_fields_0)), {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": "}"}, "tail": {$: "Nil"}}))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058chars$($0, $1) {
  for (;;) {
    {
      const _text_0 = $0;
      const _acc_0 = $1;
      if (_text_0 === "") {
        return _acc_0;
      } else {
        const _head_0 = (_text_0.codePointAt(0) > 0xFFFF ? _text_0.slice(0, 2) : _text_0[0]);
        const _tail_0 = (_text_0.codePointAt(0) > 0xFFFF ? _text_0.slice(2) : _text_0.slice(1));
        $0 = _tail_0;
        $1 = {$: "Con", "head": _head_0, "tail": _acc_0};
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058record$(_tag_0, _fields_0) {
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "$", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _tag_0}}, "tail": _fields_0}};
}

function $format$058view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _original_0 = _value_0["original"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $format$058record$("View", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "raw", "value": run_loop($format$058raw_value$(_raw_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "original", "value": run_loop($format$058raw_value$(_original_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "words", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058numbers$(_words_0))}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "flags", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058bools$(_flags_0))}}, "tail": {$: "Nil"}}}}});
}

function $format$058input_view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $format$058record$("InputView", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "raw", "value": run_loop($format$058raw_value$(_raw_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "words", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058numbers$(_words_0))}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "flags", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058bools$(_flags_0))}}, "tail": {$: "Nil"}}}});
}

function $format$058error_value$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid") {
    const _path_0 = _value_0["path"];
    const _expected_0 = _value_0["expected"];
    const _actual_0 = _value_0["actual"];
    return $format$058record$("Invalid", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "path", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _path_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "expected", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _expected_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "actual", "value": run_loop($format$058raw_value$(_actual_0))}, "tail": {$: "Nil"}}}});
  } else {
    const _path_1 = _value_0["path"];
    return $format$058record$("FuelExhausted", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "path", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _path_1}}, "tail": {$: "Nil"}});
  }
}

function $format$058snapshot$(_value_0) {
  const _meta_0 = _value_0["meta"];
  const _live_0 = _value_0["live"];
  const _resource_0 = _value_0["resource"];
  const _pending_0 = _value_0["pending"];
  return $format$058record$("Snapshot", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "meta", "value": ($format$058meta_value$(_meta_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "live", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058bools$(_live_0))}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "store", "value": ($format$058record$("Unit", {$: "Nil"}))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "resource", "value": ($format$058view$(_resource_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "pending", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _pending_0}}, "tail": {$: "Nil"}}}}}});
}

function $format$058resource_result$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Replaced") {
    const _canonical_0 = _value_0["canonical"];
    return $format$058record$("Replaced", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "canonical", "value": run_loop($format$058raw_value$(_canonical_0))}, "tail": {$: "Nil"}});
  } else {
    const _owner_0 = _value_0["owner"];
    const _error_0 = _value_0["error"];
    return $format$058record$("Refused", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "owner", "value": ($format$058view$(_owner_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "error", "value": ($format$058error_value$(_error_0))}, "tail": {$: "Nil"}}});
  }
}

function $format$058outcome_value$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    return $format$058record$("Success", {$: "Nil"});
  } else {
    const _t_0 = _value_0["error"];
    return $format$058record$("Failure", {$: "Nil"});
  }
}

function $format$058nat$(_value_0) {
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": ($Nat$show$(_value_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058construct$1260$(_codec_0, _raw_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058invoked$1260$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058invoke$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(_codec_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input$(_raw_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1264$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1264$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1265$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1265$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1266$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1266$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1267$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1267$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058construct$1261$(_codec_0, _raw_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058invoked$1261$(run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058invoke$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$(_codec_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input$(_raw_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1268$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1268$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$1269$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1269$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$12610$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$12610$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource$12611$(_raw_0, _fail_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$12611$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0)), _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$()), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number", "value": 100})))));
}

function $U32$show$(_a_0) {
  const _b_0 = _a_0;
  return $U32$show$if$(_b_0, (_b_0 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058boolean$(_value_0) {
  if (_value_0) {
    return "true";
  } else {
    return "false";
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058array_tokens$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Visit", "value": _value_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058array_tail$(_rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058object_tokens$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _field_0 = _fields_0["head"];
    const _rest_0 = _fields_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058field_tokens$(_field_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058object_tail$(_rest_0)));
  }
}

function $format$058raw_value$(_value_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_value_0));
  const _x_1 = nat_chk(4 * _x_0);
  return $format$058raw_walk$(nat_chk(1 + _x_1), {$: "Con", "head": {$: "format.VisitRaw", "value": _value_0}, "tail": {$: "Nil"}}, {$: "Nil"});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058numbers$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _value_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058numbers$(_rest_0))};
  }
}

function $format$058bools$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Truth", "value": _value_0}, "tail": ($format$058bools$(_rest_0))};
  }
}

function $format$058meta_value$(_value_0) {
  const _namespace_0 = _value_0["namespace"];
  const _nextId_0 = _value_0["nextId"];
  const _highWater_0 = _value_0["highWater"];
  const _capacity_0 = _value_0["capacity"];
  const _depth_0 = _value_0["depth"];
  const _events_0 = _value_0["events"];
  const _registrations_0 = _value_0["registrations"];
  const _nextSystemId_0 = _value_0["nextSystemId"];
  const _clock_0 = _value_0["clock"];
  return $format$058record$("Meta", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "namespace", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _namespace_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "nextId", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _nextId_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "highWater", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _highWater_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "capacity", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _capacity_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "depth", "value": ($format$058nat$(_depth_0))}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "events", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058units$(_events_0))}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "registrations", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058registration_values$(_registrations_0))}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "nextSystemId", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _nextSystemId_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "clock", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _clock_0}}, "tail": {$: "Nil"}}}}}}}}}});
}

function $Nat$show$(_n_0) {
  const _m_0 = _n_0;
  return $Nat$show$fin$(_m_0, "", ($Nat$show$put$(nat_divmod(_m_0, 10))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058invoked$1260$(_result_0) {
  const _result_1 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058observe$(_result_1);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058invoke$1260$(_factory_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1260$(_args_0, _factory_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1260$(_declaration_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1260$(_declaration_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input$(_raw_0) {
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Input", "raw": _raw_0, "words": array_node([71], [72]), "flags": array_node([true], [false])};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1264$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1264$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058owned$(_raw_0) {
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Owner", "raw": _raw_0, "original": _raw_0, "words": array_node([81], [82]), "flags": array_node([false], [true])};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1260$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058factory$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": 1};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1265$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1265$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1266$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1266$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1267$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1267$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058invoked$1261$(_result_0) {
  const _result_1 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058observe$(_result_1);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058invoke$1261$(_factory_0, _args_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1263$(_args_0, _factory_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058factory$1261$(_declaration_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-construction.Factory", "declaration": _declaration_0, "inputCodec": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1262$(_declaration_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1268$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1268$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create$1261$(_factory_0, _resource_0) {
  const _namespace_0 = _factory_0["nextNamespace"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$((_namespace_0 < 4294967295), _namespace_0, _resource_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$1269$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1269$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$12610$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$12610$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058created$12611$(_replacement_0, _fail_0, _value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected") {
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.CreateRefused"};
  } else {
    const _world_0 = _value_0["world"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$12611$(_replacement_0, _fail_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0)));
  }
}

function $U32$show$if$(_a_0, _z_0) {
  if (_z_0) {
    return "0";
  } else {
    return $U32$show$go$(10, _a_0, "");
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058array_tail$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ","}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Visit", "value": _value_0}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058array_tail$(_rest_0))}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058field_tokens$(_field_0, _rest_0) {
  const _key_0 = _field_0["key"];
  const _value_0 = _field_0["value"];
  const _x_0 = (_key_0 + "\":");
  return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ("\"" + _x_0)}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Visit", "value": _value_0}, "tail": _rest_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058object_tail$(_fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _field_0 = _fields_0["head"];
    const _rest_0 = _fields_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.TraceEmit", "text": ","}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058field_tokens$(_field_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058object_tail$(_rest_0))))};
  }
}

function $format$058raw_walk$(_fuel_0, _todo_0, _stack_0) {
  if (_fuel_0 === 0) {
    return $format$058record$("FormatterBudgetError", {$: "Nil"});
  } else {
    const _rest_0 = (_fuel_0 - 1);
    return $format$058raw_step$(_todo_0, _stack_0, run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $format$058raw_walk$(_rest_0, _x_0, _x_1);
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

function $format$058units$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": ($format$058record$("Unit", {$: "Nil"})), "tail": ($format$058units$(_rest_0))};
  }
}

function $format$058registration_values$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _values_0["head"];
    const _id_0 = _t_0["id"];
    const _name_0 = _t_0["name"];
    const _access_0 = _t_0["access"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": ($format$058record$("RegistrationMeta", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "id", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _id_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "name", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "access", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($format$058string_values$(_access_0))}}, "tail": {$: "Nil"}}}})), "tail": ($format$058registration_values$(_rest_0))};
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058observe$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid") {
    const _raw_0 = _result_0["raw"];
    const _error_0 = _result_0["error"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058rejected$(_error_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_view$(_raw_0)));
  } else {
    const _cooked_0 = _result_0["cooked"];
    const _reverse_0 = _result_0["undo"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058constructed$(_reverse_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058view$(_cooked_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1260$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058body$1260$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1260$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1264$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1260$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1266$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_resource$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1260$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": {$: "Unit"}, "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1265$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1260$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1267$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1266$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1260$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1268$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1267$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1260$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1269$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1263$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058body$1261$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1262$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1268$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1261$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12610$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_resource$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource$1261$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058create_checked$1261$(_available_0, _namespace_0, _resource_0) {
  if (!_available_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.CreateRejected", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": _namespace_0}, "resource": _resource_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Created", "factory": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Factory", "nextNamespace": ((_namespace_0 + 1) >>> 0)}, "world": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": 1, "highWater": 0, "live": array_new(0, false), "capacity": 1, "depth": 0, "store": {$: "Unit"}, "resource": _resource_0, "events": {$: "Nil"}, "pending": {$: "Nil"}, "registrations": {$: "Nil"}, "nextSystemId": 1, "clock": 0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$1269$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1261$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12611$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$12610$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1261$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12612$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058before$12611$(_replacement_0, _fail_0, _result_0) {
  const _world_0 = _result_0["fst"];
  const _before_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1261$(_before_0, _fail_0, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12613$(_replacement_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1262$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer"})))))));
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

function $format$058raw_step$(_todo_0, _stack_0, _next_0) {
  if (_todo_0.$ === "Nil") {
    if (_stack_0.$ === "Con") {
      const _value_0 = _stack_0["head"];
      const _t_0 = _stack_0["tail"];
      if (_t_0.$ === "Nil") {
        return _value_0;
      } else {
        return $format$058record$("FormatterStackError", {$: "Nil"});
      }
    } else {
      return $format$058record$("FormatterStackError", {$: "Nil"});
    }
  } else {
    const _t_1 = _todo_0["head"];
    if (_t_1.$ === "format.VisitRaw") {
      const _value_1 = _t_1["value"];
      const _rest_0 = _todo_0["tail"];
      return run_tail(_next_0(($List$append$(($format$058expand_raw$(_value_1)), _rest_0))), _stack_0);
    } else if (_t_1.$ === "format.Ready") {
      const _value_2 = _t_1["value"];
      const _rest_1 = _todo_0["tail"];
      return run_tail(_next_0(_rest_1), {$: "Con", "head": _value_2, "tail": _stack_0});
    } else if (_t_1.$ === "format.ArrayEnd") {
      const _count_0 = _t_1["count"];
      const _rest_2 = _todo_0["tail"];
      return run_tail(_next_0(_rest_2), ($format$058grouped_raw$("Array", "items", ($format$058collect_raw$(_count_0, _stack_0, {$: "Nil"})))));
    } else if (_t_1.$ === "format.ObjectEnd") {
      const _count_1 = _t_1["count"];
      const _rest_3 = _todo_0["tail"];
      return run_tail(_next_0(_rest_3), ($format$058grouped_raw$("Object", "fields", ($format$058collect_raw$(_count_1, _stack_0, {$: "Nil"})))));
    } else {
      const _name_0 = _t_1["name"];
      const _rest_4 = _todo_0["tail"];
      return run_tail(_next_0(_rest_4), ($format$058field_raw$(_name_0, _stack_0)));
    }
  }
}

function $format$058string_values$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _value_0}, "tail": ($format$058string_values$(_rest_0))};
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058rejected$(_error_0, _value_0) {
  const _view_0 = _value_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Rejected", "input": _view_0, "error": _error_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_words$(_raw_0, _flags_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1261$(_words_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058constructed$(_reverse_0, _value_0) {
  const _owner_0 = _value_0["fst"];
  const _view_0 = _value_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058restored$(_view_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_view$(_reverse_0(_owner_0))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058view$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _original_0 = _value_0["original"];
  const _values_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058words$(_raw_0, _original_0, _flags_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1261$(_values_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058body$1260$(_value_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1260$(_ctx_0, _value_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1260$(_before_0, _fail_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _t_1 = _t_0["owner"];
  const _t_2 = _t_1["batch"];
  const _t_3 = _t_2["tx"];
  const _world_0 = _t_3["world"];
  const _undo_0 = _t_3["undo"];
  const _commands_0 = _t_3["commands"];
  const _events_0 = _t_3["events"];
  const _prepared_0 = _t_2["prepared"];
  const _output_0 = _result_0["snd"];
  const _x_0 = ($List$length$(_prepared_0));
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058counted$1260$(_before_0, _fail_0, _world_0, _commands_0, _events_0, (_x_0 >>> 0), _output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_undo_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1266$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1264$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_resource$1260$(_value_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_live$1260$({$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _store_0, _resource_0, _pending_0, _view_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_live_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource$1260$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource_finish$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058view$(_resource_0)), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1267$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1265$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1268$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1266$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$1269$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1267$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058body$1261$(_value_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1263$(_ctx_0, _value_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058returned$1261$(_before_0, _fail_0, _result_0) {
  const _t_0 = _result_0["fst"];
  const _t_1 = _t_0["owner"];
  const _t_2 = _t_1["batch"];
  const _t_3 = _t_2["tx"];
  const _world_0 = _t_3["world"];
  const _undo_0 = _t_3["undo"];
  const _commands_0 = _t_3["commands"];
  const _events_0 = _t_3["events"];
  const _prepared_0 = _t_2["prepared"];
  const _output_0 = _result_0["snd"];
  const _x_0 = ($List$length$(_prepared_0));
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058counted$1261$(_before_0, _fail_0, _world_0, _commands_0, _events_0, (_x_0 >>> 0), _output_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_undo_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12610$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1268$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_frame$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0)), "handle": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.Handle", "namespace": 0, "id": 0}, "error": {$: "None"}, "cursor": 0, "receipts": {$: "Nil"}, "pending": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_resource$1261$(_value_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_live$1261$({$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _store_0, _resource_0, _pending_0, _view_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_live_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource$1261$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource_finish$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058view$(_resource_0)), _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12611$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1269$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12612$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$12610$(_args_0, _ctx_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058invoke_owned$12613$(_args_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$12611$(_args_0, _ctx_0);
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

function $format$058expand_raw$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Missing") {
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Missing", {$: "Nil"}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Null", {$: "Nil"}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
    const _value_1 = _value_0["value"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Number", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _value_1}}, "tail": {$: "Nil"}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
    const _negative_0 = _value_0["negative"];
    const _magnitude_0 = _value_0["magnitude"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("SignedInteger", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "negative", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Truth", "value": _negative_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "magnitude", "value": ($format$058nat$(_magnitude_0))}, "tail": {$: "Nil"}}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
    const _value_2 = _value_0["value"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Float", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "bits", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": f32_bits(_value_2)}}, "tail": {$: "Nil"}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
    const _high_0 = _value_0["high"];
    const _low_0 = _value_0["low"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Binary64", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "high", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _high_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "low", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _low_0}}, "tail": {$: "Nil"}}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
    const _value_3 = _value_0["value"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Text", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _value_3}}, "tail": {$: "Nil"}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
    const _units_0 = _value_0["units"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Utf16Text", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "units", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045relations$047timing$047current$045qualification$045v1$047trace$045value$058numbers$(_units_0))}}, "tail": {$: "Nil"}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
    const _value_4 = _value_0["value"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Boolean", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Truth", "value": _value_4}}, "tail": {$: "Nil"}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle") {
    const _namespace_0 = _value_0["namespace"];
    const _id_0 = _value_0["id"];
    return {$: "Con", "head": {$: "format.Ready", "value": ($format$058record$("Handle", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "namespace", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _namespace_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "id", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Number", "value": _id_0}}, "tail": {$: "Nil"}}}))}, "tail": {$: "Nil"}};
  } else if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _items_0 = _value_0["items"];
    return $List$append$(($format$058visits$(_items_0)), {$: "Con", "head": {$: "format.ArrayEnd", "count": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1260$(_items_0))}, "tail": {$: "Nil"}});
  } else {
    const _fields_0 = _value_0["fields"];
    return $List$append$(($format$058field_visits$(_fields_0)), {$: "Con", "head": {$: "format.ObjectEnd", "count": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1261$(_fields_0))}, "tail": {$: "Nil"}});
  }
}

function $format$058grouped_raw$(_tag_0, _field_0, _value_0) {
  const _stack_0 = _value_0["fst"];
  const _items_0 = _value_0["snd"];
  return {$: "Con", "head": ($format$058record$(_tag_0, {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": _field_0, "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Items", "values": _items_0}}, "tail": {$: "Nil"}})), "tail": _stack_0};
}

function $format$058collect_raw$($0, $1, $2) {
  for (;;) {
    {
      const _count_0 = $0;
      const _stack_0 = $1;
      const _acc_0 = $2;
      if (_count_0 === 0) {
        return {$: "Tuple", "fst": _stack_0, "snd": _acc_0};
      } else {
        const _more_0 = (_count_0 - 1);
        if (_stack_0.$ === "Con") {
          const _value_0 = _stack_0["head"];
          const _tail_0 = _stack_0["tail"];
          $0 = _more_0;
          $1 = _tail_0;
          $2 = {$: "Con", "head": _value_0, "tail": _acc_0};
          continue;
        } else {
          return {$: "Tuple", "fst": {$: "Nil"}, "snd": {$: "Con", "head": ($format$058record$("FormatterStackError", {$: "Nil"})), "tail": {$: "Nil"}}};
        }
      }
    }
  }
}

function $format$058field_raw$(_name_0, _stack_0) {
  if (_stack_0.$ === "Con") {
    const _value_0 = _stack_0["head"];
    const _rest_0 = _stack_0["tail"];
    return {$: "Con", "head": ($format$058record$("Field", {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "name", "value": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Text", "value": _name_0}}, "tail": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.Field", "key": "value", "value": _value_0}, "tail": {$: "Nil"}}})), "tail": _rest_0};
  } else {
    return {$: "Con", "head": ($format$058record$("FormatterStackError", {$: "Nil"})), "tail": {$: "Nil"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_words$(_raw_0, _flags_0, _value_0) {
  const _words_0 = _value_0["fst"];
  const _list_0 = _value_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_flagged$(_raw_0, _words_0, _list_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_flags_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1261$(_owner_0) {
  if (_owner_0.length === 1) {
    const _value_0 = _owner_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": _value_0, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _owner_0.slice(0, _owner_0.length >> 1);
    const _right_0 = _owner_0.slice(_owner_0.length >> 1);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058joined$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1261$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1261$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058restored$(_owner_0, _value_0) {
  const _input_0 = _value_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Constructed", "owner": _owner_0, "recovered": _input_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058words$(_raw_0, _original_0, _flags_0, _value_0) {
  const _words_0 = _value_0["fst"];
  const _list_0 = _value_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058flagged$(_raw_0, _original_0, _words_0, _list_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_flags_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1260$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058grant$1260$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058counted$1260$(_before_0, _fail_0, _world_0, _commands_0, _events_0, _pending_0, _output_0, _result_0) {
  const _undo_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058completed$1260$(_before_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_result$(_output_0)), _pending_0, _count_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058outcome$(_fail_0)))));
}

function $List$length$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = _xs_0["tail"];
    return nat_chk(($List$length$(_t_0)) + 1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1260$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1260$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1264$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1266$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1260$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_live$1260$(_meta_0, _store_0, _resource_0, _pending_0, _view_0, _live_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_pending$1260$({$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _view_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count$1260$({$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_owner_0) {
  if (_owner_0.length === 1) {
    const _value_0 = _owner_0[0];
    return {$: "Tuple", "fst": [_value_0], "snd": {$: "Con", "head": _value_0, "tail": {$: "Nil"}}};
  } else {
    const _left_0 = _owner_0.slice(0, _owner_0.length >> 1);
    const _right_0 = _owner_0.slice(_owner_0.length >> 1);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058joined$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058array$1260$(_right_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource_finish$1260$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _resource_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1265$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1267$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1266$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1268$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1267$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1269$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1263$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1262$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058grant$1261$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058counted$1261$(_before_0, _fail_0, _world_0, _commands_0, _events_0, _pending_0, _output_0, _result_0) {
  const _undo_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058completed$1261$(_before_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_result$(_output_0)), _pending_0, _count_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": _undo_0, "commands": _commands_0, "events": _events_0}, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058outcome$(_fail_0)))));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _tail_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1261$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058count_commands$1261$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1268$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12610$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045local$058begin_owner$1261$(_world_0, _codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0)))), "declaration": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_live$1261$(_meta_0, _store_0, _resource_0, _pending_0, _view_0, _live_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_pending$1261$({$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Meta", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "capacity": _capacity_0, "depth": _depth_0, "events": _events_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, _view_0, _values_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_1, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058observe_resource_finish$1261$(_observed_0, _namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _events_0, _pending_0, _registrations_0, _nextSystemId_0, _clock_0) {
  const _resource_0 = _observed_0["fst"];
  const _value_0 = _observed_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _value_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$1269$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12611$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$12610$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12612$(_ctx_0, _replacement_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_body$12611$(_replacement_0, _ctx_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12613$(_ctx_0, _replacement_0);
}

function $format$058visits$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _value_0 = _values_0["head"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "format.VisitRaw", "value": _value_0}, "tail": ($format$058visits$(_rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1260$(_values_0) {
  if (_values_0.$ === "Nil") {
    return 0;
  } else {
    const _rest_0 = _values_0["tail"];
    return nat_chk(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1260$(_rest_0)) + 1);
  }
}

function $format$058field_visits$(_values_0) {
  if (_values_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _values_0["head"];
    const _name_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _values_0["tail"];
    return {$: "Con", "head": {$: "format.VisitRaw", "value": _value_0}, "tail": {$: "Con", "head": {$: "format.FieldEnd", "name": _name_0}, "tail": ($format$058field_visits$(_rest_0))}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1261$(_values_0) {
  if (_values_0.$ === "Nil") {
    return 0;
  } else {
    const _rest_0 = _values_0["tail"];
    return nat_chk(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047application32$045v1$047timing$045alignment$045v1$047serialize$058length$1261$(_rest_0)) + 1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058input_flagged$(_raw_0, _words_0, _list_0, _value_0) {
  const _flags_0 = _value_0["fst"];
  const _values_0 = _value_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Input", "raw": _raw_0, "words": _words_0, "flags": _flags_0}, "snd": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.InputView", "raw": _raw_0, "words": _list_0, "flags": _values_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058joined$1261$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058flagged$(_raw_0, _original_0, _words_0, _list_0, _value_0) {
  const _flags_0 = _value_0["fst"];
  const _values_0 = _value_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Owner", "raw": _raw_0, "original": _original_0, "words": _words_0, "flags": _flags_0}, "snd": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.View", "raw": _raw_0, "original": _original_0, "words": _list_0, "flags": _values_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1260$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058grant$1260$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058request$1260$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058completed$1260$(_before_0, _result_0, _pending_0, _count_0, _value_0) {
  const _world_0 = _value_0["world"];
  const _outcome_0 = _value_0["outcome"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058report$1260$(_before_0, _result_0, _outcome_0, _pending_0, _count_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1260$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058resource_result$(_value_0) {
  if (_value_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced") {
    const _raw_0 = _value_0["canonical"];
    return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Replaced", "canonical": _raw_0};
  } else {
    const _owner_0 = _value_0["owner"];
    const _error_0 = _value_0["error"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058refused_resource$(_error_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058view$(_owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1260$(_tx_0, _outcome_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058outcome$(_fail_0) {
  if (!_fail_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success"};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": {$: "Unit"}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1260$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1266$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1264$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1260$(_tx_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1260$(_world_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_pending$1260$(_meta_0, _view_0, _live_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _pending_0 = _value_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Snapshot", "meta": _meta_0, "live": _live_0, "store": {$: "Unit"}, "resource": _view_0, "pending": _pending_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count$1260$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count_join$1260$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1260$(_pending_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058joined$1260$(_left_0, _right_0) {
  const _left_1 = _left_0["fst"];
  const _a_0 = _left_0["snd"];
  const _right_1 = _right_0["fst"];
  const _b_0 = _right_0["snd"];
  return {$: "Tuple", "fst": array_node(_left_1, _right_1), "snd": ($List$append$(_a_0, _b_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1267$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1265$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1268$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1266$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$1269$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1267$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1262$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058grant$1261$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058request$1261$(_x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058completed$1261$(_before_0, _result_0, _pending_0, _count_0, _value_0) {
  const _world_0 = _value_0["world"];
  const _outcome_0 = _value_0["outcome"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058report$1261$(_before_0, _result_0, _outcome_0, _pending_0, _count_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot$1261$(_world_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058tx_finish$1261$(_tx_0, _outcome_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(_tx_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058counted$1261$(_command_0, _result_0) {
  const _commands_0 = _result_0["fst"];
  const _count_0 = _result_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": nat_chk(_count_0 + 1)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12610$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1268$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047bundle$045batch$058begin$1261$(_tx_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058begin$1261$(_world_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Nil"}, "commands": {$: "Nil"}, "events": {$: "Nil"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058snapshot_pending$1261$(_meta_0, _view_0, _live_0, _value_0) {
  const _world_0 = _value_0["fst"];
  const _pending_0 = _value_0["snd"];
  return {$: "Tuple", "fst": _world_0, "snd": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Snapshot", "meta": _meta_0, "live": _live_0, "store": {$: "Unit"}, "resource": _view_0, "pending": _pending_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count$1261$(_world_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count_join$1261$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1261$(_pending_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12611$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1269$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12612$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$12610$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request$12613$(_ctx_0, _input_0) {
  return run_tail(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$12611$())))(_ctx_0), _input_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058request$1260$(_factory_0, _input_0) {
  return {$: "Tuple", "fst": _factory_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1260$(_factory_0, _input_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058report$1260$(_before_0, _result_0, _outcome_0, _pending_0, _count_0, _value_0) {
  const _after_0 = _value_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.ResourceReport", "before": _before_0, "after": _after_0, "result": _result_0, "outcome": _outcome_0, "pending": _pending_0, "undoCount": _count_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058refused_resource$(_error_0, _value_0) {
  const _view_0 = _value_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Refused", "owner": _view_0, "error": _error_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1260$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1261$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1264$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1264$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count_join$1260$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _counted_0) {
  const _pending_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _count_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1260$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_prepend$1260$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1260$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1265$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1265$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1266$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1266$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1267$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1267$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058request$1261$(_factory_0, _input_0) {
  return {$: "Tuple", "fst": _factory_0, "snd": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1261$(_factory_0, _input_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058report$1261$(_before_0, _result_0, _outcome_0, _pending_0, _count_0, _value_0) {
  const _after_0 = _value_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.ResourceReport", "before": _before_0, "after": _after_0, "result": _result_0, "outcome": _outcome_0, "pending": _pending_0, "undoCount": _count_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish$1261$(_tx_0, _outcome_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047capabilities$058owned_request_field$1263$(_cap_0) {
  const _run_0 = _cap_0["run"];
  return _run_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1268$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1268$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_count_join$1261$(_namespace_0, _nextId_0, _highWater_0, _live_0, _capacity_0, _depth_0, _store_0, _resource_0, _events_0, _registrations_0, _nextSystemId_0, _clock_0, _counted_0) {
  const _pending_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _count_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1261$(_commands_0) {
  if (_commands_0.$ === "Nil") {
    return {$: "Tuple", "fst": {$: "Nil"}, "snd": 0};
  } else {
    const _command_0 = _commands_0["head"];
    const _rest_0 = _commands_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_prepend$1261$(_command_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_length$1261$(_rest_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$1269$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1269$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$12610$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$12610$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058grants$12611$() {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$12611$();
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1260$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(_inputCodec_0, _input_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1260$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1260$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1260$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$(_undo_0, _world_0)), "outcome": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1264$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_prepend$1260$(_command_0, _counted_0) {
  const _commands_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": ((_count_0 + 1) >>> 0)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1265$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1266$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1267$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058construct$1261$(_factory_0, _input_0) {
  const _inputCodec_0 = _factory_0["inputCodec"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(_inputCodec_0, _input_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058finish_world$1261$(_world_0, _undo_0, _commands_0, _events_0, _outcome_0) {
  if (_outcome_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success") {
    const _committed_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1261$(_world_0, ($List$reverse$(_commands_0))));
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1261$(_committed_0, ($List$reverse$(_events_0)))), "outcome": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Success"}};
  } else {
    const _error_0 = _outcome_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Returned", "world": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$(_undo_0, _world_0)), "outcome": {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Failure", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1268$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058pending_prepend$1261$(_command_0, _counted_0) {
  const _commands_0 = _counted_0["fst"];
  const _count_0 = _counted_0["snd"];
  return {$: "Tuple", "fst": {$: "Con", "head": _command_0, "tail": _commands_0}, "snd": ((_count_0 + 1) >>> 0)};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$1269$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$12610$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered", "values": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": "alpha"}, "tail": {$: "Nil"}}, "expected": "expected alpha"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058grant$12611$() {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/capabilities.OwnedRequest", "run": run_clo((_x_0) => {
  return run_clo((_x_1) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue"})), _x_0, _x_1);
});
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045construction$058checked$1260$(_receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Invalid", "raw": _owner_0, "error": _error_0};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058build$(_owner_0, _canonical_0);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1260$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1260$(_codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058incoming$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1260$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1260$(_commands_0, _world_0);
}

function $List$reverse$(_xs_0) {
  return $List$reverse$go$(_xs_0, {$: "Nil"});
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1260$(_world_0, _events_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1260$(_world_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1260$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1260$(_declaration_0, _frame_0, _replacement_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1260$(_frame_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1260$(_declaration_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1261$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue$1261$(_world_0, _commands_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1261$(_commands_0, _world_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058publish$1261$(_world_0, _events_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047transaction$058rollback$1261$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058request$1261$(_declaration_0, _frame_0, _replacement_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1261$(_frame_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1261$(_declaration_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058constructed$1263$(_codec_0) {
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/persistence-declaration.Constructed", "codec": _codec_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058build$(_value_0, _canonical_0) {
  const _original_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-construction.Constructed", "cooked": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Owner", "raw": _canonical_0, "original": _original_0, "words": _words_0, "flags": _flags_0}, "undo": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058undo$(_x_0);
})};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1260$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058incoming$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Input", "raw": _raw_0, "words": _words_0, "flags": _flags_0}, "snd": _raw_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1260$($0, $1) {
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
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0));
        continue;
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1260$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1260$(_frame_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1260$(_canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1260$(_frame_0, _owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1260$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1261$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047commands$058enqueue_list$1261$($0, $1) {
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
        $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1261$(_world_0, _command_0));
        continue;
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish$1261$(_world_0, _published_0) {
  if (_published_0.$ === "Nil") {
    return _world_0;
  } else {
    const _head_0 = _published_0["head"];
    const _rest_0 = _published_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, {$: "Con", "head": _head_0, "tail": _rest_0});
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058checked$1261$(_frame_0, _receipt_0) {
  const _owner_0 = _receipt_0["owner"];
  const _t_0 = _receipt_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected") {
    const _error_0 = _t_0["error"];
    return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Refused", "owner": _owner_0, "error": _error_0}};
  } else {
    const _canonical_0 = _t_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1261$(_canonical_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1261$(_frame_0, _owner_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058validate$1261$(_declaration_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1263$(_declaration_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058undo$(_value_0) {
  const _original_0 = _value_0["original"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Input", "raw": _original_0, "words": _words_0, "flags": _flags_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1260$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058raw_size$(_raw_0));
  const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_codec_0));
  const _x_2 = nat_chk(_x_0 + 1);
  const _x_3 = nat_chk(_x_1 * _x_2);
  return nat_chk(4 * _x_3);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1260$(_world_0, _command_0) {
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
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1260$(_world_0, _published_0) {
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
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1260$(_canonical_0, _result_0) {
  const _frame_0 = _result_0["fst"];
  return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced", "canonical": _canonical_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1260$(_frame_0, _replacement_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1260$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1260$(_tx_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_owner$1261$(_codec_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1261$(_codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058project$(_owner_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1261$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058enqueue$1261$(_world_0, _command_0) {
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
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": _events_0, "pending": {$: "Con", "head": _command_0, "tail": _pending_0}, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_publish_nonempty$1261$(_world_0, _published_0) {
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
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _resource_0, "events": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_events_0, _published_0)), "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045validated$045resource$058replaced$1261$(_canonical_0, _result_0) {
  const _frame_0 = _result_0["fst"];
  return {$: "Tuple", "fst": _frame_0, "snd": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-validated-resource.Replaced", "canonical": _canonical_0}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_set$1261$(_frame_0, _replacement_0) {
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
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1261$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1261$(_tx_0, _replacement_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047persistence$045declaration$058codec$1263$(_declaration_0) {
  const _codec_0 = _declaration_0["codec"];
  return _codec_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1260$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1260$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$(_fuel_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_codec_0) {
  if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
    const _inner_0 = _codec_0["inner"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_inner_0));
    return nat_chk(1 + _x_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
    const _inner_1 = _codec_0["inner"];
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_inner_1));
    return nat_chk(1 + _x_1);
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
    const _t_0 = _codec_0["fields"];
    if (_t_0.$ === "Nil") {
      return 1;
    } else {
      const _t_1 = _t_0["head"];
      const _child_0 = _t_1["codec"];
      const _rest_0 = _t_0["tail"];
      const _x_2 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$(_child_0));
      const _x_3 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058codec_size$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": _rest_0}));
      const _x_4 = nat_chk(_x_2 + _x_3);
      return nat_chk(1 + _x_4);
    }
  } else {
    return 1;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append$1260$(_left_0, _right_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1260$(($List$reverse$(_left_0)), _right_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1260$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _tx_0) {
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": {$: "Unit"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1260$(_tx_0, _replacement_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _replacement_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_projected$1261$(_codec_0, _observed_0) {
  const _owner_0 = _observed_0["fst"];
  const _raw_0 = _observed_0["snd"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045size$058budget$(_codec_0, _raw_0)), _owner_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047experiments$047public$045decode$047public$045seam$045v1$047construction$045v1$047qualification$045v1$047canonical$045v1$047source$047fixture$058project$(_value_0) {
  const _raw_0 = _value_0["raw"];
  const _original_0 = _value_0["original"];
  const _words_0 = _value_0["words"];
  const _flags_0 = _value_0["flags"];
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.Owner", "raw": _raw_0, "original": _original_0, "words": _words_0, "flags": _flags_0}, "snd": _raw_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045frame$058resource_join$1261$(_declaration_0, _prepared_0, _handle_0, _error_0, _cursor_0, _receipts_0, _pending_0, _tx_0) {
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-frame.Frame", "owner": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-requests.Owner", "batch": {$: "../../../../../../../../../../../../bendvy/src/ecs/bundle-batch.Batch", "tx": _tx_0, "prepared": _prepared_0}, "declaration": _declaration_0}, "handle": _handle_0, "error": _error_0, "cursor": _cursor_0, "receipts": _receipts_0, "pending": _pending_0}, "snd": {$: "Unit"}};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058tx_replace$1261$(_tx_0, _replacement_0) {
  const _world_0 = _tx_0["world"];
  const _undo_0 = _tx_0["undo"];
  const _commands_0 = _tx_0["commands"];
  const _events_0 = _tx_0["events"];
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _replacement_0)), _undo_0, _commands_0, _events_0);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _codec_0 = $1;
      const _raw_0 = $2;
      if (_fuel_0 === 0) {
        return _raw_0;
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
          const _inner_0 = _codec_0["inner"];
          if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"};
          } else {
            $0 = _more_0;
            $1 = _inner_0;
            $2 = _raw_0;
            continue;
          }
        } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
          const __0 = _codec_0["inner"];
          if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
            const _t_0 = _raw_0["items"];
            if (_t_0.$ === "Nil") {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": {$: "Nil"}};
            } else {
              const _head_0 = _t_0["head"];
              const _tail_0 = _t_0["tail"];
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_array_join$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, __0, _head_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue", "inner": __0}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": _tail_0})));
            }
          } else {
            return _raw_0;
          }
        } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
          const _t_1 = _codec_0["fields"];
          if (_t_1.$ === "Nil") {
            if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
              return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Nil"}};
            } else {
              return _raw_0;
            }
          } else {
            const _t_2 = _t_1["head"];
            const _name_0 = _t_2["name"];
            const _codec_1 = _t_2["codec"];
            const _rest_0 = _t_1["tail"];
            if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
              const _values_0 = _raw_0["fields"];
              return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_struct_join$(_name_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, _codec_1, run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _values_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_more_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct", "fields": _rest_0}, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": _values_0})));
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$($0, $1, $2) {
  for (;;) {
    {
      const _fuel_0 = $0;
      const _step_0 = $1;
      const _original_0 = $2;
      if (_fuel_0 === 0) {
        if (_step_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop") {
          const _error_0 = _step_0["error"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0};
        } else {
          const _t_0 = _step_0["work"];
          if (_t_0.$ === "Nil") {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_1 = _t_0["head"];
            const _path_0 = _t_1["path"];
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FuelExhausted", "path": _path_0}};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_step_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop") {
          const _error_1 = _step_0["error"];
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_1};
        } else {
          const _t_2 = _step_0["work"];
          if (_t_2.$ === "Nil") {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": _original_0};
          } else {
            const _t_3 = _t_2["head"];
            const _codec_0 = _t_3["codec"];
            const _raw_0 = _t_3["raw"];
            const _path_1 = _t_3["path"];
            const _rest_0 = _t_2["tail"];
            $0 = _more_0;
            $1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_1, _rest_0));
            $2 = _original_0;
            continue;
          }
        }
      }
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058event_append_loop$1260$($0, $1) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1260$(_replaced_0, _undo_0, _commands_0, _events_0) {
  const _world_0 = _replaced_0["fst"];
  const _old_0 = _replaced_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1260$(_x_0, _old_0);
}), "tail": _undo_0}, "commands": _commands_0, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _replacement_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _replacement_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _resource_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$058decode_budget$1261$(_codec_0, _raw_0, _fuel_0, _owner_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Owned", "owner": _owner_0, "description": _raw_0})));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058replace_join$1261$(_replaced_0, _undo_0, _commands_0, _events_0) {
  const _world_0 = _replaced_0["fst"];
  const _old_0 = _replaced_0["snd"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/transaction.Tx", "world": _world_0, "undo": {$: "Con", "head": run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1261$(_x_0, _old_0);
}), "tail": _undo_0}, "commands": _commands_0, "events": _events_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _replacement_0) {
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
  return {$: "Tuple", "fst": {$: "../../../../../../../../../../../../bendvy/src/ecs/world.World", "namespace": _namespace_0, "nextId": _nextId_0, "highWater": _highWater_0, "live": _live_0, "capacity": _capacity_0, "depth": _depth_0, "store": _store_0, "resource": _replacement_0, "events": _events_0, "pending": _pending_0, "registrations": _registrations_0, "nextSystemId": _nextSystemId_0, "clock": _clock_0}, "snd": _resource_0};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_array_join$(_head_0, _tail_0) {
  if (_tail_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
    const _values_0 = _tail_0["items"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array", "items": {$: "Con", "head": _head_0, "tail": _values_0}};
  } else {
    return _tail_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical_struct_join$(_name_0, _head_0, _tail_0) {
  if (_tail_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
    const _fields_0 = _tail_0["fields"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object", "fields": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Field", "name": _name_0, "value": _head_0}, "tail": _fields_0}};
  } else {
    return _tail_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _fields_0) {
  if (_fields_0.$ === "Nil") {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Missing"};
  } else {
    const _t_0 = _fields_0["head"];
    const _key_0 = _t_0["name"];
    const _value_0 = _t_0["value"];
    const _rest_0 = _fields_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field_choose$(($String$eq$(_name_0, _key_0)), _value_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _rest_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058expand$(_codec_0, _raw_0, _path_0, _rest_0) {
  if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Integer") {
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
      const __1 = _raw_0["negative"];
      const _magnitude_0 = _raw_0["magnitude"];
      const _x_0 = ($Nat$div$(_magnitude_0, nat_chk(65536 * 65536)));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_0 < 2097152), _path_0, "integer", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger", "negative": __1, "magnitude": _magnitude_0}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
      const _value_0 = _raw_0["value"];
      const _x_1 = Math.fround(Math.floor(_value_0));
      const _x_2 = Math.fround(Math.abs(_value_0));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($Bool$and$((_x_1 === _value_0), (_x_2 < 9007199254740992))), _path_0, "integer", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": _value_0}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
      const _high_0 = _raw_0["high"];
      const _low_0 = _raw_0["low"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer$(_high_0, _low_0)), _path_0, "integer", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": _high_0, "low": _low_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "integer", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.FiniteNumber") {
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
      const _value_1 = _raw_0["value"];
      const _x_3 = Math.fround(Math.abs(_value_1));
      const _x_4 = 3.4028234663852886e+38;
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_3 <= _x_4), _path_0, "finite number", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float", "value": _value_1}, _rest_0);
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
      const _high_1 = _raw_0["high"];
      const __5 = _raw_0["low"];
      const _x_5 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_1));
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$((_x_5 < 2047), _path_0, "finite number", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64", "high": _high_1, "low": __5}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "finite number", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.StringValue") {
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _units_0 = _raw_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_units_0)), _path_0, "string", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": _units_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "string", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.BoolValue") {
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "boolean", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Literal") {
    const _value_2 = _codec_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_value_2, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralValues") {
    const _values_0 = _codec_0["values"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_0, _raw_0)), _path_0, "literal", _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.LiteralRendered") {
    const _values_1 = _codec_0["values"];
    const _expected_0 = _codec_0["expected"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_1, _raw_0)), _path_0, _expected_0, _raw_0, _rest_0);
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Nullable") {
    const __8 = _codec_0["inner"];
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": __8, "raw": _raw_0, "path": _path_0}, "tail": _rest_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.ArrayValue") {
    const _inner_0 = _codec_0["inner"];
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Array") {
      const _items_0 = _raw_0["items"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_inner_0, _items_0, _path_0, 0, _rest_0))};
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "array", "actual": _raw_0}};
    }
  } else if (_codec_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Struct") {
    const _fields_0 = _codec_0["fields"];
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Object") {
      const _values_2 = _raw_0["fields"];
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_fields_0, _values_2, _path_0, _rest_0))};
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "object", "actual": _raw_0}};
    }
  } else {
    const _ns_0 = _codec_0["namespace"];
    if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle") {
      const _actual_0 = _raw_0["namespace"];
      const _id_0 = _raw_0["id"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(($Bool$and$((_ns_0 === _actual_0), (_id_0 > 0))), _path_0, "same-world handle", {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Handle", "namespace": _actual_0, "id": _id_0}, _rest_0);
    } else {
      return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": "same-world handle", "actual": _raw_0}};
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1260$(_world_0, _old_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1260$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1260$(_world_0, _old_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalized$1261$(_fuel_0, _codec_0, _result_0) {
  const _owner_0 = _result_0["owner"];
  const _t_0 = _result_0["checked"];
  if (_t_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted") {
    const _value_0 = _t_0["value"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Accepted", "value": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058canonical$(_fuel_0, _codec_0, _value_0))}};
  } else {
    const _error_0 = _t_0["error"];
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Rejected", "error": _error_0}};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058owned$1261$(_fuel_0, _codec_0, _input_0) {
  const _owner_0 = _input_0["owner"];
  const _description_0 = _input_0["description"];
  return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Receipt", "owner": _owner_0, "checked": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058validate$(_fuel_0, {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _description_0, "path": "$"}, "tail": {$: "Nil"}}}, _description_0))};
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore$1261$(_world_0, _old_0) {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1261$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047world$058replace_resource$1261$(_world_0, _old_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field_choose$(_equal_0, _value_0, _next_0) {
  if (_equal_0) {
    return _value_0;
  } else {
    return run_tail(_next_0, {$: "Unit"});
  }
}

function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058choose_checked$(_valid_0, _path_0, _expected_0, _raw_0, _rest_0) {
  if (_valid_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Continue", "work": _rest_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Stop", "error": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Invalid", "path": _path_0, "expected": _expected_0, "actual": _raw_0}};
  }
}

function $Nat$div$(_a_0, _b_0) {
  return $Pair$fst$(nat_divmod(_a_0, _b_0));
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer$(_high_0, _low_0) {
  const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_0));
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0)), (_x_0 < 1076));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary64_exponent$(_high_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  return (2048 === 0 ? _x_0 : _x_0 % 2048);
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    const _unit_0 = _units_0["head"];
    const _tail_0 = _units_0["tail"];
    return $Bool$and$((_unit_0 <= 65535), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_tail_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null") {
      return true;
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Null"})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
    const _a_1 = _a_0["value"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      const _b_1 = _b_0["value"];
      return $String$eq$(_a_1, _b_1);
    } else if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _b_2 = _b_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_a_1)), _b_2);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text", "value": _a_1})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
    const _a_2 = _a_0["units"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text") {
      const _b_3 = _b_0["units"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_a_2, _b_3);
    } else if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Text") {
      const _b_4 = _b_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_a_2, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_b_4)));
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Utf16Text", "units": _a_2})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
    const _a_3 = _a_0["value"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean") {
      const _b_5 = _b_0["value"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_3, _b_5);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$({$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Boolean", "value": _a_3})), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
    }
  } else {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_a_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_b_0)));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_values_0, _raw_0) {
  if (_values_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _values_0["head"];
    const _tail_0 = _values_0["tail"];
    const _x_0 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058equal$(_value_0, _raw_0));
    const _x_1 = ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058alternatives$(_tail_0, _raw_0));
    return (_x_0 || _x_1);
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_codec_0, _items_0, _path_0, _index_0, _rest_0) {
  if (_items_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _value_0 = _items_0["head"];
    const _tail_0 = _items_0["tail"];
    const _x_0 = ($U32$show$(_index_0));
    const _x_1 = (_x_0 + "]");
    const _x_2 = ("[" + _x_1);
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": _value_0, "path": (_path_0 + _x_2)}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058array_work$(_codec_0, _tail_0, _path_0, ((_index_0 + 1) >>> 0), _rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_fields_0, _values_0, _path_0, _rest_0) {
  if (_fields_0.$ === "Nil") {
    return _rest_0;
  } else {
    const _t_0 = _fields_0["head"];
    const _name_0 = _t_0["name"];
    const _codec_0 = _t_0["codec"];
    const _tail_0 = _fields_0["tail"];
    const _x_0 = ("." + _name_0);
    return {$: "Con", "head": {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Work", "codec": _codec_0, "raw": run_loop($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058field$(_name_0, _values_0)), "path": (_path_0 + _x_0)}, "tail": ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058struct_work$(_tail_0, _values_0, _path_0, _rest_0))};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1260$(_replaced_0) {
  const _world_0 = _replaced_0["fst"];
  return _world_0;
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047resource$058restore_join$1261$(_replaced_0) {
  const _world_0 = _replaced_0["fst"];
  return _world_0;
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_checked$(_result_0, _small_0) {
  return $Bool$and$(_small_0, ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_normal$(_result_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0) {
  const _x_0 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_1 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_2 = (2048 === 0 ? _x_1 : _x_1 % 2048);
  const _x_3 = (1048576 === 0 ? 0 : (_high_0 / 1048576) >>> 0);
  const _x_4 = (2048 === 0 ? _x_3 : _x_3 % 2048);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_parts$((_high_0 >= 2147483648), (2048 === 0 ? _x_0 : _x_0 % 2048), (1048576 === 0 ? _high_0 : _high_0 % 1048576), _low_0, (_x_2 === 2047), (_x_4 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_numeric$(_a_0, _b_0) {
  if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
    const _an_0 = _a_0["negative"];
    const _ah_0 = _a_0["high"];
    const _al_0 = _a_0["low"];
    const _ae_0 = _a_0["exponent"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
      const _bn_0 = _b_0["negative"];
      const _bh_0 = _b_0["high"];
      const _bl_0 = _b_0["low"];
      const _be_0 = _b_0["exponent"];
      return $Bool$and$(($Bool$and$(($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_an_0, _bn_0)), (_ah_0 === _bh_0))), (_al_0 === _bl_0))), (_ae_0 === _be_0));
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity") {
    const _a_1 = _a_0["negative"];
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity") {
      const _b_1 = _b_0["negative"];
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_1, _b_1);
    } else {
      return false;
    }
  } else if (_a_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN") {
    if (_b_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric$(_raw_0) {
  if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Number") {
    const _value_0 = _raw_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, false, 0, _value_0, 1074);
  } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.SignedInteger") {
    const _negative_0 = _raw_0["negative"];
    const _value_1 = _raw_0["magnitude"];
    const _x_0 = ($Nat$div$(_value_1, nat_chk(65536 * 65536)));
    const _x_1 = ($Nat$mod$(_value_1, nat_chk(65536 * 65536)));
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, (_x_0 >>> 0), (_x_1 >>> 0), 1074);
  } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Float") {
    const _value_2 = _raw_0["value"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_numeric$(f32_bits(_value_2));
  } else if (_raw_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Binary64") {
    const _high_0 = _raw_0["high"];
    const _low_0 = _raw_0["low"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_numeric$(_high_0, _low_0);
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NotNumber"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058checked$(_left_0, _right_0) {
  return $Bool$and$(($Bool$and$(($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_left_0)), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058valid$(_right_0)))), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_left_0, _right_0)));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_value_0) {
  if (_value_0 === "") {
    return {$: "Nil"};
  } else {
    const _t_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(0, 2) : _value_0[0]);
    const _tail_0 = (_value_0.codePointAt(0) > 0xFFFF ? _value_0.slice(2) : _value_0.slice(1));
    const _x_0 = _t_0.codePointAt(0);
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058scalar$(_t_0.codePointAt(0), ($$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058text$(_tail_0)), (_x_0 < 65536));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058same_bool$(_a_0, _b_0) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_integer_normal$(_result_0) {
  if (_result_0.$ === "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite") {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058binary_parts$(_negative_0, _exponent_0, _high_0, _low_0, _special_0, _zero_0) {
  if (_special_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$(_negative_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))));
  } else {
    if (_zero_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, _high_0, _low_0, 0);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, _negative_0, ((_high_0 + 1048576) >>> 0), _low_0, ((_exponent_0 - 1) >>> 0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0) {
  const _x_0 = (2 === 0 ? _low_0 : _low_0 % 2);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize_checked$(_fuel_0, _negative_0, _high_0, _low_0, _exponent_0, ($Bool$and$((_high_0 === 0), (_low_0 === 0))), (_x_0 === 0));
}

function $Nat$mod$(_a_0, _b_0) {
  return $Pair$snd$(nat_divmod(_a_0, _b_0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_numeric$(_bits_0) {
  const _x_0 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_1 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_2 = (256 === 0 ? _x_1 : _x_1 % 256);
  const _x_3 = (8388608 === 0 ? 0 : (_bits_0 / 8388608) >>> 0);
  const _x_4 = (256 === 0 ? _x_3 : _x_3 % 256);
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_parts$(_bits_0, (256 === 0 ? _x_0 : _x_0 % 256), (8388608 === 0 ? _bits_0 : _bits_0 % 8388608), (_x_2 === 255), (_x_4 === 0));
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_left_0, _right_0) {
  if (_left_0.$ === "Nil") {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058empty$(_right_0);
  } else {
    const _head_0 = _left_0["head"];
    const _tail_0 = _left_0["tail"];
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058compared$(_head_0, _right_0, run_clo((_x_0) => {
  return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058equal$(_tail_0, _x_0);
}));
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058scalar$(_code_0, _rest_0, _bmp_0) {
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$(_negative_0, _infinite_0) {
  if (_infinite_0) {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Infinity", "negative": _negative_0};
  } else {
    return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.NaN"};
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize_checked$($0, $1, $2, $3, $4, $5, $6) {
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
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          } else {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
          }
        }
      } else {
        const _more_0 = (_fuel_0 - 1);
        if (_zero_0) {
          return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": false, "high": 0, "low": 0, "exponent": 0};
        } else {
          if (!_even_0) {
            return {$: "../../../../../../../../../../../../bendvy/src/ecs/decode-data.Finite", "negative": _negative_0, "high": _high_0, "low": _low_0, "exponent": _exponent_0};
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

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058float_parts$(_bits_0, _exponent_0, _fraction_0, _special_0, _zero_0) {
  if (_special_0) {
    return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058numeric_special$((_bits_0 >= 2147483648), (_fraction_0 === 0));
  } else {
    if (_zero_0) {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, _fraction_0, 925);
    } else {
      return $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045data$058normalize$(64, (_bits_0 >= 2147483648), 0, ((_fraction_0 + 8388608) >>> 0), ((_exponent_0 + 924) >>> 0));
    }
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058empty$(_units_0) {
  if (_units_0.$ === "Nil") {
    return true;
  } else {
    return false;
  }
}

function $$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047$$$047bendvy$047src$047ecs$047decode$045utf16$058compared$(_head_0, _other_0, _next_0) {
  if (_other_0.$ === "Nil") {
    return false;
  } else {
    const _value_0 = _other_0["head"];
    const _tail_0 = _other_0["tail"];
    return $Bool$and$((_head_0 === _value_0), _next_0(_tail_0));
  }
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