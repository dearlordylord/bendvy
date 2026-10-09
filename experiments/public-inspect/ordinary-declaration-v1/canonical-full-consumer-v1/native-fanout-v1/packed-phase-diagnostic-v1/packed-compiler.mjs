#!/usr/bin/env bun
// @bun

// ../bend2-core/.claude/worktrees/rel-2035/bend2/main.ts
import * as child2 from "child_process";
import * as crypto3 from "crypto";
import * as fs4 from "fs";
import * as os3 from "os";
import * as path3 from "path";
import * as url2 from "url";
import * as thr from "worker_threads";

// ../bend2-core/.claude/worktrees/rel-2035/bend2/bend.ts
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as url from "url";
function Var(k, i, s, v) {
  return { $: "Var", k, i, s, v };
}
function Ref(k, s, b) {
  return { $: "Ref", k, s, b };
}
function Sub(i, v, f, s) {
  return { $: "Sub", i, v, f, s };
}
function Let(k, i, v, f, s, q) {
  return { $: "Let", k, i, q: q ?? k.map(() => Lone()), v, f, s };
}
function Typ(g, s) {
  return { $: "Typ", g, s };
}
function Qnt(s) {
  return { $: "Qnt", s };
}
function Qua(q, s) {
  return { $: "Qua", q, s };
}
function Min(a, b, s) {
  return { $: "Min", a, b, s };
}
function All(q, k, i, A, B, s) {
  return { $: "All", q, k, i, A, B, s };
}
function Lam(k, i, f, s, q) {
  return { $: "Lam", k, i, f, s, q };
}
function App(f, x, s) {
  return { $: "App", f, x, s };
}
function ADT(k, x, s, r = []) {
  return { $: "ADT", k, x, r, s };
}
function Ctr(k, x, s) {
  return { $: "Ctr", k, x, s };
}
function Lit(k, v, s) {
  return { $: "Lit", k, v, s };
}
function Mat(k, h, m, s) {
  return { $: "Mat", k, h, m, s };
}
function Efq(s) {
  return { $: "Efq", s };
}
function Eql(a, b, T, s) {
  return { $: "Eql", a, b, T, s };
}
function Rfl(s) {
  return { $: "Rfl", s };
}
function Rwt(e, p, f, s) {
  return { $: "Rwt", e, p, f, s };
}
function Hol(k, s) {
  return { $: "Hol", k, s };
}
function Ann(x, T, s) {
  return { $: "Ann", x, T, s };
}
function Emp() {
  return { $: "Emp" };
}
function Bin(v, l, r) {
  return { $: "Bin", v, l, r };
}
function None() {
  return { $: "None" };
}
function Lone() {
  return { $: "Lone" };
}
function Many() {
  return { $: "Many" };
}
function Infer(tm, ty, us, x) {
  return { tm: Ann(tm, Var("_", -1, undefined, ty)), ty, us, x };
}
function Check(tm, ty, us) {
  return { tm: Ann(tm, Var("_", -1, undefined, ty)), us };
}
function Err(bok, ctx, exp, obs, spn, def, nte) {
  return { $: "Err", bok, ctx, exp, obs, spn, def, nte };
}
function char_is_head(c) {
  const n = c.charCodeAt(0);
  return n >= 65 && n <= 90 || n >= 97 && n <= 122 || n === 95;
}
function char_is_name(c) {
  const n = c.charCodeAt(0);
  return char_is_head(c) || n >= 48 && n <= 57 || n === 46;
}
function pmap_get(map, key) {
  let m = map;
  let k = key;
  while (true) {
    switch (m.$) {
      case "Emp": {
        return null;
      }
      case "Bin": {
        if (k === 0) {
          return m.v;
        }
        const odd = k % 2 === 1;
        m = odd ? m.l : m.r;
        k = odd ? (k - 1) / 2 : (k - 2) / 2;
        break;
      }
    }
  }
}
function pmap_set(map, key, val) {
  switch (map.$) {
    case "Emp": {
      return pmap_set(Bin(null, map, map), key, val);
    }
    case "Bin": {
      if (key === 0) {
        return Bin(val, map.l, map.r);
      }
      if (key % 2 === 1) {
        const l = pmap_set(map.l, (key - 1) / 2, val);
        return Bin(map.v, l, map.r);
      }
      const r = pmap_set(map.r, (key - 2) / 2, val);
      return Bin(map.v, map.l, r);
    }
  }
}
function pmap_union(a, b, f) {
  if (a.$ === "Emp") {
    return b;
  }
  if (b.$ === "Emp") {
    return a;
  }
  const v = a.v === null ? b.v : b.v === null ? a.v : f(a.v, b.v);
  const l = pmap_union(a.l, b.l, f);
  const r = pmap_union(a.r, b.r, f);
  return Bin(v, l, r);
}
function pmap_to_array(map, acc = 0, scl = 1) {
  switch (map.$) {
    case "Emp": {
      return [];
    }
    case "Bin": {
      const v = map.v === null ? [] : [[acc, map.v]];
      const l = pmap_to_array(map.l, acc + scl * 1, scl * 2);
      const r = pmap_to_array(map.r, acc + scl * 2, scl * 2);
      return v.concat(l, r);
    }
  }
}
function list_get(list, key) {
  for (let l = list;l !== null; l = l.n) {
    if (l.k === key) {
      return l.v;
    }
  }
  return null;
}
function list_set(list, key, val) {
  return { k: key, v: val, n: list };
}
function quant_add(a, b) {
  if (a.$ === "None") {
    return b;
  }
  if (b.$ === "None") {
    return a;
  }
  return Many();
}
function quant_join(a, b) {
  if (a.$ === "Many" || b.$ === "Many") {
    return Many();
  }
  if (a.$ === "None") {
    return b;
  }
  return a;
}
function quant_dem(q, qt) {
  if (q.$ === "None") {
    return None();
  }
  return qt;
}
function uses_nil() {
  return Emp();
}
function uses_add(a, b) {
  return pmap_union(a, b, quant_add);
}
function lhs_ext(lhs, k, n, xs = []) {
  if (n === 0) {
    return term_apply(lhs, Ctr(k, xs));
  } else {
    return Lam("_", 0, (x) => {
      return lhs_ext(lhs, k, n - 1, [...xs, x]);
    });
  }
}
function lhs_kind(lhs, q) {
  return lhs.u === true && q.$ === "Many" ? Lone() : q;
}
function term_apply(fn, tm, s) {
  const f = term_strip(fn);
  if (f.$ === "Lam") {
    return f.f(tm);
  }
  return App(f, tm, s);
}
function term_unapply(tm) {
  const xs = [];
  let cur = tm;
  while (cur.$ === "App") {
    xs.push(cur.x);
    cur = cur.f;
  }
  return [cur, xs.reverse()];
}
function term_cell(t, k = "_") {
  if (t.$ === "Var" && t.i < 0) {
    return t;
  }
  return Var(k, -1, t.s, t);
}
function term_force(t) {
  while (t.$ === "Var" && t.v !== undefined) {
    t = t.v;
  }
  return t;
}
function term_strip(tm) {
  let t = term_force(tm);
  while (t.$ === "Ann") {
    t = term_force(t.x);
  }
  return t;
}
function term_higher(tm, env = null) {
  switch (tm.$) {
    case "Var": {
      if (tm.i < 0) {
        return tm;
      }
      const v = list_get(env, tm.i);
      if (v === null) {
        return tm.v ?? Ref(tm.k, tm.s);
      } else if (typeof v === "function") {
        return v(tm.s);
      } else {
        return v.s !== undefined || tm.s === undefined || v.$ === "Var" && v.i < 0 ? v : { ...v, s: tm.s };
      }
    }
    case "Ref": {
      if (tm.k.lastIndexOf(".") === 0) {
        const op = tm.s === undefined ? tm.k : tm.s.file.str.slice(tm.s.beg, tm.s.end);
        throw Err(book_nil(), ctx_nil(), "a type for this operator (write (a " + op + " b : Nat))", undefined, tm.s, undefined, `Note: we broke this after launch, sorry. Until 2.0.16 a bare operator meant Nat.
` + "That was a bug: operators demand annotation. Wrap the expression and it'll work again.");
      }
      return Ref(tm.k, tm.s, tm.b);
    }
    case "Sub": {
      return term_higher(tm.f, list_set(env, tm.i, (s) => term_higher(patt_term(tm.v, s), env)));
    }
    case "Let": {
      const b = tm;
      const v = b.v.map((x) => term_higher(x, env));
      return Let(b.k, b.i, v, (xs) => {
        let e = env;
        for (let j = 0;j < xs.length; j++) {
          e = list_set(e, b.i[j], xs[j]);
        }
        return term_higher(b.f, e);
      }, b.s, b.q);
    }
    case "All": {
      const b = tm;
      const A = term_higher(b.A, env);
      return All(b.q, b.k, b.i, A, (x) => {
        return term_higher(b.B, list_set(env, b.i, x));
      }, b.s);
    }
    case "Lam": {
      const b = tm;
      return Lam(b.k, b.i, (x) => {
        return term_higher(b.f, list_set(env, b.i, x));
      }, b.s, b.q);
    }
    case "Typ": {
      return Typ(term_higher(tm.g, env), tm.s);
    }
    case "Min": {
      return Min(term_higher(tm.a, env), term_higher(tm.b, env), tm.s);
    }
    case "App": {
      const f = term_higher(tm.f, env);
      const x = term_higher(tm.x, env);
      if (f.$ === "Lam") {
        return f.f(x);
      }
      return App(f, x, tm.s);
    }
    case "ADT": {
      return ADT(tm.k, tm.x.map((x) => term_higher(x, env)), tm.s, tm.r);
    }
    case "Ctr": {
      return Ctr(tm.k, tm.x.map((x) => term_higher(x, env)), tm.s);
    }
    case "Mat": {
      return Mat(tm.k, term_higher(tm.h, env), term_higher(tm.m, env), tm.s);
    }
    case "Eql": {
      return Eql(term_higher(tm.a, env), term_higher(tm.b, env), term_higher(tm.T, env), tm.s);
    }
    case "Rwt": {
      return Rwt(term_higher(tm.e, env), term_higher(tm.p, env), term_higher(tm.f, env), tm.s);
    }
    case "Ann": {
      return Ann(term_higher(tm.x, env), term_higher(tm.T, env), tm.s);
    }
    default: {
      return tm;
    }
  }
}
function term_lower(term, d = 0) {
  const tm = term_force(term);
  switch (tm.$) {
    case "Let": {
      const xs = tm.k.map((k, j) => Var(k, d + j));
      const vs = tm.v.map((v) => term_lower(v, d));
      return Let(tm.k, xs.map((_, j) => d + j), vs, term_lower(tm.f(xs), d + tm.k.length), tm.s, tm.q);
    }
    case "Typ": {
      return Typ(term_lower(tm.g, d), tm.s);
    }
    case "Min": {
      return Min(term_lower(tm.a, d), term_lower(tm.b, d), tm.s);
    }
    case "All": {
      const x = Var(tm.k, d);
      return All(tm.q, tm.k, d, term_lower(tm.A, d), term_lower(tm.B(x), d + 1), tm.s);
    }
    case "Lam": {
      const x = Var(tm.k, d);
      return Lam(tm.k, d, term_lower(tm.f(x), d + 1), tm.s, tm.q);
    }
    case "App": {
      return App(term_lower(tm.f, d), term_lower(tm.x, d), tm.s);
    }
    case "ADT": {
      return ADT(tm.k, tm.x.map((x) => term_lower(x, d)), tm.s, tm.r);
    }
    case "Ctr": {
      return Ctr(tm.k, tm.x.map((x) => term_lower(x, d)), tm.s);
    }
    case "Mat": {
      return Mat(tm.k, term_lower(tm.h, d), term_lower(tm.m, d), tm.s);
    }
    case "Eql": {
      return Eql(term_lower(tm.a, d), term_lower(tm.b, d), term_lower(tm.T, d), tm.s);
    }
    case "Rwt": {
      return Rwt(term_lower(tm.e, d), term_lower(tm.p, d), term_lower(tm.f, d), tm.s);
    }
    case "Ann": {
      return Ann(term_lower(tm.x, d), term_lower(tm.T, d), tm.s);
    }
    default: {
      return tm;
    }
  }
}
function ctx_nil() {
  return Emp();
}
function ctx_bind(ctx, i, q, k, T) {
  return pmap_set(ctx, i, { q, k, T });
}
function ctx_dead(book, ctx) {
  for (const [, a] of pmap_to_array(ctx)) {
    if (a.q.$ === "None") {
      continue;
    }
    const t = term_wnf(book, a.T);
    if (t.$ === "ADT" && book_adt(book, t, ctx).c.length === 0) {
      return true;
    }
  }
  return false;
}
function ctx_scope(ctx) {
  const bnd = [];
  for (const [i, a] of pmap_to_array(ctx)) {
    bnd[i] = a.k;
  }
  return Array.from(bnd, (k) => k ?? "_");
}
function book_nil() {
  return { tlds: Object.create(null), ctrs: Object.create(null), order: [], hols: 0, tmps: Object.create(null) };
}
function book_ctr(book, k) {
  return book.ctrs[k] ?? null;
}
function book_fam(book, k) {
  const t = tele_unbind(book, book_ctr(book, k).T).ret;
  return t.$ === "ADT" ? t.k : k;
}
function book_adt(book, tm, ctx, def) {
  const tld = book.tlds[tm.k];
  if (tld === undefined || tld.$ !== "ADT") {
    throw Err(book, ctx, "a declared datatype (unknown: " + name_key(tm.k) + ")", undefined, tm.s, def);
  }
  if (tm.r.length === 0) {
    return tld;
  }
  const r = new Set(tm.r);
  return { $: "ADT", n: tld.n, g: tld.g, T: tld.T, c: tld.c.filter((c) => !r.has(c.k)) };
}
var BEND_DIR = "/home/node/.bend/bend2";
var BASE_BEND = fs.realpathSync(path.join(BEND_DIR, "base.bend"));
var BEND_LIB = path.resolve(process.env.BEND_LIB ?? path.join(os.homedir(), ".bend", "lib"));
var BEND_HUB = process.env.BEND_HUB ?? "https://hub.bend-lang.com";
var NAMED = /^([a-z][a-z0-9-]{0,63})@((?:0|[1-9][0-9]*)(?:\.(?:0|[1-9][0-9]*)){3})$/;
async function hub_get(book, sub, hash, spn) {
  const res = await fetch(BEND_HUB + "/" + sub);
  const src = res.ok ? await res.text() : "";
  const sum = Buffer.from(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(src))).toString("hex");
  if (!res.ok || hash.length < 32 || sum.slice(0, hash.length) !== hash || path.posix.normalize("/" + sub) !== "/" + sub) {
    throw Err(book, ctx_nil(), "a file at " + BEND_HUB + "/" + sub + " hashing to " + hash, undefined, spn);
  }
  return src;
}
async function name_hash(book, nv, spn) {
  if (!NAMED.test(nv)) {
    throw Err(book, ctx_nil(), "a package as <name>@<version>: a-z, 0-9 and -, 1 to 64 characters, at four numbers like 1.0.0.0", "'" + nv + "'", spn);
  }
  const at = path.join(BEND_LIB, "names", nv);
  const old = fs.existsSync(at) ? fs.readFileSync(at, "utf8").trim() : "";
  if (/^0x[0-9a-f]{32}$/.test(old)) {
    return old;
  }
  const res = await fetch(BEND_HUB + "/name/" + nv).catch(() => null);
  const got = res?.ok ? (await res.text()).trim() : "";
  if (!/^0x[0-9a-f]{32}$/.test(got)) {
    throw Err(book, ctx_nil(), "a package named " + nv + " on " + BEND_HUB + (res?.status === 410 ? " (it was taken down)" : ""), undefined, spn);
  }
  fs.mkdirSync(path.dirname(at), { recursive: true });
  fs.writeFileSync(at, got + `
`);
  return got;
}
async function book_file(book, file, spn) {
  if (file.startsWith(BEND_LIB + "/") && !fs.existsSync(file)) {
    const pkg = file.slice(BEND_LIB.length + 1).split("/")[0];
    const man = await hub_get(book, pkg + "/manifest", pkg.slice(2), spn);
    const fls = man.trim().split(`
`).map((l) => l.split(" "));
    const srs = await Promise.all(fls.map(([h, p]) => hub_get(book, pkg + "/" + p, h, spn)));
    fls.forEach(([, p], i) => {
      const at = BEND_LIB + "/" + pkg + "/" + p;
      fs.mkdirSync(path.dirname(at), { recursive: true });
      fs.writeFileSync(at, srs[i]);
    });
  }
  if (!fs.existsSync(file)) {
    throw Err(book, ctx_nil(), "no such file: " + file, undefined, spn);
  }
  return fs.realpathSync(file);
}
async function book_load(book, file, ns, seen, spn, root) {
  const real = await book_file(book, file, spn);
  if (seen.has(real)) {
    if (seen.get(real) === null) {
      throw Err(book, ctx_nil(), "an import cycle through " + file, undefined, spn);
    }
    return book.order.length;
  }
  seen.set(real, null);
  const dir = real.slice(0, real.lastIndexOf("/") + 1);
  const top = root ?? dir;
  const text = fs.readFileSync(real, "utf8");
  const lines = text.split(`
`);
  const body = lines.slice();
  const al = Object.create(null);
  const hub = (s) => /^0x[0-9a-f]+\//.test(s);
  const ok = (s, lib) => hub(s) === lib && /^(\/|(\.\.\/)*)([A-Za-z_][\w-]*\/)*[A-Za-z_][\w-]*$/.test(s.replace(/^0x[0-9a-f]+\//, ""));
  for (let i = 0, at = 0;i < lines.length; at += lines[i].length + 1, i++) {
    const line = lines[i].trim();
    if (line === "" || line.startsWith("#")) {
      continue;
    }
    if (!/^import(\s|$)/.test(line)) {
      break;
    }
    const m = /^import\s+(\S+)(?:\s+as\s+([A-Za-z_]\w*))?\s*(?:#.*)?$/.exec(line);
    const beg = at + lines[i].indexOf(m?.[1] ?? line);
    const sp = { file: { str: text, ns, al }, beg, end: beg };
    if (m === null || m[2] === undefined && m[1] !== "Base") {
      throw Err(book, ctx_nil(), "an import ('import Base', or 'import <path> as <Name>')", "'" + line + "'", sp);
    }
    body[i] = "";
    if (m[2] === undefined) {
      await book_load(book, BASE_BEND, "", seen, sp);
      continue;
    }
    if (!m[1].endsWith(".bend")) {
      throw Err(book, ctx_nil(), "an import of a .bend file", "'" + m[1] + "'", sp);
    }
    if (m[2] in al) {
      throw Err(book, ctx_nil(), "a fresh alias (" + m[2] + " names an earlier import)", "'" + line + "'", sp);
    }
    const bad = () => Err(book, ctx_nil(), "an import path of plain names (letters, digits, _ and -; the hub's files import the hub's)", "'" + m[1] + "'", sp);
    const nv = /^([^/]*@[^/]*)\//.exec(m[1]);
    const as = nv === null ? m[1] : await name_hash(book, nv[1], sp) + m[1].slice(nv[1].length);
    const rel = path.posix.normalize(as);
    if (!ok(as.replace(/^\.\//, "").slice(0, -5), hub(as))) {
      throw bad();
    }
    const got = await book_file(book, hub(as) ? BEND_LIB + "/" + rel : path.posix.resolve(dir, rel), sp);
    const lib = fs.existsSync(BEND_LIB) ? fs.realpathSync(BEND_LIB) + "/" : "\x00";
    const sub = (got.startsWith(lib) ? got.slice(lib.length) : path.posix.relative(top, got)).replace(/\.bend$/, "");
    if (!ok(sub, got.startsWith(lib)) || hub(ns) && !got.startsWith(lib)) {
      throw bad();
    }
    al[m[2]] = sub;
    await book_load(book, got, sub, seen, sp, top);
  }
  const n0 = book.order.length;
  parse_book(book, dir, body.join(`
`), ns, al);
  if (real === BASE_BEND) {
    for (const k of book.order.slice(n0)) {
      book.tlds[k].b = true;
    }
  }
  seen.set(real, ns);
  return n0;
}
function tele_bind(tele, end) {
  return tele.reduceRight((out, [q, k, i, T, s]) => All(q, k, i, T, out, s), end);
}
function tele_open(book, tel) {
  const t = term_wnf(book, tel);
  return t.$ === "All" ? t : null;
}
function tele_head(book, tel, ctx, def, s) {
  const t = tele_open(book, tel);
  if (t === null) {
    throw Err(book, ctx, "unreachable (a telescope binds its parameters and fields)", undefined, s, def);
  }
  return t;
}
function tele_fill(book, tel, xs, ctx, def, s) {
  let out = tel;
  for (const x of xs) {
    out = tele_head(book, out, ctx, def, s).B(x);
  }
  return out;
}
function tele_unbind(book, T) {
  const doms = [];
  let tel = T;
  for (let t = tele_open(book, tel);t !== null; t = tele_open(book, tel)) {
    doms.push([t.q, t.k, t.A]);
    tel = t.B(Var(t.k, doms.length - 1));
  }
  return { doms, ret: term_wnf(book, tel) };
}
function word_to_term(n, s) {
  let out = Ctr("WNil", [], s);
  for (let i = 31;i >= 0; i--) {
    out = Ctr("WCon", [Ctr(n >>> i & 1 ? "True" : "False", [], s), out], s);
  }
  return out;
}
function lit_of(cs, s) {
  if (cs.every((c) => c <= 1114111 && (c < 55296 || c > 57343))) {
    return Lit("String", cs.map((c) => String.fromCodePoint(c)).join(""), s);
  }
  return cs.reduceRight((out, c) => Ctr("SCon", [Ctr("Chr", [Lit("U32", c, s)], s), out], s), Ctr("SNil", [], s));
}
function lit_step({ k, v, s }) {
  if (k === "String") {
    const c = v.codePointAt(0);
    return c === undefined ? Ctr("SNil", [], s) : Ctr("SCon", [Ctr("Chr", [Lit("U32", c, s)], s), Lit(k, v.slice(c > 65535 ? 2 : 1), s)], s);
  }
  if (k !== "Nat") {
    return Ctr(k, [word_to_term(v, s)], s);
  }
  return v === 0 ? Ctr("Zero", [], s) : Ctr("Succ", [Lit(k, v - 1, s)], s);
}
var NAT_LITERAL_MAX = 256;
function nat_from_term(t) {
  let n = 0;
  while (t.$ === "Ctr" && t.k === "Succ" && t.x.length === 1) {
    n += 1;
    t = t.x[0];
  }
  return t.$ === "Ctr" && t.k === "Zero" && t.x.length === 0 ? n : t.$ === "Lit" && t.k === "Nat" && n + t.v <= 4294967295 ? n + t.v : null;
}
function u32_from_term(tm, k = "U32") {
  const w0 = term_strip(tm);
  if (w0.$ === "Lit") {
    return w0.k === k ? w0.v : null;
  }
  if (w0.$ !== "Ctr" || w0.k !== k || w0.x.length !== 1) {
    return null;
  }
  let n = 0;
  let i = 0;
  let w = term_strip(w0.x[0]);
  while (w.$ === "Ctr" && w.k === "WCon" && w.x.length === 2) {
    const b = term_strip(w.x[0]);
    if (b.$ !== "Ctr" || b.x.length !== 0 || b.k !== "True" && b.k !== "False") {
      return null;
    }
    n += b.k === "True" ? 2 ** i : 0;
    i += 1;
    w = term_strip(w.x[1]);
  }
  if (i !== 32 || w.$ !== "Ctr" || w.k !== "WNil" || w.x.length !== 0) {
    return null;
  }
  return n;
}
var F32_VIEW = new DataView(new ArrayBuffer(4));
function f32_to_bits(v) {
  F32_VIEW.setFloat32(0, v);
  return F32_VIEW.getUint32(0);
}
function f32_from_bits(n) {
  F32_VIEW.setUint32(0, n);
  return F32_VIEW.getFloat32(0);
}
function f32_round(s) {
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
}
function quant_show(q) {
  return { None: "-", Lone: "", Many: "+" }[q.$];
}
var ESCAPES = {
  n: 10,
  t: 9,
  r: 13,
  "0": 0,
  "\\": 92,
  "'": 39,
  '"': 34
};
function term_key(tm) {
  return JSON.stringify(tm, (k, v) => k === "s" ? undefined : v);
}
function f32_show(x) {
  let s = "nan";
  for (let p = 1;x === x && p <= 9 && f32_round(s) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return (Object.is(x, -0) ? "-0" : s).replace(/^-?\d+(?=e|$)/, "$&.0").replace("Infinity", "inf");
}
function name_key(k) {
  return k.replace(":", ".");
}
function name_show(file, k) {
  if (file === undefined) {
    return name_key(k);
  }
  const [ns, nm] = k.includes(":") ? k.split(":") : ["", k];
  const a = Object.keys(file.al).find((a2) => file.al[a2] === ns);
  return ns === file.ns ? nm : a === undefined ? name_key(k) : a + "." + nm;
}
function term_show(term, top = -1, bnd = [], file) {
  function term_show_sugar_exi(tm, prc) {
    const [h, xs] = term_unapply(tm);
    const b = xs[1];
    if (h.$ !== "Ref" || h.k !== "Exists" || xs.length !== 2 || b.$ !== "Lam") {
      return null;
    }
    const A = go(xs[0], 2);
    bnd.push(b.k);
    const f = go(b.f, 1);
    bnd.pop();
    const s = "&" + b.k + ":" + A + " -> " + f;
    return prc > 1 ? "(" + s + ")" : s;
  }
  function term_show_chain(tm, k, n) {
    const xs = [];
    let t = tm;
    while (t.$ === "Ctr" && t.k === k && t.x.length === n) {
      xs.push(t.x[0]);
      t = t.x[n - 1];
    }
    return [xs, t];
  }
  function term_show_sugar_nat(tm, prc) {
    const k = nat_from_term(tm);
    if (k !== null) {
      return String(k) + "n";
    }
    const [xs, t] = term_show_chain(tm, "Succ", 1);
    const n = xs.length;
    if (n === 0) {
      return null;
    }
    const s = String(n) + "n+" + go(t, 1);
    return prc > 1 ? "(" + s + ")" : s;
  }
  function term_show_sugar_lst(tm, prc) {
    const [xs, t] = term_show_chain(tm, "Con", 2);
    if (t.$ === "Ctr" && t.k === "Nil" && t.x.length === 0) {
      return "[" + xs.map((x) => go(x, 0)).join(", ") + "]";
    }
    if (xs.length === 0) {
      return null;
    }
    const s = xs.map((x) => go(x, 2)).join(" <> ") + " <> " + go(t, 1);
    return prc > 1 ? "(" + s + ")" : s;
  }
  function term_show_sugar_tup(tm) {
    const [xs, t] = term_show_chain(tm, "Tuple", 2);
    if (xs.length === 0) {
      return null;
    }
    return "(" + xs.concat(t).map((x) => go(x, 0)).join(", ") + ")";
  }
  function term_show_sugar_arr(tm) {
    if (tm.$ === "Ctr" && tm.k === "ALeaf" && tm.x.length === 1) {
      return [go(tm.x[0], 0)];
    }
    if (tm.$ !== "Ctr" || tm.k !== "ANode" || tm.x.length !== 2) {
      return null;
    }
    const l = term_show_sugar_arr(tm.x[0]);
    const r = term_show_sugar_arr(tm.x[1]);
    if (l === null || r === null) {
      return null;
    }
    return l.concat(r);
  }
  function chr_show(n, quote) {
    const k = Object.keys(ESCAPES).find((k2) => ESCAPES[k2] === n && (k2 !== "'" && k2 !== '"' || k2 === quote));
    if (k !== undefined) {
      return "\\" + k;
    }
    if (n < 32 || n === 127 || n >= 55296 && n <= 57343 || n > 1114111) {
      return "\\u{" + n.toString(16) + "}";
    }
    return String.fromCodePoint(n);
  }
  function lit_text(v) {
    return [...v].map((c) => chr_show(c.codePointAt(0), '"')).join("");
  }
  function term_show_sugar_chr(tm, quote) {
    const n = tm.$ === "Ctr" && tm.k === "Chr" && tm.x.length === 1 ? u32_from_term(tm.x[0]) : null;
    return n === null ? null : chr_show(n, quote);
  }
  function term_show_sugar_str(tm) {
    const [cs, t] = term_show_chain(tm, "SCon", 2);
    const ss = cs.map((c) => term_show_sugar_chr(c, '"'));
    const tl = t.$ === "Lit" && t.k === "String" ? lit_text(t.v) : t.$ === "Ctr" && t.k === "SNil" && t.x.length === 0 ? "" : null;
    if (tl === null || ss.includes(null)) {
      return null;
    }
    return '"' + ss.join("") + tl + '"';
  }
  function go(tm, prc) {
    switch (tm.$) {
      case "Var": {
        return bnd.lastIndexOf(tm.k) === tm.i ? tm.k : tm.k + "^" + String(tm.i);
      }
      case "Ref": {
        const k = name_show(file, tm.k);
        return (bnd.includes(k) ? k + "^" : k) + (tm.b === true ? "!" : "");
      }
      case "Sub": {
        return go(tm.f, prc);
      }
      case "Let": {
        const vs = tm.v.map((v) => go(v, 1));
        for (const k of tm.k) {
          bnd.push(k);
        }
        const f = go(tm.f, -1);
        bnd.length -= tm.k.length;
        const ks = tm.k.map((k, j) => quant_show(tm.q[j]) + k);
        const s = ks.join(" ") + " = " + vs.join(" ") + "; " + f;
        return prc >= 0 ? "(" + s + ")" : s;
      }
      case "Typ": {
        const g = tm.g;
        if (g.$ === "Qua" && g.q.$ === "Lone") {
          return "Type";
        }
        if (g.$ === "Qua" && g.q.$ === "Many") {
          return "Data";
        }
        return "Kind(" + go(tm.g, 0) + ")";
      }
      case "Qnt": {
        return "Quant";
      }
      case "Qua": {
        return { None: "&0", Lone: "&1", Many: "&2" }[tm.q.$];
      }
      case "Min": {
        const s = go(tm.a, 2) + " <&> " + go(tm.b, 2);
        return prc > 1 ? "(" + s + ")" : s;
      }
      case "All": {
        const A = go(tm.A, 2);
        bnd.push(tm.k);
        const B = go(tm.B, 1);
        bnd.pop();
        const s = "@" + quant_show(tm.q) + tm.k + ":" + A + " -> " + B;
        return prc > 1 ? "(" + s + ")" : s;
      }
      case "Lam": {
        bnd.push(tm.k);
        const f = go(tm.f, -1);
        bnd.pop();
        const s = quant_show(tm.q ?? Lone()) + tm.k + " => " + f;
        return prc > 0 ? "(" + s + ")" : s;
      }
      case "App": {
        const sug = term_show_sugar_exi(tm, prc);
        if (sug !== null) {
          return sug;
        }
        const [h, xs] = term_unapply(tm);
        const hs = go(h, 2);
        const as = xs.map((x) => go(x, 0));
        return hs + "(" + as.join(", ") + ")";
      }
      case "ADT": {
        const as = tm.x.map((x) => go(x, 0));
        const rs = tm.r.map((c) => " - " + name_show(file, c) + "{}").join("");
        const s = name_show(file, tm.k) + (as.length === 0 && rs === "" ? "" : "<" + as.join(", ") + ">") + rs;
        return rs !== "" && prc > 1 ? "(" + s + ")" : s;
      }
      case "Ctr": {
        const u32 = u32_from_term(tm);
        const f32 = u32_from_term(tm, "F32");
        const chr = term_show_sugar_chr(tm, "'");
        const arr = term_show_sugar_arr(tm);
        const sug = u32 !== null ? String(u32) : f32 !== null ? f32_show(f32_from_bits(f32)) : term_show_sugar_nat(tm, prc) ?? (chr !== null ? "'" + chr + "'" : null) ?? term_show_sugar_str(tm) ?? term_show_sugar_lst(tm, prc) ?? term_show_sugar_tup(tm) ?? (arr !== null ? "[" + arr.join(", ") + "]" : null);
        if (sug !== null) {
          return sug;
        }
        const as = tm.x.map((x) => go(x, 0));
        return name_show(file, tm.k) + "{" + as.join(", ") + "}";
      }
      case "Lit": {
        return go(lit_step(tm), prc);
      }
      case "Mat": {
        const arms = [];
        let m = tm;
        while (m.$ === "Mat") {
          arms.push(name_show(file, m.k) + ": " + go(m.h, 1));
          m = m.m;
        }
        if (m.$ !== "Efq") {
          arms.push(go(m, 1));
        }
        return "\\{" + arms.join("; ") + "}";
      }
      case "Efq": {
        return "\\{}";
      }
      case "Eql": {
        return "{" + go(tm.a, 1) + " == " + go(tm.b, 1) + " : " + go(tm.T, 1) + "}";
      }
      case "Rfl": {
        return "{==}";
      }
      case "Hol": {
        return "?" + tm.k;
      }
      case "Rwt": {
        const e = go(tm.e, 1);
        const mp = term_strip(tm.p);
        const mb = mp.$ === "Lam" ? term_strip(mp.f) : mp;
        let n = "";
        let P;
        if (mp.$ === "Lam" && mb.$ === "Lam") {
          bnd.push(mp.k, mb.k);
          P = go(mb.f, 1);
          bnd.length -= 2;
          n = mb.k === "" ? "" : mb.k + "@";
        } else {
          P = go(tm.p, 1);
        }
        const f = go(tm.f, -1);
        const s = "%" + n + e + " : " + P + "; " + f;
        return prc > 0 ? "(" + s + ")" : s;
      }
      case "Ann": {
        return "{" + go(tm.x, 1) + " : " + go(tm.T, 1) + "}";
      }
    }
  }
  return go(term, top);
}
function expr_show(book, x, bnd = [], file) {
  if (typeof x === "string") {
    return x;
  } else {
    const t = term_lower(term_snf(book, x), bnd.length);
    return term_show(t, -1, bnd, file);
  }
}
function err_show(err) {
  const file = err.spn?.file;
  const bnd = ctx_scope(err.ctx);
  const anns = pmap_to_array(err.ctx).sort((a, b) => a[0] - b[0]);
  const wid = Math.max(0, ...anns.map(([, a]) => a.k.length));
  const msg = err.obs === undefined ? `
- message  : ` + expr_show(err.bok, err.exp, bnd, file) : `
- expected : ` + expr_show(err.bok, err.exp, bnd, file) + `
- observed : ` + expr_show(err.bok, err.obs, bnd, file);
  const ctx = anns.map(([i, a]) => `
- ` + a.k.padEnd(wid) + " : " + expr_show(err.bok, a.T, bnd.slice(0, i), file)).join("");
  const def = err.def === undefined ? "" : " " + name_show(file, err.def);
  let spn = "";
  if (err.spn !== undefined) {
    const lns = err.spn.file.str.split(`
`);
    const pre = err.spn.file.str.slice(0, err.spn.beg).split(`
`);
    const at = pre.length;
    const beg = Math.max(1, at - 1);
    const end = Math.min(lns.length, at + 1);
    const num = String(end).length;
    const lft = pre[at - 1];
    const car = " ".repeat(num) + " | " + lft.replace(/[^\t]/g, " ") + "^".repeat(Math.max(1, Math.min(err.spn.end - err.spn.beg, lns[at - 1].length - lft.length)));
    spn = `
` + lns.slice(beg - 1, end).map((l, j) => String(beg + j).padStart(num) + (beg + j === at ? ">| " + l + `
` + car : " | " + l)).join(`
`);
  }
  const loc = def === "" && spn === "" ? "" : `
Location:` + def + spn;
  const nte = err.nte === undefined ? "" : `
` + err.nte;
  return "Error:" + msg + (anns.length === 0 ? "" : `
Context:`) + ctx + loc + nte;
}
var KEYWORDS = new Set([
  "def",
  "type",
  "law",
  "match",
  "case",
  "do",
  "return",
  "for",
  "exs",
  "where",
  "is",
  "import",
  "Type",
  "Data",
  "Kind",
  "Quant"
]);
var QUAS = { "0": None(), "1": Lone(), "2": Many() };
function parse_col(src, pos) {
  return pos - src.lastIndexOf(`
`, pos - 1);
}
function parse_span(p, beg) {
  return { file: p, beg, end: p.pos };
}
function parse_fail(p, exp, beg = p.pos, end = p.pos) {
  const obs = beg < end ? "'" + p.str.slice(beg, end) + "'" : p.pos < p.str.length ? "'" + p.str[p.pos] + "'" : "end of input";
  throw Err(p.book, ctx_nil(), exp, obs, { file: p, beg, end });
}
function parse_peek(p) {
  return p.pos < p.str.length ? p.str[p.pos] : "";
}
function parse_bump(p) {
  const c = parse_peek(p);
  p.pos += 1;
  return c;
}
function parse_at(p, s) {
  if (p.str.charCodeAt(p.pos) !== s.charCodeAt(0)) {
    return false;
  }
  return s.length === 1 || p.str.startsWith(s, p.pos);
}
function parse_take(p, s) {
  if (!parse_at(p, s)) {
    return false;
  }
  p.pos += s.length;
  return true;
}
function parse_skip(p) {
  const s = p.str;
  while (p.pos < s.length) {
    const n = s.charCodeAt(p.pos);
    if (n === 32 || n === 10 || n === 13 || n === 9) {
      p.pos += 1;
      continue;
    }
    if (n === 35) {
      while (p.pos < s.length && s.charCodeAt(p.pos) !== 10) {
        p.pos += 1;
      }
      continue;
    }
    return;
  }
}
function parse_eat(p, s) {
  parse_skip(p);
  if (!parse_take(p, s)) {
    parse_fail(p, "'" + s + "'");
  }
}
function parse_at_word(p, w) {
  parse_skip(p);
  if (!parse_at(p, w)) {
    return false;
  }
  return !char_is_name(p.str[p.pos + w.length] ?? "");
}
function parse_word(p, w) {
  if (!parse_at_word(p, w)) {
    return false;
  }
  parse_take(p, w);
  return true;
}
function parse_lexeme(p) {
  parse_skip(p);
  if (!char_is_head(parse_peek(p))) {
    parse_fail(p, "a name");
  }
  const beg = p.pos;
  while (p.pos < p.str.length && char_is_name(p.str[p.pos])) {
    p.pos += 1;
  }
  const k = p.str.slice(beg, p.pos);
  if (!/^[A-Za-z_]\w*(\.[A-Za-z_]\w*)*$/.test(k)) {
    parse_fail(p, "a name (words joined by dots, got '" + k + "')", beg);
  }
  return k;
}
function parse_name(p) {
  const k = parse_lexeme(p);
  if (KEYWORDS.has(k)) {
    parse_fail(p, "a name (got the keyword '" + k + "')", p.pos - k.length);
  }
  return k;
}
function parse_char(p) {
  if (parse_take(p, "\\")) {
    const u = /^u\{([0-9a-f]+)\}/i.exec(p.str.slice(p.pos, p.pos + 11));
    if (u !== null) {
      p.pos += u[0].length;
      return parseInt(u[1], 16);
    }
    const c = ESCAPES[parse_bump(p)];
    if (c === undefined) {
      parse_fail(p, "an escape (\\n \\t \\r \\0 \\\\ \\' \\\" \\u{1F600})");
    }
    return c;
  }
  const n = p.str.codePointAt(p.pos);
  if (n === undefined) {
    parse_fail(p, "a character");
  }
  p.pos += n > 65535 ? 2 : 1;
  return n;
}
function parse_open(p, k) {
  const i = p.frs++;
  if (k !== "_") {
    p.stk.push([k, i]);
  }
  return i;
}
function parse_close(p, n) {
  p.stk.length = n;
}
function parse_var(p, k, s) {
  for (let j = p.stk.length - 1;j >= 0; j--) {
    if (p.stk[j][0] === k) {
      return Var(k, p.stk[j][1], s);
    }
  }
  const q = parse_reso(p, k);
  if (k.includes(".")) {
    return Ref(q, s);
  }
  return Var(k, p.frs++, s, Ref(q, s));
}
function parse_qual(p, k) {
  return p.ns === "" ? k : p.ns + ":" + k;
}
function parse_reso(p, k) {
  const dot = k.indexOf(".");
  let q = parse_qual(p, k);
  if (dot !== -1 && k.slice(0, dot) in p.al) {
    q = p.al[k.slice(0, dot)] + ":" + k.slice(dot + 1);
    if (q !== k && ((q in p.book.tlds) || (q in p.book.ctrs)) && ((k in p.book.tlds) || (k in p.book.ctrs))) {
      parse_fail(p, "an unambiguous name (the alias " + k.slice(0, dot) + " shadows " + k + ")");
    }
  }
  const own = q in p.book.tlds || q in p.book.ctrs;
  const far = k in p.book.tlds || k in p.book.ctrs;
  return own || !far ? q : k;
}
function parse_call(p, k, xs, s) {
  return xs.reduce((f, x) => App(f, x, s), Ref(parse_reso(p, k), s));
}
function parse_quant(p) {
  parse_skip(p);
  if (parse_take(p, "-")) {
    return None();
  }
  if (parse_take(p, "+")) {
    return Many();
  }
  return Lone();
}
function parse_bind(p, t) {
  if (t.$ !== "Var") {
    parse_fail(p, "a lambda binder (one name: k => body)");
  }
  return { $: "PVar", k: t.k, i: parse_open(p, t.k), q: t.i < 0 ? Many() : Lone(), s: t.s };
}
function parse_patt(p, t) {
  const book = p.book;
  switch (t.$) {
    case "Var": {
      if (book_ctr(book, parse_reso(p, t.k)) !== null) {
        throw Err(book, ctx_nil(), "a braced constructor pattern (" + name_key(t.k) + " is a constructor: write " + name_key(t.k) + "{}, or rename the binder)", undefined, t.s);
      }
      return parse_bind(p, t);
    }
    case "Ctr": {
      const ctr = book_ctr(book, t.k);
      if (ctr === null) {
        throw Err(book, ctx_nil(), "a declared constructor (unknown: " + name_key(t.k) + ")", undefined, t.s);
      }
      if (ctr.n !== t.x.length) {
        throw Err(book, ctx_nil(), "a " + name_key(t.k) + " pattern with " + String(ctr.n) + (ctr.n === 1 ? " field" : " fields"), undefined, t.s);
      }
      return { $: "PCtr", k: t.k, x: t.x.map((x) => parse_patt(p, x)), s: t.s };
    }
    case "Lit": {
      return parse_patt(p, lit_step(t));
    }
    default: {
      throw Err(book, ctx_nil(), "a pattern (a binder or a constructor)", term_show(term_lower(term_higher(t), 0)), t.s);
    }
  }
}
function parse_term(p, lvl = 0) {
  parse_skip(p);
  const beg = p.pos;
  const base = parse_term_base(p, beg);
  base.s ??= parse_span(p, beg);
  return parse_term_ops(p, base, base.s.beg, lvl);
}
function parse_term_base(p, beg) {
  const c = parse_peek(p);
  if (char_is_head(c)) {
    const k = parse_lexeme(p);
    if (k === "Type") {
      return Typ(Qua(Lone()));
    }
    if (k === "Data") {
      return Typ(Qua(Many()));
    }
    if (k === "Quant") {
      return Qnt();
    }
    if (k === "Kind") {
      parse_eat(p, "(");
      const g = parse_term(p);
      parse_eat(p, ")");
      return Typ(g);
    }
    if (k === "do") {
      const m = parse_name(p);
      parse_eat(p, "<");
      const ts = parse_fill(p, parse_reso(p, m), parse_term_args(p, ">"), parse_span(p, beg));
      parse_eat(p, ":");
      parse_skip(p);
      return parse_term_do_stmt(p, m, ts, parse_col(p.str, p.pos));
    }
    if (k === "match") {
      parse_fail(p, "a term (a match heads a def body, not a term)", beg);
    }
    if (k === "case") {
      parse_fail(p, "a match heading this case (this case is orphaned)", beg);
    }
    if (k === "return") {
      parse_fail(p, "a do-block heading this return", beg);
    }
    if (KEYWORDS.has(k)) {
      parse_fail(p, "a term (the keyword '" + k + "' cannot head one)", beg);
    }
    if (parse_take(p, "{")) {
      const xs = parse_term_args(p, "}");
      return Ctr(parse_reso(p, k), xs);
    }
    return parse_var(p, k, parse_span(p, beg));
  }
  if (/[0-9]/.test(c)) {
    return parse_term_num(p);
  }
  switch (c) {
    case "@": {
      return parse_term_all(p, false);
    }
    case "&": {
      const q = QUAS[p.str[p.pos + 1] ?? ""];
      if (q !== undefined) {
        parse_bump(p);
        parse_bump(p);
        return Qua(q);
      }
      return parse_term_all(p, true);
    }
    case "+": {
      parse_bump(p);
      const t = parse_term(p, 12);
      const s = parse_span(p, beg);
      const k = t.$ === "ADT" ? t.k : t.$ === "Var" || t.$ === "Ref" ? parse_reso(p, t.k) : "";
      const tld = p.book.tlds[k];
      if (t.$ === "Var" && (tld === undefined || tld.$ !== "ADT")) {
        return Var(t.k, -1, s);
      }
      if (tld === undefined || tld.$ !== "ADT" || tld.g === 0 || tld.g < tld.n && t.$ !== "ADT") {
        parse_fail(p, "a quantified datatype after + (+D<..> sets D's leading quantities to &2)");
      }
      const xs = t.$ === "ADT" ? t.x : Array.from({ length: tld.n }, () => Qua(Lone(), s));
      return ADT(k, xs.map((x, i) => i < tld.g ? Qua(Many(), s) : x), s);
    }
    case "\\": {
      parse_bump(p);
      parse_eat(p, "{");
      const arms = [];
      let tail = Efq();
      while (true) {
        parse_skip(p);
        if (parse_take(p, "}")) {
          break;
        }
        const t = parse_term(p);
        parse_skip(p);
        if ((t.$ === "Var" || t.$ === "Ref") && parse_take(p, ":")) {
          const h = parse_term(p);
          arms.push([parse_reso(p, t.k), h]);
          parse_skip(p);
          parse_take(p, ";");
          continue;
        }
        tail = t;
        parse_skip(p);
        parse_take(p, ";");
        parse_eat(p, "}");
        break;
      }
      const s = parse_span(p, beg);
      tail.s ??= s;
      return arms.reduceRight((out, arm) => Mat(arm[0], arm[1], out, s), tail);
    }
    case "%": {
      parse_bump(p);
      const e0 = parse_term(p);
      parse_skip(p);
      let k = "";
      let e = e0;
      if (parse_take(p, "@")) {
        if (e0.$ !== "Var") {
          parse_fail(p, "a name before @ (a rewrite binder is one name: %e@E : P)");
        }
        k = e0.k;
        e = parse_term(p);
      }
      parse_eat(p, ":");
      const n0 = p.stk.length;
      const xi = p.frs++;
      p.stk.push(["_", xi]);
      const ei = parse_open(p, k);
      const P = parse_term(p);
      parse_close(p, n0);
      parse_skip(p);
      parse_take(p, ";");
      const f = parse_block(p);
      const s = parse_span(p, beg);
      return Rwt(e, Lam("_", xi, Lam(k, ei, P, e0.s), s), f, s);
    }
    case "{": {
      parse_bump(p);
      parse_skip(p);
      if (parse_take(p, "==")) {
        parse_eat(p, "}");
        return Rfl();
      }
      const a = parse_term(p);
      parse_skip(p);
      const ne = parse_take(p, "!=");
      const ns = parse_span(p, p.pos - 2);
      const b = ne || parse_take(p, "==") ? parse_term(p) : null;
      parse_eat(p, ":");
      const T = parse_term(p);
      parse_eat(p, "}");
      if (b === null) {
        return Ann(a, T);
      }
      if (!ne) {
        return Eql(a, b, T);
      }
      const s = parse_span(p, beg);
      return All(Lone(), "_", parse_open(p, "_"), Eql(a, b, T, s), Ref("Empty", ns), s);
    }
    case "(": {
      parse_bump(p);
      return parse_term_tup(p, beg);
    }
    case "[": {
      parse_bump(p);
      parse_skip(p);
      const xs = parse_at(p, "]") ? [] : [parse_term(p)];
      parse_skip(p);
      if (xs.length !== 0 && parse_take(p, ":")) {
        const T = parse_term(p, 12);
        parse_skip(p);
        const cnt = parse_take(p, "*");
        if (!cnt) {
          parse_eat(p, "^");
        }
        const n = parse_term(p);
        parse_eat(p, "]");
        const s = parse_span(p, beg);
        parse_term_ns(p, xs[0], T);
        let d = n;
        if (cnt) {
          const k = Math.log2(nat_from_term(n) ?? 0);
          if (!Number.isInteger(k)) {
            throw Err(p.book, ctx_nil(), "a power of two count (^d takes a depth)", undefined, n.s);
          }
          d = Lit("Nat", k, n.s);
        }
        return App(App(App(Ref("Array.new", s), T, s), d, s), xs[0], s);
      }
      parse_take(p, ",");
      const ys = xs.concat(parse_term_args(p, "]"));
      const spn = parse_span(p, beg);
      return ys.reduceRight((t, x) => Ctr("Con", [x, t], spn), Ctr("Nil", [], spn));
    }
    case "'": {
      parse_bump(p);
      const n = parse_char(p);
      if (!parse_take(p, "'")) {
        parse_fail(p, "a closing '");
      }
      const spn = parse_span(p, beg);
      return Ctr("Chr", [Lit("U32", n, spn)], spn);
    }
    case '"': {
      parse_bump(p);
      const cs = [];
      while (!parse_take(p, '"')) {
        if (p.pos >= p.str.length) {
          parse_fail(p, 'a closing "');
        }
        cs.push(parse_char(p));
      }
      return lit_of(cs, parse_span(p, beg));
    }
    case "?": {
      parse_bump(p);
      const k = parse_name(p);
      if (k === "TODO") {
        p.book.hols += 1;
      }
      return Hol(k);
    }
    default: {
      parse_fail(p, "a term");
    }
  }
}
var INFIX = {
  "<-": [-1, false, ""],
  "->": [0, true, ""],
  "&": [1, true, "Pair"],
  "|": [1, true, "Or"],
  "||": [2, false, "Bool.or"],
  "&&": [3, false, "Bool.and"],
  "<": [4, false, ".is_lt"],
  "<=": [4, false, ".is_le"],
  ">": [4, false, ".is_gt"],
  ">=": [4, false, ".is_ge"],
  "<>": [5, true, "Con"],
  "++": [5, true, "String.append"],
  "<&>": [5, true, ""],
  ".|.": [6, false, ".or"],
  ".^.": [7, false, ".xor"],
  ".&.": [8, false, ".and"],
  "<<": [9, false, ".shln"],
  ">>": [9, false, ".shrn"],
  "+": [10, false, ".add"],
  "-": [10, false, ".sub"],
  "*": [11, false, ".mul"],
  "/": [11, false, ".div"],
  "%": [11, false, ".mod"]
};
function parse_nl(p) {
  for (let j = p.pos - 1;j >= 0; j--) {
    const c = p.str[j];
    if (c === `
`) {
      return true;
    }
    if (c !== " " && c !== "\r" && c !== "\t") {
      return false;
    }
  }
  return true;
}
function parse_term_ops(p, tm, beg, lvl) {
  let out = tm;
  while (true) {
    parse_skip(p);
    if (parse_nl(p) && (parse_at(p, "(") || parse_at(p, "["))) {
      return out;
    }
    if (parse_at(p, "(") || parse_at(p, "!(")) {
      if (out.$ === "Var" && out.v !== undefined) {
        out = out.v;
      }
      if (parse_at(p, "!")) {
        if (out.$ !== "Ref") {
          parse_fail(p, "a named def before ! (only f!(..) offloads)");
        }
        parse_bump(p);
        out.b = true;
        continue;
      }
      parse_bump(p);
      const hd = p.book.tlds[out.$ === "Ref" ? out.k : ""];
      const x = hd?.$ === "Def" ? hd.x : 0;
      const ts = [];
      for (parse_skip(p);x > 0 && parse_at(p, "~"); parse_skip(p)) {
        if (ts.length === x) {
          parse_fail(p, "a term (" + name_key(out.k) + " takes " + String(x) + " ~)");
        }
        parse_bump(p);
        ts.push(parse_term(p));
        parse_skip(p);
        parse_take(p, ",");
      }
      const xs = ts.concat(parse_term_args(p, ")"));
      const s2 = parse_span(p, beg);
      for (const a of xs) {
        out = App(out, a, s2);
      }
      continue;
    }
    if (parse_at(p, "[")) {
      parse_bump(p);
      const ix = parse_term(p);
      parse_eat(p, "]");
      const s2 = parse_span(p, beg);
      parse_term_ns(p, ix, Ref("U32", s2));
      parse_skip(p);
      if (!parse_nl(p) && parse_take(p, "<-")) {
        const v = parse_term(p, 2);
        out = App(App(App(App(Ref("Array.set", s2), Ref("U32", s2), s2), out, s2), ix, s2), v, s2);
      } else {
        out = App(App(App(Ref("Array.get", s2), Ref("U32", s2), s2), out, s2), ix, s2);
      }
      continue;
    }
    if (lvl === 0 && parse_take(p, "=>")) {
      const n0 = p.stk.length;
      const x = parse_bind(p, out);
      const f = parse_block(p);
      parse_close(p, n0);
      out = Lam(x.k, x.i, f, x.s, x.q);
      continue;
    }
    let op = p.str.slice(p.pos, p.pos + 3);
    while (op !== "" && INFIX[op] === undefined) {
      op = op.slice(0, -1);
    }
    if (op === "") {
      return out;
    }
    const [prc, right, k] = INFIX[op];
    const nx = p.str[p.pos + op.length] ?? "";
    const gl = /\S/.test(p.str[p.pos - 1] ?? "");
    if (prc < lvl && !(op === "<" && gl) || (op === "-" || op === "+") && (nx === ">" || char_is_head(nx)) || op[0] === ">" && gl || op === "%" && !/\s/.test(nx)) {
      return out;
    }
    p.pos += op.length;
    const t = parse_span(p, p.pos - op.length);
    const b = parse_term(p, right ? prc : prc + 1);
    const s = parse_span(p, beg);
    parse_skip(p);
    if (op === "<" && gl && /^(->|[&|](?![&|]))/.test(p.str.slice(p.pos, p.pos + 2))) {
      parse_fail(p, "'>' or ',' (a compound type argument takes parens: F<(A & B)>)");
    }
    if (op === "<" && (parse_at(p, ">") || parse_at(p, ","))) {
      if (out.$ !== "Var" && out.$ !== "Ref") {
        parse_fail(p, "a family name before <..> (a comparison here needs parens)");
      }
      parse_take(p, ",");
      const d = parse_reso(p, out.k);
      out = ADT(d, parse_fill(p, d, [b, ...parse_term_args(p, ">")], s), s);
    } else if (op === "->") {
      out = All(Lone(), "_", parse_open(p, "_"), out, b, s);
    } else if (op === "<&>") {
      out = Min(out, b, s);
    } else if (op === "<>") {
      out = Ctr(k, [out, b], s);
    } else if (op === "&" || op === "|") {
      out = App(App(Ref(k, s), out, s), b, s);
    } else {
      out = App(App(Ref(k, t), out, s), b, s);
    }
  }
}
function parse_term_ns(p, tm, T) {
  if (tm.$ === "Let") {
    return parse_term_ns(p, tm.f, T);
  }
  const [f, xs] = term_unapply(tm);
  if (f.$ !== "Ref") {
    return;
  }
  if (f.k.lastIndexOf(".") === 0) {
    const h = term_unapply(T)[0];
    if (h.$ !== "Var" && h.$ !== "Ref" && h.$ !== "ADT") {
      throw Err(p.book, ctx_nil(), "a type name after : (the operators' namespace)", undefined, h.s);
    }
    f.k = parse_reso(p, h.k + f.k);
  } else if (f.k !== "Bool.and" && f.k !== "Bool.or" && f.k !== "String.append") {
    return;
  }
  for (const x of xs) {
    parse_term_ns(p, x, T);
  }
}
function parse_term_args(p, close) {
  const xs = [];
  while (true) {
    parse_skip(p);
    if (parse_take(p, close)) {
      return xs;
    }
    const x = parse_term(p);
    xs.push(x);
    parse_skip(p);
    parse_take(p, ",");
  }
}
function parse_term_all(p, exi) {
  const beg = p.pos;
  parse_bump(p);
  const q = exi ? Lone() : parse_quant(p);
  const k = parse_name(p);
  parse_eat(p, ":");
  const A = parse_term(p, 1);
  parse_eat(p, "->");
  const n0 = p.stk.length;
  const i = parse_open(p, k);
  const B = parse_term(p);
  parse_close(p, n0);
  if (exi) {
    const s = parse_span(p, beg);
    return App(App(Ref("Exists", s), A, s), Lam(k, i, B, s), s);
  }
  return All(q, k, i, A, B);
}
function parse_term_tup(p, beg) {
  parse_skip(p);
  const b = parse_body(p, parse_col(p.str, p.pos) - 1);
  parse_skip(p);
  if (b.$ !== "Match" && b.$ !== "Local" && parse_take(p, ",")) {
    const rest = parse_term_tup(p, beg);
    return Ctr("Tuple", [b, rest], parse_span(p, beg));
  }
  const out = body_flatten(b, [], () => p.frs++);
  if (parse_take(p, ":")) {
    parse_term_ns(p, out, parse_term(p));
  }
  parse_eat(p, ")");
  return out;
}
var NUMBER = /(\d+)(n|\.\d+([eE][+-]?\d+)?)?/y;
function parse_term_num(p) {
  const beg = p.pos;
  NUMBER.lastIndex = p.pos;
  const m = NUMBER.exec(p.str);
  const n = Number(m[1]);
  p.pos += m[0].length;
  if (m[2] !== undefined && m[2] !== "n") {
    const v = f32_round(m[0]);
    if (!isFinite(v)) {
      parse_fail(p, "a float literal with a finite f32 value (got " + m[0] + ")", beg);
    }
    return Lit("F32", f32_to_bits(v));
  }
  if (m[2] === undefined) {
    if (char_is_name(parse_peek(p))) {
      parse_fail(p, "a numeric literal (NUMBER is U32, NUMBER n is Nat)");
    }
    if (n > 4294967295) {
      parse_fail(p, "a u32 literal up to 4294967295 (got " + m[1] + ")", beg);
    }
    return Lit("U32", n);
  }
  if (n > 4294967295) {
    parse_fail(p, "a nat literal up to 4294967295n (got " + m[1] + "n)");
  }
  if (parse_take(p, "+")) {
    let out = parse_term(p);
    const spn = parse_span(p, beg);
    if (out.$ === "Lit" && out.k === "Nat" && n + out.v <= 4294967295) {
      return Lit("Nat", n + out.v, spn);
    }
    if (n > NAT_LITERAL_MAX) {
      return App(App(Ref("Nat.add", spn), Lit("Nat", n, spn), spn), out, spn);
    }
    for (let i = 0;i < n; i++) {
      out = Ctr("Succ", [out], spn);
    }
    return out;
  }
  if (char_is_name(parse_peek(p))) {
    parse_fail(p, "a nat literal (NUMBER n)");
  }
  return Lit("Nat", n);
}
function parse_fill(p, k, xs, s) {
  const tld = p.book.tlds[k];
  return tld?.$ !== "ADT" || xs.length + tld.g !== tld.n ? xs : Array.from({ length: tld.g }, () => Qua(Lone(), s)).concat(xs);
}
function parse_term_do_stmt(p, m, ts, col) {
  parse_skip(p);
  const beg = p.pos;
  if (parse_word(p, "return")) {
    const e = parse_term(p);
    return parse_call(p, m + ".pure", [...ts, e], parse_span(p, beg));
  }
  const t = parse_term(p);
  parse_skip(p);
  const typed = t.$ === "Var" && parse_take(p, ":");
  const step = !typed && parse_more(p, col);
  const A = typed ? parse_term(p, 1) : step ? parse_var(p, "Unit", t.s) : t;
  parse_skip(p);
  const asg = typed && !parse_at(p, "==") && parse_take(p, "=");
  if (typed && !asg) {
    parse_eat(p, "<-");
  } else if (!typed && !step && !parse_take(p, "<-")) {
    const k = parse_reso(p, m);
    return Ann(t, p.book.tlds[k]?.$ === "ADT" ? ADT(k, ts, t.s) : parse_call(p, m, ts, t.s), t.s);
  }
  const v = step ? t : parse_term(p);
  parse_skip(p);
  parse_take(p, ";");
  const s = parse_span(p, beg);
  const n0 = p.stk.length;
  const x = parse_bind(p, typed ? t : Var("_", 0));
  const f = parse_term_do_stmt(p, m, ts, col);
  parse_close(p, n0);
  if (asg) {
    return Let([x.k], [x.i], [Ann(v, A, s)], f, s, [x.q]);
  }
  return parse_call(p, m + ".bind", [...ts.slice(0, -1), A, ...ts.slice(-1), v, Lam(x.k, x.i, f, s, x.q)], s);
}
function parse_body(p, col = 0) {
  parse_skip(p);
  const beg = p.pos;
  if (parse_word(p, "match")) {
    const es = parse_terms(p);
    parse_skip(p);
    const ccol = parse_col(p.str, p.pos);
    const rows = [];
    while (ccol > col && parse_at_word(p, "case") && parse_col(p.str, p.pos) >= ccol) {
      const rcol = parse_col(p.str, p.pos);
      parse_word(p, "case");
      parse_skip(p);
      const qbeg = p.pos;
      const qs = parse_terms(p);
      if (qs.length !== es.length) {
        parse_fail(p, String(es.length) + " patterns (one per scrutinee)", qbeg, p.pos - 1);
      }
      const n02 = p.stk.length;
      const pp = qs.map((q2) => parse_patt(p, q2));
      const f2 = parse_body(p, rcol);
      parse_close(p, n02);
      rows.push({ p: pp, f: f2 });
    }
    return { $: "Match", e: es, r: rows, s: parse_span(p, beg) };
  }
  const q = parse_take(p, "-") ? None() : Lone();
  const vs = [];
  let ts = [q.$ === "None" ? Var(parse_name(p), 0, parse_span(p, beg)) : parse_term(p)];
  parse_skip(p);
  while (!parse_nl(p) && (char_is_head(parse_peek(p)) || q.$ === "Lone" && parse_at(p, "+")) && !KEYWORDS.has(p.str.slice(p.pos).match(/^[A-Za-z0-9_.]*/)?.[0] ?? "")) {
    ts.push(parse_term(p));
    parse_skip(p);
  }
  const at = p.pos;
  let T = ts.length === 1 && parse_take(p, ":") ? parse_term(p) : null;
  parse_skip(p);
  if (T !== null && !parse_at(p, "=")) {
    [p.pos, T] = [at, null];
  }
  if (T === null && q.$ === "Lone" && ts.length === 1 && !(parse_at(p, "=") && !parse_at(p, "=="))) {
    const w = term_write(ts[0]);
    if (w === null || !parse_more(p, parse_col(p.str, beg))) {
      return ts[0];
    }
    vs.push(ts[0]);
    ts = [w];
  } else {
    parse_eat(p, "=");
    T !== null && vs.push(Ann(parse_term(p), T, parse_span(p, beg)));
  }
  while (vs.length < ts.length) {
    vs.push(parse_term(p));
  }
  parse_skip(p);
  parse_take(p, ";");
  const n0 = p.stk.length;
  const ks = ts.map((x) => {
    if ((ts.length > 1 || T !== null) && x.$ !== "Var") {
      throw Err(p.book, ctx_nil(), "a name (a parallel or typed let binds names; destructure in its body)", undefined, x.s);
    }
    return parse_patt(p, x);
  });
  const f = parse_body(p, col);
  parse_close(p, n0);
  return { $: "Local", k: ks, q, v: vs, f };
}
function term_write(t) {
  const [h, xs] = term_unapply(t);
  if (h.$ === "Ref" && h.k === "Array.set" && xs.length === 4 && xs[1].$ === "Var") {
    return xs[1];
  }
  return null;
}
function parse_more(p, col) {
  return parse_at(p, ";") || p.pos < p.str.length && parse_col(p.str, p.pos) === col;
}
function parse_block(p) {
  parse_skip(p);
  const b = parse_body(p, parse_col(p.str, p.pos) - 1);
  return body_flatten(b, [], () => p.frs++);
}
function parse_terms(p) {
  const xs = [];
  while (true) {
    xs.push(parse_term(p));
    parse_skip(p);
    if (parse_take(p, ":")) {
      return xs;
    }
    parse_take(p, ",");
  }
}
function parse_tele(p, close, tk = []) {
  const tele = [];
  while (true) {
    parse_skip(p);
    if (parse_take(p, close)) {
      return tele;
    }
    if (close === ")" && parse_at(p, "~") && tk.length < tele.length) {
      parse_fail(p, "a plain binder (only leading binders take ~)");
    }
    const ct = close === ")" && parse_take(p, "~");
    const q = ct ? None() : parse_quant(p);
    const beg = p.pos;
    const k = parse_name(p);
    if (close === "}" && tele.some((cell) => cell[1] === k)) {
      parse_fail(p, "a fresh field name (duplicate declaration: " + k + ")", p.pos - k.length);
    }
    const s = parse_span(p, beg);
    parse_skip(p);
    const bare = q.$ === "Lone" && !parse_at(p, ":");
    if (!bare) {
      parse_eat(p, ":");
    }
    const T = bare ? Qnt(s) : parse_term(p);
    if (ct) {
      tk.push(k);
    }
    tele.push([bare ? None() : q, k, parse_open(p, k), T, s]);
    parse_skip(p);
    parse_take(p, ",");
  }
}
function parse_fresh(p, nm, tab = p.book.tlds, what = "a fresh name") {
  const k = parse_qual(p, nm);
  const a = nm.includes(".") ? nm.slice(0, nm.indexOf(".")) : "";
  if (k in tab || nm in tab || a in p.al) {
    parse_fail(p, what + " (" + (a in p.al ? a + " is an import's alias" : "duplicate declaration: " + nm) + ")", p.pos - nm.length);
  }
  return k;
}
function parse_def(p, u) {
  const book = p.book;
  const nm = parse_name(p);
  const q = parse_reso(p, nm);
  const tld = book.tlds[q];
  const law = tld?.$ === "Def" && tld.v === null && tld.b !== true && !tld.i ? tld : undefined;
  const k = law ? q : parse_fresh(p, nm);
  const un = parse_take(p, "?") || u;
  parse_eat(p, "(");
  parse_skip(p);
  if (law && parse_at(p, "~")) {
    parse_fail(p, "a name");
  }
  const tk = [];
  const tele = parse_tele(p, ")", tk);
  parse_skip(p);
  let def;
  if (law) {
    if (tele.some((cell) => cell[3].$ !== "Qnt")) {
      parse_fail(p, "a name");
    }
    if (tele.length < law.x) {
      parse_fail(p, "a name for each ~ clause of the law (" + String(law.x) + ")");
    }
    def = law;
    def.n = tele.length;
  } else {
    if (!parse_take(p, "->")) {
      parse_fail(p, "'->' (a def with no return type fills a law; no law named " + nm + " is in scope)");
    }
    def = book.tlds[k] = { $: "Def", n: tele.length, x: tk.length, T: term_higher(tele_bind(tele, parse_term(p))), v: null, m: p.ns };
  }
  def.u ||= un;
  parse_eat(p, ":");
  if (parse_at_word(p, "import")) {
    if (def.x > 0) {
      parse_fail(p, "a body (a template is not foreign)");
    }
    def.i = [];
    while (parse_word(p, "import")) {
      parse_eat(p, '"');
      let eff = "";
      while (parse_peek(p) !== '"' && parse_peek(p) !== "") {
        eff += parse_bump(p);
      }
      parse_eat(p, '"');
      if (!/\.(c|js)$/.test(eff)) {
        parse_fail(p, "a .c or .js path");
      }
      def.i.push(p.dir + eff);
    }
  } else {
    const vars = tele.map((cell) => ({ $: "PVar", k: cell[1], i: cell[2], q: Lone(), s: cell[4] }));
    def.v = term_higher(term_lower(term_higher(body_flatten(parse_body(p), vars, () => p.frs++))));
  }
  book.order.push(k);
}
function parse_book(book, dir, src, ns, al) {
  const p = { book, dir, str: src, pos: 0, stk: [], frs: 0, ns, al };
  while (true) {
    parse_skip(p);
    if (p.pos >= p.str.length) {
      return;
    }
    p.frs = 0;
    parse_close(p, 0);
    if (parse_take(p, "@")) {
      if (!parse_word(p, "unsafe")) {
        parse_fail(p, "'unsafe' (the one decorator)");
      }
      if (!parse_word(p, "def")) {
        parse_fail(p, "'def' (@unsafe marks the def below it)");
      }
      parse_def(p, true);
      continue;
    }
    if (parse_word(p, "def")) {
      parse_def(p, false);
      continue;
    }
    if (parse_word(p, "type")) {
      const k = parse_fresh(p, parse_name(p));
      parse_skip(p);
      const params = parse_take(p, "<") ? parse_tele(p, ">") : [];
      if (!parse_word(p, "is")) {
        parse_fail(p, "'is'");
      }
      const K = parse_term(p);
      parse_eat(p, ":");
      const cs = [];
      const g = params.findIndex((cell) => cell[3].$ !== "Qnt");
      book.tlds[k] = { $: "ADT", n: params.length, g: g < 0 ? params.length : g, T: term_higher(tele_bind(params, K)), c: cs };
      while (true) {
        parse_skip(p);
        if (!char_is_head(parse_peek(p)) || ["def", "type", "law"].some((w) => parse_at_word(p, w))) {
          break;
        }
        const c = parse_fresh(p, parse_name(p), book.ctrs, "a fresh constructor name");
        parse_eat(p, "{");
        const n1 = p.stk.length;
        const fs2 = parse_tele(p, "}");
        const tip = ADT(k, params.map((cell) => Var(cell[1], cell[2])));
        const ctr = { k: c, n: fs2.length, T: term_higher(tele_bind(params.concat(fs2), tip)) };
        parse_close(p, n1);
        cs.push(ctr);
        book.ctrs[c] = ctr;
      }
      book.order.push(k);
      continue;
    }
    if (parse_word(p, "law")) {
      const k = parse_fresh(p, parse_name(p));
      parse_eat(p, ":");
      const cls = [];
      let tc = 0;
      while (parse_at_word(p, "for") || parse_at_word(p, "exs")) {
        const all = parse_word(p, "for");
        if (!all) {
          parse_word(p, "exs");
        }
        parse_skip(p);
        if (all && parse_at(p, "~") && tc < cls.length) {
          parse_fail(p, "a plain clause (only leading clauses take ~)");
        }
        const ct = all && parse_take(p, "~");
        const q = ct ? None() : all ? parse_quant(p) : Lone();
        const beg = p.pos;
        const c = parse_name(p);
        const s = parse_span(p, beg);
        if (ct) {
          tc += 1;
        }
        parse_eat(p, ":");
        let A = parse_term(p);
        if (parse_at_word(p, "where")) {
          const beg2 = p.pos;
          parse_word(p, "where");
          const ws = parse_span(p, beg2);
          const n1 = p.stk.length;
          const i = parse_open(p, c);
          const w = parse_term(p);
          parse_close(p, n1);
          A = App(App(Ref("Exists", ws), A, s), Lam(c, i, w, s), s);
        }
        cls.push([all, q, c, parse_open(p, c), A, s]);
      }
      const T = cls.reduceRight((T2, [all, q, c, i, A, s]) => all ? All(q, c, i, A, T2, s) : App(App(Ref("Exists", s), A, s), Lam(c, i, T2, s), s), parse_block(p));
      const n = cls.findIndex((c) => !c[0]);
      book.tlds[k] = { $: "Def", n: n < 0 ? cls.length : n, T: term_higher(T), v: null, x: tc, m: p.ns };
      book.order.push(k);
      continue;
    }
    parse_fail(p, "'def', 'type' or 'law'");
  }
}
function body_sub(b, i, v) {
  function scrut(e) {
    if (e.$ === "Var") {
      return e.i !== i ? e : patt_term(v, e.s);
    } else {
      return Sub(i, v, e);
    }
  }
  switch (b.$) {
    case "Match": {
      const es = b.e.map(scrut);
      const rs = b.r.map((row) => ({ p: row.p, f: body_sub(row.f, i, v) }));
      return { $: "Match", e: es, r: rs, s: b.s };
    }
    case "Local": {
      const w = b.v.map(scrut);
      const f = body_sub(b.f, i, v);
      return { $: "Local", k: b.k, q: b.q, v: w, f };
    }
    default: {
      return Sub(i, v, b);
    }
  }
}
function match_flatten(m, vars, fr) {
  if (m.e.length === 0 && m.r.length > 0) {
    return body_flatten(m.r[0].f, vars, fr);
  } else if (m.e.length === 0) {
    throw Err(book_nil(), ctx_nil(), "a case (this match has no row to return)", undefined, m.s);
  } else if (vars.length === 0) {
    let e = m.e[0];
    while (e.$ === "Sub") {
      e = e.f;
    }
    switch (e.$) {
      case "Var": {
        const x = e.s === undefined ? e.k : e.s.file.str.slice(e.s.beg, e.s.end);
        throw Err(book_nil(), ctx_nil(), "'" + x + "' can't be matched in this position" + " (it is matched after a local statement or after a match on a later binder," + " it was already matched, or it is a def)", undefined, e.s);
      }
      case "Ctr":
      case "Lit": {
        throw Err(book_nil(), ctx_nil(), "an undestructed scrutinee (this value is already a constructor: bind its fields directly; if an outer match destructed it, fold the pattern into the outer case)", undefined, m.s);
      }
      default: {
        throw Err(book_nil(), ctx_nil(), "a parameter or field scrutinee (a match cannot scrutinize a computed value: give it its own def)", undefined, e.s ?? m.s);
      }
    }
  } else {
    const x = vars[0];
    const scu = m.e[0];
    const c = m.r.map((row) => row.p[0]).find((q) => q.$ === "PCtr") ?? null;
    const v = vars.find((w) => scu.$ === "Var" && w.i === scu.i);
    if (v !== undefined && c === null && m.r.length > 0) {
      const w = { ...v, q: patt_mark(v, m.r) };
      const rs = m.r.map((row) => {
        const p0 = row.p[0];
        if (p0.$ !== "PVar") {
          throw Err(book_nil(), ctx_nil(), "a variable pattern (this column has no constructor row)", undefined, p0.s);
        }
        return { p: row.p.slice(1), f: body_sub(row.f, p0.i, w) };
      });
      return match_flatten({ $: "Match", e: m.e.slice(1), r: rs, s: m.s }, vars.map((u) => u === v ? w : u), fr);
    } else if (v === x) {
      if (c === null) {
        return Efq(m.s);
      } else {
        const xq = patt_mark(x, m.r);
        const xs = c.x.map((q) => {
          if (q.$ === "PVar") {
            return { ...q, q: quant_join(q.q, xq) };
          }
          const i = fr();
          return { $: "PVar", k: "_" + String(i), i, q: xq, s: q.s };
        });
        const kx = { $: "PCtr", k: c.k, x: xs, s: x.s };
        const ps = m.r.flatMap((row) => {
          const p0 = row.p[0];
          switch (p0.$) {
            case "PCtr": {
              if (p0.k !== c.k) {
                return [];
              }
              const f = body_sub(row.f, x.i, kx);
              return [{ p: [...p0.x, ...row.p.slice(1)], f }];
            }
            case "PVar": {
              const g = body_sub(row.f, p0.i, x);
              const f = body_sub(g, x.i, kx);
              return [{ p: [...xs, ...row.p.slice(1)], f }];
            }
          }
        });
        const pe = xs.map((q) => patt_term(q)).concat(m.e.slice(1));
        const pv = xs.concat(vars.slice(1));
        const pt = match_flatten({ $: "Match", e: pe, r: ps, s: m.s }, pv, fr);
        const ds = m.r.filter((row) => row.p[0].$ !== "PCtr" || row.p[0].k !== c.k);
        const dt = match_flatten({ $: "Match", e: m.e, r: ds, s: m.s }, vars, fr);
        return Mat(c.k, pt, dt, c.s);
      }
    } else {
      const t = match_flatten(m, vars.slice(1), fr);
      return Lam(x.k, x.i, t, x.s, x.q);
    }
  }
}
function patt_mark(x, rows) {
  return rows.map((row) => row.p[0]).reduce((q, p) => p.$ === "PVar" ? quant_join(q, p.q) : q, x.q);
}
function patt_term(q, s) {
  switch (q.$) {
    case "PVar": {
      return Var(q.k, q.i, s ?? q.s);
    }
    case "PCtr": {
      const xs = q.x.map((x) => patt_term(x, s));
      return Ctr(q.k, xs, s ?? q.s);
    }
  }
}
function body_flatten(b, vars, fr) {
  switch (b.$) {
    case "Local": {
      if (b.k.length === 1 && b.k[0].$ === "PCtr") {
        const r = { p: [b.k[0]], f: b.f };
        return match_flatten({ $: "Match", e: [b.v[0]], r: [r], s: b.v[0].s }, vars, fr);
      }
      const ws = b.k;
      let g = body_flatten(b.f, ws, fr);
      for (const w of ws) {
        if (g.$ !== "Lam") {
          throw Err(book_nil(), ctx_nil(), "a parameter or field scrutinee (a match cannot scrutinize a local binder: give it its own def)", undefined, w.s);
        }
        g = g.f;
      }
      const x = Let(ws.map((w) => w.k), ws.map((w) => w.i), b.v, g, ws[0].s, ws.map((w) => quant_dem(b.q, w.q)));
      return body_flatten(x, vars, fr);
    }
    case "Match": {
      return match_flatten(b, vars, fr);
    }
    default: {
      if (vars.length === 0) {
        return b;
      } else {
        const v = vars[0];
        const f = body_flatten(b, vars.slice(1), fr);
        return Lam(v.k, v.i, f, v.s, v.q);
      }
    }
  }
}
function term_wnf(book, term) {
  const frs = [];
  let tm = term;
  let lhs = null;
  main:
    while (true) {
      focus:
        switch (tm.$) {
          case "Var": {
            if (tm.v === undefined) {
              break focus;
            } else {
              if (tm.i === -1) {
                frs.push({ $: "VAR", l: tm, a: tm.v.$ === "Ann" ? tm.v : undefined });
              }
              lhs = null;
              tm = tm.v;
              continue main;
            }
          }
          case "Ann": {
            tm = tm.x;
            continue main;
          }
          case "Min": {
            frs.push({ $: "MNA", b: tm.b, s: tm.s });
            tm = tm.a;
            continue main;
          }
          case "Let": {
            const l = tm;
            tm = l.f(l.v.map((v, j) => term_cell(v, l.k[j])));
            continue main;
          }
          case "App": {
            frs.push({ $: "APP", x: term_cell(tm.x), s: tm.s });
            lhs = null;
            tm = tm.f;
            continue main;
          }
          case "Lam": {
            if (frs.length === 0 || frs[frs.length - 1].$ !== "APP") {
              break focus;
            } else {
              const fr = frs.pop();
              if (lhs !== null && lhs.n === 0) {
                lhs = null;
              } else if (lhs !== null) {
                const pt = lhs.t;
                const pn = lhs.n;
                lhs = { t: () => term_apply(pt(), fr.x, fr.s), n: pn - 1 };
              }
              tm = tm.f(fr.x);
              continue main;
            }
          }
          case "Mat": {
            if (frs.length === 0 || frs[frs.length - 1].$ !== "APP") {
              break focus;
            } else {
              const fr = frs.pop();
              frs.push({ $: "MAT", t: tm, e: fr.x, lhs, s: fr.s });
              tm = fr.x;
              lhs = null;
              continue main;
            }
          }
          case "Efq": {
            if (lhs !== null && lhs.n > 0 && frs.length > 0 && frs[frs.length - 1].$ === "APP") {
              tm = lhs.t();
            }
            break focus;
          }
          case "Rwt": {
            const e = term_wnf(book, tm.e);
            if (e.$ === "Rfl") {
              tm = tm.f;
              continue main;
            }
            break focus;
          }
          case "Ref": {
            const tld = book.tlds[tm.k];
            if (tld === undefined) {
              break focus;
            }
            if (tld.$ === "ADT") {
              if (tld.n === 0) {
                tm = ADT(tm.k, [], tm.s);
              }
              break focus;
            }
            let run = 0;
            while (run < tld.n && run < frs.length && frs[frs.length - 1 - run].$ === "APP") {
              run += 1;
            }
            if (run < tld.n || tld.v === null) {
              break focus;
            }
            const rf = tm;
            lhs = { t: () => rf, n: tld.n };
            tm = tld.v;
            continue main;
          }
          default: {
            break focus;
          }
        }
      lhs = null;
      back:
        while (true) {
          const fr = frs.pop();
          if (fr === undefined) {
            return tm;
          } else {
            switch (fr.$) {
              case "VAR": {
                switch (tm.$) {
                  case "Ctr":
                    tm = Ctr(tm.k, tm.x.map((x) => term_cell(x)), tm.s);
                    break;
                  case "ADT":
                    tm = ADT(tm.k, tm.x.map((x) => term_cell(x)), tm.s, tm.r);
                    break;
                  case "All":
                    tm = All(tm.q, tm.k, tm.i, term_cell(tm.A), tm.B, tm.s);
                    break;
                  case "Mat":
                    tm = Mat(tm.k, term_cell(tm.h), term_cell(tm.m), tm.s);
                    break;
                  case "Eql":
                    tm = Eql(term_cell(tm.a), term_cell(tm.b), term_cell(tm.T), tm.s);
                    break;
                  case "Min":
                    tm = Min(term_cell(tm.a), term_cell(tm.b), tm.s);
                    break;
                  case "Typ":
                    tm = Typ(term_cell(tm.g), tm.s);
                    break;
                  default:
                    break;
                }
                fr.l.v = fr.a === undefined ? tm : Ann(tm, term_cell(fr.a.T), fr.a.s);
                fr.l.i = -2;
                continue main;
              }
              case "APP": {
                tm = term_apply(tm, fr.x, fr.s);
                continue back;
              }
              case "MNA": {
                if (tm.$ === "Qua" && tm.q.$ === "Many") {
                  tm = fr.b;
                  continue main;
                }
                if (tm.$ === "Qua" && tm.q.$ === "None") {
                  continue back;
                }
                frs.push({ $: "MNB", a: tm, s: fr.s });
                tm = fr.b;
                continue main;
              }
              case "MNB": {
                if (tm.$ === "Qua" && tm.q.$ === "Many") {
                  tm = fr.a;
                } else if (tm.$ !== "Qua" || tm.q.$ === "Lone" && fr.a.$ !== "Qua") {
                  tm = Min(fr.a, tm, fr.s);
                }
                continue back;
              }
              case "MAT": {
                if (tm.$ === "Lit") {
                  tm = lit_step(tm);
                }
                if (tm.$ === "Ctr") {
                  const ctr = tm;
                  let t = fr.t;
                  walk:
                    while (true) {
                      switch (t.$) {
                        case "Ann": {
                          t = t.x;
                          continue walk;
                        }
                        case "Mat": {
                          if (t.k === ctr.k) {
                            const fl = fr.lhs;
                            if (fl === null) {
                              lhs = null;
                            } else {
                              lhs = { t: () => lhs_ext(fl.t(), ctr.k, ctr.x.length), n: fl.n - 1 + ctr.x.length };
                            }
                            for (let j = ctr.x.length - 1;j >= 0; j--) {
                              frs.push({ $: "APP", x: term_cell(ctr.x[j]) });
                            }
                            tm = t.h;
                            continue main;
                          } else {
                            t = t.m;
                            continue walk;
                          }
                        }
                        case "Efq": {
                          break walk;
                        }
                        default: {
                          lhs = fr.lhs;
                          frs.push({ $: "APP", x: ctr });
                          tm = t;
                          continue main;
                        }
                      }
                    }
                }
                tm = term_apply(fr.lhs === null ? fr.t : fr.lhs.t(), fr.e, fr.s);
                continue back;
              }
            }
          }
        }
    }
}
function term_snf(book, term) {
  const tm = term_wnf(book, term);
  switch (tm.$) {
    case "Typ": {
      return Typ(term_snf(book, tm.g), tm.s);
    }
    case "Min": {
      return Min(term_snf(book, tm.a), term_snf(book, tm.b), tm.s);
    }
    case "All": {
      return All(tm.q, tm.k, tm.i, term_snf(book, tm.A), (x) => {
        return term_snf(book, tm.B(x));
      }, tm.s);
    }
    case "Lam": {
      return Lam(tm.k, tm.i, (x) => {
        return term_snf(book, tm.f(x));
      }, tm.s);
    }
    case "App": {
      return App(tm.f.$ === "Ref" ? tm.f : term_snf(book, tm.f), term_snf(book, tm.x), tm.s);
    }
    case "ADT": {
      return ADT(tm.k, tm.x.map((x) => term_snf(book, x)), tm.s, tm.r);
    }
    case "Ctr": {
      return Ctr(tm.k, tm.x.map((x) => term_snf(book, x)), tm.s);
    }
    case "Mat": {
      return Mat(tm.k, term_snf(book, tm.h), term_snf(book, tm.m), tm.s);
    }
    case "Eql": {
      return Eql(term_snf(book, tm.a), term_snf(book, tm.b), term_snf(book, tm.T), tm.s);
    }
    case "Rwt": {
      return Rwt(term_snf(book, tm.e), term_snf(book, tm.p), term_snf(book, tm.f), tm.s);
    }
    default: {
      return tm;
    }
  }
}
var RIGID = book_nil();
function term_compare(mode, book, lhs, rhs, dep = 0) {
  return compare_go(mode, RIGID, lhs, rhs, dep) || compare_go(mode, book, lhs, rhs, dep);
}
function compare_go(mode, book, lhs, rhs, dep) {
  if (lhs === rhs) {
    return true;
  }
  let a = term_wnf(book, lhs);
  let b = term_wnf(book, rhs);
  if (a === b) {
    return true;
  }
  if (mode === "EQ" && lhs.$ === "Var" && lhs.i === -2 && rhs.$ === "Var" && rhs.i === -2) {
    const same = compare_go(mode, book, a, b, dep);
    if (same) {
      rhs.v = lhs.v;
    }
    return same;
  }
  if (a.$ === "Lam" || b.$ === "Lam") {
    const x = Var("_", dep);
    return compare_go(mode, book, term_apply(a, x), term_apply(b, x), dep + 1);
  }
  if (a.$ === "Lit" && b.$ === "Ctr") {
    a = lit_step(a);
  }
  if (b.$ === "Lit" && a.$ === "Ctr") {
    b = lit_step(b);
  }
  switch (a.$) {
    case "Var": {
      return b.$ === "Var" && a.i === b.i;
    }
    case "Ref": {
      if (b.$ !== "Ref" || a.k === b.k) {
        return b.$ === "Ref";
      }
      const n = Math.max(book.tlds[a.k]?.n ?? 0, book.tlds[b.k]?.n ?? 0);
      let [f, g] = [a, b];
      for (let j = 0;j < n; j++) {
        [f, g] = [App(f, Var("_", dep + j)), App(g, Var("_", dep + j))];
      }
      return n > 0 && compare_go(mode, book, f, g, dep + n);
    }
    case "Typ": {
      if (b.$ !== "Typ") {
        return false;
      }
      if (mode === "EQ") {
        return compare_go("EQ", book, a.g, b.g, dep);
      }
      const g = term_wnf(book, a.g);
      const h = term_wnf(book, b.g);
      if (g.$ === "Qua" && g.q.$ === "Many" || h.$ === "Qua" && h.q.$ !== "Many") {
        return true;
      }
      if (g.$ === "Min") {
        const fa = compare_go("LE", book, Typ(g.a), b, dep);
        const fb = compare_go("LE", book, Typ(g.b), b, dep);
        return fa && fb;
      }
      if (h.$ === "Min") {
        const fa = compare_go("LE", book, a, Typ(h.a), dep);
        const fb = compare_go("LE", book, a, Typ(h.b), dep);
        return fa || fb;
      }
      return compare_go("LE", book, g, h, dep);
    }
    case "Qnt":
    case "Efq":
    case "Rfl": {
      return b.$ === a.$;
    }
    case "Qua": {
      return b.$ === "Qua" && a.q.$ === b.q.$;
    }
    case "Min": {
      return b.$ === "Min" && compare_go("EQ", book, a.a, b.a, dep) && compare_go("EQ", book, a.b, b.b, dep);
    }
    case "All": {
      const x = Var(a.k, dep);
      return b.$ === "All" && a.q.$ === b.q.$ && compare_go(mode, book, b.A, a.A, dep) && compare_go(mode, book, a.B(x), b.B(x), dep + 1);
    }
    case "App": {
      if (b.$ !== "App") {
        return false;
      }
      const head = a.f.$ === "Ref" && b.f.$ === "Ref" ? a.f.k === b.f.k : compare_go("EQ", book, a.f, b.f, dep);
      return head && compare_go("EQ", book, a.x, b.x, dep);
    }
    case "ADT": {
      if (b.$ !== "ADT" || a.k !== b.k || a.x.length !== b.x.length) {
        return false;
      }
      if (mode === "EQ" && a.r.length !== b.r.length) {
        return false;
      }
      return b.r.every((c) => a.r.includes(c)) && a.x.every((x, j) => compare_go("EQ", book, x, b.x[j], dep));
    }
    case "Ctr": {
      return b.$ === "Ctr" && a.k === b.k && a.x.length === b.x.length && a.x.every((x, j) => compare_go("EQ", book, x, b.x[j], dep));
    }
    case "Lit": {
      return b.$ === "Lit" && a.k === b.k && a.v === b.v;
    }
    case "Mat": {
      return b.$ === "Mat" && a.k === b.k && compare_go("EQ", book, a.h, b.h, dep) && compare_go("EQ", book, a.m, b.m, dep);
    }
    case "Eql": {
      return b.$ === "Eql" && compare_go("EQ", book, a.a, b.a, dep) && compare_go("EQ", book, a.b, b.b, dep) && compare_go("EQ", book, a.T, b.T, dep);
    }
    case "Hol": {
      return b.$ === "Hol" && a.k === b.k;
    }
    case "Rwt": {
      return b.$ === "Rwt" && compare_go("EQ", book, a.e, b.e, dep) && compare_go("EQ", book, a.p, b.p, dep) && compare_go("EQ", book, a.f, b.f, dep);
    }
    default: {
      return false;
    }
  }
}
function term_descend(q, arg, col) {
  if (q.$ === "None") {
    return "EQ";
  }
  const s = term_strip(arg);
  const p = term_strip(col);
  const a = s.$ === "Lit" && p.$ === "Ctr" ? lit_step(s) : s;
  switch (p.$) {
    case "Var": {
      if (a.$ === "Var" && a.i === p.i) {
        return "EQ";
      } else {
        return "GT";
      }
    }
    case "Ctr": {
      let bad = -1;
      if (a.$ === "Ctr" && a.k === p.k && a.x.length === p.x.length) {
        let ord = "EQ";
        for (let j = 0;j < a.x.length && bad < 0; j++) {
          const fld = term_descend(Lone(), a.x[j], p.x[j]);
          ord = fld === "EQ" ? ord : fld;
          bad = fld === "GT" ? j : bad;
        }
        if (bad < 0) {
          return ord;
        }
      }
      for (let j = 0;j < p.x.length; j++) {
        if (j !== bad && term_descend(Lone(), a, p.x[j]) !== "GT") {
          return "LT";
        }
      }
      return "GT";
    }
    default: {
      return "GT";
    }
  }
}
function term_infer(book, lhs, tm, qt, ctx, d, sp = []) {
  switch (tm.$) {
    case "Var": {
      if (tm.i < 0 && tm.v !== undefined) {
        return term_infer(book, lhs, term_force(tm), qt, ctx, d, sp);
      }
      const ann = pmap_get(ctx, tm.i);
      if (ann === null) {
        throw Err(book, ctx, "a bound variable", tm, tm.s, lhs.def);
      } else {
        return Infer(Var(tm.k, tm.i, tm.s), ann.T, pmap_set(uses_nil(), tm.i, qt));
      }
    }
    case "Ref": {
      const tld = book.tlds[tm.k];
      if (tld === undefined) {
        throw Err(book, ctx, "a defined name", tm, tm.s, lhs.def);
      }
      let k = tm.k;
      let x = 0;
      if (qt.$ !== "None") {
        const gen = tld.$ === "Def" && tld.x > 0 && !book.tlds[lhs.def].x ? tld : null;
        if (tld.$ === "Def" && tld.v === null && !tld.i && (tld.b !== true && lhs.u !== true || gen !== null) && k !== lhs.def) {
          throw Err(book, ctx, "a filled definition (an unfilled law is a dead claim: live code cannot use it)", tm, tm.s, lhs.def);
        }
        if (gen !== null) {
          k = def_inst(book, lhs, tm, gen, sp, ctx, d);
          x = gen.x;
          sp = sp.slice(x);
        }
        if (k === lhs.def && lhs.u !== true) {
          const cols = term_unapply(lhs.t)[1];
          let ord = "EQ";
          for (let j = 0;j < cols.length && j < sp.length && ord === "EQ"; j++) {
            ord = term_descend(lhs.qs[j], sp[j], cols[j]);
          }
          if (ord !== "LT") {
            throw Err(book, ctx, "a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)", tm, tm.s, lhs.def);
          }
        }
      }
      if (tld.$ === "ADT" && tld.n > 0) {
        throw Err(book, ctx, "a family instance (write " + name_key(tm.k) + "<..>)", tm, tm.s, lhs.def);
      }
      return Infer(Ref(k, tm.s, tm.b), book.tlds[k].T, uses_nil(), x);
    }
    case "Typ": {
      const g_chk = term_check(book, lhs, tm.g, None(), Qnt(tm.s), ctx, d);
      return Infer(Typ(g_chk.tm, tm.s), Typ(Qua(Lone()), tm.s), uses_nil());
    }
    case "Qnt": {
      return Infer(tm, Typ(Qua(Lone()), tm.s), uses_nil());
    }
    case "Qua": {
      return Infer(tm, Qnt(tm.s), uses_nil());
    }
    case "Min": {
      const a_chk = term_check(book, lhs, tm.a, qt, Qnt(tm.s), ctx, d);
      const b_chk = term_check(book, lhs, tm.b, qt, Qnt(tm.s), ctx, d);
      return Infer(Min(a_chk.tm, b_chk.tm, tm.s), Qnt(tm.s), uses_add(a_chk.us, b_chk.us));
    }
    case "All": {
      const B_ctx = ctx_bind(ctx, d, tm.q, tm.k, tm.A);
      const A_chk = term_check_kind(book, lhs, tm.A, tm.q, tm.k, ctx, d, tm.A.s ?? tm.s);
      const B_chk = term_check(book, lhs, tm.B(Var(tm.k, d)), None(), Typ(Qua(Lone()), tm.s), B_ctx, d + 1);
      return Infer(All(tm.q, tm.k, d, A_chk.tm, B_chk.tm, tm.s), Typ(Qua(Lone()), tm.s), uses_nil());
    }
    case "App": {
      const f_inf = term_infer(book, lhs, tm.f, qt, ctx, d, [tm.x, ...sp]);
      if (f_inf.x) {
        return { ...f_inf, x: f_inf.x - 1 };
      }
      const f_wnf = term_wnf(book, f_inf.ty);
      if (f_wnf.$ !== "All") {
        throw Err(book, ctx, "a function type", f_inf.ty, tm.s, lhs.def);
      }
      const x_chk = term_check(book, lhs, tm.x, quant_dem(f_wnf.q, qt), f_wnf.A, ctx, d);
      return Infer(App(f_inf.tm, x_chk.tm, tm.s), f_wnf.B(tm.x), uses_add(f_inf.us, x_chk.us));
    }
    case "ADT": {
      const adt = book_adt(book, tm, ctx, lhs.def);
      if (tm.x.length !== adt.n) {
        throw Err(book, ctx, name_key(tm.k) + " with " + String(adt.n) + (adt.n === 1 ? " parameter" : " parameters"), tm, tm.s, lhs.def);
      }
      const { xs, us, tel } = tele_check(book, lhs, adt.T, tm.x, qt, ctx, d, tm.s);
      return Infer(ADT(tm.k, xs, tm.s, tm.r), tel, us);
    }
    case "Eql": {
      const T_chk = term_check(book, lhs, tm.T, None(), Typ(Qua(Lone()), tm.s), ctx, d);
      const a_chk = term_check(book, lhs, tm.a, None(), tm.T, ctx, d);
      const b_chk = term_check(book, lhs, tm.b, None(), tm.T, ctx, d);
      return Infer(Eql(a_chk.tm, b_chk.tm, T_chk.tm, tm.s), Typ(Qua(Many()), tm.s), uses_nil());
    }
    case "Ann": {
      term_check(book, lhs, tm.T, None(), Typ(Qua(Lone()), tm.s), ctx, d);
      const x_chk = term_check(book, lhs, tm.x, qt, tm.T, ctx, d);
      return { tm: x_chk.tm, ty: tm.T, us: x_chk.us };
    }
    default: {
      const t = tm.$ === "Lit" ? lit_step(tm) : tm;
      if (t.$ === "Ctr" && book_ctr(book, t.k) === null) {
        throw Err(book, ctx, "a declared constructor", tm, tm.s, lhs.def);
      }
      throw Err(book, ctx, "an annotated term (cannot infer)", tm, tm.s, lhs.def);
    }
  }
}
function tele_check(book, lhs, tel, xs, qt, ctx, d, s) {
  const out = [];
  let us = uses_nil();
  for (const x of xs) {
    const t_all = tele_head(book, tel, ctx, lhs.def, s);
    const t_dem = quant_dem(t_all.q, qt);
    const x_chk = term_check(book, lhs, x, t_dem, t_all.A, ctx, d);
    out.push(x_chk.tm);
    us = uses_add(us, x_chk.us);
    tel = t_all.B(x);
  }
  return { xs: out, us, tel };
}
function term_check_kind(book, lhs, T, q, k, ctx, d, s) {
  const kind = Typ(Qua(lhs_kind(lhs, q)), s);
  try {
    return term_check(book, lhs, T, None(), kind, ctx, d);
  } catch (e) {
    const err = e;
    const nte = q.$ === "Many" ? "Note: +" + k + " can be used many times, so its type must be Data." : undefined;
    throw err?.$ === "Err" && err.exp === kind ? { ...err, spn: s ?? err.spn, nte } : e;
  }
}
function uses_close(book, ctx, us, i, k, q, s, def) {
  const u = pmap_get(us, i) ?? None();
  if (quant_join(u, q).$ !== q.$) {
    let obs = quant_show(u) + k;
    if (u.$ === "Many") {
      obs = k + " (consumed more than once)";
    }
    throw Err(book, ctx, quant_show(q) + k, obs, s, def);
  }
  return pmap_set(us, i, None());
}
function term_check(book, lhs, tm, qt, ty, ctx, d) {
  switch (tm.$) {
    case "Var": {
      if (tm.i < 0 && tm.v !== undefined) {
        return term_check(book, lhs, term_force(tm), qt, ty, ctx, d);
      }
      break;
    }
    case "Lam": {
      const t_wnf = term_wnf(book, ty);
      if (t_wnf.$ !== "All") {
        throw Err(book, ctx, ty, "non-inferrable term", tm.s, lhs.def);
      }
      const x = Var(tm.k, d);
      let f_lhs = lhs;
      if (lhs.n > 0) {
        f_lhs = { ...lhs, t: term_apply(lhs.t, x), n: lhs.n - 1 };
      }
      let q = t_wnf.q;
      if (tm.q?.$ === "Many" && q.$ === "Lone") {
        q = tm.q;
        term_check_kind(book, lhs, t_wnf.A, q, tm.k, ctx, d, tm.s);
      }
      const f_ctx = ctx_bind(ctx, d, q, tm.k, t_wnf.A);
      const f_chk = term_check(book, f_lhs, tm.f(x), qt, t_wnf.B(x), f_ctx, d + 1);
      return Check(Lam(tm.k, d, f_chk.tm, tm.s), ty, uses_close(book, ctx, f_chk.us, d, tm.k, q, tm.s, lhs.def));
    }
    case "Let": {
      const n = tm.k.length;
      const vx = [];
      let us = uses_nil();
      let f_ctx = ctx;
      for (let j = 0;j < n; j++) {
        const v_dem = quant_dem(tm.q[j], qt);
        const v_inf = term_infer(book, lhs, tm.v[j], v_dem, ctx, d);
        term_check_kind(book, lhs, v_inf.ty, tm.q[j], tm.k[j], ctx, d, tm.s);
        vx.push(v_inf.tm);
        us = uses_add(us, v_inf.us);
        f_ctx = ctx_bind(f_ctx, d + j, tm.q[j], tm.k[j], v_inf.ty);
      }
      const xs = tm.k.map((k, j) => Var(k, d + j, undefined, tm.v[j]));
      const f_chk = term_check(book, lhs, tm.f(xs), qt, ty, f_ctx, d + n);
      let fu = f_chk.us;
      for (let j = 0;j < n; j++) {
        fu = uses_close(book, ctx, fu, d + j, tm.k[j], tm.q[j], tm.s, lhs.def);
      }
      return Check(Let(tm.k, xs.map((_, j) => d + j), vx, f_chk.tm, tm.s, tm.q), ty, uses_add(us, fu));
    }
    case "Ctr": {
      const t_wnf = term_wnf(book, ty);
      if (t_wnf.$ !== "ADT") {
        const fam = book_ctr(book, tm.k) === null ? null : book_fam(book, tm.k);
        const nte = fam === null && book.tlds[tm.k]?.$ === "ADT" ? "Note: " + tm.k + " is a datatype: write its arguments as <>" : undefined;
        throw Err(book, ctx, ty, fam === null ? "non-inferrable term" : Ref(fam, tm.s), tm.s, lhs.def, nte);
      }
      const adt = book_adt(book, t_wnf, ctx, lhs.def);
      const ctr = adt.c.find((c) => c.k === tm.k);
      if (ctr === undefined) {
        if (book_ctr(book, tm.k) === null) {
          throw Err(book, ctx, "a declared constructor (" + name_key(t_wnf.k) + " declares " + adt.c.map((c) => name_key(c.k)).join(", ") + ")", tm, tm.s, lhs.def);
        }
        throw Err(book, ctx, ty, Ref(book_fam(book, tm.k), tm.s), tm.s, lhs.def);
      }
      if (tm.x.length !== ctr.n) {
        throw Err(book, ctx, name_key(tm.k) + " with " + String(ctr.n) + (ctr.n === 1 ? " field" : " fields"), tm, tm.s, lhs.def);
      }
      const tel = tele_fill(book, ctr.T, t_wnf.x, ctx, lhs.def, tm.s);
      const { xs, us } = tele_check(book, lhs, tel, tm.x, qt, ctx, d, tm.s);
      return Check(Ctr(tm.k, xs, tm.s), ty, us);
    }
    case "Lit": {
      const t_wnf = term_wnf(book, ty);
      if (t_wnf.$ === "ADT" && t_wnf.k === tm.k && t_wnf.r.length === 0 && book.tlds[tm.k]?.b === true) {
        return Check(tm, ty, uses_nil());
      }
      return term_check(book, lhs, lit_step(tm), qt, ty, ctx, d);
    }
    case "Mat":
    case "Efq": {
      const t_wnf = term_wnf(book, ty);
      if (t_wnf.$ !== "All") {
        throw Err(book, ctx, ty, "non-inferrable term", tm.s, lhs.def);
      }
      if (qt.$ !== "None" && t_wnf.q.$ === "None") {
        throw Err(book, ctx, "a live scrutinee (a - scrutinee matches only in a dead region)", undefined, tm.s, lhs.def);
      }
      const a_wnf = term_wnf(book, t_wnf.A);
      if (a_wnf.$ !== "ADT") {
        throw Err(book, ctx, "a datatype", t_wnf.A, tm.s, lhs.def);
      }
      const rem = book_adt(book, a_wnf, ctx, lhs.def).c;
      switch (tm.$) {
        case "Efq": {
          if (rem.length !== 0 && !ctx_dead(book, ctx)) {
            throw Err(book, ctx, "cases for " + rem.map((c) => name_key(c.k)).join(", "), tm, tm.s, lhs.def);
          }
          return Check(tm, ty, uses_nil());
        }
        case "Mat": {
          let term_check_mat_goal = function(cur, n, xs) {
            if (n === 0) {
              return t_all.B(Ctr(b.k, xs, b.s));
            } else {
              const c_all = tele_head(book, cur, ctx, lhs.def, b.s);
              const c_dem = c_all.q.$ === "None" ? None() : c_all.q.$ === "Lone" ? t_all.q : quant_add(t_all.q, t_all.q);
              return All(c_dem, c_all.k, c_all.i, c_all.A, (x) => {
                return term_check_mat_goal(c_all.B(x), n - 1, xs.concat([x]));
              }, b.s);
            }
          };
          const b = tm;
          const t_all = t_wnf;
          const ctr = rem.find((c) => c.k === tm.k);
          if (ctr === undefined) {
            throw Err(book, ctx, "a constructor of " + name_key(a_wnf.k) + " (missing, or already matched)", tm, tm.s, lhs.def);
          }
          const tel = tele_fill(book, ctr.T, a_wnf.x, ctx, lhs.def, tm.s);
          let h_lhs = lhs;
          if (lhs.n > 0) {
            h_lhs = { ...lhs, t: lhs_ext(lhs.t, tm.k, ctr.n), n: lhs.n - 1 + ctr.n };
          }
          const h_chk = term_check(book, h_lhs, tm.h, qt, term_check_mat_goal(tel, ctr.n, []), ctx, d);
          const m_gol = All(t_wnf.q, t_wnf.k, t_wnf.i, ADT(a_wnf.k, a_wnf.x, tm.s, a_wnf.r.concat([ctr.k])), t_wnf.B, tm.s);
          const m_chk = rem.length === 1 && tm.m.$ !== "Mat" ? Check(Efq(tm.s), m_gol, uses_nil()) : term_check(book, lhs, tm.m, qt, m_gol, ctx, d);
          return Check(Mat(tm.k, h_chk.tm, m_chk.tm, tm.s), ty, pmap_union(h_chk.us, m_chk.us, quant_join));
        }
      }
    }
    case "Rfl": {
      const t_wnf = term_wnf(book, ty);
      if (t_wnf.$ !== "Eql") {
        throw Err(book, ctx, ty, "non-inferrable term", tm.s, lhs.def);
      }
      if (!term_compare("EQ", book, t_wnf.a, t_wnf.b, d)) {
        throw Err(book, ctx, t_wnf.a, t_wnf.b, tm.s, lhs.def);
      }
      return Check(tm, ty, uses_nil());
    }
    case "Hol": {
      if (tm.k === "TODO") {
        return Check(tm, ty, uses_nil());
      }
      throw Err(book, ctx, ty, tm, tm.s, lhs.def);
    }
    case "Rwt": {
      const e_inf = term_infer(book, lhs, tm.e, qt, ctx, d);
      const e_wnf = term_wnf(book, e_inf.ty);
      if (e_wnf.$ !== "Eql") {
        throw Err(book, ctx, "an equation {a == b : T}", e_inf.ty, tm.e.s ?? tm.s, lhs.def);
      }
      const p_typ = All(Lone(), "_", 0, e_wnf.T, (x) => All(Lone(), "e", 0, Eql(e_wnf.a, x, e_wnf.T), () => Typ(Qua(Lone())), tm.s), tm.s);
      const p_chk = term_check(book, lhs, tm.p, None(), p_typ, ctx, d);
      const b_gol = term_apply(term_apply(tm.p, e_wnf.b), tm.e);
      if (!term_compare("LE", book, b_gol, ty, d)) {
        throw Err(book, ctx, ty, b_gol, tm.s, lhs.def);
      }
      const a_gol = term_apply(term_apply(tm.p, e_wnf.a), Rfl(tm.s));
      const f_chk = term_check(book, lhs, tm.f, qt, a_gol, ctx, d);
      return Check(Rwt(e_inf.tm, p_chk.tm, f_chk.tm, tm.s), ty, uses_add(e_inf.us, f_chk.us));
    }
    default: {
      break;
    }
  }
  const x_inf = term_infer(book, lhs, tm, qt, ctx, d);
  if (term_compare("LE", book, x_inf.ty, ty, d)) {
    return x_inf;
  }
  throw Err(book, ctx, ty, x_inf.ty, tm.s, lhs.def);
}
function def_check(book, k, def, z) {
  const qs = tele_unbind(book, def.T).doms.map((dom) => dom[0]);
  const gen = def.x === 0 ? book : { ...book, tlds: Object.create(book.tlds) };
  let [t, v, T] = [Ref(k), def.v, def.T];
  for (let j = 0;j < def.x; j++) {
    const h = tele_head(gen, T, ctx_nil(), k);
    const o = k + "~" + h.k;
    if (o in gen.tlds) {
      throw Err(book, ctx_nil(), "a fresh ~ binder name", h.k, h.s);
    }
    gen.tlds[o] = { $: "Def", n: 0, x: 0, T: h.A, v: null, b: true };
    t = App(t, Ref(o));
    v = term_apply(v, Ref(o));
    T = h.B(Ref(o));
  }
  return term_check(gen, { t, n: def.n - def.x, def: k, qs, u: def.u, z }, v, Lone(), T, ctx_nil(), 0).tm;
}
function def_inst(book, lhs, tm, def, sp, ctx, d) {
  const xs = sp.slice(0, def.x);
  if (xs.length < def.x) {
    throw Err(book, ctx, "a template applied to closed ~ arguments (a def parameter is not comptime)", tm, tm.s, lhs.def);
  }
  let T;
  try {
    T = tele_check(book, lhs, def.T, xs, None(), ctx_nil(), d, tm.s).tel;
  } catch (e) {
    const v = e?.obs;
    if (typeof v === "object" && v.$ === "Var" && v.i >= 0 && v.i < d) {
      throw Err(book, ctx, "a template applied to closed ~ arguments (" + v.k + " is a variable here, not comptime: pass it at run time)", tm, tm.s, lhs.def);
    }
    throw e;
  }
  const key = xs.map((a) => term_key(term_lower(a))).join(`
`);
  if (key.length > 32768) {
    throw Err(book, ctx, "a ~ argument that stops growing", tm, tm.s, lhs.def);
  }
  const is = book.tmps[tm.k] ??= new Map;
  let o = is.get(key);
  if (o === undefined) {
    const z = (lhs.z ?? 0) + 1;
    if (z > 64) {
      throw Err(book, ctx, "a template that stops instantiating itself (64 levels at most)", tm, tm.s, lhs.def);
    }
    o = tm.k + "~" + String(is.size);
    is.set(key, o);
    const inst = { $: "Def", n: def.n - def.x, x: 0, T, v: xs.reduce((v, a) => term_apply(v, a), def.v), u: def.u };
    book.tlds[o] = { ...inst, v: null };
    inst.e = def_check(book, o, inst, z);
    book.tlds[o] = inst;
  } else if (book.tlds[o].v === null && o !== lhs.def) {
    throw Err(book, ctx, "a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)", tm, tm.s, lhs.def);
  }
  return o;
}
function book_valid(book, done = 0) {
  const tlds = book.tlds;
  const last = new Map;
  for (let i = 0;i < book.order.length; i++) {
    last.set(book.order[i], i);
  }
  book.tlds = Object.create(null);
  for (const k in tlds) {
    const t = tlds[k];
    book.tlds[k] = last.has(k) && t.$ === "Def" ? { ...t, v: null } : t;
  }
  for (let i = 0;i < book.order.length; i++) {
    const k = book.order[i];
    const tld = tlds[k];
    const fin = last.get(k) === i;
    if (tld.$ === "ADT") {
      if (i >= done) {
        term_check(book, { t: Ref(k), n: 0, def: k, qs: [] }, tld.T, None(), Typ(Qua(Lone())), ctx_nil(), 0);
        const { doms, ret: kind } = tele_unbind(book, tld.T);
        if (kind.$ !== "Typ") {
          let ctx = ctx_nil();
          for (const [d, [q, x, A]] of doms.entries()) {
            ctx = ctx_bind(ctx, d, q, x, A);
          }
          throw Err(book, ctx, "a kind (type " + name_key(k) + "<..> is Kind(g))", kind, kind.s ?? tld.T.s, k);
        }
        for (const ctr of tld.c) {
          let tel = ctr.T;
          let ctx = ctx_nil();
          for (let d = 0;d < tld.n + ctr.n; d++) {
            const t_all = tele_head(book, tel, ctx, ctr.k);
            let goal = Typ(Qua(t_all.q));
            if (d >= tld.n && t_all.q.$ === "Lone") {
              goal = kind;
            }
            term_check(book, { t: Ref(ctr.k), n: 0, def: ctr.k, qs: [] }, t_all.A, None(), goal, ctx, d);
            ctx = ctx_bind(ctx, d, t_all.q, t_all.k, t_all.A);
            tel = t_all.B(Var(t_all.k, d));
          }
          const exp = "a telescope tipped at " + name_key(k) + " applied to its own parameters";
          const tip = term_wnf(book, tel);
          if (tip.$ !== "ADT" || tip.k !== k || tip.x.length !== tld.n || tip.r.length !== 0) {
            throw Err(book, ctx, exp, tip, undefined, ctr.k);
          }
          for (let d = 0;d < tld.n; d++) {
            const x = term_wnf(book, tip.x[d]);
            if (x.$ !== "Var" || x.i !== d) {
              throw Err(book, ctx, exp, tip, undefined, ctr.k);
            }
          }
        }
      }
      continue;
    }
    if (i >= done) {
      if (fin && tld.v === null && tld.b !== true && !tld.i) {
        book.hols += 1;
      }
      term_check(book, { t: Ref(k), n: 0, def: k, qs: [], u: tld.u }, tld.T, None(), Typ(Qua(Lone())), ctx_nil(), 0);
      if (tld.i) {
        let tel = term_strip(tld.T);
        for (let d = 0;tel.$ === "All"; d++) {
          tel = term_strip(tel.B(Var(tel.k, d)));
        }
        const [h] = term_unapply(tel);
        const io = book.tlds["IO"];
        if (h.$ !== "Ref" || h.k !== "IO" || io === undefined || io.$ !== "Def" || io.b !== true) {
          throw Err(book, ctx_nil(), "a foreign definition returning base IO(...) directly (return type aliases are not unfolded)", k, tel.s, k);
        }
      }
      if (fin && tld.v !== null) {
        tld.e = def_check(book, k, tld);
      }
    }
    if (fin) {
      book.tlds[k] = tld;
    }
  }
}

// ../bend2-core/.claude/worktrees/rel-2035/bend2/comp.ts
import * as fs2 from "fs";
var CLO_APPLY = "Clo~apply";
var IO_EMIT = "IO~emit";
var ATOM = /^(?:[A-Za-z_$][A-Za-z0-9_$]*|\d+|\d+\.\d+)$/;
var STRLIT = /^"(?:[^"\\]|\\.)*"$/;
var VIEW = /^(?:u32_to_word\((\w+|f32_bits\(\w+\))\)|(\w+)\.codePointAt\(0\))$/;
var TAB_BAD = /\b(?!(?:fround|imul)\()\w+\(/;
var FOLD_FUEL = 8192;
var SPIN_FAR = 256;
var TPL_DEEP = 32;
var USE0 = Emp();
var W32 = { ks: ["w32"], arms: null };
var BOX = { ks: ["box"], arms: null };
var W64 = { ks: ["w64"], arms: null };
var WORDS = Object.setPrototypeOf({ U32: W32, F32: W32, Nat: W64 }, null);
var WIDE = 247;
var ERRS = ("|*|*|out of memory: run again with a bigger span, as in" + " --gpu 8GB|a function the device does not hold|a Nat past the" + " largest immediate 2^48-1|*|memory fault (machine stack overflow?)|an" + " array past the deepest block class 31").replaceAll("*", "runtime fail-stop").split("|");
var CMPS = "is_eq:==:=== is_ne:!=:!== is_lt:< is_le:<= is_gt:> is_ge:>=";
var OPERATIONS = Object.setPrototypeOf({
  ...tpl_ops("u32_", "add:+ sub:- and:& or:| xor:^", "U32_BIN($0, $o, $1)", "(($0 $o $1) >>> 0)"),
  ...tpl_ops("u32_", CMPS, "U32_BIN($0, $o, $1)", "($0 $o $1)"),
  u32_mul: { C: "U32_BIN($0, *, $1)", JS: "(Math.imul($0, $1) >>> 0)" },
  u32_div: {
    C: "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))",
    JS: "($1 === 0 ? 0 : ($0 / $1) >>> 0)"
  },
  u32_mod: {
    C: "((u32)($1) == 0 ? $0 : U32_BIN($0, -," + " U32_QUO((u32)($0), (u32)($1)) * $1))",
    JS: "($1 === 0 ? $0 : $0 % $1)"
  },
  ...tpl_ops("u32_", "inc:+ shl:<< shr:>>:>>>", "U32_BIN($0, $o, 1)", "(($0 $o 1) >>> 0)"),
  ...tpl_ops("u32_", "shln:<< shrn:>>:>>>", "($1 >= 32 ? 0 : U32_BIN($0, $o, $1))", "($1 >= 32 ? 0 : ($0 $o $1) >>> 0)"),
  u32_not: { C: "((u64)~(u32)($0))", JS: "(~$0 >>> 0)" },
  u32_is_zero: { C: "U32_BIN($0, ==, 0)", JS: "($0 === 0)" },
  u32_cmp: {
    C: "(U32_BIN($0, >, $1) + U32_BIN($0, >=, $1))",
    JS: "cmp_new($0, $1)"
  },
  u32_to_f32: { C: "f32_rewrap((f32)(u32)($0))", JS: "Math.fround($0)" },
  u32_to_nat: { C: "((u64)$0)", JS: "$0" },
  u32_from_nat: { C: "((u64)(u32)($0))", JS: "($0 >>> 0)" },
  ...tpl_ops("f32_", "add:+ sub:- mul:* div:/", "f32_rewrap(f32_unbox($0) $o f32_unbox($1))", "Math.fround($0 $o $1)"),
  f32_neg: { C: "f32_rewrap(-f32_unbox($0))", JS: "(-$0)" },
  ...tpl_ops("f32_", CMPS, "((u64)(f32_unbox($0) $o f32_unbox($1)))", "($0 $o $1)"),
  ...tpl_ops("f32_", "sqrt exp log log2 log10 sin cos tan asin acos atan" + " sinh cosh tanh floor ceil trunc abs:fabs:abs", "f32_rewrap((f32)$o(f32_unbox($0)))", "Math.fround(Math.$o($0))"),
  ...tpl_ops("f32_", "atan2", "f32_rewrap((f32)$o(f32_unbox($0), f32_unbox($1)))", "Math.fround(Math.$o($0, $1))"),
  f32_pow: {
    C: "f32_rewrap((f32)pow(f32_unbox($0), f32_unbox($1)))",
    JS: "($0 === 1 || $0 === -1 && Math.abs($1) === Infinity ? 1" + " : Math.fround(Math.pow($0, $1)))"
  },
  f32_mod: {
    C: "f32_rewrap((f32)fmod(f32_unbox($0), f32_unbox($1)))",
    JS: "Math.fround($0 % $1)"
  },
  f32_to_u32: {
    C: "f32_to_u32($0)",
    JS: "($0 >= 1 && $0 < 4294967296 ? Math.floor($0) : 0)"
  },
  f32_bits: { C: "$0", JS: "f32_bits($0)" },
  f32_show: { C: "f32_show(e, $0)", call: true, JS: "f32_show($0)" },
  f32_read: { C: "f32_read(e, $0)", call: true, JS: "f32_read($0)" },
  nat_add: { C: "nat_chk(e, $0 + $1)", JS: "nat_chk($0 + $1)" },
  nat_mul: { C: "nat_mul(e, $0, $1)", JS: "nat_chk($0 * $1)" },
  nat_double: { C: "nat_chk(e, $0 + $0)", JS: "nat_chk($0 + $0)" },
  nat_cmp: { C: "(($0 > $1) + ($0 >= $1))", JS: "cmp_new($0, $1)" },
  ...tpl_ops("nat_", "sub", "($0 < $1 ? 0 : $0 - $1)"),
  ...tpl_ops("nat_", "is_lt:<", "($0 $o $1)"),
  ...tpl_ops("nat_", "min:< max:>", "($0 $o $1 ? $0 : $1)"),
  nat_divmod: {
    C: ["($1 == 0 ? 0 : $0 / $1)", "($1 == 0 ? $0 : $0 % $1)"],
    call: true,
    JS: "nat_divmod($0, $1)"
  },
  ...tpl_ops("bool_", "or:|:|| xor:^:!==", "(($0) $o ($1))", "($0 $o $1)"),
  string_append: { JS: "($0 + $1)" },
  string_length: { JS: "[...$0].length" },
  ...Object.fromEntries(Object.entries({
    new: "array_new($0, $1)",
    set: "($0[$1 % $0.length] = $2, $0)",
    get: '{$: "Tuple", fst: $0, snd: $0[$1 % $0.length]}',
    swap: "array_rmw($0, $1, () => $2)",
    size: '{$: "Tuple", fst: $0, snd: $0.length}'
  }).map(([k, JS]) => ["array_" + k, { call: true, JS }])),
  array_clone: {
    C: ["$0", "blk_copy(e, $0)"],
    call: true,
    JS: '{$: "Tuple", fst: $0, snd: $0.slice()}'
  },
  ...Object.fromEntries(Object.entries({
    add: "(o + $2) >>> 0",
    min: "Math.min(o, $2)",
    max: "Math.max(o, $2)",
    and: "(o & $2) >>> 0",
    or: "(o | $2) >>> 0",
    xor: "(o ^ $2) >>> 0",
    exch: "$2",
    cmpx: "o === $2 ? $3 : o",
    fadd: "Math.fround(o + $2)"
  }).map(([k, js]) => ["array_atomic_" + k.replace("cmpx", "cas"), {
    C: ["$0", "a32_" + k + "(blk_ptr(e.mem, blk_loc(e.mem, $0)," + " blk_at($0, $1, 0)), (u32)$2" + (k === "cmpx" ? ", (u32)$3)" : ")")],
    call: true,
    JS: `array_rmw($0, $1, (o) => ${js})`
  }]))
}, null);
var OPTIMIZED = Object.setPrototypeOf({
  Nat: { Zero: { intr: "0" }, Succ: { intr: tpl_nat("", "nat_chk($0 + 1)") } },
  Bool: {
    False: { intr: "false", cond: "!$0" },
    True: { intr: "true", cond: "$0" }
  },
  U32: { U32: { intr: ([w]) => view_of(w) ?? `word_to_u32(${w})` } },
  F32: {
    F32: {
      intr: ([w]) => w.match(/^u32_to_word\(f32_bits\((\w+)\)\)$/)?.[1] ?? `f32_from_bits(${tpl(OPTIMIZED.U32.U32.intr, [w])})`
    }
  },
  Char: {
    Chr: {
      intr: ([c]) => {
        const n = Number(c);
        return view_of(c) ?? (/^\d+$/.test(c) && (n < 55296 || n >= 57344 && n <= 1114111) ? JSON.stringify(String.fromCodePoint(n)) : `char_new(${c})`);
      },
      elim: ["$0.codePointAt(0)"]
    }
  },
  Array: {
    ALeaf: { intr: "[$0]", elim: ["$0[0]"], cond: "$0.length === 1" },
    ANode: {
      intr: "array_node($0, $1)",
      elim: ["$0.slice(0, $0.length >> 1)", "$0.slice($0.length >> 1)"],
      cond: "$0.length !== 1"
    }
  },
  String: {
    SNil: { intr: '""', cond: '$0 === ""' },
    SCon: {
      intr: ([h, t]) => STRLIT.test(h) && STRLIT.test(t) ? JSON.stringify(JSON.parse(h) + JSON.parse(t)) : `(${h} + ${t})`,
      elim: [
        "($0.codePointAt(0) > 0xFFFF ? $0.slice(0, 2) : $0[0])",
        "($0.codePointAt(0) > 0xFFFF ? $0.slice(2) : $0.slice(1))"
      ],
      cond: '$0 !== ""'
    }
  }
}, null);
var RUNTIME_ADTS = [
  "Sigma",
  "String",
  "Word.Con",
  "IO.OP",
  "Result",
  "Maybe",
  "Bool",
  "Unit"
];
var OWNED = ["IO", ...RUNTIME_ADTS, ...Object.keys(OPTIMIZED)];
var SHIMS = "sqrt exp log log2 log10 sin cos tan pow fmod".split(" ").map((n) => "#define " + n.padEnd(5) + ("sin cos tan".includes(n) ? " fast::" : " precise::") + n).join(`
`) + `
#define atan2 atan2_c99`;
var NATIVE = {
  C: String.raw`
#ifdef __METAL_VERSION__
INLINE f32 atan2_c99(f32 y, f32 x) {
  return y == 0.0f && x == x
    ? copysign(signbit(x) ? M_PI_F : 0.0f, y) : atan2(y, x);
}
${SHIMS}
#define U32_QUO(a, b) \
  ((a) / 2 / (b) * 2 + ((a) - (a) / 2 / (b) * 2 * (b) >= (b)))
#else
#define U32_QUO(a, b) ((a) / (b))
#endif

#define U32_BIN(a, o, b) ((u64)((u32)(a) o (u32)(b)))

INLINE f32 f32_unbox(u64 x) {
  union { u32 u; f32 f; } p = { (u32)x };
  return p.f;
}

INLINE u64 f32_rewrap(f32 x) {
  union { f32 f; u32 u; } p = { x };
  return p.u;
}

INLINE u64 f32_to_u32(u64 a) {
  f32 v = f32_unbox(a);
  return v >= 0.0f && v < 4294967296.0f ? (u32)v : 0;
}

INLINE u64 nat_chk(Env e, u64 n) {
  if (n > NAT_IMM) {
    err_post(e.mem, ERR_NATS);
    return NAT_IMM;
  }
  return n;
}

INLINE u64 nat_mul(Env e, u64 a, u64 b) {
  return nat_chk(e, b != 0 && a > NAT_IMM / b ? NAT_IMM + 1 : a * b);
}

#if DEVICE

#define f32_show(e, x) (err_post(e.mem, ERR_FIDS), 0)
#define f32_read(e, s) (err_post(e.mem, ERR_FIDS), 0)

#else

static Term f32_show(Env e, Term x);
static Term f32_read(Env e, Term s);

#endif
`.slice(1),
  IO: String.raw`
static int f32_text(char* buf, f32 v) {
  int n = 0;
  int p = 0;
  if (v != v) {
    return sprintf(buf, "nan");
  }
  for (; p < 9; p += 1) {
    n = snprintf(buf, 40, "%.*e", p, (double)v);
    if (strtof(buf, NULL) == v) {
      break;
    }
  }
  char* ep = strchr(buf, 'e');
  if (ep == NULL) {
    return n;
  }
  int ex = atoi(ep + 1);
  if (ex >= 21 || ex <= -7) {
    n = (int)(ep - buf) + sprintf(ep, "e%c%d", ex < 0 ? '-' : '+', abs(ex));
  } else if (ex <= p) {
    n = snprintf(buf, 40, "%.*f", p - ex, (double)v);
  } else {
    int s = *buf == '-';
    memmove(buf + s + 1, buf + s + 2, p);
    memset(buf + s + 1 + p, '0', ex - p);
    n = s + 1 + ex;
  }
  return n;
}

static Term f32_show(Env e, Term x) {
  char buf[40];
  return io_str(e, buf, f32_text(buf, f32_unbox(x)));
}

static Term f32_read(Env e, Term s) {
  u64 n = 0;
  char* text = io_cstr(e, s, &n);
  char* end;
  f32 v = strtof(text, &end);
  Term out = n > 0 && (u64)(end - text) == n && strpbrk(text, "xX(") == NULL
    ? io_box(e, CID(Some), f32_rewrap(v)) : term_pak(CID(None), 0);
  free(text);
  return out;
}
`.slice(1),
  JS: String.raw`
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
    throw "bend: ${ERRS[5]}";
  }
  return n;
}

function nat_host(n) {
  const int = typeof n === "bigint" || Number.isInteger(n);
  if (int && n >= 0 && n <= 2 ** 53) {
    return Number(n);
  }
  return { [Symbol.toPrimitive]() { throw "bend: ${ERRS[5]}"; } };
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

const f32_round = ${f32_round};

function char_new(code) {
  if (code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) {
    throw "bend: " + code + " is not a Unicode scalar value";
  }
  return String.fromCodePoint(code);
}
`.slice(1)
};
var IDS = new Map;
var TAKEN = new Set;
var PROBES = [];
var DUMMY = probe("~");
var OPENS = new Map;
var USES = new Map;
var TELES = new Map;
var SRCS = new Map;
var LOOPS = new Map;
var FOLDS = new Map;
var FLATS = new Map;
var FUNS = new Map;
var BRWS = new Map;
var SPINES = new Map;
var NODES = new Map;
var LAYS = new Map;
var LAY_IDS = new Map;
var CONSTS = new Map;
var LITS = new Map;
var FUEL = 0;
function name_clean(k) {
  return k.replace(/[^A-Za-z0-9_]/g, "_");
}
function name_local(fl, k) {
  const base = name_clean(k).replace(/^_+/, "");
  const n = fl.fresh.get(base) ?? 0;
  fl.fresh.set(base, n + 1);
  return `_${base}_${n}`;
}
function name_id(pre, k) {
  return memo(IDS, pre + k, () => {
    const base = pre + name_clean(k).toUpperCase();
    let id = base;
    for (let n = 1;TAKEN.has(id); n += 1) {
      id = base + "_" + n;
    }
    TAKEN.add(id);
    return id;
  });
}
function cid_mac(k) {
  return name_id("CID_", k);
}
function tpl_ops(pre, names, C, JS = C) {
  return Object.fromEntries(names.split(" ").map((p) => {
    const [k, o = k, jo = o] = p.split(":");
    return [pre + k, { C: C.replaceAll("$o", o), JS: JS.replaceAll("$o", jo) }];
  }));
}
function tpl_deep(e) {
  let d = 0;
  return [...e].some((c) => (d += c === "(" ? 1 : c === ")" ? -1 : 0) > TPL_DEEP);
}
function tpl(t, xs) {
  return typeof t !== "string" ? t(xs) : t.split(/\$(\d)/).map((p, i) => i % 2 ? xs[+p] : p).join("");
}
function view_of(e) {
  const m = e.match(VIEW);
  return m?.[1] ?? m?.[2];
}
function tpl_nat(u, f) {
  return ([p]) => /^\d/.test(p) ? BigInt(parseInt(p)) + 1n + u : /^nat_chk\(.* \+ \d+n?\)$/.test(p) ? p.replace(/\d+(?=n?\)$)/, (k) => String(+k + 1)) : tpl(f, [p]);
}
function probe(k) {
  const p = Var(k, PROBES.length);
  PROBES.push(p);
  return p;
}
function probe_of(t) {
  return PROBES[term_force2(t).i];
}
function graph_close(set, edges) {
  for (const k of set) {
    edges.forEach(([a, b]) => a === k && set.add(b));
  }
  return set;
}
function lit_call(s) {
  return s.k === "Nat" && s.v > NAT_LITERAL_MAX ? App(Ref("U32.to_nat"), Lit("U32", s.v)) : null;
}
function term_force2(t) {
  const s = term_force(t);
  return s.$ !== "Lit" ? s : memo(LITS, s, () => lit_call(s) ?? lit_step(s));
}
function term_strip2(t) {
  return term_force2(term_strip(t));
}
function term_open(t) {
  return memo(OPENS, t, () => {
    const ps = (t.$ === "Lam" ? [t.k] : t.k).map(probe);
    return { ps, b: t.$ === "Lam" ? t.f(ps[0]) : t.f(ps) };
  });
}
function let_open(ps, vs, b) {
  const l = Let(ps.map((p) => p.k), ps.map(() => 0), vs, () => die("a pre-opened let"));
  OPENS.set(l, { ps, b });
  return l;
}
function let_live(fl, t) {
  const o = term_open(t);
  const u = term_uses(fl, o.b);
  return t.q.map((_, j) => term_use(u, o.ps[j]) > 0);
}
function term_spine(fl, tm) {
  return memo(SPINES, tm, () => {
    const apps = [];
    let h = tm;
    let c = term_force2(tm);
    while (c.$ === "Ann" || c.$ === "App") {
      if (c.$ === "App") {
        apps.unshift(c);
        h = c.f;
      }
      c = term_force2(c.$ === "App" ? c.f : c.x);
    }
    const tld = c.$ === "Ref" ? fl.book.tlds[c.k] : undefined;
    const T = tld?.$ === "Def" ? tld.T : ty_ann(h);
    const qs = T === null ? [] : tele_unbind2(fl.book, T).doms;
    const live = apps.map((_, i) => i >= qs.length || dom_live(qs[i]));
    const all = apps.map((a2) => a2.x);
    const args = all.filter((_, i) => live[i]);
    const def = c.$ === "Ref" && intr_of(fl, c.k) === undefined && fun_runs(tld) ? c.k : null;
    const need = def === null ? 0 : fun_of(fl, def).lays.length;
    const a = apps[live.lastIndexOf(true)];
    const m = { h, t: c, all, args, tld, k: null, xs: args };
    if (def !== null && args.length === need) {
      return { ...m, k: def, b: c.b };
    }
    if (args.length > need && (def !== null || c.$ !== "Ref")) {
      return { ...m, k: CLO_APPLY, xs: [a.f, a.x] };
    }
    return m;
  });
}
function term_eta(book, t, T, n) {
  if (n === 0) {
    return t;
  }
  const all = ty_all(book, T);
  return Ann(Lam("x", 0, (y) => term_eta(book, App(t, y), all.B(y), n - 1)), T);
}
function call_eta(fl, t) {
  const m = term_spine(fl, t);
  const f = m.t.$ === "Ref" ? fun_of(fl, m.t.k) : null;
  if (m.tld?.$ !== "Def" || f === null || m.args.length >= f.live.length) {
    return null;
  }
  return term_eta(fl.book, t, tele_fill(fl.book, m.tld.T, m.all, ctx_nil()), f.n - m.all.length);
}
function term_kids(fl, tm) {
  const t = term_force2(tm);
  switch (t.$) {
    case "Ann": {
      return [t.x];
    }
    case "Lam": {
      return [term_open(t).b];
    }
    case "Let": {
      const on = let_live(fl, t);
      return [...t.v.filter((_, j) => on[j]), term_open(t).b];
    }
    case "App": {
      const m = term_spine(fl, t);
      return [m.h, ...m.args];
    }
    case "Ctr": {
      return term_const(t) ? [] : ctr_flds(fl.book, t.k, t.x);
    }
    case "Mat": {
      return [t.h, t.m];
    }
    case "Rwt": {
      return [t.f];
    }
    default: {
      return [];
    }
  }
}
function term_any(fl, t, p, tail = true) {
  const s = term_force2(t);
  const kids = term_kids(fl, s);
  return p(s, tail) || kids.some((x, i) => term_any(fl, x, p, tail && (s.$ === "Let" ? i === kids.length - 1 : "Ann Lam Mat Rwt".includes(s.$))));
}
function term_const(t) {
  const s = term_strip(t);
  return s.$ === "Lit" ? lit_call(s) === null : s.$ === "Ctr" && (s.x.length === 0 || memo(CONSTS, s, () => s.x.every(term_const)));
}
function term_use(u, p) {
  return pmap_get(u, p.i) ?? 0;
}
function term_uses(fl, tm) {
  return memo(USES, tm, () => {
    const t = term_force2(tm);
    switch (t.$) {
      case "Var": {
        const p = probe_of(t);
        return p === DUMMY ? USE0 : pmap_set(USE0, p.i, 1);
      }
      case "Mat": {
        return pmap_union(term_uses(fl, t.h), term_uses(fl, t.m), Math.max);
      }
      default: {
        return term_kids(fl, t).reduce((u, x) => pmap_union(u, term_uses(fl, x), (a, b) => a + b), USE0);
      }
    }
  });
}
function rest_use(fl, rest, p) {
  return rest.reduce((n, r) => n + term_use(term_uses(fl, r), p), 0);
}
function fun_live(book, x, ty) {
  return mat_head(x) || x.$ === "Lam" && quant_live(ty_all(book, ty).q);
}
function flat_call(fl, t) {
  const ck = term_spine(fl, t);
  return ck.k !== null && !ck.b && flat_of(ck.k);
}
function dom_live([q]) {
  return quant_live(q);
}
function quant_live(q) {
  return q.$ !== "None";
}
function intr_of(fl, k, js = false) {
  const tld = fl.book.tlds[k];
  const it = tld?.$ === "Def" && tld.i === undefined && tld.b ? OPERATIONS[op_name(k)] : undefined;
  return it && (js || it.C !== undefined || it.call) ? it : undefined;
}
function op_name(k) {
  return k.toLowerCase().replace(/[./]/g, "_");
}
function tele_unbind2(book, T) {
  return memo(TELES, T, () => tele_unbind(book, T));
}
function ty_ann(t) {
  const v = term_force2(t);
  return v.$ === "Ann" ? v.T : null;
}
function ty_wnf(book, ty) {
  return ty && term_wnf(book, ty);
}
function ty_all(book, ty) {
  return tele_open(book, ty);
}
function ty_peel(tm, ty) {
  let x = term_force2(tm);
  while (x.$ === "Ann" || x.$ === "Rwt") {
    ty = x.$ === "Ann" ? x.T : ty;
    x = term_force2(x.$ === "Ann" ? x.x : x.f);
  }
  return [x, ty];
}
function ty_adt(book, A) {
  const t = ty_wnf(book, A);
  return t?.$ === "ADT" ? t : null;
}
function adt_of(book, A) {
  const adt = ty_adt(book, A);
  if (adt.k === "Array") {
    lay_el(book, adt.x[0]);
  }
  return adt;
}
function ty_holds(book, A, p, seen = new Set) {
  const t = ty_wnf(book, A);
  const got = p(t);
  if (got !== null || t?.$ !== "ADT") {
    return got === true;
  }
  if (t.x.some((x) => ty_holds(book, x, p, seen))) {
    return true;
  }
  const tld = book.tlds[t.k];
  if (tld?.$ !== "ADT" || seen.has(t.k)) {
    return false;
  }
  seen.add(t.k);
  return tld.c.some((c) => ctr_doms(book, c, t.x).some((f) => ty_holds(book, f, p, seen)));
}
function ty_clo(book, A) {
  return ty_holds(book, A, (t) => t?.$ === "ADT" ? WORDS[t.k] !== undefined ? false : null : !["Typ", "Qua", "Min", "Eql"].includes(t?.$ ?? ""));
}
function type_adts(fl, T) {
  const t = ty_wnf(fl.book, T);
  switch (t?.$) {
    case "All": {
      return [...type_adts(fl, t.A), ...type_adts(fl, t.B(DUMMY))];
    }
    case "Lam": {
      return type_adts(fl, t.f(DUMMY));
    }
    case "ADT": {
      return [...WORDS[t.k] === undefined && t.k !== "Array" ? [t.k] : [], ...t.x.flatMap((x) => type_adts(fl, x))];
    }
    default: {
      return [];
    }
  }
}
function lay_of(book, A) {
  const t = ty_adt(book, A);
  return t === null ? BOX : WORDS[t.k] ?? memo(LAYS, term_key(term_lower(t)), (key) => {
    const tld = book.tlds[t.k];
    if (t.k === "Array" || t.k === "IO.OP" || tld?.$ !== "ADT" || tld.c.some((c) => ctr_doms(book, c).some((F) => ty_holds(book, F, (u) => u?.$ !== "ADT" || WORDS[u.k] ? false : u.k === t.k || null)))) {
      return BOX;
    }
    LAYS.set(key, BOX);
    const lay = lay_pack(tld.c.map((c) => [c.k, ctr_doms(book, c, t.x).map((A2) => lay_of(book, A2))]));
    return lay.ks.length > WIDE ? BOX : lay;
  });
}
function lay_el(book, A) {
  const t = ty_wnf(book, A);
  if (t?.$ === "Eql") {
    return lay_of(book, A);
  }
  if (t?.$ !== "ADT") {
    die("an open Array element type");
  }
  const tld = book.tlds[t.k];
  return lay_of(book, tld?.$ === "ADT" && tld.c[0] ? tele_unbind2(book, tld.c[0].T).ret : A);
}
function lay_pack(arms) {
  const tag = Number(arms.length > 1);
  const ks = tag ? ["w32"] : [];
  for (const [, lays] of arms) {
    let at = tag;
    for (const k of lays.flatMap((lay) => lay.ks)) {
      const old = ks[at] ?? "w32";
      ks[at++] = old === "box" || k === "w32" ? old : k;
    }
  }
  return { ks, arms: Object.fromEntries(arms) };
}
function lay_node(book, k) {
  return memo(NODES, k, () => {
    const lay = lay_pack([[k, (book.ctrs[k] ? ctr_doms(book, book.ctrs[k]) : []).map((A) => lay_of(book, A))]]);
    while (lay.ks.length > WIDE && lay.ks.length & lay.ks.length - 1) {
      lay.ks.push("w32");
    }
    return lay;
  });
}
function lay_eq(a, b) {
  return a === b || JSON.stringify(a) === JSON.stringify(b);
}
function lay_c(k) {
  return k === "w32" ? "u32" : "Term";
}
function lay_packed(lay) {
  return ["", "w32"].includes(lay.ks.join());
}
function lay_box(lay) {
  return lay.arms === null && lay.ks[0] === "box";
}
function lay_arr(lay) {
  return {
    arr: lay.ks.some((k) => k !== "w32"),
    lgs: cls_fit(Math.max(1, lay.ks.length))
  };
}
function ctr_adt(fl, x, ty) {
  const ctr = fl.book.ctrs[x.k];
  const adt = adt_of(fl.book, ty ?? (ctr ? tele_unbind2(fl.book, ctr.T).ret : null));
  if (ty === null && adt.x.length > 0) {
    die("a constructor outside a datatype");
  }
  return [adt, adt.k === "U32" || adt.k === "F32" ? u32_from_term(x, adt.k) : null];
}
function ctr_tail(book, ctr, xs) {
  const doms = (xs ? tele_unbind(book, tele_fill(book, ctr.T, xs, ctx_nil())) : tele_unbind2(book, ctr.T)).doms;
  return doms.slice(doms.length - ctr.n);
}
function ctr_live(book, ctr, xs) {
  return ctr_tail(book, ctr, xs).filter(dom_live);
}
function ctr_doms(book, ctr, xs) {
  return ctr_live(book, ctr, xs).map(([, , A]) => A);
}
function ctr_flds(book, k, xs) {
  const ds = book.ctrs[k] ? ctr_tail(book, book.ctrs[k]) : [];
  return xs.filter((_, j) => !ds[j] || dom_live(ds[j]));
}
function ctr_build(fl, k, exprs, stat = false) {
  const cid = cid_mac(k);
  if (lay_node(fl.book, k).ks.join() === "w32" || exprs.length === 0) {
    return `term_pak(${cid}, ${exprs[0] ?? 0})`;
  }
  if (stat) {
    fl.stat.add(k);
    const at2 = memo(fl.lits, exprs.join(", "), () => fl.img.push(...exprs) - exprs.length);
    return `term_ctr(${cid}, STAT_OFF + ${at2})`;
  }
  const alloc = `heap_alloc(e, cls_fit(${exprs.length}))`;
  const at = fl.spares.findIndex((s2) => cls_fit(s2.words) === cls_fit(exprs.length));
  const s = at < 0 ? null : fl.spares.splice(at, 1)[0];
  const got = s === null ? alloc : s.z ? `${s.name} >= HEAP_OFF ? ${s.name} : ${alloc}` : s.name;
  return `term_ctr(${cid}, ${node_fill(fl, "nd", got, exprs, fl.hot.has(k))})`;
}
function facts_packed(fl, t) {
  const s = term_strip2(t);
  return s.$ === "Ctr" && lay_packed(lay_node(fl.book, s.k));
}
function mat_head(t) {
  return t.$ === "Mat" || t.$ === "Efq";
}
function mat_arms(t) {
  const arms = [];
  let end = t;
  for (let m = term_strip2(end);m.$ === "Mat"; m = term_strip2(end)) {
    arms.push([m.k, m.h]);
    end = m.m;
  }
  return { arms, end };
}
function mat_lits(x) {
  const ws = [];
  const key = (t) => JSON.stringify(term_lower(t), (k, v) => k === "s" ? undefined : v?.$ === "Ann" ? term_strip(v) : v);
  const walk = (t, j, n, cov) => {
    const h = mat_arms(t).arms[0]?.[1];
    if (h && j === 32) {
      ws.push([h, j, n, 0]);
      return;
    }
    const { arms, end } = mat_arms(h ?? t);
    const inst = (w2) => (h ? w2.x : [w2]).reduce((f, a) => term_apply(f, a), end);
    const w = Ctr("WCon", [probe("b"), probe("t")]);
    const own = arms.length < 2 && (!cov || key(cov(w)) !== key(inst(w)));
    const sub = own ? inst : cov;
    for (const [k, a] of arms) {
      walk(a, j + 1, n + (k === "True" ? 2 ** j : 0), sub && ((v) => sub(Ctr("WCon", [Ctr(k, []), v]))));
    }
    if (own) {
      ws.push([end, j, n, h ? 2 : 1]);
    }
  };
  walk(mat_arms(x).arms[0][1], 0, 0, null);
  return ws;
}
function mat_rows(fl, x, ty) {
  const all = ty_all(fl.book, ty);
  const adt = adt_of(fl.book, all.A);
  const ret = all.B(DUMMY);
  if (adt.k === "Nat") {
    const rows2 = [];
    for (let m = x, n = 0;; n++) {
      const { arms, end } = mat_arms(m);
      const { Zero, Succ } = Object.fromEntries(arms);
      rows2.push([Zero ?? end, 64, n, Zero ? 0 : 1]);
      m = term_strip2(Succ ?? end);
      if (!Succ || m.$ !== "Mat") {
        rows2.push([Succ ?? end, 0, Succ ? n + 1 : n, 1]);
        return { adt, ret, rows: rows2, cells: rows2.map(([h]) => h) };
      }
    }
  }
  const rows = WORDS[adt.k] === W32 ? mat_lits(x) : null;
  if (adt.k !== "U32" || rows === null) {
    return { adt, ret, rows, cells: null };
  }
  const hit = new Map(rows.flatMap(([h, j, n]) => j === 32 ? [[n, h]] : []));
  const out = rows.filter(([, j]) => j < 32);
  const rs = new Set(out.map(([o]) => emit_row(fl, o, ret)));
  const len = Math.max(-1, ...hit.keys()) + 1;
  return { adt, ret, rows, cells: hit.size * 2 > len && rs.size === 1 ? [...Array(len + 1)].map((_, i) => hit.get(i) ?? out[0][0]) : null };
}
function lits_cond(w, j, n) {
  return j >= 32 ? `${w} == ${n}` : `(${w} & ${2 ** j - 1}) == ${n}`;
}
function mat_ctrs(fl, x, adt, keep = false) {
  const { arms, end } = mat_arms(x);
  return keep || arms.length < book_adt(fl.book, adt, Emp()).c.length ? [...arms, ["", end]] : arms;
}
function fun_of(fl, k) {
  return memo(FUNS, k, () => {
    const tld = fl.book.tlds[k];
    if (tld?.$ !== "Def") {
      return { n: 0, h: null, live: [], lays: [BOX, BOX], ret: BOX };
    }
    const doms = tele_unbind2(fl.book, tld.T).doms;
    const h = tld.e ? term_higher(tld.e) : null;
    const n = tld.n + (h === null ? 0 : Math.min(def_raise(fl.book, h, tld.n), doms.length - tld.n));
    const live = doms.slice(0, n).filter(dom_live);
    const lays = live.map(([, , A]) => lay_of(fl.book, A));
    if (def_foreign(tld)) {
      return { n, h, live, lays: [...lays.map(() => BOX), BOX], ret: BOX };
    }
    const ret = lay_of(fl.book, tele_fill(fl.book, tld.T, Array(n).fill(DUMMY), ctx_nil()));
    const wide = lays.flatMap((l) => l.ks).length > WIDE;
    return { n, h, live, lays: lays.map((l) => wide && l.ks.length > 1 ? BOX : l), ret: ret.ks.length === 0 ? BOX : ret };
  });
}
function brw_of(fl, k) {
  return memo(BRWS, k, () => {
    const { live, lays } = fun_of(fl, k);
    return lays.map((l, i) => done_live(fl.book.tlds[k]) && l.ks.includes("box") && ty_adt(fl.book, live[i][2])?.k !== "Array" && !fl.own.has(k + "~" + i));
  });
}
function def_raise(book, t, left) {
  const s = term_strip2(t);
  if (s.$ === "Lam") {
    const b = term_open(s).b;
    return left > 0 ? def_raise(book, b, left - 1) : 1 + def_raise(book, b, 0);
  }
  if (s.$ === "Mat") {
    return Math.min(def_raise(book, s.h, left - 1 + book.ctrs[s.k].n), def_raise(book, s.m, left));
  }
  return s.$ === "Efq" ? 99 : 0;
}
function def_foreign(tld) {
  return tld?.$ === "Def" && tld.i !== undefined;
}
function done_live(tld) {
  return tld?.$ === "Def" && tld.v !== null;
}
function fun_runs(tld) {
  return done_live(tld) || def_foreign(tld);
}
function done_defs(fl, live = done_live) {
  return [...SRCS.keys()].map((k) => [k, fl.book.tlds[k]]).filter(([, d]) => live(d));
}
function loop_of(fl, k) {
  const stack = [];
  const visit = (k2) => {
    const id = stack.push(k2) - 1;
    let low = id;
    let self = false;
    if (done_live(fl.book.tlds[k2])) {
      term_any(fl, fun_of(fl, k2).h, (s, tail) => {
        const d = tail ? term_spine(fl, s).k : null;
        if (d !== null && done_live(fl.book.tlds[d])) {
          const at = stack.indexOf(d);
          self ||= d === k2;
          low = Math.min(low, at >= 0 ? at : LOOPS.has(d) ? low : visit(d));
        }
        return false;
      });
    }
    if (low === id) {
      const all = stack.splice(id);
      all.forEach((d) => LOOPS.set(d, all.length > 1 || self ? all : []));
    }
    return low;
  };
  return memo(LOOPS, k, () => (visit(k), LOOPS.get(k)));
}
function flat_of(k) {
  return memo(FLATS, k, () => {
    const deps = SRCS.get(k);
    FLATS.set(k, false);
    return deps != null && [...deps].every(flat_of);
  });
}
function io_base(book, t) {
  const io = book.tlds["IO"];
  if (io?.$ !== "Def" || !io.b) {
    return null;
  }
  const tlds = Object.assign(Object.create(book.tlds), { IO: { ...io, v: null } });
  const [h, xs] = term_unapply(term_wnf({ ...book, tlds }, t));
  return h.$ === "Ref" && h.k === "IO" ? xs : null;
}
function io_type(book) {
  const main = book.tlds["main"];
  const xs = main?.$ === "Def" ? io_base(book, main.T) : null;
  if (xs && def_foreign(main)) {
    die("main must be a filled def: a foreign main cannot anchor IO");
  }
  return xs?.length === 1 ? xs[0] : null;
}
function io_run(book, args) {
  const src = `${js_lib(book)}
${RUNTIME_MAIN}
cli_args = ${JSON.stringify(args)};
return io_run(${js_sat("main")});`;
  return new Function("require", src)(import.meta.require);
}
function file_book(book, roots, js) {
  BVY_PD_PHASE("file_book", "enter");
  for (const k of OWNED) {
    if (book.tlds[k] && !book.tlds[k].b) {
      die(name_key(k) + " is a name the compiler encodes itself: name yours apart");
    }
  }
  for (const [k, tld] of Object.entries(book.tlds)) {
    if (def_foreign(tld) && k in book.ctrs) {
      die(name_key(k) + " names both a constructor and a foreign def: name one apart");
    }
  }
  [
    TELES,
    SRCS,
    LOOPS,
    NODES,
    LAYS,
    LAY_IDS,
    FLATS,
    FUNS,
    BRWS,
    IDS,
    TAKEN
  ].forEach((m) => m.clear());
  "FID_EXIT FID_ENTER FID_T CID_T".split(" ").forEach((id) => TAKEN.add(id));
  PROBES.length = 1;
  const fl = {
    book,
    js,
    bangs: new Set,
    sites: new Map,
    hot: new Set,
    stat: new Set,
    own: new Set,
    lend: new Set,
    segs: [],
    spins: [],
    spun: new Map,
    clos: new Set,
    tabs: new Map,
    tails: new Map,
    img: [],
    lits: new Map,
    consts: new Map,
    fresh: new Map,
    brwl: new Map,
    seg: seg_new("", BOX, []),
    spares: [],
    uses: new Map,
    rest: [],
    def: ""
  };
  const queue = roots.slice();
  for (const d of queue) {
    if (SRCS.has(d)) {
      continue;
    }
    memo_gc();
    const tld = book.tlds[d];
    SRCS.set(d, null);
    for (const x of tld?.$ === "ADT" ? tld.c : tld ? [tld] : []) {
      queue.push(...type_adts(fl, x.T));
    }
    if (!done_live(tld)) {
      continue;
    }
    const deps = new Set;
    const refs = new Set;
    let flat = true;
    term_any(fl, fun_of(fl, d).h, (s, tail) => {
      if (s.$ === "Ann") {
        queue.push(...type_adts(fl, s.T));
      }
      if (s.$ === "Ref") {
        if (s.b) {
          fl.bangs.add(s.k);
        }
        if (intr_of(fl, s.k) === undefined) {
          refs.add(s.k);
          fl.sites.set(s.k, (fl.sites.get(s.k) ?? 0) + 1);
        }
      }
      const ck = term_spine(fl, s);
      if (ck.k !== null && ck.k !== d) {
        deps.add(ck.k);
      }
      flat &&= !(s.$ === "Let" && s.k.length >= 2 || ck.k !== null && (ck.b || ck.k === d && !tail));
      return false;
    });
    SRCS.set(d, flat ? deps : null);
    queue.push(...refs);
  }
  BVY_PD_PHASE("file_book", "exit");
  return fl;
}
function facts_hot(fl, B, force, local = false) {
  const w = ty_wnf(fl.book, B);
  if (w?.$ === "Lam") {
    return facts_hot(fl, w.f(DUMMY), force, local);
  }
  if (w?.$ !== "ADT") {
    if (!force) {
      return;
    }
    const m = w?.$ === "App" && term_spine(fl, w);
    const fam = m && done_live(m.tld) && term_strip2(term_unapply(m.all.reduce((b, x) => term_apply(b, x), m.tld.v))[0]);
    if (m && fam && fam.$ === "Mat") {
      m.all.forEach((x) => facts_hot(fl, x, true, local));
      const key = "m:" + m.t.k;
      if (!fl.hot.has(key)) {
        fl.hot.add(key);
        facts_hot(fl, fam, true, local);
      }
      return;
    }
    if (w?.$ === "Mat") {
      return term_kids(fl, w).forEach((h) => facts_hot(fl, h, true, local));
    }
    const dom = w?.$ === "Var" && !local && tele_unbind2(fl.book, fl.book.tlds[fl.def].T).doms[w.i];
    if (dom && dom[1] === w.k && !dom_live(dom)) {
      fl.hot.add(fl.def + "~" + w.i);
    } else if ("All Var App".includes(w?.$)) {
      fl.hot.add("*");
    }
    return;
  }
  const tk = "t:" + w.k;
  const hot = force || fl.hot.has(tk);
  w.x.forEach((x) => facts_hot(fl, x, hot, local));
  if (!hot || fl.hot.has(tk)) {
    return;
  }
  fl.hot.add(tk);
  const tld = fl.book.tlds[w.k];
  if (tld?.$ === "ADT") {
    for (const c of tld.c) {
      fl.hot.add(c.k);
      facts_ctr(fl, c, w.x);
    }
  }
}
function facts_ctr(fl, c, xs) {
  const ds = ctr_tail(fl.book, c, xs);
  const own = !ds.every(dom_live);
  ds.filter(dom_live).forEach(([, , A]) => facts_hot(fl, A, true, own));
}
function file_push(fl, line) {
  fl.seg.lines.push(line);
}
function block(fl, open, go) {
  file_push(fl, open);
  go();
  file_push(fl, "}");
}
function cls_fit(words) {
  return 32 - Math.clz32(words - 1);
}
function spare_free(fl, s) {
  file_push(fl, `${s.z ? "spare_free" : "heap_free"}(e, cls_fit(${s.words}), ${s.name});`);
}
function spare_flush(fl) {
  fl.spares.splice(0).reverse().forEach((s) => spare_free(fl, s));
}
function seg_new(name, ret, params, ks = params.map(() => "w64"), frame = null) {
  return {
    fid: seg_fid(name),
    def: name,
    ret,
    lines: [],
    params,
    ks,
    frame,
    refs: new Set
  };
}
function seg_fid(k) {
  return name_id("FID_", k);
}
function seg_take(seg) {
  const { pop, at } = seg.frame ?? { pop: 0, at: [] };
  return [...pop > 0 ? [`WL_POPN(${pop});`] : [], ...seg.params.map((p, i) => `${lay_c(seg.ks[i])} ${p} = ${i < at.length ? `STK(${at[i]})` : `r${i - at.length}`};`)];
}
function seg_text(lines, tab) {
  return lines.map((l) => {
    const out = "  ".repeat(tab -= Number(l.startsWith("}"))) + l;
    tab += Number(l.endsWith("{"));
    return out;
  });
}
function seg_ref(fl, fid) {
  fl.seg.refs.add(fid);
  return fid;
}
function seg_clo(fl, fid, words) {
  fl.clos.add(fid);
  return `term_clo(${seg_ref(fl, fid)}, ${words.length === 0 ? 0 : node_fill(fl, "nd", `heap_alloc(e, cls_fit(${words.length}))`, words)})`;
}
function seg_name(fl, stem) {
  return fl.seg.def.split("$")[0] + "$" + stem + fl.segs.length;
}
function seg_open(fl, name, ret, frame, live, res, rest) {
  const olds = live.flatMap(([, b]) => b.val.ws);
  const news = olds.map((w) => name_local(fl, w.replace(/_\d+$/, "")));
  const seg = seg_new(name, ret, [...news, ...res.ws], [...live.flatMap(([, b]) => b.val.lay.ks), ...res.lay.ks], frame);
  fl.segs.push(seg);
  fl = { ...fl, seg, spares: [], uses: new Map };
  olds.forEach((w, i2) => {
    if (fl.brwl.has(w)) {
      fl.brwl.set(news[i2], fl.brwl.get(w));
    }
  });
  let i = 0;
  live.forEach(([p, b]) => bind_uses(fl, p, val_new(news.slice(i, i += b.val.ws.length), b.val.lay), rest, b.A, false));
  return fl;
}
function node_fill(fl, k, alloc, exprs, shr = false) {
  const nd = name_local(fl, k);
  file_push(fl, `u64 ${nd} = ${alloc};`);
  exprs.forEach((w, j) => file_push(fl, `e.mem[${nd} + ${j}] = ${shr ? `rfc_seal(e, ${w})` : w};`));
  return nd;
}
function node_fields(fl, t, k, tail = false) {
  const node = lay_node(fl.book, k);
  const n = node.ks.length;
  if (lay_packed(node)) {
    return node.arms[k].map((lay) => val_new(lay.ks.map(() => `term_loc(${t})`), lay));
  }
  const r = fl.brwl.get(t);
  const z = r === undefined && (fl.hot.has(k) || fl.stat.has(k));
  const sp = name_local(fl, "sp");
  let fb = `e.mem[${sp} + `;
  let at = (r === undefined ? "term_loc(" : "term_peek(e.mem, ") + t + ")";
  if (z) {
    fb = name_local(fl, "fb");
    file_push(fl, `Term ${fb}[${n}];`);
    at = `ctr_take(e, ${t}, ${n}, ${fb})`;
    fb += "[";
  }
  file_push(fl, `u64 ${sp} = ${at};`);
  const ws = emit_hold(fl, node.ks.map((_, j) => `${fb}${j}]`), "f", node.ks);
  if (r !== undefined) {
    ws.forEach((w, j) => {
      if (node.ks[j] === "box") {
        fl.brwl.set(w, r);
      }
    });
  } else if (tail) {
    fl.spares.push({ words: n, name: sp, z });
  } else {
    spare_free(fl, { words: n, name: sp, z });
  }
  return val_arm(val_new(ws, node));
}
function val_new(ws, lay, stat = false) {
  return { ws, lay, stat };
}
function val_arm(v, k = Object.keys(v.lay.arms)[0]) {
  let at = Number(Object.keys(v.lay.arms).length > 1);
  return v.lay.arms[k].map((lay) => val_new(v.ws.slice(at, at += lay.ks.length), lay));
}
function val_hold(fl, v, k) {
  return val_new(v.ws.map((w, j) => emit_alias(fl, w, k, v.lay.ks[j])), v.lay);
}
function val_own(fl, v, at = null, held = false) {
  v.ws.forEach((w, j) => {
    const r = fl.brwl.get(w);
    if (r !== undefined && at !== null) {
      fl.lend.add(at + "<" + r);
    } else if (r !== undefined || at !== null && !held && v.lay.ks[j] === "box") {
      fl.own.add(r ?? at);
    }
  });
  return v.ws;
}
function val_owned(fl, v) {
  return v.ws.filter((w, j) => v.lay.ks[j] === "box" && !fl.brwl.has(w));
}
function val_brw(fl, v) {
  return val_owned(fl, v).length === 0;
}
function val_sink(fl, v) {
  val_owned(fl, v).forEach((w) => file_push(fl, `term_sink(e, ${w});`));
}
function val_to(fl, v, lay) {
  return lay_eq(v.lay, lay) ? v : lay_box(lay) ? val_new([val_box(fl, v)], BOX) : lay_box(v.lay) ? val_unbox(fl, v, lay) : val_arms(fl, lay, v.ws[0], (k) => val_arm(v, k));
}
function val_arms(fl, lay, sel, read, cond = (t, i) => `${t} == ${i}`) {
  const arms = Object.keys(lay.arms);
  const ws = (k) => read(k).flatMap((f, j) => val_to(fl, f, lay.arms[k][j]).ws);
  if (arms.length <= 1) {
    return val_new(arms.flatMap(ws), lay);
  }
  const out = emit_dst(fl, lay, "o").ws;
  const t = emit_alias(fl, sel, "t");
  const rs = out.map(() => []);
  emit_chain(fl, (i) => cond(t, i), arms.map((k, i) => () => {
    file_push(fl, `${out[0]} = ${i};`);
    ws(k).forEach((w, n) => {
      rs[1 + n].push(fl.brwl.get(w) ?? "");
      file_push(fl, `${out[1 + n]} = ${w};`);
    });
  }));
  rs.forEach((r, k) => {
    if (r[0] && r.every((x) => x === r[0])) {
      fl.brwl.set(out[k], r[0]);
    } else {
      r.filter((x) => x).forEach((x) => fl.own.add(x));
    }
  });
  return val_new(out, lay);
}
function val_box(fl, v) {
  if (v.lay.arms === null) {
    return val_own(fl, v)[0];
  }
  const arms = Object.keys(v.lay.arms);
  const build = (bl, k) => ctr_build(bl, k, val_arm(v, k).flatMap((f, j) => val_own(bl, val_to(bl, f, lay_node(fl.book, k).arms[k][j]))));
  if (arms.length <= 1) {
    return arms.length === 0 ? "0" : build(fl, arms[0]);
  }
  const out = emit_hold(fl, ["0"], "b")[0];
  const tag = emit_alias(fl, v.ws[0], "t");
  emit_chain(fl, (i) => `${tag} == ${i}`, arms.map((k) => () => {
    const bl = { ...fl, spares: [] };
    file_push(bl, `${out} = ${build(bl, k)};`);
    spare_flush(bl);
  }));
  return out;
}
function val_unbox(fl, v, lay) {
  if (lay.arms === null) {
    return val_new(v.ws, lay);
  }
  const t = emit_alias(fl, v.ws[0], "u");
  return val_arms(fl, lay, t, (k) => node_fields(fl, t, k), (_, i) => `term_aux(${t}) == ${cid_mac(Object.keys(lay.arms)[i])}`);
}
function arr_cells(fl, l, at, el, box) {
  return val_new(emit_hold(fl, el.ks.map((k, j) => k === "box" ? box.replaceAll("$", `${l} + ${at} + ${j}`) : `blk_read(e.mem, ${Number(lay_arr(el).arr)}, ${l}, ${at} + ${j})`), "c", el.ks), el);
}
function arr_new(fl, d, v, el) {
  const { arr, lgs } = lay_arr(el);
  const ws = val_own(fl, val_to(fl, v, el));
  const fv = name_local(fl, "fv");
  file_push(fl, `Term ${fv}[${Math.max(1, ws.length)}];`);
  ws.forEach((w, j) => file_push(fl, `${fv}[${j}] = ${w};`));
  return `blk_new(e, ${Number(arr)}, ${d}, ${lgs}, ${ws.length}, ${fv})`;
}
function arr_q(fl, k) {
  return k === "box" && fl.hot.has("t:Array");
}
function arr_loc(fl, a) {
  const p = fl.seg.params.indexOf(a);
  return fl.seg.ks.reduce((s, k, i) => fl.seg.fid.startsWith("spin_") && arr_q(fl, k) && (p < 0 || p === i) ? `${a} == h${i} ? q${i} : ${s}` : s, `blk_loc(e.mem, ${a})`);
}
function arr_op(fl, k, el, args) {
  const { arr, lgs } = lay_arr(el);
  if (k === "array_new") {
    return val_new([arr_new(fl, args[0].ws[0], args[1], el)], BOX);
  }
  const a = emit_alias(fl, val_own(fl, args[0])[0], "a");
  if (k === "array_size") {
    return val_new([a, `(1ull << (blk_cls(${a}) - ${lgs}))`], lay_pack([["Tuple", [BOX, W32]]]));
  }
  const [l, at] = emit_hold(fl, [
    arr_loc(fl, a),
    `blk_at(${a}, ${args[1].ws[0]}, ${lgs})`
  ], "at");
  const old = arr_cells(fl, l, at, el, k === "array_get" ? "blk_keep(e, $)" : "e.mem[$]");
  if (k !== "array_get") {
    val_own(fl, val_to(fl, args[2], el)).forEach((w, j) => file_push(fl, `blk_write(e.mem, ${Number(arr)}, ${l}, ${at} + ${j}, ${w});`));
    if (k !== "array_swap") {
      val_sink(fl, old);
      return val_new([a], BOX);
    }
  }
  return val_new([a, ...old.ws], lay_pack([["Tuple", [BOX, el]]]));
}
function arr_leaf(fl, s, el) {
  const got = arr_cells(fl, arr_loc(fl, s), "0", el, `blk_shr(${s}) ? blk_keep(e, $) : e.mem[$]`);
  file_push(fl, `blk_free(e, ${s});`);
  return got;
}
function bind_pop(fl, x) {
  const p = probe_of(x);
  const b = fl.uses.get(p);
  if (b.n <= 1) {
    fl.uses.delete(p);
    return b.val;
  }
  fl.uses.set(p, { ...b, n: b.n - 1 });
  val_owned(fl, b.val).forEach((w) => {
    file_push(fl, `${w} = term_keep(e, ${w}, 1);`);
    facts_hot(fl, b.A, true);
  });
  return b.val;
}
function bind_uses(fl, p, v, rest, A, fresh = true) {
  const n = rest_use(fl, rest, p);
  const lay = lay_of(fl.book, A);
  if (fresh && n > 1 && lay_box(v.lay) && !lay_box(lay) && !val_brw(fl, v)) {
    v = val_unbox(fl, v, lay);
  }
  facts_hot(fl, A, fl.hot.has("*"));
  bind_set(fl, p, { val: v, n, A }, n);
}
function bind_set(fl, p, b, n) {
  if (n > 0) {
    fl.uses.set(p, { ...b, n });
  } else {
    fl.uses.delete(p);
    val_sink(fl, b.val);
  }
}
function bind_dead(fl, rest, ps = [...fl.uses.keys()]) {
  for (const p of ps) {
    const b = fl.uses.get(p);
    if (b) {
      bind_set(fl, p, b, Math.min(b.n, rest_use(fl, rest, p)));
    }
  }
}
function die(m) {
  throw new Error(m);
}
function memo(m, k, f) {
  let v = m.get(k);
  if (v === undefined) {
    m.set(k, v = f(k));
  }
  return v;
}
function memo_gc() {
  BVY_PD_CHECK("memo_gc");
  [OPENS, USES, FOLDS, SPINES, CONSTS, LITS].forEach((m) => m.clear());
}
function show_main(book) {
  const main = book.tlds.main;
  if (!book.tlds.IO) {
    die("a build needs import Base");
  }
  if (!fun_runs(main)) {
    die("no main to run");
  }
  if (io_type(book) !== null) {
    return null;
  }
  const show = [];
  let names = 0;
  const lays = new Map;
  const refuse = () => die("main's type " + term_show(term_lower(main.T)) + " cannot be printed (a function, a Type, an" + " erased or dependent field)");
  const node = (T, lay2) => {
    const t = ty_wnf(book, T);
    const box = lay_box(lay2);
    const key = term_key(term_lower(t));
    const ids = memo(lays, lay2, () => new Map);
    const adt = ty_adt(book, t);
    const tld = adt && book.tlds[adt.k];
    const kind = t.$ === "Eql" ? 5 : "U32 F32 Nat Char String . Array".split(" ").indexOf(adt?.k ?? "") & 7;
    if (ids.has(key)) {
      return ids.get(key);
    }
    if (kind !== 5 && (tld?.$ !== "ADT" || adt?.k === "IO.OP")) {
      return refuse();
    }
    const id = show.push(kind) - 1;
    ids.set(key, id);
    const refs = [];
    if (kind === 3) {
      show.push(Number(box));
    } else if (kind === 6) {
      const el = lay_el(book, adt.x[0]);
      refs.push([show.push(0, lay_arr(el).lgs) - 2, adt.x[0], el]);
    } else if (kind === 7 && tld?.$ === "ADT") {
      show.push(Number(box), tld.c.length);
      for (const c of tld.c) {
        const fs3 = (box ? lay_node(book, c.k) : lay2).arms[c.k];
        const doms = ctr_tail(book, c, adt.x);
        let at = Number(!box && tld.c.length > 1);
        show.push(names++, c.k, doms.length, c.k === "Tuple" ? 2 : Number(c.k === "Con" || c.k === "Nil"));
        for (const [f, d] of doms.entries()) {
          if (!dom_live(d)) {
            refuse();
          }
          refs.push([show.push(at, 0) - 1, d[2], fs3[f]]);
          at += fs3[f].ks.length;
        }
      }
    }
    for (const [at, T2, l] of refs) {
      show[at] = node(T2, l);
    }
    return id;
  };
  const lay = lay_of(book, main.T);
  node(main.T, lay.ks.length === 0 ? BOX : lay);
  return show;
}
function anf(fl, t, ty = null) {
  const binds = [];
  const cut = (r, T) => {
    if (term_spine(fl, r).k === null || flat_call(fl, r)) {
      return r;
    }
    const p = probe("h");
    binds.push([p, Ann(r, T)]);
    return Ann(p, T);
  };
  const go = (u, top, T) => {
    const s = term_force2(u);
    if (term_const(s)) {
      return s;
    }
    switch (s.$) {
      case "Ann": {
        const x2 = go(s.x, top, s.T);
        return x2 === s.x ? s : Ann(x2, s.T, s.s);
      }
      case "Rwt": {
        return go(s.f, top, T);
      }
      case "Ctr": {
        const on2 = ctr_flds(fl.book, s.k, s.x);
        const xs = s.x.map((x2) => on2.includes(x2) ? go(x2, false, null) : x2);
        return xs.every((x2, j) => x2 === s.x[j]) ? s : Ctr(s.k, xs, s.s);
      }
      case "Ref":
      case "App": {
        const m = term_spine(fl, s);
        const spine = (v) => {
          const f = term_force2(v);
          if (f.$ === "Ann") {
            const x3 = spine(f.x);
            return x3 === f.x ? f : Ann(x3, f.T, f.s);
          }
          if (f.$ !== "App") {
            return f;
          }
          if (m.t.$ === "Var" && !m.args.includes(f.x)) {
            return spine(f.f);
          }
          const g = cut(spine(f.f), ty_ann(f.f));
          const x2 = m.args.includes(f.x) ? go(f.x, false, null) : f.x;
          return g === f.f && x2 === f.x ? f : App(g, x2, f.s);
        };
        const r = spine(s);
        return top ? r : cut(r, T);
      }
      case "Let": {
        const o2 = term_open(s);
        const on2 = let_live(fl, s);
        for (const [j, v] of s.v.entries()) {
          if (on2[j]) {
            binds.push([o2.ps[j], go(v, true, null)]);
          }
        }
        return go(o2.b, top, T);
      }
      case "Lam": {
        const all = T && tele_open(fl.book, T);
        return all === null || quant_live(all.q) ? s : Ann(go(s.f(DUMMY), top, all.B(DUMMY)), all.B(DUMMY));
      }
      default: {
        return s;
      }
    }
  };
  const wrap = (b) => binds.reduceRight((b2, [p, v]) => let_open([p], [v], b2), b);
  const x = term_force2(t);
  if (x.$ !== "Let") {
    const b = go(x, true, ty);
    return wrap(binds.length === 0 || ty === null ? b : Ann(b, ty));
  }
  const o = term_open(x);
  const on = let_live(fl, x);
  const ps = o.ps.filter((_, j) => on[j]);
  const vs = x.v.filter((_, j) => on[j]);
  if (ps.length === 0) {
    return o.b;
  }
  if (ps.length >= 2 && vs.some((v) => term_spine(fl, v).k === null)) {
    return anf(fl, ps.reduceRight((b, p, j) => let_open([p], [vs[j]], b), o.b));
  }
  const ws = vs.map((v) => go(v, true, null));
  return wrap(on.every(Boolean) && ws.every((w, j) => w === x.v[j]) ? x : let_open(ps, ws, o.b));
}
function emit_hold(fl, exprs, k, ks) {
  return exprs.map((ex, i) => {
    const al = name_local(fl, k);
    const ty = fl.js ? "const" : lay_c(ks?.[i] ?? "w64");
    file_push(fl, `${ty} ${al} = ${ex};`);
    return al;
  });
}
function emit_alias(fl, e, k, kd) {
  return /^\w*_\d+$/.test(e) ? e : emit_hold(fl, [e], k, kd && [kd])[0];
}
function emit_task(fl, fid, rem, words, cont = "WL_CONT", idx = "WL_IDX") {
  return node_fill(fl, "t", `task_node(e, ${seg_ref(fl, fid)}, ${cont}, ${idx}, ${rem})`, words);
}
function emit_jump(fl, args, k, bang) {
  const fid = seg_fid(k);
  fl.seg.fork ||= bang;
  if (bang || fl.seg.def !== k) {
    block(fl, `if (${bang ? "!seq" : `!DEVICE && !seq && fid_nofk(${fid})`}) {`, () => file_push(fl, `return term_tsk(${fid}, ${emit_task(fl, fid, 0, args)});`));
  }
  args.forEach((a, i) => file_push(fl, `r${i} = ${a};`));
  if (fl.seg.def !== k) {
    return file_push(fl, `WL_JMP(${seg_ref(fl, fid)});`);
  }
  fl.seg.spin = true;
  fl.seg.params.forEach((p, i) => file_push(fl, `${p} = r${i};`));
  file_push(fl, `WL_AGAIN(${fl.seg.fid});`);
}
function emit_args(fl, ck, jump = false, fork = false) {
  const k = ck.k;
  const brw = brw_of(fl, k);
  ck.all.forEach((a, q) => {
    if (fl.hot.has(k + "~" + q)) {
      facts_hot(fl, a, true);
    }
  });
  const xs = ck.xs.map(term_strip2);
  const vars = xs.filter((x) => x.$ === "Var");
  const lays = fun_of(fl, k).lays;
  const vs = ck.xs.map((a, i) => xs[i].$ === "Var" ? null : emit_expr({ ...fl, rest: [...xs.slice(i + 1).filter((x) => x.$ !== "Var"), ...vars, ...fl.rest] }, a, null, lays[i]));
  xs.forEach((x, i) => vs[i] ??= brw[i] ? null : bind_pop(fl, x));
  return xs.flatMap((x, i) => {
    const at = k + "~" + i;
    let b = vs[i];
    if (b === null) {
      const p = probe_of(x);
      const bd = fl.uses.get(p);
      const twin = vars.filter((y) => probe_of(y) === p).length > 1;
      const dead = rest_use(fl, fl.rest, p) === 0;
      if (!dead || !jump && twin) {
        fl.lend.add(at);
      } else {
        val_own(fl, bd.val, at, !jump);
      }
      if (dead && !twin && val_brw(fl, bd.val)) {
        fl.uses.delete(p);
      } else if (!fork) {
        fl.uses.set(p, { ...bd, n: Math.max(bd.n - 1, 1) });
      }
      b = bd.val;
    }
    const v = val_to(fl, b, lays[i]);
    return !brw[i] ? val_own(fl, v) : vs[i] === null && v === b || facts_packed(fl, x) ? v.ws : val_own(fl, v, at);
  });
}
function emit_each(fl, xs, ats = []) {
  return xs.map((x, i) => emit_expr({ ...fl, rest: [
    ...xs.slice(i + 1),
    ...fl.rest
  ] }, x, null, ats[i] ?? null));
}
function emit_put(fl, dst, v) {
  if (dst === null) {
    spare_flush(fl);
  }
  const ws = val_own(fl, val_to(fl, v, dst?.lay ?? fl.seg.ret));
  ws.forEach((w, j) => file_push(fl, `${dst?.ws[j] ?? "r" + j} = ${w};`));
  if (dst === null) {
    file_push(fl, `WL_RETN(${ws.length});`);
  }
}
function emit_fuse(fl, ck, dst, tail = false) {
  const k = ck.k;
  const T = fl.book.tlds[k].T;
  const doms = tele_unbind2(fl.book, T).doms;
  const { n, h, lays, ret } = fun_of(fl, k);
  const ers = ck.all.filter((_, i) => i < n && !dom_live(doms[i]));
  const flat = flat_of(k);
  const ws = emit_args(fl, ck, tail && !flat);
  if (!flat) {
    return emit_body({ ...fl, def: k }, h, T, ers, lays.map((lay) => val_new(ws.splice(0, lay.ks.length), lay)), dst);
  }
  const out = emit_dst(fl, ret);
  const name = emit_native(fl, k, ers);
  const o = name_local(fl, "o");
  file_push(fl, `Term ${o}[${out.ws.length}];`);
  const ks = lays.flatMap((l) => l.ks);
  const xs = ws.flatMap((w, i) => !arr_q(fl, ks[i]) ? [w] : [w = emit_alias(fl, w, "a"), arr_loc(fl, w)]);
  block(fl, `if (${name}(${["e", o, ...xs].join(", ")}) == 0) {`, () => file_push(fl, "return 0;"));
  out.ws.forEach((v, j) => file_push(fl, `${v} = ${o}[${j}];`));
  bind_dead(fl, tail ? [] : fl.rest, tail ? undefined : ck.xs.map(term_strip2).filter((x) => x.$ === "Var").map(probe_of));
  emit_put(fl, dst, out);
}
function emit_open(fl, k) {
  FUEL = FOLD_FUEL;
  const { live, lays, ret } = fun_of(fl, k);
  const vals = lays.map((l, i) => val_new(l.ks.map(() => name_local(fl, live[i][1])), l));
  brw_of(fl, k).forEach((b, i) => vals[i].ws.forEach((w, j) => {
    if (b && lays[i].ks[j] === "box") {
      fl.brwl.set(w, k + "~" + i);
    }
  }));
  const seg = seg_new(k, ret, vals.flatMap((v) => v.ws), vals.flatMap((v) => v.lay.ks));
  return [{ ...fl, seg, spares: [], uses: new Map, def: k }, vals];
}
function emit_native(fl, k, ers) {
  const key = [k, ...ers.map((e) => memo(LAY_IDS, lay_of(fl.book, e), () => LAY_IDS.size))].join("|");
  const got = fl.spun.get(key);
  if (got !== undefined) {
    return seg_ref(fl, got);
  }
  const name = seg_ref(fl, `spin_${fl.spun.size}`);
  fl.spun.set(key, name);
  const fuel = FUEL;
  const [sl, vals] = emit_open(fl, k);
  const seg = sl.seg;
  seg.fid = name;
  const dst = val_new(seg.ret.ks.map(() => name_local(fl, "v")), seg.ret);
  emit_body(sl, fun_of(fl, k).h, fl.book.tlds[k].T, ers, vals, dst);
  FUEL = fuel;
  fl.spins.push({ ...seg, lines: [
    `${seg.lines.length < SPIN_FAR ? "INLINE" : "FAR"} Term ${name}(Env e, THR Term* o${seg.ks.map((k2, i) => `, ${lay_c(k2)} r${i}${arr_q(fl, k2) ? `, u64 q${i}` : ""}`).join("")}) {`,
    ...seg_text([
      "u32 wpoll = 0;",
      ...seg.ks.flatMap((k2, i) => arr_q(fl, k2) ? [`Term h${i} = r${i};`] : []),
      ...dst.ws.map((v, j) => `${lay_c(seg.ret.ks[j])} ${v} = 0;`),
      ...seg_take(seg),
      "WL_SPIN"
    ], 1),
    ...seg_text(seg.lines, 2),
    "  break;",
    "  }",
    ...dst.ws.map((v, j) => `  o[${j}] = ${v};`),
    "  return 1;",
    "}"
  ] });
  return name;
}
function emit_dst(fl, lay, k = "v") {
  return val_new(emit_hold(fl, lay.ks.map(() => "0"), k, lay.ks), lay);
}
function emit_intr(fl, it, m, ty) {
  const k = m.t.k;
  const args = emit_each(fl, m.args);
  const op = op_name(k);
  if ("array_get array_new array_clone".includes(op) && lay_el(fl.book, m.all[0]).ks.includes("box") && !(op === "array_new" && facts_packed(fl, m.all[2]))) {
    facts_hot(fl, m.all[0], true);
  }
  if (it.call === true && it.C === undefined) {
    return arr_op(fl, op, lay_el(fl.book, m.all[0]), args);
  }
  const ws = args.map((v, i) => val_own(fl, val_to(fl, v, fun_of(fl, k).lays[i]))[0]);
  const lay = lay_of(fl.book, ty);
  const C = it.C;
  const all = Array.isArray(C) || /\$(\d)[^]*\$\1/.test(C);
  const as = ws.map((w) => all || tpl_deep(w) ? emit_alias(fl, w, "a") : w);
  if (Array.isArray(C)) {
    C.forEach((p) => as.push(emit_alias(fl, tpl(p, as), "a")));
    return val_new(as.slice(ws.length), lay);
  }
  return val_new([tpl(C, as)], lay.ks.length === 1 ? lay : BOX);
}
function emit_clo(fl, x, ty) {
  const u = term_uses(fl, x);
  const live = [...fl.uses].filter(([p]) => term_use(u, p) > 0).map(([p, b]) => {
    fl.uses.set(p, { ...b, n: b.n - term_use(u, p) + 1 });
    return [p, { ...b, val: bind_pop(fl, p) }];
  });
  const words = live.flatMap(([, b]) => val_own(fl, b.val));
  const name = seg_name(fl, "c");
  const clo = seg_clo(fl, seg_fid(name), words);
  const arg = val_new([name_local(fl, "x")], BOX);
  emit_body(seg_open(fl, name, BOX, null, live, arg, [x]), x, ty, [], [arg], null);
  return val_new([clo], BOX);
}
function emit_ctr(fl, x, ty, at) {
  const [adt, u] = ctr_adt(fl, x, ty);
  if (u !== null) {
    return val_new([`${u}ull`], W32, true);
  }
  const flds = ctr_flds(fl.book, x.k, x.x);
  const word = WORDS[adt.k];
  if (word !== undefined) {
    const vs2 = emit_each(fl, flds);
    if (vs2.length === 1 && vs2[0].ws.length > 1) {
      return val_new([`(${vs2[0].ws.map((w2, i) => `((u64)${w2} << ${i})`).join(" | ")})`], word);
    }
    if (vs2.length === 0) {
      return val_new(["0"], word, true);
    }
    const w = adt.k === "Nat" ? tpl(tpl_nat("ull", "nat_chk(e, $0 + 1)"), [vs2[0].ws[0]]) : `term_word(e, ${vs2[0].ws[0]})`;
    return val_new([w], word, /^\d/.test(w));
  }
  if (adt.k === "Array") {
    const vs2 = emit_each(fl, flds);
    return val_new([x.k === "ALeaf" ? arr_new(fl, "0", vs2[0], lay_el(fl.book, adt.x[0])) : `blk_node(e, ${val_own(fl, vs2[0])[0]}, ${val_own(fl, vs2[1])[0]})`], BOX);
  }
  if (fl.hot.has(x.k)) {
    facts_ctr(fl, fl.book.ctrs[x.k], adt.x);
  }
  const pos = at ?? lay_of(fl.book, adt);
  const seen = memo(fl.consts, pos, () => new Map);
  const got = seen.get(x);
  if (got !== undefined) {
    return got;
  }
  const lay = lay_box(pos) ? lay_node(fl.book, x.k) : pos;
  const arms = Object.keys(lay.arms);
  const vs = emit_each(fl, flds, lay.arms[x.k]);
  const ws = [
    ...arms.length > 1 ? [String(arms.indexOf(x.k))] : [],
    ...vs.flatMap((f, j) => val_to(fl, f, lay.arms[x.k][j]).ws)
  ];
  const v = val_new(lay.ks.map((_, j) => ws[j] ?? "0"), lay, vs.every((f) => f.stat));
  const out = lay === pos ? v : val_new([ctr_build(fl, x.k, val_own(fl, v), v.stat)], BOX, v.stat);
  if (out.stat) {
    seen.set(x, out);
  }
  return out;
}
function emit_fold(fl, t) {
  const s = term_strip2(t);
  const r = memo(FOLDS, s, () => {
    if (term_const(s)) {
      return s;
    }
    const m = term_spine(fl, s);
    const it = m.t.$ === "Ref" ? intr_of(fl, m.t.k) : undefined;
    if (it === undefined) {
      const b = emit_unfold(fl, m);
      if (b === null) {
        return null;
      }
      term_any(fl, b, () => {
        FUEL -= 1;
        return false;
      });
      return term_any(fl, b, (y) => {
        if (y.$ === "App" || y.$ === "Ref") {
          emit_fold(fl, y);
        }
        return FUEL < 0;
      }) ? null : b;
    }
    const as = emit_fold_args(fl, m);
    return it.call === true ? null : as.every((a, i) => a === m.all[i]) ? s : as.reduce((f, x) => App(f, x), m.t);
  });
  const T = ty_ann(t);
  return r === s ? t : r === null || T === null ? r : Ann(r, T);
}
function emit_fold_args(fl, m) {
  return m.all.map((a) => m.args.includes(a) ? emit_fold(fl, a) ?? a : a);
}
function emit_unfold(fl, m) {
  if (m.t.$ !== "Ref") {
    return null;
  }
  const { h, n } = fun_of(fl, m.t.k);
  if (h == null || m.all.length !== n || !flat_of(m.t.k)) {
    return null;
  }
  const fs3 = emit_fold_args(fl, m);
  const walk = (xs) => {
    let b = h;
    let hit = m.args.every((a) => term_const(fs3[m.all.indexOf(a)]));
    for (let w = term_strip2(b);xs.length > 0; w = term_strip2(b)) {
      if (w.$ === "Lam") {
        b = w.f(xs[0]);
        xs = xs.slice(1);
        continue;
      }
      const c = w.$ === "Mat" ? term_strip2(xs[0]) : null;
      if (c?.$ !== "Ctr" || !term_const(c)) {
        return null;
      }
      const { arms, end } = mat_arms(w);
      const arm = arms.find(([k]) => k === c.k);
      b = arm?.[1] ?? end;
      xs = arm ? [...ctr_flds(fl.book, c.k, c.x), ...xs.slice(1)] : xs;
      hit = true;
    }
    return !hit || term_any(fl, b, (y) => y.$ === "Lam" || mat_head(y)) ? null : b;
  };
  const doms = tele_unbind2(fl.book, m.tld.T).doms;
  const bind = (i, ys) => {
    const a = fs3[i];
    return i === fs3.length ? walk(ys) : !m.args.includes(m.all[i]) || term_const(a) || term_strip2(a).$ === "Var" ? bind(i + 1, [...ys, a]) : Let(["a"], [0], [Ann(a, doms[i][2])], (xs) => bind(i + 1, [...ys, xs[0]]), undefined, [Many()]);
  };
  return walk(fs3) === null ? null : bind(0, []);
}
function emit_expr(fl, tm, ty0, at) {
  const [x, ty] = ty_peel(tm, ty0);
  switch (x.$) {
    case "Var": {
      return bind_pop(fl, x);
    }
    case "Ref":
    case "App": {
      const got = emit_fold(fl, x);
      if (got !== null && got !== x) {
        const a = term_uses(fl, x);
        const b = term_uses(fl, got);
        fl.uses.forEach((bd, p) => bind_set(fl, p, bd, bd.n - term_use(a, p) + term_use(b, p)));
        return emit_expr(fl, got, ty, at);
      }
      const m = term_spine(fl, x);
      if (flat_call(fl, x)) {
        const dst = emit_dst(fl, fun_of(fl, m.k).ret);
        emit_fuse(fl, m, dst);
        return dst;
      }
      const y = call_eta(fl, x) ?? (m.t.$ !== "Ref" && m.args.length === 0 ? m.h : null);
      if (y !== null) {
        return emit_expr(fl, y, ty, at);
      }
      const g = m.t;
      const intr = intr_of(fl, g.k);
      if (intr !== undefined) {
        return emit_intr(fl, intr, m, ty);
      }
      if (m.tld?.$ === "ADT") {
        return emit_zero(fl, ty);
      }
      if (!def_foreign(m.tld)) {
        die(`a live call into the law ${name_key(g.k)}`);
      }
      return val_new([seg_clo(fl, seg_fid(g.k), emit_each(fl, m.args, m.args.map(() => BOX)).map((v) => val_box(fl, v)))], BOX);
    }
    case "Ctr": {
      return emit_ctr(fl, x, ty, at);
    }
    case "Let": {
      const o = term_open(x);
      if (let_live(fl, x)[0]) {
        emit_let({ ...fl, rest: [o.b, ...fl.rest] }, x);
      }
      return emit_expr(fl, o.b, null, at);
    }
    case "Lam":
    case "Mat":
    case "Efq": {
      return fun_live(fl.book, x, ty) ? emit_clo(fl, x, ty) : emit_expr(fl, x.f(DUMMY), ty_all(fl.book, ty).B(DUMMY), at);
    }
    default: {
      return emit_zero(fl, ty);
    }
  }
}
function emit_zero(fl, ty) {
  const lay = lay_of(fl.book, ty);
  return val_new(lay.ks.map(() => "0ull"), lay);
}
function emit_let(fl, x) {
  const o = term_open(x);
  bind_uses(fl, o.ps[0], val_hold(fl, emit_expr(fl, x.v[0], null, null), x.k[0]), [o.b], ty_ann(x.v[0]));
}
function emit_body(fl, tm, ty0, ers, args, dst) {
  BVY_PD_CHECK("emit_body", fl.def);
  const [x, ty] = ty_peel(tm, ty0);
  if (args.length === 0 && fun_live(fl.book, x, ty)) {
    return emit_put(fl, dst, emit_clo(fl, x, ty));
  }
  const l = x.$ === "Let" || args.length === 0 && x.$ !== "Lam" ? anf(fl, x, ty) : x;
  if (l !== x) {
    return emit_body(fl, l, ty, ers, args, dst);
  }
  switch (x.$) {
    case "Lam": {
      const all = ty_all(fl.book, ty);
      if (!quant_live(all.q)) {
        const t = ers[0] ?? Var(x.k, x.i);
        return emit_body(fl, x.f(t), all.B(t), ers.slice(1), args, dst);
      }
      const o = term_open(x);
      bind_uses(fl, o.ps[0], val_hold(fl, val_to(fl, args[0], lay_of(fl.book, all.A)), x.k), [o.b], all.A);
      return emit_body(fl, o.b, all.B(DUMMY), ers, args.slice(1), dst);
    }
    case "Mat":
    case "Efq": {
      return emit_match(fl, x, ty, ers, args, dst);
    }
    case "Let": {
      if (x.k.length >= 2 || term_spine(fl, x.v[0]).k !== null && !flat_call(fl, x.v[0])) {
        return emit_fork(fl, x, ers);
      }
      const o = term_open(x);
      emit_let({ ...fl, rest: [o.b] }, x);
      bind_dead(fl, [o.b]);
      return emit_body(fl, o.b, null, ers, [], dst);
    }
    default: {
      if (args.length > 0) {
        return emit_body(fl, term_eta(fl.book, x, ty, 1), ty, ers, args, dst);
      }
      fl = { ...fl, rest: [] };
      const ck = term_spine(fl, x);
      if (ck.k === null) {
        const v = emit_expr(fl, x, ty, dst?.lay ?? fl.seg.ret);
        bind_dead(fl, []);
        return emit_put(fl, dst, v);
      }
      const ret = fun_of(fl, ck.k).ret;
      const once = fl.sites.get(ck.k) === 1 && !ck.b && !def_foreign(fl.book.tlds[ck.k]) && (!lay_box(ret) || lay_box(fl.seg.ret));
      if (fl.seg.def !== ck.k && (flat_call(fl, x) || dst === null && once)) {
        return emit_fuse(fl, ck, dst, true);
      }
      if (!lay_eq(fl.seg.ret, ret) && (fl.seg.ret.arms !== null || ret.arms !== null)) {
        return emit_body(fl, Let(["r"], [0], [Ann(x, ty)], (xs) => xs[0]), ty, ers, args, dst);
      }
      const cargs = emit_args(fl, ck, true);
      spare_flush(fl);
      emit_jump(fl, cargs, ck.k, ck.b);
    }
  }
}
function emit_fork(fl, x, ers) {
  const o = term_open(x);
  const calls = x.v.map((v) => term_spine(fl, v));
  const fork = calls.length > 1;
  const name = seg_name(fl, "j");
  let hold = [];
  if (fork) {
    spare_flush(fl);
    fl.seg.fork = true;
    const pl = { ...fl, uses: new Map(fl.uses) };
    block(pl, "if (!seq) {", () => {
      const margs = calls.map((c, j) => emit_args({
        ...pl,
        rest: [...x.v.filter((_, i) => i !== j), o.b]
      }, c, false, true));
      const live = [...pl.uses].filter(([p, b]) => !val_brw(pl, b.val) || rest_use(pl, [o.b], p) > 0);
      hold = live.map(([p]) => p);
      const caps = live.flatMap(([, b]) => b.val.ws);
      spare_flush(pl);
      const jn = emit_task(pl, seg_fid(name), calls.length, caps);
      const jt = `term_tsk(${seg_fid(name)}, ${jn})`;
      let idx = caps.length;
      calls.forEach((c, j) => {
        const fj = seg_fid(c.k);
        file_push(pl, `e.mem[${jn} + ${idx}] = term_tsk(${fj}, ${emit_task(pl, fj, 0, margs[j], jt, idx)});`);
        idx += fun_of(pl, c.k).ret.ks.length;
      });
      file_push(pl, `return ${jt};`);
    });
  }
  const chain = calls.map(() => o.b);
  for (let j = calls.length - 2;j >= 0; j -= 1) {
    chain[j] = let_open([o.ps[j + 1]], [x.v[j + 1]], chain[j + 1]);
  }
  const pos = new Map;
  let depth = 0;
  calls.forEach((c, i) => {
    const cargs = emit_args({ ...fl, rest: [chain[i]] }, c);
    const vs = i === 0 ? [...fl.uses] : [[o.ps[i - 1], fl.uses.get(o.ps[i - 1])]];
    const kn = seg_name(fl, "k");
    spare_flush(fl);
    const ws = vs.flatMap(([p, b]) => (pos.set(p, depth), depth += b.val.ws.length, b.val.ws));
    emit_chain(fl, () => "seq", [() => {
      const fr = [...ws, seg_ref(fl, seg_fid(kn))];
      file_push(fl, `WL_ROOM(${fr.length});`);
      fr.forEach((w, j) => file_push(fl, `STK(${j}) = ${w};`));
      file_push(fl, `WL_PUSHN(${fr.length});`);
    }, ...fork ? [] : [() => {
      file_push(fl, `WL_CONT = term_tsk(${seg_fid(kn)}, ${emit_task(fl, seg_fid(kn), 1, ws)});`);
      file_push(fl, `WL_IDX = ${ws.length};`);
    }]]);
    emit_jump(fl, cargs, c.k, !fork && c.b);
    const last = i === calls.length - 1;
    const held = [...fl.uses].filter(([p]) => pos.has(p));
    const at = held.flatMap(([p, b]) => b.val.ws.map((_, j) => pos.get(p) + j - (last ? 0 : depth)));
    const ret = fun_of(fl, c.k).ret;
    const rest = [...hold, chain[i]];
    const rs = val_new(ret.ks.map(() => name_local(fl, o.ps[i].k)), ret);
    fl = seg_open(fl, kn, fl.seg.ret, { pop: last ? depth : 0, at }, held, rs, rest);
    bind_uses(fl, o.ps[i], rs, rest, ty_ann(x.v[i]));
  });
  if (fork) {
    const live = [...fl.uses];
    emit_jump(fl, live.flatMap(([, b]) => b.val.ws), name);
    fl = seg_open(fl, name, fl.seg.ret, null, live, val_new([], lay_pack([])), [o.b]);
  }
  emit_body(fl, o.b, null, ers, [], null);
}
function emit_row(fl, t, ty) {
  const k = ty_adt(fl.book, ty)?.k ?? "";
  if (ty !== null && WORDS[k] === undefined) {
    return null;
  }
  let s = term_strip2(t);
  while (s.$ === "Lam") {
    s = term_strip2(term_open(s).b);
  }
  s = emit_fold(fl, s) ?? s;
  const bits = k === "F32" && !fl.js;
  if (term_const(s)) {
    return bits ? String(u32_from_term(s, "F32")) : js_expr(fl, s, ty);
  }
  const m = term_spine(fl, s);
  const it = m.t.$ === "Ref" ? intr_of(fl, m.t.k) : undefined;
  if (it === undefined || TAB_BAD.test(it.JS)) {
    return null;
  }
  const xs = m.args.map((a) => emit_row(fl, a, null));
  if (xs.includes(null)) {
    return null;
  }
  const r = tpl(it.JS, xs);
  return bits ? `f32_bits(${r})` : r;
}
function emit_tab(fl, cells, ty, s) {
  const ls = cells?.map((t) => emit_row(fl, t, ty));
  if (ls === undefined || ls.includes(null)) {
    return null;
  }
  const key = (fl.js ? ls : Function("f32_bits", `return [${ls}]`)(f32_to_bits).map((v) => BigInt(v) + "ull")).join(", ");
  const tab = "TAB_" + memo(fl.tabs, key, () => fl.tabs.size);
  return fl.js ? `${tab}[Math.min(${s}, ${ls.length - 1})]` : `TAB_AT(${tab}, ${s}, ${ls.length - 1})`;
}
function emit_match(fl, x, ty, ers, args, dst) {
  if (x.$ === "Efq") {
    file_push(fl, "err_post(e.mem, ERR_TAGS);");
    return file_push(fl, "return 0;");
  }
  const { adt, ret, rows, cells } = mat_rows(fl, x, ty);
  const word = WORDS[adt.k] === W32;
  const lay = word ? lay_node(fl.book, adt.k) : lay_of(fl.book, adt);
  const u = val_hold(fl, val_to(fl, args[0], word ? W32 : lay), "s");
  const sw = u.ws[0];
  const tab = emit_tab(fl, cells, ret, sw);
  if (tab !== null) {
    bind_dead(fl, []);
    return emit_put(fl, dst, val_new([tab], lay_of(fl.book, ret)));
  }
  const lv = rows !== null ? rows.map(([h, j, n, e]) => [lits_cond(sw, j, n), h, () => {
    if (!word) {
      return [val_new([`(${sw} - ${n})`], lay)].slice(0, e);
    }
    let v = val_new(lay.ks.map((_, i) => `((${sw} >> ${i}) & 1)`), lay.arms[adt.k][0]);
    for (let i = 0;i < j; i++) {
      v = val_arm(v)[1];
    }
    return e === 1 ? [v] : val_arm(v).slice(0, e);
  }]) : mat_ctrs(fl, x, adt, adt.k === "IO.OP").map(([k, h]) => {
    if (k === "") {
      return ["", h, () => [u]];
    }
    if (adt.k === "Array") {
      const el = lay_el(fl.book, adt.x[0]);
      const leaf = k === "ALeaf";
      return [
        `blk_cls(${sw}) ${leaf ? "==" : "!="} ${lay_arr(el).lgs}`,
        h,
        () => {
          val_own(fl, u);
          return leaf ? [arr_leaf(fl, sw, el)] : emit_hold(fl, [0, 1].map((hi) => `blk_half(e, ${sw}, ${hi})`), "h").map((w) => val_new([w], BOX));
        }
      ];
    }
    return lay_box(lay) ? [
      `term_aux(${sw}) == ${cid_mac(k)}`,
      h,
      (al) => node_fields(al, sw, k, true)
    ] : [
      `${sw} == ${Object.keys(lay.arms).indexOf(k)}`,
      h,
      () => val_arm(u, k)
    ];
  });
  emit_chain(fl, (i) => lv[i][0], lv.map(([, h, fs3]) => () => {
    const al = { ...fl, uses: new Map(fl.uses), spares: fl.spares.slice() };
    bind_dead(al, [h]);
    emit_body(al, h, null, ers, [...fs3(al), ...args.slice(1)], dst);
    if (dst !== null) {
      spare_flush(al);
    }
  }));
  if (dst !== null) {
    fl.spares.splice(0);
  }
}
function emit_chain(fl, cond, bodies) {
  if (bodies.length === 1) {
    return bodies[0]();
  }
  bodies.forEach((body, i) => {
    file_push(fl, i === bodies.length - 1 ? "} else {" : `${i === 0 ? "if" : "} else if"} (${cond(i)}) {`);
    body();
  });
  file_push(fl, "}");
}
function c_ids(fl, src, m = "") {
  return src.replace(/\/\/(?:\\\n|.)*|\/\*[^]*?\*\/|"(?:\\[^]|[^"\\\n])*"|'(?:\\[^]|[^'\\\n])*'|`(?:\\[^]|[^`\\])*`|\b([CF]ID)\(([\w./~-]+)\)/g, (t, p, k) => {
    if (!p) {
      return t;
    }
    const q = [m === "" ? k : m + ":" + k, k].find((q2) => (q2 in fl.book.ctrs) || (q2 in fl.book.tlds) || IDS.has(p + "_" + q2)) ?? die(`${p}(${k}) names no constructor or def`);
    return fl.js ? JSON.stringify(name_key(q)) : name_id(p + "_", q);
  });
}
function effect_srcs(fl, ext, miss) {
  const seen = new Map;
  for (const [k, tld] of done_defs(fl, def_foreign)) {
    const path2 = fs2.realpathSync(tld.i.find((x) => x.endsWith(ext)) ?? die(miss + name_key(k)));
    const m = tld.m ?? "";
    if ((seen.get(path2) ?? m) !== m) {
      die(path2 + " is imported from two namespaces, '" + seen.get(path2) + "' and '" + m + "'");
    }
    seen.set(path2, m);
  }
  return [...seen].map(([p, m]) => c_ids(fl, fs2.readFileSync(p, "utf8"), m));
}
function compile_book(book) {
  BVY_PD_PHASE("compile_book", "enter");
  const show = show_main(book);
  const fams = (show ?? []).flatMap((c) => typeof c === "string" ? [book_fam(book, c)] : []);
  const fl = file_book(book, ["main", ...RUNTIME_ADTS, ...fams], false);
  const facts = () => fl.own.size + fl.hot.size + fl.stat.size;
  let was;
  let reqs;
  do {
    BVY_PD_STATE.pass++;
    BVY_PD_PHASE("emit-pass", "enter");
    was = facts();
    [fl.lend, fl.spun, fl.clos, fl.tabs, fl.lits, fl.consts, BRWS].forEach((m) => m.clear());
    fl.segs = [];
    fl.spins = [];
    fl.img = [];
    for (const [k, tld] of done_defs(fl).reverse()) {
      BVY_PD_STATE.definition = k;
      memo_gc();
      const [dl, vals] = emit_open({
        ...fl,
        fresh: new Map,
        brwl: new Map,
        rest: []
      }, k);
      fl.segs.push(dl.seg);
      emit_body(dl, fun_of(fl, k).h, tld.T, [], vals, null);
    }
    reqs = effect_srcs(fl, ".c", "no .c import: ").join("");
    for (const [k] of done_defs(fl, def_foreign)) {
      const qp = [
        ...fun_of(fl, k).live.map(([, n2]) => name_local(fl, n2)),
        name_local(fl, "k")
      ];
      const rl = { ...fl, seg: seg_new(k, BOX, qp), spares: [] };
      fl.segs.push(rl.seg);
      file_push(rl, `r0 = ${ctr_build(rl, k, qp)};`);
      file_push(rl, "WL_RETN(1);");
    }
    graph_close(fl.lend, [...fl.lend].flatMap((l) => {
      const [a, r] = l.split("<");
      return r === undefined ? [] : [[r, a]];
    }));
    BRWS.forEach((bs, k) => bs.forEach((b, i) => {
      if (b && !fl.lend.has(k + "~" + i)) {
        fl.own.add(k + "~" + i);
      }
    }));
    BVY_PD_PHASE("emit-pass", "exit");
  } while (was !== facts());
  const edges = [...fl.segs, ...fl.spins].flatMap((s) => [...s.refs].map((r) => [s.fid, r]));
  const reach = (from) => graph_close(new Set(from), edges);
  const live = reach([seg_fid("main")]);
  const wide = [...fl.bangs].some((k) => fun_of(fl, k).live.some(([, , A]) => ty_clo(book, A)));
  const dev = reach([...[...fl.bangs].map(seg_fid), ...wide ? fl.clos : []]);
  fl.segs = fl.segs.filter((s) => live.has(s.fid));
  fl.spins = fl.spins.filter((s) => live.has(s.fid));
  const desc = show === null ? [] : [
    "#if !DEVICE",
    `static const u32 SHOW_DESC[] = { ${show.map((c) => typeof c === "string" ? cid_mac(c) : c).join(", ")} };`,
    `static const char* SHOW_NAMES[] = { ${show.filter((c) => typeof c === "string").map((n2) => JSON.stringify(name_key(n2))).join(", ")} };`,
    "#endif"
  ];
  const entries = [
    ...fl.segs,
    seg_new(IO_EMIT, BOX, [""]),
    seg_new(CLO_APPLY, BOX, ["", ""])
  ];
  const cids = new Map;
  for (const k of SRCS.keys()) {
    for (const c of book.tlds[k].c ?? []) {
      cids.set(c.k, lay_node(book, c.k).ks.length);
    }
  }
  for (const [k] of done_defs(fl, def_foreign)) {
    cids.set(k, fun_of(fl, k).lays.length);
  }
  const forky = graph_close(new Set(fl.segs.filter((s) => s.fork).map((s) => s.fid)), [...fl.segs, {
    fid: seg_fid(CLO_APPLY),
    refs: fl.clos
  }].flatMap((s) => [...s.refs].map((r) => [r, s.fid])));
  const ars = [...cids.values()].map((n2) => n2 > WIDE ? 240 + Math.log2(n2) : n2);
  if (entries.some((s) => s.params.length > WIDE) || ars.some((n2) => n2 > 255)) {
    die("an arity over " + WIDE);
  }
  const defs = [
    [...cids.keys()].map(cid_mac),
    [...entries.map((s) => s.fid), "FID_EXIT", "FID_ENTER"]
  ].flatMap((ms) => ms.length > 65536 ? die("an id over 65535") : ms.map((m, i) => `#define ${m} ${i}`));
  const resw = Math.max(...entries.map((s) => s.ret.ks.length));
  const n = Math.max(resw, ...entries.filter((s) => s.frame === null).map((s) => s.params.length));
  const rs = [...Array(n).keys()].map((i) => "r" + i);
  const ws = n > 6 ? [...rs.slice(0, 6), "rp", ...rs.slice(6)] : rs;
  defs.push(`CONSTV u8 FID_T[][3] = { ${entries.map((s) => `{ ${s.params.length}, ${s.frame === null ? 0 : s.params.length - s.frame.at.length}, ${Number(fl.bangs.has(s.def)) | Number(!forky.has(s.fid)) << 1} }`).join(", ")} };`, `CONSTV u8 CID_T[][2] = { ${[...cids.keys()].map((k, i) => `{ ${ars[i]}, ${Number(fl.hot.has(k))} }`).join(", ")} };`, `#define STAT_LEN ${fl.img.length}`, "", `#define WL_RESW ${resw}`, `#define BANGS   ${fl.bangs.size}`, "", `#define WL_BANK Term ${ws.join(", ")};`, "", `#define WL_LOAD(A, N) \\
  do { \\
${rs.map((r, i) => `    if ((N) <= ${i}) break; ${r} = e.mem[(A) + ${i}]; \\
`).join("")}  } while (0);`, "", `#define WL_LAST(X) \\
  switch (war) { \\
${rs.map((r, i) => `    case ${i}: ${r} = (X); \\
      break; \\
`).join("")}  }`, "", `#define WL_SAVE(V) ${rs.slice(0, resw).map((r, j) => `(V)[${j}] = ${r};`).join(" ")}`, "", `#define WL_TAKE(V) ${rs.slice(0, resw).map((r, j) => `${r} = (V)[${j}];`).join(" ")}`, "", `#define WL_SIG Env e, DEV Term* sp, u32 seq, u32 rn, ${ws.map((w) => "Term " + w).join(", ")}`, "", `#define WL_ALL e, sp, seq, rn, ${ws.join(", ")}`, "", `#define WL_TABLE ${entries.map((s) => `WL_X(${s.fid})`).join(" ")} WL_X(FID_EXIT)`, `#define MAIN_FID ${seg_fid("main")}`, `#define MAIN_PURE ${Number(show !== null)}`, `#define BLK_SHR ${Number(fl.hot.has("t:Array"))}`);
  const tabs = [defs.join(`
`), ...[...fl.tabs].map(([r, i]) => `CONSTV u64 TAB_${i}[] = { ${r} };`)].join(`

`);
  const spins = [
    `CONSTV u64 STAT_IMG[] = { ${fl.img.join(", ") || 0} };`,
    ...fl.spins.map((s) => s.lines.join(`
`))
  ].join(`

`);
  const segs = fl.segs.map((seg) => {
    const out = [
      `  WL_CASE(${seg.fid})`,
      "  {",
      ...seg_take(seg).map((l) => "    " + l),
      "    WL_OPEN",
      ...seg.spin ? ["    WL_SPIN"] : [],
      ...seg_text(seg.lines, 2),
      ...seg.spin ? ["    WL_SPUN"] : [],
      "  }}"
    ];
    return (dev.has(seg.fid) ? out : ["#if !DEVICE", ...out, "#endif"]).join(`
`);
  }).join(`

`);
  if (/\bundefined\b/.test([tabs, spins, segs].join(`
`))) {
    die("an unbound name in the emitted C");
  }
  BVY_PD_PHASE("C-assembly", "enter");
  const BVY_PD_RESULT = c_ids(fl, runtime_c([tabs, ...desc].join(`

`), spins, segs, reqs));
  BVY_PD_PHASE("C-assembly", "exit");
  BVY_PD_PHASE("compile_book", "exit");
  return BVY_PD_RESULT;
}
function js_sat(k) {
  return `$${k.replace(/\W/g, (c) => c === "." ? "$" : "$" + String(c.charCodeAt(0)).padStart(3, "0"))}$`;
}
function js_call(fl, k, args, tail) {
  if (tail) {
    memo(fl.tails, fl.seg.def, () => new Set).add(k);
  }
  const exprs = args.map((x) => js_expr(fl, x, null));
  if (k === CLO_APPLY) {
    const [f, x] = exprs;
    return tail ? `run_tail(${f}, ${x})` : `${f}(${x})`;
  }
  const tld = fl.book.tlds[k];
  if (tld.$ === "ADT") {
    return "null";
  }
  const intr = intr_of(fl, k, true)?.JS ?? null;
  if (intr === null && !fun_runs(tld)) {
    die("a live call into the law " + name_key(k));
  }
  const v = def_foreign(tld) && exprs.length === fun_of(fl, k).lays.length - 1 ? name_local(fl, "x") : "";
  if (v) {
    exprs.push(v);
  }
  if (intr !== null) {
    return tpl(intr, exprs.map((e) => ATOM.test(e) || STRLIT.test(e) ? e : emit_hold(fl, [e], "x")[0]));
  }
  const call = `${js_sat(k)}(${exprs.join(", ")})`;
  return v ? `(${v}) => ${call}` : def_foreign(tld) || tail ? call : `\x01${k}\x02(${call})`;
}
function js_open(fl, x) {
  const on = let_live(fl, x);
  return x.f(x.v.map((v, j) => !on[j] ? v : Var(emit_hold(fl, [js_expr(fl, v, null)], x.k[j])[0], 0)));
}
function js_key(n) {
  return (n === "__proto__" ? `["${n}"]` : `"${n}"`) + ": ";
}
function js_expr(fl, tm, ty0) {
  const [x, ty] = ty_peel(tm, ty0);
  switch (x.$) {
    case "Var": {
      return x.k;
    }
    case "Ref":
    case "App": {
      const m = term_spine(fl, x);
      if (m.k !== null) {
        return js_call(fl, m.k, m.xs, false);
      }
      const y = call_eta(fl, x) ?? (m.t.$ !== "Ref" ? m.h : null);
      if (y !== null) {
        return js_expr(fl, y, ty);
      }
      const k = m.t.k;
      const it = intr_of(fl, k, true);
      if (it?.call === true && it.C === undefined) {
        lay_el(fl.book, m.all[0]);
      }
      return js_call(fl, k, m.args, false);
    }
    case "Ctr": {
      const [adt, u] = ctr_adt(fl, x, ty);
      if (u !== null) {
        const v = adt.k === "F32" ? f32_from_bits(u) : u;
        return Object.is(v, -0) ? "-0" : String(v);
      }
      const exprs = ctr_flds(fl.book, x.k, x.x).map((f) => js_expr(fl, f, null));
      const native = OPTIMIZED[adt.k];
      if (native !== undefined) {
        return tpl(native[x.k].intr, exprs);
      }
      const fs3 = ctr_live(fl.book, fl.book.ctrs[x.k]);
      return `{$: "${name_key(x.k)}"${exprs.map((z, j) => ", " + js_key(fs3[j][1]) + z).join("")}}`;
    }
    case "Let": {
      return js_expr(fl, js_open(fl, x), ty);
    }
    case "Lam":
    case "Mat":
    case "Efq": {
      if (!fun_live(fl.book, x, ty)) {
        return js_expr(fl, x.f(Var("null", 0)), ty_all(fl.book, ty).B(DUMMY));
      }
      const arg = name_local(fl, "x");
      const cl = { ...fl, seg: seg_new("", BOX, []) };
      js_func(cl, x, ty, [arg]);
      return `run_clo((${arg}) => {
${seg_text(cl.seg.lines, 1).join(`
`)}
})`;
    }
    default: {
      return "null";
    }
  }
}
function js_func(fl, tm, ty0, args) {
  const [x, ty] = ty_peel(tm, ty0);
  if (args.length === 0 && fun_live(fl.book, x, ty)) {
    return file_push(fl, `return ${js_expr(fl, x, ty)};`);
  }
  if (x.$ === "Lam") {
    const all = ty_all(fl.book, ty);
    const [e, ...rest] = quant_live(all.q) ? args : ["null", ...args];
    const k = /^(\w*_\d+|null)$/.test(e) || VIEW.test(e) ? e : name_local(fl, x.k);
    const at2 = fl.seg.lines.length;
    js_func(fl, x.f(Var(k, 0)), all.B(Var(k, 0)), rest);
    if (k !== e && fl.seg.lines.slice(at2).some((l) => l.includes(k))) {
      fl.seg.lines.splice(at2, 0, `const ${k} = ${e};`);
    }
    return;
  }
  if (mat_head(x)) {
    return js_match(fl, x, ty, args);
  }
  if (x.$ === "Let") {
    return js_func(fl, js_open(fl, x), ty, args);
  }
  if (args.length > 0) {
    return js_func(fl, term_eta(fl.book, x, ty, 1), ty, args);
  }
  const ck = term_spine(fl, x);
  const loop = loop_of(fl, fl.seg.def);
  const at = loop.indexOf(ck.k ?? "");
  if (at >= 0) {
    ck.xs.map((a) => js_expr(fl, a, null)).forEach((e, i) => file_push(fl, `$${i} = ${e};`));
    return file_push(fl, `${loop.length > 1 ? `$pc = ${at}; ` : ""}continue;`);
  }
  file_push(fl, `return ${ck.k === null ? js_expr(fl, x, ty) : js_call(fl, ck.k, ck.xs, true)};`);
}
function js_match(fl, x, ty, args) {
  if (x.$ === "Efq") {
    return file_push(fl, `throw "bend: ${ERRS[2]}";`);
  }
  const { adt, ret, rows, cells } = mat_rows(fl, x, ty);
  const s = emit_alias(fl, args[0], "$t");
  if (adt.k === "IO.OP") {
    block(fl, `if (${s}.$ === "$FFI") {`, () => file_push(fl, `throw ${s};`));
  }
  const tab = emit_tab(fl, cells, ret, s);
  if (tab !== null) {
    return file_push(fl, `return ${tab};`);
  }
  let lv;
  if (adt.k === "Nat") {
    lv = rows.map(([h, , n, e]) => [
      `${s} === ${n}`,
      h,
      [`(${s} - ${n})`].slice(0, e)
    ]);
  } else if (rows !== null) {
    const bits = adt.k === "F32" ? `f32_bits(${s})` : s;
    const wd = (j) => `u32_to_word(${bits})` + '["tail"]'.repeat(j);
    lv = rows.map(([h, j, n, e]) => [lits_cond(bits, j, n), h, e === 1 ? [wd(j)] : [wd(j) + '["head"]', wd(j + 1)].slice(0, e)]);
  } else {
    const native = OPTIMIZED[adt.k];
    lv = mat_ctrs(fl, x, adt).map(([k, h]) => k === "" ? ["", h, [s]] : native === undefined ? [
      `${s}.$ === "${name_key(k)}"`,
      h,
      ctr_live(fl.book, fl.book.ctrs[k]).map(([, f]) => `${s}["${f}"]`)
    ] : [
      tpl(native[k].cond ?? "", [s]),
      h,
      (native[k].elim ?? []).map((e) => tpl(e, [s]))
    ]);
  }
  emit_chain(fl, (i) => lv[i][0], lv.map(([, h, fs3]) => () => js_func(fl, h, null, [...fs3, ...args.slice(1)])));
}
function js_def(fl, k, def) {
  if (intr_of(fl, k, true) !== undefined) {
    return;
  }
  FUEL = FOLD_FUEL;
  fl = { ...fl, fresh: new Map };
  fl.seg.def = k;
  const { live, h } = fun_of(fl, k);
  const loop = loop_of(fl, k);
  const params = loop.length > 0 ? [...Array(Math.max(...loop.map((d) => fun_of(fl, d).live.length))).keys()].map((i) => "$" + i) : live.map(([, x]) => name_local(fl, x));
  if (def.i !== undefined) {
    const doms = [...live, tele_unbind2(fl.book, def.T).doms.at(-1)];
    params.push(name_local(fl, "k"));
    const xs = params.map((p, i) => `${js_marshal(fl, doms[i][2], true)}(${p})`);
    const n = JSON.stringify(name_key(k));
    return block(fl, `function ${js_sat(k)}(${params.join(", ")}) {`, () => file_push(fl, `return { $: "$FFI", run: $0eff[${n}].run, need: $0eff[${n}].need, args: [${xs.slice(0, -1).join(", ")}], kont: ${xs.at(-1)} };`));
  }
  block(fl, `function ${js_sat(k)}(${params.join(", ")}) {`, () => {
    if (loop.length === 0) {
      return js_func(fl, h, def.T, params);
    }
    const pc = loop.length > 1;
    if (pc) {
      file_push(fl, `let $pc = ${loop.indexOf(k)};`);
    }
    block(fl, pc ? "for (;;) switch ($pc) {" : "for (;;) {", () => loop.forEach((d, i) => {
      memo_gc();
      FUEL = FOLD_FUEL;
      const fx = { ...fl, fresh: new Map };
      const ps = fun_of(fx, d).live.map(([, x]) => name_local(fx, x));
      block(fx, pc ? `case ${i}: {` : "{", () => {
        ps.forEach((p, j) => file_push(fx, `const ${p} = $${j};`));
        js_func(fx, fun_of(fx, d).h, fl.book.tlds[d].T, ps);
      });
    }));
  });
  file_push(fl, "");
}
function js_marshal(fl, A, out) {
  const book = fl.book;
  const t = ty_wnf(book, A);
  if (t?.$ === "All") {
    const y = js_marshal(fl, t.B(DUMMY), out);
    if (!quant_live(t.q)) {
      return y;
    }
    const x = js_marshal(fl, t.A, !out);
    return x + y === "" ? y : `((f) => (x) => ${y}(f(${x}(x))))`;
  }
  const seen = new Set;
  const nat = (u) => u?.$ === "All" ? [u.A, u.B(DUMMY)].some((v) => ty_holds(book, v, nat, seen)) : u?.$ !== "ADT" ? false : WORDS[u.k] ? u.k === "Nat" : null;
  if (t?.$ !== "ADT" || !ty_holds(book, t, nat, seen)) {
    return "";
  }
  if (t.k === "Nat") {
    return out ? "BigInt" : "nat_host";
  }
  if (t.k === "Array") {
    return `((a) => (a.forEach((x, i) => a[i] = ${js_marshal(fl, t.x[0], out)}(x)), a))`;
  }
  const key = (out ? "out " : "in ") + term_key(term_lower(t));
  const got = fl.spun.get(key);
  if (got !== undefined) {
    return got;
  }
  const name = "$0m" + fl.spun.size;
  fl.spun.set(key, name);
  const cs = book.tlds[t.k].c;
  const arms = cs.map((c) => {
    const fs3 = ctr_live(book, c, t.x).flatMap(([, n2, B]) => {
      const f = js_marshal(fl, B, out);
      return f === "" ? [] : [[n2, f]];
    });
    const [n] = fs3.filter(([, f]) => f === name).pop() ?? [];
    const copy = fs3.filter(([m]) => m !== n).map(([m, f]) => `, ${js_key(m)}${f}(v["${m}"])`).join("");
    const tag = name_key(c.k);
    return `case "${tag}": ` + (fs3.length === 0 ? "at[key] = v; return top[0];" : `at = at[key] = {...v${copy}}; ` + (n === undefined ? "return top[0];" : `key = "${n}"; v = v[key]; continue;`));
  });
  const tk = name_key(t.k);
  const tags = cs.map((c) => name_key(c.k)).join(", ");
  fl.spins.push({ ...seg_new("", BOX, ["v"]), lines: [
    `function ${name}(v) {`,
    "const top = [v];",
    "for (let at = top, key = 0;;) {",
    "switch (v.$) {",
    ...arms,
    `default: throw "bend: ${tk} has no tag " + v?.$ + " (its tags: ${tags}); a tag names its constructor as the"
      + " loading file sees it, which a later version will make the same"
      + " everywhere (#1105)";`,
    "}",
    "}",
    "}",
    ""
  ] });
  return name;
}
function js_host(fl, k) {
  const { n, live } = fun_of(fl, k);
  const ps = live.map((_, i) => "a" + i);
  const xs = live.map(([, , A], i) => `${js_marshal(fl, A, false)}(${ps[i]})`);
  const ret = tele_fill(fl.book, fl.book.tlds[k].T, Array(n).fill(DUMMY), ctx_nil());
  const back = live.map(([, , A], i) => `${js_marshal(fl, A, true)}(${ps[i]});`);
  return `(${ps.join(", ")}) => { const r = ${js_marshal(fl, ret, true)}(run_loop(${js_sat(k)}(${xs.join(", ")}))); ${back.join(" ")} return r; }`;
}
function js_lib(book, mod = false) {
  const outs = !mod ? null : [...new Set(book.order)].filter((k) => {
    const t = book.tlds[k];
    return done_live(t) && !def_foreign(t) && t.b !== true && t.x === 0 && io_base(book, t.T) === null;
  });
  const fl = file_book(book, outs ?? ["main"], true);
  for (const [k, def] of done_defs(fl, fun_runs)) {
    memo_gc();
    js_def(fl, k, def);
  }
  const srcs = effect_srcs(fl, ".js", "a foreign def without a .js import: ");
  const effs = srcs.map((t) => `(() => {
${t}
})();

`).join("") + (srcs.length === 0 ? "" : `for (const k of ${JSON.stringify(done_defs(fl, def_foreign).map(([k]) => name_key(k)))}) {
  if (!(k in $0eff)) {
    throw new Error("bend: no effect registers " + k);
  }
}

`);
  const lib = outs === null ? "" : `export default {
${outs.map((k) => `  "${name_key(k)}": run_lib(${js_host(fl, k)}, ${fun_of(fl, k).lays.length}),`).join(`
`)}
};
`;
  const jmps = new Map;
  const jmp = (k) => k === CLO_APPLY || memo(jmps, k, () => (jmps.set(k, true), [...fl.tails.get(k) ?? []].some(jmp)));
  const funs = [fl.seg, ...fl.spins].flatMap((f) => seg_text(f.lines, 0)).join(`
`).replace(/\x01([^\x02]*)\x02/g, (_, k) => jmp(k) ? "run_loop" : "");
  return RUNTIME + effs + `// Program
// =======

` + [funs, ...[...fl.tabs].map(([r, i]) => `const TAB_${i} = [${r}];`)].join(`
`) + lib;
}
function js_book(book) {
  const lib = js_lib(book);
  const show = show_main(book);
  return `${lib}
${RUNTIME_MAIN}
cli(process.argv.slice(1));
io_exit(${js_sat("main")}, ${JSON.stringify(show && [show.map((c) => typeof c === "string" ? 0 : c), show.flatMap((c) => typeof c === "string" ? [name_key(c)] : [])])});`;
}
function a32_ops(f) {
  return "add sub and or xor min max".split(" ").map((k) => "#define " + f(k)).join(`
`);
}
var runtime_c = (tabs, spins, segs, reqs) => String.raw`

// Imports
// =======

// The Objective-C headers take #include, not #import: a build
// (-o) reads an #import as the framework of an effect.

#pragma clang fp contract(off)

#if defined(__CUDACC_RTC__)
#define BEND_RTC 1
#endif

#ifdef __METAL_VERSION__
#include <metal_stdlib>
using namespace metal;
#elif !defined(BEND_RTC)
#ifdef __APPLE__
#define _DARWIN_UNLIMITED_SELECT
#else
#define _GNU_SOURCE
#endif
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h>
#include <time.h>
#include <poll.h>
#include <sys/select.h>
#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif
#ifdef __OBJC__
#include <Metal/Metal.h>
#include <Foundation/Foundation.h>
#elif BEND_CUDA
#include <cuda.h>
#include <nvrtc.h>
#include <fcntl.h>
#include <sys/stat.h>
#endif
#endif

// Dialect
// =======

// Metal needs coherent(device) (MSL 3.2), or M1-class parts lose stores
// across the threadgroups of a dispatch. CUDA keeps plain data cacheable
// in L1: lanes hand off through a32 and FENCE. Only clang 19+ has both
// preserve_none and preserve_most, and compiles preserve_most soundly; at
// -O0 its register allocator cannot place a preserve_none segment, so an
// unoptimized build takes neither. A segment is a case of the device's
// switch; on the host, a preserve_none function (WL_SIG) entered by
// musttail, its words fresh at WL_OPEN.

#ifdef __METAL_VERSION__
#if __METAL_VERSION__ >= 320
#define DEV     coherent(device) device
#else
#define DEV     device
#endif
#define THR     thread
#define TG      threadgroup
#define INLINE  inline
#define OUTLINE static
#define CONSTV  constant
#define DEVICE  1
#define CLZ(x)  clz(x)
#define FENCE() atomic_thread_fence(mem_flags::mem_device, memory_order_seq_cst)
#define BAR()   threadgroup_barrier(mem_flags::mem_threadgroup)
#define BARD()  threadgroup_barrier(mem_flags::mem_device \
  | mem_flags::mem_threadgroup)
#else
#define DEV
#define THR
#define TG
#define INLINE  static inline
#define CONSTV  static const
#ifdef BEND_RTC
#define OUTLINE static __attribute__((noinline))
#define DEVICE  1
#define CLZ(x)  (u32)__clz((int)(x))
#define FENCE() __threadfence()
#define BAR()   __syncthreads()
#define BARD()  \
  { __threadfence(); __syncthreads(); }
#else
#if __has_attribute(preserve_none) && __has_attribute(preserve_most) \
  && defined(__OPTIMIZE__)
#define PRESERVE(A) __attribute__((A))
#else
#define PRESERVE(A)
#endif
#define OUTLINE static __attribute__((noinline, cold)) PRESERVE(preserve_most)
#define DEVICE  0
#define CLZ(x)  (u32)__builtin_clz(x)
#define FENCE() ((void)0)
#endif
#endif
#define FAR static __attribute__((noinline))

#if DEVICE
#define LOCK(l)
#define UNLOCK(l)
#define WL_CASE(F) case F:
#define WL_OPEN    {
#define WL_JMP(F)  { fid = (F); break; }
#define WL_DYN     WL_JMP
#else
#define LOCK(l)    while (__atomic_exchange_n(&(l), 1, __ATOMIC_ACQUIRE)) {}
#define UNLOCK(l)  __atomic_store_n(&(l), 0, __ATOMIC_RELEASE)
#define WL_FN      static PRESERVE(preserve_none) __attribute__((noinline)) Term
#define WL_CASE(F) WL_FN WL_##F(WL_SIG)
#define WL_OPEN    { WL_BANK u32 rn;
#define WL_JMP(F)  __attribute__((musttail)) return WL_##F(WL_ALL)
#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)
#endif
#define WL_SPIN     for (;;) { if (err_spun(e.mem, &wpoll)) { return 0; }
#define WL_SPUN     } break;
#define WL_AGAIN(F) continue

#define LANE_STEP (DEVICE ? (long)CUBE : 1)
#define STK(I)    sp[(long)(I) * LANE_STEP]

#define WL_RETN(N)  { rn = (N); sp -= LANE_STEP; WL_DYN((u32)STK(0)); }
#define WL_CONT     STK(-3)
#define WL_IDX      STK(-2)
#define WL_POPN(N)  sp -= N * LANE_STEP
#define WL_PUSHN(N) sp += N * LANE_STEP
#define WL_FRAME(T) \
  u64 wtl = task_tail(T); \
  u64 wtw = e.mem[wtl + 1]; \
  STK(0) = e.mem[wtl]; \
  STK(1) = (wtw >> 32) & 0xFFFF; \
  STK(2) = FID_EXIT; \
  sp += 3 * LANE_STEP;
#define WL_ARGS(A, N) \
  for (u32 wi = 0; wi + 1 < N; wi += 1) { \
    STK(wi) = e.mem[A + wi]; \
  } \
  sp += (N - 1) * LANE_STEP;
#define WL_ROOM(N) \
  if (DEVICE && sp + (N) * CUBE >= e.mem + STAT_OFF + CUBE) { \
    err_post(e.mem, ERR_DEEP); \
    return 0; \
  }

// Types
// =====

#ifdef __METAL_VERSION__
typedef ulong u64;
typedef uint  u32;
typedef uchar u8;
#elif defined(BEND_RTC)
typedef unsigned long long u64;
typedef unsigned int       u32;
typedef unsigned char      u8;
#else
typedef uint64_t u64;
typedef uint32_t u32;
typedef uint8_t  u8;
#endif
typedef float f32;

typedef u64 Term;

typedef struct {
  DEV u64* mem;
  DEV u64* alc;
} Env;

typedef struct {
  u64 off;
  u32 rd;
  u32 wr;
  u32 top;
} Bank;

#if DEVICE
typedef u32 u32a;
#else
typedef u32 __attribute__((may_alias)) u32a;
#endif

// Constants
// =========

#define TAG_PAK 1ull
#define TAG_CTR 2ull
#define TAG_CLO 3ull
#define TAG_BUF 4ull
#define TAG_TSK 5ull
#define TAG_ARR 6ull

#define TERM_HOLE (~0ull)
#define LOC_MASK  ((1ull << 40) - 1)
#define RFC_BIT   (1ull << 63)
#define RFC_CNT   ((1u << 24) - 1)
#define NAT_IMM   ((1ull << 48) - 1)

#define ERR_RING 1
#define ERR_TAGS 2
#define ERR_HEAP 3
#define ERR_FIDS 4
#define ERR_NATS 5
#define ERR_RFCS 6
#define ERR_DEEP 7
#define ERR_ARRS 8

#define LINE      16
#define PAGE_BITS 7
#define PAGE_LEN  (1ull << PAGE_BITS)
#define CUBE_T    128
#define CUBE      ((u64)CUBE_T * CUBE_T)
#define CUBE_G    (1u << CUBE_LOG)
#define LANES     ((u64)CUBE_T << CUBE_LOG)
#define RING_LOG  (17 - CUBE_LOG)
#define RING_LEN  (1ull << RING_LOG)
#define STAK_LEN  (1ull << 11)
#define NCLS      8
#define NCLS_ALL  32
#define IO_HELP   64

#define TG_HOLD   2304
#define CHUNK     256
#define CAP_WORDS 32768
#define QUANTUM   (DEVICE ? PAGE_LEN \
  : KEEP_WORDS < 32 * PAGE_LEN ? KEEP_WORDS : 32 * PAGE_LEN)
#if DEVICE
#define KEEP_WORDS CHUNK
#endif
#define RING_WORDS ((1ull << 10) + 2)

#define H_BUMP       0
#define H_CAP        1
#define H_CURSOR     LINE
#define H_ROOT_DONE  (2 * LINE)
#define H_ERROR_CODE (3 * LINE)
#define H_ROOT_WORD  (4 * LINE)
#define H_BANK       (H_ROOT_WORD + WL_RESW)

#define PAGE_UP(n) (((n) + PAGE_LEN - 1) & ~(PAGE_LEN - 1))
#define ALC_OFF  PAGE_UP(H_BANK + 3 * NCLS_ALL)
#define RING_OFF (ALC_OFF + CUBE * 2 * NCLS_ALL)
#define STAK_OFF (RING_OFF + CUBE * RING_WORDS)
#define STAT_OFF (STAK_OFF + CUBE * STAK_LEN)
#define HEAP_OFF (STAT_OFF + PAGE_UP(STAT_LEN))

// Globals
// =======

// The bag is 2^CUBE_LOG groups of CUBE_T lanes (a -D constant on the
// device). The device program compiles from the binary's own text.

#if !DEVICE

static u64*    CORPUS;
static u64    ALC[CUBE_T + 1][3 * NCLS_ALL] __attribute__((aligned(128)));
static u32    KEEP_WORDS;
static u32    CUBE_LOG = 7;
static u32    bank_lock;

static u32             pool_size;
static u32             pool_row;
static u32             pool_done;
static pthread_mutex_t pool_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  pool_wake = PTHREAD_COND_INITIALIZER;
static pthread_cond_t  pool_join = PTHREAD_COND_INITIALIZER;

#if BEND_METAL || BEND_CUDA
#pragma clang diagnostic ignored "-Wc23-extensions"
static const char BEND_SRC[] = {
#embed __FILE__
, 0 };
#endif

#ifdef __OBJC__
static id<MTLDevice>               gpu_dev;
static id<MTLCommandQueue>         gpu_que;
static id<MTLComputePipelineState> gpu_pso;
static id<MTLBuffer>               gpu_buf;
static id<MTLComputeCommandEncoder> gpu_enc;
#elif BEND_CUDA
static CUdevice   gpu_dev;
static CUmodule   gpu_lib;
static CUfunction gpu_pso;
#endif
static bool io_gpu;
static DEV Term*  io_stk;

static const char* CLI_HELP =
  "usage: %s [options] [arguments]\n"
  "  --threads N       worker threads, 1 to 128 (default: the CPU count)\n"
  "  --gpu on|off|4GB  run ! calls on the GPU, over this much of its memory\n"
  "                    (default: on if present, over 2GB on Metal)\n"
  "  --gpu-build       write the GPU program and exit\n"
  "  --bend-help       show this text\n"
  "  --                the rest are the program's arguments (IO.args)\n";

#endif

// Tables
// ======

${tabs}

#define TAB_AT(T, S, I) T[S < I ? S : I]

#define fid_arity(x) ((u32)FID_T[x][0])
#define fid_resw(x)  ((u32)FID_T[x][1])
#define fid_bangs(x) ((bool)(FID_T[x][2] & 1))
#define fid_nofk(x)  ((bool)(FID_T[x][2] & 2))
#define cid_arity(x) ((u32)CID_T[x][0])
#define cid_hot(x)   ((bool)CID_T[x][1])

// A32
// ===

// C11's atomics on every lane; a device FENCE releases or acquires.
// Metal's loads read through a volatile local, or the M1 and M2 pipeline
// builds die. A weak CAS may fail with the cell still x: a32_cmpx loops.

#define A32_LOOP(k, x) \
  INLINE u32 a32_##k(DEV u32* p, u32 v) { \
    u32 o = a32_load(p); \
    while (!a32_cas(p, &o, x)) { \
    } \
    return o; \
  }

#ifdef __METAL_VERSION__

INLINE DEV atomic_uint* A32(DEV u32* p) {
  return (DEV atomic_uint*)p;
}

INLINE TG atomic_uint* A32(TG u32* p) {
  return (TG atomic_uint*)p;
}

#define a32_load(p) \
  ({ volatile thread u32 _a32v = atomic_load_explicit(A32(p), RLX); _a32v; })

#else

#define a32_load(p) atomic_load_explicit(A32(p), RLX)

#ifdef BEND_RTC

#define A32(p) (p)
#define atomic_load_explicit(p, o)     (*(volatile u32*)(p))
#define atomic_store_explicit(p, v, o) (*(volatile u32*)(p) = (v))
${a32_ops((k) => `atomic_fetch_${k}_explicit(p, v, o) atomic${k[0].toUpperCase()}${k.slice(1)}((u32*)(p), v)`)}
#define atomic_compare_exchange_weak_explicit(p, e, v, s, f) a32_swp(p, e, v)

INLINE bool a32_swp(DEV u32* p, u32* e, u32 v) {
  u32 x = *e;
  *e = atomicCAS((u32*)p, x, v);
  return *e == x;
}

#else

#define A32(p) ((_Atomic u32*)(p))
#define atomic_fetch_min_explicit __c11_atomic_fetch_min
#define atomic_fetch_max_explicit __c11_atomic_fetch_max

#endif

#endif

#define RLX memory_order_relaxed

#if DEVICE
#define REL RLX
#define ACQ RLX
#define ACR RLX
#define a32_acq(p) FENCE()
#define w64_load(p) (*(p))
#else
#define REL memory_order_release
#define ACQ memory_order_acquire
#define ACR memory_order_acq_rel
#define a32_acq(p) ((void)a32_load_acq(p))
#define w64_load(p) atomic_load_explicit((_Atomic u64*)(p), RLX)
#endif

#define a32_store(p, v)     atomic_store_explicit(A32(p), v, RLX)
${a32_ops((k) => `a32_${k}(p, v) atomic_fetch_${k}_explicit(A32(p), v, RLX)`)}
#define a32_sub_rel(p, v)   (FENCE(), atomic_fetch_sub_explicit(A32(p), v, REL))
#define a32_store_rel(p, v) (FENCE(), atomic_store_explicit(A32(p), v, REL))
#define a32_at(H, word)     ((DEV u32*)&(H)[word])

INLINE u32 a32_load_acq(DEV u32* p) {
  u32 v = DEVICE ? a32_load(p) : atomic_load_explicit(A32(p), ACQ);
  FENCE();
  return v;
}

INLINE bool a32_cas(DEV u32* p, THR u32* e, u32 v) {
  FENCE();
  bool ok = atomic_compare_exchange_weak_explicit(A32(p), e, v, ACR, ACQ);
  FENCE();
  return ok;
}

A32_LOOP(exch, v)

INLINE u32 a32_cmpx(DEV u32* p, u32 x, u32 v) {
  u32 o = x;
  while (!a32_cas(p, &o, v) && o == x) {
  }
  return o;
}

// Err
// ===

#if DEVICE

INLINE void err_post(DEV u64* H, u32 code) {
  a32_cmpx(a32_at(H, H_ERROR_CODE), 0, code);
}

#else

static const char* ERR_TEXT[] = { ${ERRS.map((s) => JSON.stringify(s)).join(`,
  `)} };

static void err_fail(const char* msg) {
  fflush(stdout);
  fprintf(stderr, "bend: %s\n", msg);
  _exit(1);
}

static void err_post(u64* H, u32 code) {
  err_fail(ERR_TEXT[code]);
}

static void err_trap(int sig) {
  err_post(NULL, ERR_DEEP);
}

#endif

#define err_seen(H)    (DEVICE && a32_load(a32_at(H, H_ERROR_CODE)) != 0)
#define err_spun(H, n) ((++*(n) & 4095) == 0 && err_seen(H))

${NATIVE.C}
A32_LOOP(fadd, f32_rewrap(f32_unbox(o) + f32_unbox(v)))

// Bank
// ====

// A stack of exact generations per class. The host pops and pushes at rd;
// a device pass pops below rd and pushes above top, compacted after it.

#define bank_at(H, c) ((DEV Bank*)((H) + H_BANK) + (c))

INLINE u64 bank_pop(DEV u64* H, u32 c) {
  DEV Bank* b = bank_at(H, c);
  u64 got = 0;
  LOCK(bank_lock);
  u32 t = a32_sub(&b->rd, 1);
  if ((int)t > 0) {
    got = H[b->off + t - 1];
  } else {
    a32_add(&b->rd, 1);
  }
  if (!DEVICE) {
    b->wr = b->top = b->rd;
  }
  UNLOCK(bank_lock);
  return got;
}

INLINE void bank_push(DEV u64* H, u32 c, u64 head) {
  DEV Bank* b = bank_at(H, c);
  LOCK(bank_lock);
  H[b->off + a32_add(&b->wr, 1)] = head;
  if (!DEVICE) {
    b->rd = b->top = b->wr;
  }
  UNLOCK(bank_lock);
}

// Heap
// ====

// Per lane and class: HOT, a LIFO free chain; LEN, its length in words;
// on the host COLD, one parked generation. A host free reaching KEEP_WORDS
// parks HOT as COLD and banks the old COLD. A miss takes COLD, a bank entry
// or a fresh quantum. A device lane banks its complete generations at the
// kernel end (dev_cut). The bump grows only when all of these are empty.

#define ALC_AT(e, i)   (e).alc[(i) * LANE_STEP]
#define ALC_LEN(e, c)  ALC_AT(e, NCLS_ALL + (c))
#define ALC_COLD(e, c) ALC_AT(e, 2 * NCLS_ALL + (c))
#define KEEP(c)        (KEEP_WORDS >> (c) ? KEEP_WORDS >> (c) : 1)

INLINE u32 cls_fit(u32 words) {
  return words > 1 ? 32 - CLZ(words - 1) : 0;
}

OUTLINE void heap_hand(Env e, u32 cls) {
  u64 cold = ALC_COLD(e, cls);
  if (cold) {
    bank_push(e.mem, cls, cold);
  }
  ALC_COLD(e, cls) = ALC_AT(e, cls);
  ALC_AT(e, cls)   = 0;
  ALC_LEN(e, cls)  = 0;
}

#if DEVICE
#define corpus_grow(H, n) false
#else
static bool corpus_grow(u64* H, u64 need);
#endif

OUTLINE u64 heap_alloc_miss(Env e, u32 cls) {
  DEV u64* H = e.mem;
  u64  got = 0;
  if (!DEVICE) {
    got = ALC_COLD(e, cls);
    ALC_COLD(e, cls) = 0;
  }
  if (!got) {
    got = bank_pop(H, cls);
  }
  u32 n = got ? KEEP(cls) : cls < NCLS ? QUANTUM >> cls : 1;
  if (!got) {
    u32 pages = (n << cls) >> PAGE_BITS;
    u32 p     = a32_add(a32_at(H, H_BUMP), pages);
    if ((u64)p + pages > a32_load_acq(a32_at(H, H_CAP))
      && !corpus_grow(H, (u64)p + pages)) {
      err_post(H, ERR_HEAP);
      return HEAP_OFF;
    }
    got = HEAP_OFF + ((u64)p << PAGE_BITS);
    for (u32 i = 1; i <= n; i += 1) {
      H[got + ((u64)(i - 1) << cls)] = i < n ? got + ((u64)i << cls) : 0;
    }
  }
  ALC_AT(e, cls)  = H[got];
  ALC_LEN(e, cls) = (u64)(n - 1) << cls;
  return got;
}

INLINE u64 heap_alloc(Env e, u32 cls) {
  u64 h = ALC_AT(e, cls);
  if (h) {
    ALC_AT(e, cls)   = e.mem[h];
    ALC_LEN(e, cls) -= 1ull << cls;
    return h;
  }
  return heap_alloc_miss(e, cls);
}

INLINE void heap_free(Env e, u32 cls, u64 loc) {
  if (err_seen(e.mem)) {
    return;
  }
  e.mem[loc]       = ALC_AT(e, cls);
  ALC_AT(e, cls)   = loc;
  ALC_LEN(e, cls) += 1ull << cls;
  if (!DEVICE && ALC_LEN(e, cls) >= KEEP_WORDS) {
    heap_hand(e, cls);
  }
}

INLINE void spare_free(Env e, u32 cls, u64 loc) {
  if (loc >= HEAP_OFF) {
    heap_free(e, cls, loc);
  }
}

// Term
// ====

#define term_make(tag, aux, loc) \
  (((u64)(tag) << 56) | ((u64)(aux) << 40) | (u64)(loc))

#define term_ctr(cid, loc) term_make(TAG_CTR, cid, loc)
#define term_pak(cid, loc) term_make(TAG_PAK, cid, loc)
#define term_clo(fid, loc) term_make(TAG_CLO, fid, loc)
#define term_buf(cls, loc) term_make(TAG_BUF, cls, loc)
#define term_tsk(fid, loc) term_make(TAG_TSK, fid, loc)

INLINE Term term_blk(bool arr, u32 cls, u64 loc) {
  return term_buf(cls, loc) | ((u64)arr << 57);
}

INLINE u64 term_tag(Term t) {
  return (t >> 56) & 0x7f;
}

INLINE bool term_rfc(Term t) {
  return (t & RFC_BIT) != 0;
}

INLINE u64 term_aux(Term t) {
  return (t >> 40) & 0xFFFF;
}

INLINE u64 term_loc(Term t) {
  return t & LOC_MASK;
}

INLINE bool term_triv(Term t) {
  return term_tag(t) <= TAG_PAK || t == TERM_HOLE || term_loc(t) < HEAP_OFF;
}

OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {
  if (term_tag(t) == TAG_CLO || term_tag(t) == TAG_TSK) {
    err_post(e.mem, ERR_RFCS);
    return t;
  }
  u64 r = heap_alloc(e, 0);
  e.mem[r] = ((u64)term_loc(t) << 24) | cnt;
  return (t & ~LOC_MASK) | RFC_BIT | r;
}

INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1);
}

// A redirect cell holds its target's loc over a 24-bit count, which
// changes by atomic adds on the low half, so a host never reads it as one
// plain word.
INLINE u64 rfc_view(DEV u64* H, u64 r) {
  DEV u32* w = a32_at(H, r);
  u64 cell = ((u64)a32_load(w + 1) << 32) | a32_load(w);
  if ((cell & RFC_CNT) == 1) {
    a32_acq(w);
  }
  return cell;
}

INLINE void rfc_bump(Env e, u64 r, u32 k) {
  u32 c = a32_add(a32_at(e.mem, r), k);
  if ((c & RFC_CNT) >= RFC_CNT - k) {
    err_post(e.mem, ERR_RFCS);
  }
}

INLINE Term term_keep(Env e, Term t, u32 k) {
  if (term_rfc(t)) {
    rfc_bump(e, term_loc(t), k);
    return t;
  }
  if (term_triv(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1 + k);
}

INLINE u64 term_peek(DEV u64* H, Term t) {
  if (term_rfc(t)) {
    return rfc_view(H, term_loc(t)) >> 24;
  }
  return term_loc(t);
}

#define blk_shr(t) (BLK_SHR && term_rfc(t))

INLINE u64 blk_loc(DEV u64* H, Term a) {
  return blk_shr(a) ? w64_load(&H[term_loc(a)]) >> 24 : term_loc(a);
}

INLINE u32 blk_cls(Term t) {
  return (u32)term_aux(t) & 31;
}

#define buf_wcls(c) ((c) == 0 ? 0 : (c) - 1)

INLINE u32 blk_span(Term t) {
  u32 c = blk_cls(t);
  return term_tag(t) == TAG_ARR ? c : buf_wcls(c);
}

FAR void term_drop(Env e, Term t) {
  DEV u64* H = e.mem;
  u64  cur = 0;
  Term c0  = 0;
  u32  step = 0;
  for (;;) {
    if (!term_triv(t) && term_rfc(t)) {
      u64      r = term_loc(t);
      DEV u32* p = a32_at(H, r);
      if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {
        t = 0;
      } else {
        a32_acq(p);
        t = (t & ~(RFC_BIT | LOC_MASK)) | (H[r] >> 24);
        heap_free(e, 0, r);
      }
    }
    if (!term_triv(t)) {
      u64 tag = term_tag(t);
      if (tag == TAG_BUF) {
        heap_free(e, blk_span(t), term_loc(t));
      } else {
        u32 aux = (u32)term_aux(t);
        u64 loc = term_loc(t);
        u32 n   = tag == TAG_ARR ? 0 : tag == TAG_CTR ? cid_arity(aux)
          : fid_arity(aux) - (tag == TAG_CLO);
        u32 cls = tag == TAG_ARR ? 64 | blk_cls(t)
          : n > ${WIDE} ? 64 | (n - 240)
          : cls_fit(tag == TAG_TSK ? n + 2 : n);
        c0 = H[loc];
        H[loc] = cur;
        cur = loc | ((u64)n << 48) | ((u64)cls << 56);
      }
    }
    for (;;) {
      if (err_spun(H, &step) || cur == 0) {
        return;
      }
      u64  loc = cur & LOC_MASK;
      u32  i   = (u8)(cur >> 40);
      u32  n   = (u8)(cur >> 48);
      u32  cls = (u32)(cur >> 56);
      bool arr = cls > 63;
      u32  j   = i;
      if (arr) {
        cls &= 63;
        n   = 1u << cls;
        if (i == 2) {
          j = (u32)H[loc + 1];
        }
      }
      if (j < n) {
        Term c = j == 0 ? c0 : H[loc + j];
        if (arr && j > 0) {
          H[loc + 1] = j + 1;
        }
        if (!arr || i < 2) {
          cur += 1ull << 40;
        }
        if (!term_triv(c)) {
          t = c;
          break;
        }
      } else {
        u64 up = H[loc];
        heap_free(e, cls, loc);
        cur = up;
      }
    }
  }
}

INLINE void term_sink(Env e, Term t) {
  if (!term_triv(t)) {
    term_drop(e, t);
  }
}

OUTLINE void span_fade(Env e, Term t, u64 src, u32 n) {
  for (u32 j = 0; j < n; j += 1) {
    Term f = e.mem[src + j];
    if (term_rfc(f)) {
      rfc_bump(e, term_loc(f), 1);
    } else if (!term_triv(f)) {
      err_post(e.mem, ERR_RFCS);
    }
  }
  term_drop(e, t);
}

INLINE u64 ctr_take(Env e, Term t, u32 n, THR Term* out) {
  DEV u64* H = e.mem;
  if (!term_rfc(t)) {
    for (u32 j = 0; j < n; j += 1) {
      out[j] = H[term_loc(t) + j];
    }
    return term_loc(t);
  }
  u64 r    = term_loc(t);
  u64 cell = rfc_view(H, r);
  u64 src  = cell >> 24;
  for (u32 j = 0; j < n; j += 1) {
    out[j] = H[src + j];
  }
  if ((cell & RFC_CNT) == 1) {
    heap_free(e, 0, r);
    return src;
  }
  span_fade(e, t, src, n);
  return 0;
}

INLINE Term term_word(Env e, Term w) {
  u32 x = 0;
  Term t = w;
  for (u32 i = 0; i < 32 && term_aux(t) == CID(WCon); i += 1) {
    u64 l = term_peek(e.mem, t);
    x |= (u32)(e.mem[l] & 1) << i;
    t = e.mem[l + 1];
  }
  term_sink(e, w);
  return x;
}

// Blk
// ===

// A block owns one allocation in its class (an ARR 2^c Terms, a BUF 2^c
// u32). Matching ANode is blk_half twice (the high call frees the source);
// ANode{l, r} is blk_node; Array.clone is blk_copy.

#define BLK_ALLOC(n, w) \
  u64 n = heap_alloc(e, w); \
  if (err_seen(e.mem)) { \
    return term_buf(0, n); \
  }

INLINE DEV u32a* blk_ptr(DEV u64* H, u64 loc, u32 i) {
  return (DEV u32a*)(H + loc) + i;
}

INLINE Term blk_read(DEV u64* H, bool arr, u64 loc, u32 i) {
  if (arr) {
    return H[loc + i];
  }
  return (u64)*blk_ptr(H, loc, i);
}

INLINE void blk_write(DEV u64* H, bool arr, u64 loc, u32 i, Term v) {
  if (arr) {
    H[loc + i] = v;
  } else {
    *blk_ptr(H, loc, i) = (u32)v;
  }
}

INLINE u32 blk_at(Term a, u64 i, u32 lgs) {
  return ((u32)i & (u32)((1ull << (blk_cls(a) - lgs)) - 1)) << lgs;
}

INLINE Term blk_keep(Env e, u64 at) {
  Term w = e.mem[at];
  Term v = term_keep(e, w, 1);
  if (v != w) {
    e.mem[at] = v;
  }
  return v;
}

INLINE void blk_fill(Env e, u64 dst, u64 src, u64 n, bool keep) {
  for (u64 j = 0; j < n; j += 1) {
    e.mem[dst + j] = keep ? blk_keep(e, src + j) : e.mem[src + j];
  }
}

INLINE void blk_free(Env e, Term t) {
  blk_shr(t) ? term_drop(e, t) : heap_free(e, blk_span(t), term_loc(t));
}

OUTLINE Term blk_copy(Env e, Term a) {
  bool arr = term_tag(a) == TAG_ARR;
  u32 cls = blk_span(a);
  BLK_ALLOC(dst, cls)
  blk_fill(e, dst, blk_loc(e.mem, a), 1ull << cls, arr);
  return term_blk(arr, blk_cls(a), dst);
}

INLINE Term blk_node(Env e, Term l, Term r) {
  DEV u64* H = e.mem;
  bool arr = term_tag(l) == TAG_ARR;
  u32 c = blk_cls(l);
  if (c != blk_cls(r) || c + 1 >= NCLS_ALL) {
    err_post(H, ERR_TAGS);
    return l;
  }
  u64 pl = blk_loc(H, l);
  u64 pr = blk_loc(H, r);
  BLK_ALLOC(n, arr ? c + 1 : c)
  if (!arr && c == 0) {
    H[n] = (u64)*blk_ptr(H, pl, 0) | ((u64)*blk_ptr(H, pr, 0) << 32);
  } else {
    u64 cw = 1ull << blk_span(l);
    blk_fill(e, n, pl, cw, arr && blk_shr(l));
    blk_fill(e, n + cw, pr, cw, arr && blk_shr(r));
  }
  blk_free(e, l);
  blk_free(e, r);
  return term_blk(arr, c + 1, n);
}

INLINE Term blk_half(Env e, Term a, u32 hi) {
  DEV u64* H = e.mem;
  bool arr = term_tag(a) == TAG_ARR;
  u32 c = blk_cls(a);
  if (c == 0) {
    err_post(H, ERR_TAGS);
    return a;
  }
  c -= 1;
  u32 cw = arr ? c : buf_wcls(c);
  u64 src = blk_loc(H, a);
  BLK_ALLOC(n, cw)
  if (!arr && c == 0) {
    H[n] = (u64)*blk_ptr(H, src, hi);
  } else {
    blk_fill(e, n, src + ((u64)hi << cw), 1ull << cw, arr && blk_shr(a));
  }
  if (hi) {
    blk_free(e, a);
  }
  return term_blk(arr, c, n);
}

INLINE Term blk_new(Env e, bool arr, u64 d, u32 lgs, u32 n, THR Term* v) {
  DEV u64* H = e.mem;
  if (d + lgs > 31) {
    err_post(H, ERR_ARRS);
    d = 0;
  }
  u32 c = (u32)d + lgs;
  BLK_ALLOC(l, arr ? c : buf_wcls(c))
  for (u32 j = 0; arr && d > 0 && j < n; j += 1) {
    if (d >= 24 && !term_triv(v[j])) {
      err_post(H, ERR_RFCS);
    }
    v[j] = term_keep(e, v[j], (1u << d) - 1);
  }
  for (u64 i = 0; i < (1ull << c); i += 1) {
    blk_write(H, arr, l, (u32)i, i % (1u << lgs) < n ? v[i % (1u << lgs)] : 0);
  }
  return term_blk(arr, c, l);
}

// Ring
// ====

#define ring_word(H, r, w) ((H) + RING_OFF + (w) * LANES + (r))
#define ring_slot(H, r, p) ring_word(H, r, (p) & (RING_LEN - 1))
#define ring_get(H, r)     ((DEV u32*)ring_word(H, r, RING_LEN))
#define ring_put(H, r)     ((DEV u32*)ring_word(H, r, RING_LEN + 1))

INLINE u32 ring_lap(u32 pos) {
  return ~(u32)(pos / RING_LEN) & 1;
}

INLINE void ring_push(DEV u64* H, u32 r, Term tsk) {
  u32 pos = a32_add(ring_put(H, r), 1);
  if (pos - a32_load(ring_get(H, r)) >= RING_LEN) {
    err_post(H, ERR_RING);
    return;
  }
  DEV u32* lo = (DEV u32*)ring_slot(H, r, pos);
  a32_store(lo, (u32)tsk);
  a32_store_rel(lo + 1, (u32)(tsk >> 32) | (ring_lap(pos) << 31));
}

INLINE u32 ring_flip(u32 i) {
  return (i % CUBE_T << CUBE_LOG) + i / CUBE_T;
}

#define ring_pick(b, s, c) ((b) + (s) * (a32_add(c, 1) & (CUBE_T - 1)))

// Task
// ====

INLINE u64 task_node(Env e, u32 fid, Term cont, u32 idx, u32 rem) {
  u32 ar  = fid_arity(fid);
  u64 loc = heap_alloc(e, cls_fit(ar + 2));
  for (u32 i = 0; rem && i < ar; i += 1) {
    e.mem[loc + i] = TERM_HOLE;
  }
  e.mem[loc + ar]     = cont;
  e.mem[loc + ar + 1] = ((u64)idx << 32) | rem;
  return loc;
}

INLINE u64 task_tail(Term t) {
  return term_loc(t) + fid_arity((u32)term_aux(t));
}

INLINE Term task_deliver(DEV u64* H, Term cont, u32 idx, THR Term* v, u32 n) {
  u64 at = cont == TERM_HOLE ? H_ROOT_WORD : term_loc(cont) + idx;
  for (u32 j = 0; j < WL_RESW; j += 1) {
    if (j < n) {
      H[at + j] = v[j];
    }
  }
  if (cont == TERM_HOLE) {
    a32_store_rel(a32_at(H, H_ROOT_DONE), n + 1);
    return 0;
  }
  u64 tl = task_tail(cont);
  if (a32_sub_rel(a32_at(H, tl + 1), 1) == 1) {
    a32_acq(a32_at(H, tl + 1));
    return cont;
  }
  return 0;
}

INLINE void task_deal(DEV u64* H, Term join, u32 base, u32 stride, TG u32* cur) {
  u64 loc = term_loc(join);
  u32 ar  = fid_arity((u32)term_aux(join));
  u32 g   = 0;
  if (stride == 0) {
    u32 rem = (u32)H[loc + ar + 1];
    g = a32_add(a32_at(H, H_CURSOR), rem);
  }
  for (u32 i = 0; i < ar; i += 1) {
    Term k = H[loc + i];
    if (term_tag(k) == TAG_TSK) {
      H[loc + i] = TERM_HOLE;
      u32 to;
      if (stride != 0) {
        to = ring_pick(base, stride, cur);
      } else {
        to = ring_flip(g & (u32)(LANES - 1));
        g += 1;
      }
      ring_push(H, to, k);
    }
  }
}

// Root
// ====

INLINE bool root_done(DEV u64* H) {
  return a32_load_acq(a32_at(H, H_ROOT_DONE)) != 0;
}

static u32 root_take(DEV u64* H, THR Term* v) {
  u32 n = a32_load_acq(a32_at(H, H_ROOT_DONE)) - 1;
  for (u32 j = 0; j < n; j += 1) {
    v[j] = H[H_ROOT_WORD + j];
  }
  a32_store(a32_at(H, H_ROOT_DONE), 0);
  return n;
}

// Spins
// =====

${spins}

// Work
// ====

// A host self-jump is a tail call: as a loop, clang hoisted constants into
// symreg's entry (3.05 s against 2.51 s).
#if !DEVICE
#undef  WL_SPIN
#undef  WL_SPUN
#undef  WL_AGAIN
#define WL_SPIN
#define WL_SPUN
#define WL_AGAIN(F) __attribute__((musttail)) return WL_##F(WL_ALL)

typedef Term (PRESERVE(preserve_none) *WlFn)(WL_SIG);
#define WL_X(F) WL_FN WL_##F(WL_SIG);
WL_TABLE WL_X(FID_ENTER)
#undef WL_X
#define WL_X(F) WL_##F,
static const WlFn wl_tab[] = { WL_TABLE };
#undef WL_X
#endif

static Term work_loop(Env e, DEV Term* sp, Term t, u32 seq) {
  WL_BANK
  u32 rn = 0;
  r0 = t;
#if DEVICE
  u32 fid   = FID_ENTER;
  u32 wpoll = 0;
  for (;;) {
  if (err_spun(e.mem, &wpoll)) {
    return 0;
  }
  switch (fid) {
#else
  return WL_FID_ENTER(WL_ALL);
}
#endif

// Segments
// ========

// A task enters through its words: a continuation's results ride r0..
// and its parameters the stack; any other segment's parameters ride r0..

${segs}

  WL_CASE(FID_ENTER)
  {
    Term t = r0;
    WL_OPEN
    u32 f   = (u32)term_aux(t);
    u64 a   = term_loc(t);
    u32 war = fid_arity(f);
    WL_FRAME(t)
    seq |= fid_nofk(f) << 1;
    u32 rw = fid_resw(f);
    if (rw) {
      WL_LOAD(a + war - rw, rw)
      WL_ARGS(a, war - rw + 1)
    } else {
      WL_LOAD(a, war)
    }
    heap_free(e, cls_fit(war + 2), a);
    WL_DYN(f);
  }}

  WL_CASE(FID(IO~emit))
  {
    Term x = r0;
    WL_OPEN
    u64 l = heap_alloc(e, 0);
    e.mem[l] = x;
    r0 = term_ctr(CID(Emit), l);
    WL_RETN(1);
  }}

  WL_CASE(FID(Clo~apply))
  {
    Term fun = r0;
    Term arg = r1;
    WL_OPEN
    u32 f    = (u32)term_aux(fun);
    u32 war  = fid_arity(f) - 1;
    u64 a    = term_loc(fun);
    WL_LOAD(a, war)
    spare_free(e, cls_fit(war), a);
    WL_LAST(arg)
    WL_DYN(f);
  }}

  WL_CASE(FID_EXIT)
  {
    u32  n = rn;
    Term rv[WL_RESW];
    WL_SAVE(rv)
    WL_OPEN
    if (err_seen(e.mem)) {
      return 0;
    }
    sp -= 2 * LANE_STEP;
    Term cont = STK(0);
    u32  idx  = (u32)STK(1);
    u32  wf   = (u32)term_aux(cont);
    if (cont != TERM_HOLE && fid_resw(wf)) {
      u64 wa = term_loc(cont);
      u32 wn = fid_arity(wf);
      WL_FRAME(cont)
      seq = (seq & 1) | fid_nofk(wf) << 1;
      WL_ARGS(wa, wn - n + 1)
      heap_free(e, cls_fit(wn + 2), wa);
      WL_TAKE(rv)
      WL_DYN(wf);
    }
    return task_deliver(e.mem, cont, idx, rv, n);
  }}

#if DEVICE
  default: {
    err_post(e.mem, ERR_FIDS);
    return 0;
  }
  }
  }
}
#endif

// Monk
// ====

// One turn on a ring: its head task below put0 runs (a growing
// lane skips a fork-free one). The host grows a row ring by
// ring and drains a ring; a device lane does both.
INLINE u32 monk_step(Env e, DEV Term* stk, u32 rg, u32 put0, u32 base, u32 stride,
  TG u32* cur) {
  DEV u64* H   = e.mem;
  bool     seq = stride == 0;
  DEV u32* get = ring_get(H, rg);
  if (*get == put0) {
    return 0;
  }
  DEV u32* lo = (DEV u32*)ring_slot(H, rg, *get);
  u32      hi = a32_load_acq(lo + 1);
  Term     t  = (((u64)hi << 32) | a32_load(lo)) & ~RFC_BIT;
  if ((hi >> 31) != ring_lap(*get) || (!seq && fid_nofk((u32)term_aux(t)))) {
    return 0;
  }
  a32_store(get, *get + 1);
  u32 spin = 0;
  for (;;) {
    Term r = work_loop(e, stk, t, seq);
    if (r == 0) {
      return 2;
    }
    if ((u32)H[task_tail(r) + 1] == 0) {
      if (err_spun(H, &spin)) {
        return 2;
      }
      if (stride != 0 && fid_nofk((u32)term_aux(r))) {
        ring_push(H, ring_pick(base, stride, cur), r);
        return 2;
      }
      t      = r;
      seq    = false;
      stride = 0;
      continue;
    }
    task_deal(H, r, base, stride, cur);
    return 1;
  }
}

// Dev
// ===

// One kernel: pass 0 grows the frontier, pass 1 drains each lane's ring,
// pass 2 packs the banks: in one group, each bank's [top, wr) slides onto
// rd, CUBE_T entries a step (loads, barrier, stores: rd <= top), off the
// host's pages. A grow pass ends when its group is full or nothing grew,
// so a spine of forks unrolls whole. TG_HOLD words of threadgroup memory
// hold one group per Apple core (bitonic 1.35x without).

#if DEVICE

INLINE void dev_cut(Env e) {
  if (err_seen(e.mem)) {
    return;
  }
  for (u32 c = 0; c < NCLS_ALL; c += 1) {
    u64 gen = (u64)KEEP(c) << c;
    while (ALC_LEN(e, c) >= gen) {
      u64 head = ALC_AT(e, c);
      u64 tail = head;
      for (u32 i = 1; i < KEEP(c); i += 1) {
        tail = e.mem[tail];
      }
      ALC_AT(e, c)    = e.mem[tail];
      ALC_LEN(e, c)  -= gen;
      e.mem[tail]     = 0;
      bank_push(e.mem, c, head);
    }
  }
}

INLINE void bank_pack(DEV u64* H, u32 lane) {
  for (u32 c = 0; c < NCLS_ALL; c += 1) {
    DEV Bank* b  = bank_at(H, c);
    u32       rd = b->rd;
    u32       n  = b->wr - b->top;
    for (u32 i = 0; i < n; i += CUBE_T) {
      Term v = i + lane < n ? H[b->off + b->top + i + lane] : 0;
      BAR();
      if (i + lane < n) {
        H[b->off + rd + i + lane] = v;
      }
    }
    BAR();
    if (lane == 0) {
      b->rd = b->wr = b->top = rd + n;
    }
  }
}

#ifdef __METAL_VERSION__
kernel void bend_dev(DEV u64* H [[buffer(0)]], constant u32& pass [[buffer(1)]],
  TG u32* vote [[threadgroup(0)]],
  u32 grids [[threadgroups_per_grid]],
  u32 row [[threadgroup_position_in_grid]],
  u32 lane [[thread_position_in_threadgroup]]) {
#else
extern "C" __global__ void bend_dev(DEV u64* H, u32 pass) {
  extern __shared__ u32 vote[];
  u32 grids = gridDim.x;
  u32 row   = blockIdx.x;
  u32 lane  = threadIdx.x;
#endif
  if (pass == 2) {
    bank_pack(H, lane);
    return;
  }
  u32  stride = grids == 1 ? CUBE_G : 1;
  u32  me     = row * CUBE_T + stride * lane;
  u32 rg     = pass ? ring_flip(me) : me;
  Env  e      = { H, H + ALC_OFF + me };
  DEV Term*  stk    = (DEV Term*)(H + STAK_OFF + me);
  if (lane == 0) {
    for (u32 i = 0; i < 3; i += 1) {
      a32_store(vote + i, 0);
    }
  }
  BAR();
  u32 put0      = a32_load(ring_put(H, rg));
  u32 seen_has  = 0;
  u32 seen_grew = 0;
  for (;;) {
    if (pass) {
      if (*ring_get(H, rg) == put0 || err_seen(H)) {
        break;
      }
    } else {
      put0 = a32_load(ring_put(H, rg));
      u32 has = put0 != a32_load(ring_get(H, rg));
      if (lane == 0 && (err_seen(H) || root_done(H))) {
        has = CUBE_T;
      }
      a32_add(vote + 2, has);
      BAR();
      has = a32_load(vote + 2);
      if (has - seen_has >= CUBE_T) {
        break;
      }
      seen_has = has;
    }
    u32 ran = monk_step(e, stk, rg, put0, row * CUBE_T, pass ? 0 : stride,
      vote);
    if (!pass) {
      if (ran == 1) {
        a32_add(vote + 1, 1);
      }
      BARD();
      u32 grew = a32_load(vote + 1);
      if (grew == seen_grew) {
        break;
      }
      seen_grew = grew;
    }
  }
  dev_cut(e);
}

#endif

// Window
// ======

// Linux's window fill (the Mac's is window_msl): an Image is a quadtree over
// 2^k x 2^k (Qua splits tl, tr, bl, br; Pix is 0xRRGGBB).
#if defined(__linux__) || defined(BEND_RTC)

INLINE u32 window_pix(DEV u64* H, Term t, u32 k, u32 x, u32 y) {
  for (u32 i = k; term_tag(t) == TAG_CTR;) {
    u32 j = 0;
    if (i > 0) {
      i -= 1;
      j = ((y >> i) & 1) * 2 + ((x >> i) & 1);
    }
    t = H[term_peek(H, t) + j];
  }
  return (u32)term_loc(t) & 0xFFFFFF;
}

#ifdef BEND_RTC
extern "C" __global__ void window_dev(DEV u64* H, Term root, u32 w, u32 h,
  u32 k, u32* out) {
  u32 x = blockIdx.x * blockDim.x + threadIdx.x;
  u32 y = blockIdx.y * blockDim.y + threadIdx.y;
  if (x < w && y < h) {
    out[y * w + x] = window_pix(H, root, k, x, y);
  }
}
#endif

#endif

#if !DEVICE

// Row
// ===

static u32 row_grow(Env e, DEV Term* stk, u32 base, u32 stride, u32 want) {
  u64* H = e.mem;
  u32 cur = 0;
  for (;;) {
    u32 put0[CUBE_T];
    u32 has = 0;
    for (u32 i = 0; i < CUBE_T; i += 1) {
      put0[i] = *ring_put(H, base + i * stride);
      has += put0[i] != *ring_get(H, base + i * stride);
    }
    if (root_done(H) || has >= want) {
      return cur;
    }
    u32 grew = 0;
    u32 ran  = 0;
    for (u32 i = 0; i < CUBE_T && ran != 2; i += 1) {
      ran   = monk_step(e, stk, base + i * stride, put0[i], base, stride,
        &cur);
      grew += ran == 1;
    }
    if (grew == 0) {
      return cur;
    }
  }
}

// Pool
// ====

static void* pool_try(void* at, u64 bytes) {
  return mmap(at, bytes, PROT_READ | PROT_WRITE,
    MAP_PRIVATE | MAP_ANON | MAP_NORESERVE, -1, 0);
}

static void* pool_mmap(u64 bytes) {
  void* p = pool_try(NULL, bytes);
  if (p == MAP_FAILED) {
    err_fail("reservation failed");
  }
  return p;
}

static Term* pool_stack(void) {
  u64   len = 1ull << 31;
  char* p   = pool_mmap(len + 16384 + SIGSTKSZ);
  if (mprotect(p + len, 16384, PROT_NONE) != 0) {
    err_fail("stack guard failed");
  }
  stack_t ss = { .ss_sp = p + len + 16384, .ss_size = SIGSTKSZ };
  sigaltstack(&ss, NULL);
  struct sigaction sa = { .sa_handler = err_trap, .sa_flags = SA_ONSTACK };
  sigaction(SIGSEGV, &sa, NULL);
  sigaction(SIGBUS, &sa, NULL);
  return (Term*)p;
}

// A wait yields a while before it sleeps, so a turn that ends (or follows)
// within microseconds never pays a condvar wake.

#define POOL_WAIT(c, cv) \
  for (u32 s = 0; s < 128 && (c); s += 1) { \
    sched_yield(); \
  } \
  pthread_mutex_lock(&pool_lock); \
  while (c) { \
    pthread_cond_wait(&cv, &pool_lock); \
  } \
  pthread_mutex_unlock(&pool_lock);

static u32 pool_step(u32 rows) {
  u32 per = rows * CUBE_T / (32 * pool_size);
  return CUBE_T >> (31 - CLZ(per < LINE ? per | 1 : LINE));
}

static u32 pool_rows(Env e, DEV Term* stk) {
  u32 n = 0;
  for (;;) {
    u32 c    = a32_add(&pool_row, 1);
    u32 r    = c & 32767;
    u32 rows = c >> 15 & 255;
    u32 step = c >> 23 & 1 ? 1 : pool_step(rows);
    if (r >= rows * step) {
      if (n != 0 && a32_sub_rel(&pool_done, n) == n) {
        pthread_mutex_lock(&pool_lock);
        pthread_cond_signal(&pool_join);
        pthread_mutex_unlock(&pool_lock);
      }
      return c >> 24;
    }
    a32_acq(&pool_row);
    if (c >> 23 & 1) {
      row_grow(e, stk, r * CUBE_T, 1, CUBE_T);
    } else {
      u32 row = r / step * CUBE_T;
      for (u32 rg = row + r % step; rg < row + CUBE_T; rg += step) {
        u32 put0 = a32_load(ring_put(e.mem, rg));
        while (*ring_get(e.mem, rg) != put0 && !err_seen(e.mem)) {
          monk_step(e, stk, rg, put0, rg, 0, NULL);
        }
      }
    }
    n += 1;
  }
}

static void* pool_work(void* arg) {
  Term* stk  = pool_stack();
  u32   seen = 0;
  for (;;) {
    POOL_WAIT(a32_load(&pool_row) >> 24 == seen, pool_wake)
    seen = pool_rows((Env){ CORPUS, ALC[(uintptr_t)arg] }, stk);
  }
}

OUTLINE void pool_open(void) {
  static bool up;
  if (up) {
    return;
  }
  up = true;
  for (u32 w = 1; w < pool_size; w += 1) {
    pthread_t tid;
    if (pthread_create(&tid, NULL, pool_work, (void*)(uintptr_t)w)) {
      err_fail("pthread_create");
    }
  }
}

static int cpu_read(const char* path, long* a, long* b) {
  FILE* f = fopen(path, "r");
  if (f == NULL) {
    return 0;
  }
  int n = fscanf(f, "%ld %ld", a, b);
  fclose(f);
  return n;
}

static long cpu_count(void) {
  long n = sysconf(_SC_NPROCESSORS_ONLN);
#ifdef __linux__
  cpu_set_t set;
  if (sched_getaffinity(0, sizeof set, &set) == 0) {
    n = CPU_COUNT(&set);
  }
  long q = 0;
  long p = 0;
  if (cpu_read("/sys/fs/cgroup/cpu.max", &q, &p) != 2) {
    cpu_read("/sys/fs/cgroup/cpu/cpu.cfs_quota_us", &q, &p);
    cpu_read("/sys/fs/cgroup/cpu/cpu.cfs_period_us", &p, &p);
  }
  if (q > 0 && p > 0 && (q + p - 1) / p < n) {
    n = (q + p - 1) / p;
  }
#endif
  return n;
}

OUTLINE void pool_turn(bool grow, u32 rows) {
  static u32 turn;
  u32 n = rows < CUBE_G ? rows : CUBE_G;
  turn += 1;
  a32_store(&pool_done, grow ? n : n * pool_step(n));
  pthread_mutex_lock(&pool_lock);
  a32_store_rel(&pool_row, turn << 24 | grow << 23 | n << 15);
  pthread_cond_broadcast(&pool_wake);
  pthread_mutex_unlock(&pool_lock);
  pool_rows((Env){ CORPUS, ALC[0] }, io_stk);
  POOL_WAIT(a32_load_acq(&pool_done) != 0, pool_join)
}

// Gpu
// ===

// gpu_make compiles the device program into <binary>.gpu
// (--gpu-build): Metal's binary archive, or CUDA's cubin behind a
// hash of the text. A launch loads it, else notes and compiles. CUDA
// shapes the bag by the device: a group of 128 lanes per 64 KB of
// L2, a power of two in 16..128 (Apple keeps the tuned 128). CUDA
// runs one stream: the default 8 cost about half of the startup.

static const char* gpu_path(void) {
  static char path[4096];
  u32 n = sizeof path - 8;
#ifdef __APPLE__
  _NSGetExecutablePath(path, &n);
#else
  path[readlink("/proc/self/exe", path, n)] = 0;
#endif
  return strcat(path, ".gpu");
}

static void gpu_note(const char* path) {
  fprintf(stderr, "bend: compiling the GPU program (%s is missing or"
    " stale)\n", path);
}

#if !BEND_CUDA
#define gpu_map pool_mmap
#endif

#if BEND_METAL || BEND_CUDA

static void gpu_kernel(u32 pass, u32 groups);

static void gpu_run(u32 f) {
  if (f < CUBE_T) {
    gpu_kernel(0, 1);
  }
  if (f < LANES) {
    gpu_kernel(0, CUBE_G);
  }
  gpu_kernel(1, CUBE_G);
  gpu_kernel(2, 1);
}

#endif

#if BEND_CUDA

static u64 gpu_hash(void) {
  u64 key = 14695981039346656037ull ^ CUBE_LOG;
  for (const char* p = BEND_SRC; *p != 0; p += 1) {
    key = (key ^ (u8)*p) * 1099511628211ull;
  }
  return key;
}

#endif

#if BEND_METAL

static void gpu_fail(NSError* err) {
  err_fail([[err localizedDescription] UTF8String]);
}

static bool gpu_probe(void) {
  return (gpu_dev = MTLCreateSystemDefaultDevice()) != nil;
}

static MTLComputePipelineDescriptor* gpu_desc(void) {
  NSError* err = nil;
  MTLCompileOptions* opts = [MTLCompileOptions new];
  opts.mathMode = MTLMathModeSafe;
  opts.preprocessorMacros = @{ @"CUBE_LOG": @(CUBE_LOG) };
  id<MTLLibrary> lib = [gpu_dev newLibraryWithSource:@(BEND_SRC) options:opts
    error:&err];
  if (!lib) {
    gpu_fail(err);
  }
  MTLComputePipelineDescriptor* d = [MTLComputePipelineDescriptor new];
  d.computeFunction = [lib newFunctionWithName:@"bend_dev"];
  return d;
}

static bool gpu_make(const char* path) {
  NSError* err = nil;
  id<MTLBinaryArchive> ar = [gpu_dev
    newBinaryArchiveWithDescriptor:[MTLBinaryArchiveDescriptor new] error:&err];
  if (![ar addComputePipelineFunctionsWithDescriptor:gpu_desc() error:&err]) {
    gpu_fail(err);
  }
  return [ar serializeToURL:[NSURL fileURLWithPath:@(path)] error:&err];
}

static id<MTLComputePipelineState> gpu_pipe(MTLComputePipelineDescriptor* d,
  id<MTLBinaryArchive> ar) {
  NSError* err = nil;
  d.binaryArchives = ar ? @[ar] : @[];
  id<MTLComputePipelineState> pso = [gpu_dev
    newComputePipelineStateWithDescriptor:d
    options:ar ? MTLPipelineOptionFailOnBinaryArchiveMiss : 0 reflection:nil
    error:&err];
  if (!pso && !ar) {
    gpu_fail(err);
  }
  return pso;
}

static u64 gpu_span(void) {
  u64 span = [gpu_dev recommendedMaxWorkingSetSize];
  u64 most = [gpu_dev maxBufferLength];
  span = span < most ? span : most;
  return span < (2ull << 30) ? span : 2ull << 30;
}

static void gpu_load(u64 bytes) {
  gpu_buf = [gpu_dev newBufferWithBytesNoCopy:CORPUS length:bytes
    options:MTLResourceStorageModeShared
      | MTLResourceHazardTrackingModeUntracked deallocator:nil];
  u64 most = [gpu_dev maxBufferLength];
  if (!gpu_buf && bytes > most) {
    char msg[96];
    snprintf(msg, sizeof msg, "--gpu %lluMB is over the device's %lluMB",
      (unsigned long long)(bytes >> 20), (unsigned long long)(most >> 20));
    err_fail(msg);
  }
  if (!gpu_buf) {
    err_fail("the GPU span is more than the device has");
  }
  @autoreleasepool {
    gpu_que = [gpu_dev newCommandQueue];
    const char* path = gpu_path();
    MTLBinaryArchiveDescriptor* ad = [MTLBinaryArchiveDescriptor new];
    ad.url = [NSURL fileURLWithPath:@(path)];
    MTLComputePipelineDescriptor* d = gpu_desc();
    id<MTLBinaryArchive> ar = [gpu_dev newBinaryArchiveWithDescriptor:ad
      error:nil];
    gpu_pso = ar ? gpu_pipe(d, ar) : nil;
    if (!gpu_pso) {
      gpu_note(path);
      gpu_pso = gpu_pipe(d, nil);
    }
  }
}

static void gpu_kernel(u32 pass, u32 groups) {
  [gpu_enc setComputePipelineState:gpu_pso];
  [gpu_enc setBuffer:gpu_buf offset:0 atIndex:0];
  [gpu_enc setBytes:&pass length:sizeof pass atIndex:1];
  [gpu_enc setThreadgroupMemoryLength:TG_HOLD * 8 atIndex:0];
  [gpu_enc dispatchThreadgroups:MTLSizeMake(groups, 1, 1)
    threadsPerThreadgroup:MTLSizeMake(CUBE_T, 1, 1)];
  [gpu_enc memoryBarrierWithScope:MTLBarrierScopeBuffers];
}

static void gpu_pass(u32 f) {
  @autoreleasepool {
    id<MTLCommandBuffer> cb = [gpu_que commandBuffer];
    gpu_enc = [cb computeCommandEncoder];
    gpu_run(f);
    [gpu_enc endEncoding];
    [cb commit];
    [cb waitUntilCompleted];
    if ([cb error]) {
      gpu_fail([cb error]);
    }
  }
}

#elif BEND_CUDA

static void gpu_shape(int units) {
  CUBE_LOG = 31 - CLZ(units < 16 ? 16 : units > 128 ? 128 : units);
}

static bool gpu_probe(void) {
  int       managed = 0;
  CUcontext ctx;
  setenv("CUDA_DEVICE_MAX_CONNECTIONS", "1", 0);
  if (cuInit(0) == CUDA_SUCCESS && cuDeviceGet(&gpu_dev, 0) == CUDA_SUCCESS) {
    cuDeviceGetAttribute(&managed,
      CU_DEVICE_ATTRIBUTE_CONCURRENT_MANAGED_ACCESS, gpu_dev);
  }
  int l2 = 1 << 23;
  cuDeviceGetAttribute(&l2, CU_DEVICE_ATTRIBUTE_L2_CACHE_SIZE, gpu_dev);
  gpu_shape(l2 >> 16);
  return managed != 0
    && cuDevicePrimaryCtxRetain(&ctx, gpu_dev) == CUDA_SUCCESS
    && cuCtxSetCurrent(ctx) == CUDA_SUCCESS;
}

static u64* gpu_map(u64 bytes) {
  CUdeviceptr p = 0;
  if (cuMemAllocManaged(&p, bytes, CU_MEM_ATTACH_GLOBAL) != CUDA_SUCCESS) {
    err_fail("corpus reservation failed");
  }
#if CUDA_VERSION >= 13000
  cuMemAdvise(p, bytes, CU_MEM_ADVISE_SET_PREFERRED_LOCATION,
    (CUmemLocation){ CU_MEM_LOCATION_TYPE_DEVICE, gpu_dev });
#else
  cuMemAdvise(p, bytes, CU_MEM_ADVISE_SET_PREFERRED_LOCATION, gpu_dev);
#endif
  return (u64*)(uintptr_t)p;
}

static bool gpu_make(const char* path) {
  int cc[2] = {0, 0};
  cuDeviceGetAttribute(cc,
    CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MAJOR, gpu_dev);
  cuDeviceGetAttribute(cc + 1,
    CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MINOR, gpu_dev);
  char arch[40];
  char bag[24];
  snprintf(arch, sizeof arch, "--gpu-architecture=sm_%d%d", cc[0], cc[1]);
  snprintf(bag, sizeof bag, "-DCUBE_LOG=%u", CUBE_LOG);
  const char* opts[] = { arch, bag, "--fmad=false", "-default-device" };
  nvrtcProgram prog;
  if (nvrtcCreateProgram(&prog, BEND_SRC, "bend.cu", 0, NULL, NULL)
    != NVRTC_SUCCESS) {
    err_fail("cannot compile the CUDA library");
  }
  if (nvrtcCompileProgram(prog, 4, opts) != NVRTC_SUCCESS) {
    size_t n = 0;
    nvrtcGetProgramLogSize(prog, &n);
    char* log = calloc(n + 1, 1);
    if (log != NULL && nvrtcGetProgramLog(prog, log) == NVRTC_SUCCESS) {
      fprintf(stderr, "%s\n", log);
    }
    err_fail("cannot compile the CUDA library");
  }
  size_t len = 0;
  nvrtcGetCUBINSize(prog, &len);
  char* bin = malloc(len);
  if (bin == NULL || nvrtcGetCUBIN(prog, bin) != NVRTC_SUCCESS) {
    err_fail("cannot load the CUDA library");
  }
  nvrtcDestroyProgram(&prog);
  u64   key = gpu_hash();
  FILE* out = path == NULL ? NULL : fopen(path, "wb");
  bool  ok  = out != NULL && fwrite(&key, 8, 1, out) == 1
    && fwrite(bin, 1, len, out) == len && fclose(out) == 0;
  if (cuModuleLoadData(&gpu_lib, bin) != CUDA_SUCCESS) {
    err_fail("cannot load the CUDA library");
  }
  free(bin);
  return path == NULL || ok;
}

static u64 gpu_span(void) {
  size_t span = 0;
  cuDeviceTotalMem(&span, gpu_dev);
  return span;
}

static void gpu_load(u64 bytes) {
  const char* path = gpu_path();
  int         fd   = open(path, O_RDONLY);
  struct stat st   = { 0 };
  u64         key  = 0;
  char*       bin  = fd < 0 || fstat(fd, &st) != 0 || st.st_size <= 8 ? NULL
    : mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  if (bin != NULL && bin != MAP_FAILED) {
    memcpy(&key, bin, 8);
  }
  if (key != gpu_hash()
    || cuModuleLoadData(&gpu_lib, bin + 8) != CUDA_SUCCESS) {
    gpu_note(path);
    gpu_make(path);
  }
  if (cuModuleGetFunction(&gpu_pso, gpu_lib, "bend_dev") != CUDA_SUCCESS) {
    err_fail("cannot load the GPU program");
  }
}

static void gpu_kernel(u32 pass, u32 groups) {
  void* args[] = { &CORPUS, &pass };
  if (cuLaunchKernel(gpu_pso, groups, 1, 1, CUBE_T, 1, 1, TG_HOLD * 8, NULL,
    args, NULL) != CUDA_SUCCESS) {
    err_fail("device launch failed");
  }
}

static void gpu_pass(u32 f) {
  gpu_run(f);
  if (cuCtxSynchronize() != CUDA_SUCCESS) {
    err_fail("device fault");
  }
}

#else

#define gpu_probe() false
#define gpu_make(p) true
#define gpu_span()  0
#define gpu_load(b)
#define gpu_pass(f)

#endif

// Cube
// ====

// The host's column grows to the rows that give a LINE of tasks a thread,
// no more: every task a grow starts early is live at once (tree-matmul's
// 2048 at 16 threads start 384 rounds: 15 MB -> 68 MB), and pool_step
// splits the few rows finely instead. A turn visits only the rows below
// its bound: a drain deals task g to ring_flip(g), whose row is at most g,
// a row grows into itself, and a column grow's cur tasks land in rows 0
// to cur - 1, so those rows hold every task.

// Between turns, each ring's pending tasks move back to slot 0.

static void ring_rewind(u64* H, u32 rows) {
  Term keep[RING_LEN];
  for (u32 r = 0; r < (rows < CUBE_G ? rows : CUBE_G) * CUBE_T; r += 1) {
    u32 g = *ring_get(H, r);
    u32 n = *ring_put(H, r) - g;
    if (g == 0 || n > RING_LEN) {
      continue;
    }
    for (u32 i = 0; i < n; i += 1) {
      keep[i] = *ring_slot(H, r, g + i) & ~RFC_BIT;
    }
    for (u32 i = n; i < g + n && i < RING_LEN; i += 1) {
      ((u32*)ring_slot(H, r, i))[1] = 0;
    }
    *ring_get(H, r) = *ring_put(H, r) = 0;
    for (u32 i = 0; i < n; i += 1) {
      ring_push(H, r, keep[i]);
    }
  }
}

static void cube_run(u64* H, bool gpu) {
  for (;;) {
    u32 f = a32_exch(a32_at(H, H_CURSOR), 0);
    if (root_done(H)) {
      return;
    }
    if (f == 0) {
      err_fail("frontier drained without a result");
    }
    if (gpu) {
      gpu_pass(f);
    } else {
      u32 rows = f;
      u32 want = (pool_size - 1) / (CUBE_T / LINE) + 1;
      if (f < want) {
        u32 cur = row_grow((Env){ H, ALC[0] }, io_stk, 0, CUBE_G, want);
        rows = cur > f ? cur : f;
      }
      if (f < CUBE) {
        pool_turn(true, rows);
      }
      f = a32_load(a32_at(H, H_CURSOR));
      pool_turn(false, f > rows ? f : rows);
      f = a32_load(a32_at(H, H_CURSOR));
      ring_rewind(H, f > rows ? f : rows);
    }
    u32 ec = a32_load(a32_at(H, H_ERROR_CODE));
    if (ec != 0) {
      err_post(H, ec);
    }
  }
}

// Corpus
// ======

// The cores map 8 GiB at a high base and double it in place, so one
// base holds every location; the banks move up past the pages. The GPU maps
// its whole span at once, and never grows it.

static u64 corpus_size;

static void* corpus_map(u64 size) {
  u64   hint = 1ull << 45;
  void* p    = pool_try((void*)hint, size);
  while (p != (void*)hint && hint > size) {
    if (p != MAP_FAILED) {
      munmap(p, size);
    }
    hint /= 2;
    p     = pool_try((void*)hint, size);
  }
  if (p == MAP_FAILED) {
    err_fail("reservation failed");
  }
  return p;
}

static void corpus_lay(u64* H, u64 size) {
  u64 span = size / 8;
  u64 cap  = span > HEAP_OFF ? (span - HEAP_OFF) / (PAGE_LEN + 10) : 0;
  if (cap <= CUBE) {
    err_fail("the GPU span is under the rings, stacks and a page per lane");
  }
  cap = cap < ~0u ? cap : ~0u - 1;
  u64 at = HEAP_OFF + (cap << PAGE_BITS);
  for (u32 c = 0; c < NCLS_ALL; c += 1) {
    Bank* b = bank_at(H, c);
    memcpy(H + at, H + b->off, b->wr * sizeof(u64));
    b->off  = at;
    at     += 2 * (cap >> ((c < NCLS ? NCLS : c) - PAGE_BITS));
  }
  corpus_size = size;
  a32_store_rel(a32_at(H, H_CAP), (u32)cap);
}

static bool corpus_grow(u64* H, u64 need) {
  bool ok = true;
  LOCK(bank_lock);
  while (ok && need > a32_load(a32_at(H, H_CAP))) {
    u64   more = corpus_size;
    char* at   = (char*)H + more;
    void* got  = io_gpu || more >= 1ull << 43 ? MAP_FAILED
      : pool_try(at, more);
    ok = got == at;
    if (ok) {
      corpus_lay(H, more * 2);
    } else if (got != MAP_FAILED) {
      munmap(got, more);
    }
  }
  UNLOCK(bank_lock);
  return ok;
}

static u64* corpus_setup(bool gpu, long threads, u64 bytes) {
  io_gpu     = gpu;
  KEEP_WORDS = gpu ? CHUNK : CAP_WORDS;
  u64 dflt   = gpu ? gpu_span() : 1ull << 33;
  u64 size   = (gpu && bytes != 0 ? bytes : dflt) & ~16383ull;
  CORPUS     = gpu ? gpu_map(size) : corpus_map(size);
  u64* H     = CORPUS;
#if BEND_CUDA
  if (gpu) {
    cuMemsetD8((CUdeviceptr)(uintptr_t)H, 0, STAK_OFF * 8);
    cuCtxSynchronize();
  }
#endif
  corpus_lay(H, size);
  memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));
  a32_store(a32_at(H, H_BUMP), 1);
  if (gpu) {
    gpu_load(size);
  }
  pool_size = threads < 1 ? 1 : threads < CUBE_T ? threads : CUBE_T;
  return H;
}

OUTLINE Term corpus_eval(u64* H, Term t) {
  Env  e = { H, ALC[0] };
  Term rv[WL_RESW];
  for (;;) {
    Term r = work_loop(e, io_stk, t, !BANGS && pool_size == 1);
    if (r == 0) {
      if (root_done(H)) {
        break;
      }
      err_fail("solo delivery lost");
    }
    if ((u32)H[task_tail(r) + 1] == 0) {
      t = r;
      if (io_gpu && fid_bangs((u32)term_aux(t))) {
        u64  tl   = task_tail(t);
        Term cont = H[tl];
        u32  idx  = (u32)(H[tl + 1] >> 32) & 0xFFFF;
        H[tl]     = TERM_HOLE;
        a32_store(a32_at(H, H_CURSOR), 1);
        ring_push(H, 0, t);
        cube_run(H, true);
        Term p = task_deliver(H, cont, idx, rv, root_take(H, rv));
        if (root_done(H)) {
          break;
        }
        if (p == 0) {
          err_fail("seam delivery lost");
        }
        t = p;
      }
      continue;
    }
    task_deal(H, r, 0, 0, NULL);
    pool_open();
    cube_run(H, false);
    break;
  }
  root_take(H, rv);
  return rv[0];
}

// Io
// ==

// Base's opaque, linear handles pack host fds or pointers into aux and loc:
// no forging, copying, reuse or host wrapper. A request's cont applied to
// its item is the next request. A parked request keeps its fd, deadline and
// readiness in word, time and evts; the loop then calls pack: a value
// resumes, IO_PARK parks again. The edge is UTF-8, decoded as WHATWG does: a
// broken sequence yields one U+FFFD and its breaking byte is read again as a
// lead. inet_aton reads a leading zero as octal, so io_sys_addr refuses it.
// macOS poll misses FIFO EOF, so io_wait selects, its sets sized to the
// highest fd (_DARWIN_UNLIMITED_SELECT allows fds past FD_SETSIZE).

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>

#define IO_READ 1
#define IO_TIME 2
#define IO_PARK TERM_HOLE

#define io_hand(v)   term_make(TAG_PAK, (u64)(v) >> 40, (u64)(v) & LOC_MASK)
#define io_hand_v(t) (((u64)term_aux(t) << 40) | term_loc(t))

struct IoWork;
typedef void (*IoCall)(struct IoWork* w);
typedef Term (*IoPack)(Env e, struct IoWork* w);

typedef struct IoWork {
  intptr_t       hand;
  intptr_t       made;
  u32            word;
  u64            size;
  char*          data;
  char*          text;
  u32            code;
  IoCall         call;
  IoPack         pack;
  Term           cont;
  Term           item;
  u64            time;
  short          evts;
  struct IoWork* next;
} IoWork;

typedef Term (*Effect)(Env e, Term* f, IoWork* w);

typedef struct {
  Effect run;
  u32    ask;
} IoEff;

static IoEff io_eff_rows[1 << 16];
static u32   io_live;

static u64 io_tick(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (u64)ts.tv_sec * 1000000000ull + (u64)ts.tv_nsec;
}

OUTLINE void* io_mem(void* mem) {
  if (mem == NULL) {
    err_fail("host allocation failed");
  }
  return mem;
}

static int io_sys_addr(const char* host, u32 port, struct sockaddr_in* at) {
  memset(at, 0, sizeof(*at));
  at->sin_family = AF_INET;
  at->sin_port   = htons((uint16_t)port);
  for (const char* p = host; *p != 0; p += 1) {
    if ((p == host || p[-1] == '.') && *p == '0'
      && p[1] >= '0' && p[1] <= '9') {
      return -1;
    }
  }
  return port > 65535 || inet_pton(AF_INET, host, &at->sin_addr) != 1
    ? -1 : 0;
}

static int    io_argc;
static char** io_argv;

static void io_eff(u32 cid, Effect run, u32 need) {
  if (io_eff_rows[cid].run != NULL) {
    err_fail("two effects register one request");
  }
  io_eff_rows[cid] = (IoEff){ run, need };
}

static u64 io_sys_end(IoWork* w, ssize_t n) {
  w->code = n < 0 ? (u32)errno : 0;
  return n < 0 ? 0 : (u64)n;
}

static IoWork* io_runs;
static IoWork* io_park;
static IoWork* io_jobs;

static void io_push(IoWork** q, IoWork* a) {
  IoWork* l = *q != NULL ? *q : a;
  a->next = l->next;
  l->next = a;
  *q      = a;
}

static IoWork* io_pop(IoWork** q) {
  IoWork* a  = (*q)->next;
  (*q)->next = a->next;
  *q         = a != *q ? *q : NULL;
  return a;
}

static void io_spawn(Term m) {
  IoWork* a = io_mem(calloc(1, sizeof(IoWork)));
  a->cont  = m;
  a->item  = term_clo(FID(IO~emit), 0);
  io_push(&io_runs, a);
  io_live += 1;
}

// io_park stays in deadline order (time 0, none, sorts last; ties keep
// their park order), so io_wait wakes due timers in the order they expire.
static void io_park_add(IoWork* w) {
  IoWork* p = io_park;
  if (p == NULL || p->time - 1 <= w->time - 1) {
    io_push(&io_park, w);
    return;
  }
  while (p->next->time - 1 <= w->time - 1) {
    p = p->next;
  }
  io_push(&p, w);
}

static Term io_wait_on(IoWork* w, int fd, short evts, u64 time, IoPack more) {
  w->word = (u32)fd;
  w->pack = more;
  w->time = time;
  w->evts = evts;
  io_park_add(w);
  return IO_PARK;
}

OUTLINE void io_out(FILE* h, const char* data, u64 len) {
  if (fwrite(data, 1, len, h) != len) {
    err_fail("a short write on a standard stream");
  }
}

OUTLINE void io_sync(void) {
  if (fflush(stdout) != 0) {
    err_fail("a short write on a standard stream");
  }
}

static u64 io_utf8(char* buf, u64 c) {
  u64 k = c < 0x80 ? 1 : c < 0x800 ? 2 : c < 0x10000 ? 3 : 4;
  for (u64 i = k; i > 1; i -= 1) {
    buf[i - 1] = (char)(0x80 | (c & 0x3F));
    c >>= 6;
  }
  buf[0] = (char)(k == 1 ? c : (0xF00 >> k) | c);
  return k;
}

// io_cbuf writes a String (cons SCon) as UTF-8, or a List (cons Con) as
// its bytes, with no UTF-8: NULL if a value is past 255.
OUTLINE char* io_cbuf(Env e, Term s, u64* len, u64 cons) {
  u64   cap = 64;
  u64   n   = 0;
  u64   bad = 0;
  char* buf = io_mem(malloc(cap));
  while (term_aux(s) == cons) {
    Term fb[2];
    spare_free(e, cls_fit(2), ctr_take(e, s, 2, fb));
    if (n + 5 > cap) {
      cap *= 2;
      buf = io_mem(realloc(buf, cap));
    }
    if (cons == CID(SCon)) {
      n += io_utf8(buf + n, fb[0]);
    } else {
      bad |= fb[0] > 255;
      buf[n++] = (char)fb[0];
    }
    s = fb[1];
  }
  buf[n] = 0;
  *len = n;
  if (bad) {
    free(buf);
    return NULL;
  }
  return buf;
}

#define io_cstr(e, s, len) io_cbuf(e, s, len, CID(SCon))

OUTLINE void io_errs(Env e, Term s) {
  u64   n    = 0;
  char* text = io_cstr(e, s, &n);
  io_sync();
  io_out(stderr, text, n);
  io_out(stderr, "\n", 1);
  free(text);
}

#define io_nul(s, n) (strlen(s) != (n))

#define io_seal(e, t, cid) (cid_hot(cid) ? rfc_seal(e, t) : (t))

static Term io_node(Env e, u64 cid, Term a, Term b) {
  u64 l = heap_alloc(e, 1);
  e.mem[l]     = io_seal(e, a, cid);
  e.mem[l + 1] = io_seal(e, b, cid);
  return term_ctr(cid, l);
}

static Term io_str(Env e, const char* p, u64 n) {
  Term s    = term_pak(CID(SNil), 0);
  u64  hole = 0;
  u64  c = 0, need = 0, lo = 0x80, hi = 0xBF;
  for (u64 i = 0; i < n || need > 0; i += 1) {
    u64 b = i < n ? (uint8_t)p[i] : 0x100;
    if (need > 0 && (b < lo || b > hi)) {
      need = 0;
      c    = 0xFFFD;
      i   -= 1;
    } else if (need > 0) {
      lo = 0x80;
      hi = 0xBF;
      c  = (c << 6) | (b & 0x3F);
      if (--need > 0) {
        continue;
      }
    } else if (b < 0x80) {
      c = b;
    } else if (b < 0xC2 || b > 0xF4) {
      c = 0xFFFD;
    } else {
      need = b < 0xE0 ? 1 : b < 0xF0 ? 2 : 3;
      lo   = b == 0xE0 ? 0xA0 : b == 0xF0 ? 0x90 : 0x80;
      hi   = b == 0xED ? 0x9F : b == 0xF4 ? 0x8F : 0xBF;
      c    = b & (0x3F >> need);
      continue;
    }
    u64  l = heap_alloc(e, 1);
    Term t = term_ctr(CID(SCon), l);
    e.mem[l] = c;
    if (hole == 0) {
      s = t;
    } else {
      e.mem[hole] = io_seal(e, t, CID(SCon));
    }
    hole = l + 1;
  }
  if (hole != 0) {
    e.mem[hole] = io_seal(e, term_pak(CID(SNil), 0), CID(SCon));
  }
  return s;
}

// Bytes cross as they are (0..255), one List cell each, with no UTF-8.
#ifdef CID(Con)

static Term io_list(Env e, const char* p, u64 n) {
  Term xs = term_pak(CID(Nil), 0);
  for (u64 i = n; i > 0; i -= 1) {
    xs = io_node(e, CID(Con), (uint8_t)p[i - 1], xs);
  }
  return xs;
}

#endif

#define io_tup(e, a, b) io_node(e, CID(Tuple), a, b)
#define io_done(e, v)   io_box(e, CID(Done), v)
#define io_res(e, w, v) ((w)->code ? io_fail(e, (w)->code, NULL) \
  : io_done(e, v))

static Term io_box(Env e, u64 cid, Term v) {
  u64 l = heap_alloc(e, 0);
  e.mem[l] = io_seal(e, v, cid);
  return term_ctr(cid, l);
}

static Term io_fail(Env e, u32 code, const char* text) {
  const char* s = text != NULL ? text : strerror((int)code);
  Term t = io_tup(e, code, io_str(e, s, strlen(s)));
  return io_box(e, CID(Fail), t);
}

static pthread_mutex_t io_gate = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  io_bell = PTHREAD_COND_INITIALIZER;
static u32             io_busy;
static u32             io_size;
static int             io_wake_fd[2];

static void io_take(Env e) {
  IoWork* acts[64];
  ssize_t n;
  while ((n = read(io_wake_fd[0], acts, sizeof acts)) > 0) {
    for (u32 i = 0; i < (u32)n / sizeof(IoWork*); i += 1) {
      IoWork* a = acts[i];
      a->item   = a->pack(e, a);
      io_push(&io_runs, a);
      io_busy -= 1;
    }
  }
}

static void* io_help(void* arg) {
  for (;;) {
    pthread_mutex_lock(&io_gate);
    while (io_jobs == NULL) {
      pthread_cond_wait(&io_bell, &io_gate);
    }
    IoWork* a = io_pop(&io_jobs);
    pthread_mutex_unlock(&io_gate);
    a->call(a);
    while (write(io_wake_fd[1], &a, sizeof a) != sizeof a) {
    }
  }
}

static Term io_work(IoWork* w, IoCall call, IoPack pack) {
  w->call  = call;
  w->pack  = pack;
  io_busy += 1;
  if (io_busy > io_size && io_size < IO_HELP) {
    pthread_t tid;
    if (pthread_create(&tid, NULL, io_help, NULL)) {
      err_fail("pthread_create");
    }
    pthread_detach(tid);
    io_size += 1;
  }
  pthread_mutex_lock(&io_gate);
  io_push(&io_jobs, w);
  pthread_cond_signal(&io_bell);
  pthread_mutex_unlock(&io_gate);
  return IO_PARK;
}

static Term io_exec(Env e, IoWork* w) {
  Term fs[256];
  u32  c = (u32)term_aux(w->cont);
  u32  n = cid_arity(c);
  spare_free(e, cls_fit(n), ctr_take(e, w->cont, n, fs));
  w->cont = fs[n - 1];
  return io_eff_rows[c].run(e, fs, w);
}

static bool io_bit(u8* set, int fd, bool put) {
  u8* at = set + fd / 8;
  *at |= put << fd % 8;
  return *at >> fd % 8 & 1;
}

static void io_wait(Env e, bool block) {
  int top  = io_wake_fd[0];
  u64 soon = io_park != NULL ? io_park->next->time : 0;
  for (IoWork* a = io_park; a != NULL;
    a = a->next != io_park ? a->next : NULL) {
    if (a->evts != 0 && (int)a->word > top) {
      top = (int)a->word;
    }
  }
  u64 len = (u64)top / 64 * 8 + 8;
  u8* set[2] = { io_mem(calloc(2, len)), NULL };
  set[1] = set[0] + len;
  io_bit(set[0], io_wake_fd[0], true);
  for (IoWork* a = io_park; a != NULL;
    a = a->next != io_park ? a->next : NULL) {
    if (a->evts != 0) {
      io_bit(set[a->evts == POLLOUT], (int)a->word, true);
    }
  }
  u64 tick = io_tick();
  u64 ms = soon > tick && block ? (soon - tick) / 1000000 + 1 : 0;
  struct timeval tv = { ms / 1000, ms % 1000 * 1000 };
  io_sync();
  if (select(top + 1, (fd_set*)set[0], (fd_set*)set[1], NULL,
    soon == 0 && block ? NULL : &tv) < 0) {
    if (errno != EINTR) {
      err_fail("the poller failed");
    }
    memset(set[0], 0, 2 * len);
  }
  if (io_bit(set[0], io_wake_fd[0], false)) {
    io_take(e);
  }
  u64     now  = io_tick();
  IoWork* todo = io_park;
  io_park = NULL;
  while (todo != NULL) {
    IoWork* a   = io_pop(&todo);
    bool    due = (a->evts != 0
        && io_bit(set[a->evts == POLLOUT], (int)a->word, false))
      || (a->time != 0 && a->time <= now);
    if (!due) {
      io_park_add(a);
      continue;
    }
    Term x = a->pack(e, a);
    if (x != IO_PARK) {
      a->item = x;
      io_push(&io_runs, a);
    }
  }
  free(set[0]);
}

${NATIVE.IO}

// Show
// ====

// show_val prints a pure main's value as term_show spells it: d
// is a SHOW_DESC node (see show_main), w its words, and chain the
// bracket of the [a, b] or (a, b) the value continues, or 0. Con
// or Nil spell a list, Tuple a tuple, and their tails continue
// it. show_chr escapes as char_show does; show_f32 prints the
// shortest text that reads back, with a point before an e.

#if MAIN_PURE

static void show_val(Env e, u32 d, const Term* w, char chain);

static void show_chr(u64 c, char q) {
  char b[4];
  int  k = c == 10 ? 'n' : c == 9 ? 't' : c == 13 ? 'r' : c == 0 ? '0'
    : c == 92 || c == (u64)q ? (int)c : 0;
  if (k != 0) {
    printf("\\%c", k);
  } else if (c < 32 || c == 127 || (c >= 0xD800 && c <= 0xDFFF)
    || c > 0x10FFFF) {
    printf("\\u{%llx}", (unsigned long long)c);
  } else {
    fwrite(b, 1, io_utf8(b, c), stdout);
  }
}

static void show_f32(u32 x) {
  char  buf[40];
  int   n  = f32_text(buf, f32_unbox(x));
  char* ep = memchr(buf, 'e', n);
  int   m  = ep == NULL ? n : (int)(ep - buf);
  buf[n] = 0;
  if (strpbrk(buf, ".ni") == NULL) {
    printf("%.*s.0%s", m, buf, buf + m);
  } else {
    fputs(buf, stdout);
  }
}

static void show_val(Env e, u32 d, const Term* w, char chain) {
  const u32* D = SHOW_DESC;
  Term one;
  char zs[4];
  u32  zn = 0;
  for (bool tail = true; tail;) switch (tail = false, D[d]) {
    case 0:
      printf("%u", (u32)w[0]);
      break;
    case 1:
      show_f32((u32)w[0]);
      break;
    case 2:
      printf("%llun", (unsigned long long)w[0]);
      break;
    case 3:
      putchar('\'');
      show_chr(D[d + 1] != 0 ? term_loc(w[0]) : w[0], '\'');
      putchar('\'');
      break;
    case 4:
      putchar('"');
      for (Term s = w[0]; term_aux(s) == CID(SCon);) {
        u64 l = term_peek(e.mem, s);
        show_chr(e.mem[l], '"');
        s = e.mem[l + 1];
      }
      putchar('"');
      break;
    case 5:
      fputs("{==}", stdout);
      break;
    case 6:
      putchar('[');
      for (u32 i = 0, g = D[d + 2]; i < 1u << (blk_cls(w[0]) - g); i += 1) {
        Term v[1u << g];
        for (u32 j = 0; j < 1u << g; j += 1) {
          v[j] = blk_read(e.mem, term_tag(w[0]) == TAG_ARR,
            term_peek(e.mem, w[0]), (i << g) + j);
        }
        fputs(i > 0 ? ", " : "", stdout);
        show_val(e, D[d + 1], v, 0);
      }
      putchar(']');
      break;
    default: {
      Term t   = w[0];
      bool box = D[d + 1] != 0;
      u32  key = box ? (u32)term_aux(t) : D[d + 2] > 1 ? (u32)t : 0;
      u32  a   = d + 3;
      for (u32 i = 0; box ? D[a + 1] != key : i != key; i += 1) {
        a += 4 + 2 * D[a + 2];
      }
      if (box) {
        one = term_loc(t);
        w   = term_tag(t) == TAG_PAK ? &one : e.mem + term_peek(e.mem, t);
      }
      char o = "{[("[D[a + 3]];
      if (o == '{') {
        printf("%s{", SHOW_NAMES[D[a]]);
      } else if (chain != o) {
        putchar(o);
      }
      if (o == '{' || chain != o) {
        zs[zn++] = "}])"[D[a + 3]];
      }
      for (u32 j = 0; j < D[a + 2]; j += 1) {
        if (o == '[' ? j == 0 && chain == o : j > 0) {
          fputs(", ", stdout);
        }
        if (j == 1 && o != '{') {
          tail  = true;
          chain = o;
          d     = D[a + 5 + 2 * j];
          w     = w + D[a + 4 + 2 * j];
        } else {
          show_val(e, D[a + 5 + 2 * j], w + D[a + 4 + 2 * j], 0);
        }
      }
    }
  }
  while (zn > 0) {
    putchar(zs[--zn]);
  }
}

#endif

// Run
// ===

static void io_step(Env e, IoWork* a) {
  for (;;) {
    u64  ap  = task_node(e, FID(Clo~apply), TERM_HOLE, 0, 0);
    e.mem[ap]     = a->cont;
    e.mem[ap + 1] = a->item;
    Term req = corpus_eval(e.mem, term_tsk(FID(Clo~apply), ap));
    u32  c   = (u32)term_aux(req);
    u64  at  = term_peek(e.mem, req);
    if (c == CID(Emit)) {
      term_drop(e, req);
      free(a);
      io_live -= 1;
      return;
    }
    if (c == CID(Halt)) {
      io_errs(e, e.mem[at + 1]);
      exit((int)(u32)e.mem[at]);
    }
    if (io_eff_rows[c].run == NULL) {
      err_fail("an alien request");
    }
    u32 need = io_eff_rows[c].ask;
    u32 word = (u32)(need & IO_READ ? io_hand_v(e.mem[at]) : e.mem[at]);
    a->cont  = req;
    if (need != 0) {
      io_wait_on(a, (int)word, need & IO_READ ? POLLIN : 0,
        need & IO_TIME ? io_tick() + (u64)word * 1000000ull : 0, io_exec);
      return;
    }
    Term x = io_exec(e, a);
    if (x == IO_PARK) {
      return;
    }
    a->item = x;
  }
}

OUTLINE void io_loop(u64* H) {
  Env e = { H, ALC[0] };
  io_stk = pool_stack();
  signal(SIGPIPE, SIG_IGN);
  if (pipe(io_wake_fd) | fcntl(io_wake_fd[0], F_SETFL, O_NONBLOCK)) {
    err_fail("the event loop failed to open");
  }
  Term m = corpus_eval(H, term_tsk(MAIN_FID, task_node(e, MAIN_FID,
    TERM_HOLE, 0, 0)));
#if MAIN_PURE
  show_val(e, 0, H + H_ROOT_WORD, 0);
  putchar('\n');
  return;
#endif
  io_spawn(m);
  u64 look = 0;
  for (u32 n = 0;; n += 1) {
    if (io_runs == NULL) {
      if (io_live == 0) {
        return;
      }
      if (io_park == NULL && io_busy == 0) {
        io_sync();
        err_fail("deadlock: every computation waits on a channel");
      }
      io_wait(e, true);
      continue;
    }
    if ((n & 63) == 0 && io_busy != 0) {
      io_take(e);
    }
    // A busy loop still checks due timers, and fds periodically.
    if ((n & 63) == 0 && io_park != NULL) {
      u64 now = io_tick();
      if (now >= look || io_park->next->time - 1 < now) {
        look = now + 10000000;
        io_wait(e, false);
      }
    }
    io_step(e, io_pop(&io_runs));
  }
}

// Requests
// ========

${reqs}

// Main
// ====

int main(int argc, char** argv) {
  long thr = 0;
  int  gpu = -1;
  u64  mem = 0;
  io_argv = argv;
  io_argc = 1;
  for (int i = 1; i < argc; i += 1) {
    const char* a = argv[i];
    const char* v = i + 1 < argc ? argv[i + 1] : NULL;
    if (strcmp(a, "--") == 0) {
      while (i + 1 < argc) {
        io_argv[io_argc++] = argv[++i];
      }
    } else if (strcmp(a, "--bend-help") == 0) {
      printf(CLI_HELP, argv[0]);
      return 0;
    } else if (strcmp(a, "--gpu-build") == 0) {
      if (gpu_probe() && !gpu_make(gpu_path())) {
        fprintf(stderr, "bend: cannot write %s\n", gpu_path());
        return 1;
      }
      return 0;
    } else if (strcmp(a, "--threads") == 0) {
      char* end = NULL;
      thr = v != NULL ? strtol(v, &end, 10) : 0;
      if (thr < 1 || *end != '\0') {
        err_fail("expected a thread count of 1 or more after --threads");
      }
      i += 1;
    } else if (strcmp(a, "--gpu") == 0) {
      char*  end = NULL;
      double n   = v != NULL ? strtod(v, &end) : 0;
      u64    mul = end == NULL ? 0 : strcmp(end, "GB") == 0 ? 1ull << 30
        : strcmp(end, "MB") == 0 ? 1ull << 20 : 0;
      if (v != NULL && strcmp(v, "off") == 0) {
        gpu = 0;
      } else if (v != NULL && (strcmp(v, "on") == 0 || (mul != 0 && n > 0))) {
        gpu = 1;
        mem = (u64)(n * (double)mul);
      } else {
        err_fail("expected on, off or a size like 4GB after --gpu");
      }
      i += 1;
    } else {
      io_argv[io_argc++] = argv[i];
    }
  }
  bool dev = gpu != 0 && BANGS != 0 && gpu_probe();
  if (gpu == 1 && BANGS != 0 && !dev) {
    err_fail("--gpu on, but this binary found no usable GPU (a CUDA GPU needs"
      " concurrent managed access, which WSL2's lack)");
  }
  io_loop(corpus_setup(dev, thr > 0 ? thr : cpu_count(), mem));
  io_sync();
  return 0;
}

#endif
`.slice(1);
var RUNTIME = String.raw`
${NATIVE.JS}
// Array
// =====

function array_new(d, v) {
  if (d > 31) {
    throw "bend: ${ERRS[8]}";
  }
  return Array(2 ** d).fill(v);
}

function array_node(a, b) {
  if (a.length !== b.length) {
    throw "bend: ${ERRS[2]}";
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
`.slice(1);
var RUNTIME_MAIN = String.raw`
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
      throw "bend: ${ERRS[7]}";
    }
    if (req?.$ !== "$FFI") {
      throw req;
    }
    io_errs("bend: ${ERRS[2]}");
    return 1;
  }
}
`.slice(1);

// ../bend2-core/.claude/worktrees/rel-2035/bend2/safe.ts
import * as child from "child_process";
import * as crypto2 from "crypto";
import * as fs3 from "fs";
import * as os2 from "os";
import * as path2 from "path";
var NAT_MAX = 4096;
var MODEL_FUEL = 1 << 22;
var MODEL_DEPTH = 8;

class Scope_Error extends Error {
}

class Regroup extends Error {
  key;
  constructor(key) {
    super(key);
    this.key = key;
  }
}

class Reroute extends Error {
}
function oos(why) {
  throw new Scope_Error(why);
}
function safe_book(book) {
  const n0 = Object.keys(book.tlds).length;
  const groups = new Map;
  const inst = new Map(Object.entries(book.tmps).flatMap(([k, is]) => [...is].map(([key, n]) => [n, [k, key.split(`
`).map((a) => term_higher(JSON.parse(a)))]])));
  for (let r = safe_pass(book, groups, inst);; r = safe_pass(book, groups, inst)) {
    if (r !== null) {
      return r;
    }
    Object.keys(book.tlds).slice(n0).forEach((k) => delete book.tlds[k]);
  }
}
function safe_pass(book, groups, inst) {
  const g0 = groups.size;
  const e = {
    book,
    mb: { ...book, tlds: Object.create(book.tlds) },
    out: [],
    names: new Map,
    seen: new Set,
    todo: [],
    taken: new Set,
    fail: new Map,
    spec: new Map,
    groups,
    inst,
    stack: [],
    going: new Set,
    grew: false
  };
  const roots = [];
  for (const k of [...book.order].filter((k2, i) => book.order.lastIndexOf(k2) === i && book.tlds[k2].b !== true)) {
    try {
      roots.push(...root_cols(e, k, book.tlds[k].T, 0).map((cols) => [k, item_try(e, k, cols)]));
    } catch (x) {
      if (!(x instanceof Scope_Error)) {
        throw x;
      }
      const n = fresh(e, name_tt(k));
      e.fail.set(n, x.message);
      roots.push([k, n]);
    }
  }
  for (let it = e.todo.pop();it !== undefined; it = e.todo.pop()) {
    item_try(e, it[0], it[1]);
  }
  if (e.grew || groups.size > g0 && [...e.names.keys()].some((key) => key[0] !== "\t" && groups.has(key.split(`
`)[0]))) {
    return null;
  }
  const bad = new Map(e.fail);
  for (let more = true;more; ) {
    more = false;
    for (const [k, T, v] of e.out) {
      const r = bad.has(k) ? undefined : [...o_refs(T), ...o_refs(v)].find((r2) => bad.has(r2));
      if (r !== undefined) {
        bad.set(k, "names " + name_key(r) + ", out of scope: " + (e.fail.get(r) ?? bad.get(r)));
        more = true;
      }
    }
  }
  e.out = e.out.filter(([k]) => !bad.has(k));
  const oos2 = roots.filter(([, n]) => bad.has(n)).map(([k, n]) => [k, bad.get(n)]);
  return { text: book_show(e), oos: oos2 };
}
function root_cols(e, k, T, j) {
  const sp = spec_of(e, k);
  const F = term_wnf(e.book, T);
  if (j === sp.length || F.$ !== "All") {
    return [[]];
  }
  const at = (v) => root_cols(e, k, F.B(v ?? Var(F.k, j)), j + 1).map((cs) => [v, ...cs]);
  if (!sp[j]) {
    return at(null);
  }
  const A = term_wnf(e.book, F.A);
  const adt = A.$ === "ADT" && A.x.length === 0 ? e.book.tlds[A.k] : null;
  const vs = A.$ === "Qnt" ? [None(), Lone(), Many()].map((q) => Qua(q)) : adt !== null && adt.c.every((c2) => term_wnf(e.book, c2.T).$ !== "All") ? adt.c.map((c2) => Ctr(c2.k, [])) : null;
  if (vs !== null) {
    return vs.flatMap(at);
  }
  if (mentions(term_lower(F.A, j), (i) => i >= 0 && i < j)) {
    oos("a specialized parameter whose type names a parameter");
  }
  let c = k + "~" + F.k;
  while (e.book.tlds[c] !== undefined) {
    c += "~";
  }
  const def = { $: "Def", n: 0, x: 0, T: F.A, v: null };
  e.book.tlds[c] = def;
  const m = model(e, F.A);
  if (m !== null) {
    e.mb.tlds[c] = { ...def, v: m };
  }
  return at(Ref(c));
}
function item_try(e, k, cols) {
  try {
    return item_ref(e, k, cols, true);
  } catch (x) {
    if (x instanceof Reroute) {
      return item_try(e, k, cols);
    }
    if (!(x instanceof Scope_Error)) {
      throw x;
    }
    return e.names.get(item_key(k, cols));
  }
}
function item_key(k, cols) {
  return [k, ...cols.flatMap((v) => v === null ? [] : [term_key(term_lower(v))])].join(`
`);
}
function item_ref(e, k, cols, live) {
  const key = item_key(k, cols);
  const m = live && !e.seen.has(key) ? trail(e) : null;
  let n = e.names.get(key);
  if (n === undefined) {
    const tag = cols.flatMap((v) => v === null ? [] : [v.$ === "Qua" ? String(quant(v.q)) : "v"]).join("");
    n = fresh(e, name_tt(k[0] === "\t" ? k.slice(1) + ".group" : k) + (tag !== "" ? ".q" + tag : ""));
    e.names.set(key, n);
    e.todo.push([k, cols]);
  }
  const why = e.fail.get(n);
  if (why !== undefined && live) {
    oos(why);
  }
  if (m !== null) {
    e.seen.add(key);
    e.stack.push(key);
    e.going.add(key);
    try {
      item_emit(e, k, cols, n);
    } catch (x) {
      if (x instanceof Scope_Error) {
        e.fail.set(n, x.message);
      }
      if (x instanceof Regroup && x.key === key) {
        undo(e, m);
        throw new Reroute;
      }
      throw x;
    } finally {
      e.stack.pop();
      e.going.delete(key);
    }
  } else if (live && e.going.has(key) && e.stack[e.stack.length - 1] !== key) {
    regroup(e, key);
  }
  return n;
}
function item_emit(e, k, cols, n) {
  if (k[0] === "\t") {
    return group_emit(e, group_of(e, k.slice(1)), cols, n);
  }
  const tld = e.book.tlds[k];
  if (tld === undefined) {
    oos("an unknown name " + name_key(k));
  }
  if (tld.$ === "ADT") {
    return adt_emit(e, cols, n, tld);
  }
  if (tld.u === true) {
    oos("uses " + (tld.b === true ? "base's" : "the") + " @unsafe def " + name_key(k));
  }
  def_emit(e, k, cols, n, tld);
}
function def_emit(e, k, cols, n, tld) {
  const T = type_drop(e, tld.T, cols);
  const t = tld.e !== undefined ? null : model(e, T) ?? oos("no model for " + (tld.i === undefined ? "" : (tld.b === true ? "base's" : "the") + " foreign def ") + name_key(k));
  const s = { ...scope_nil(), self: n };
  const To = term(e, s, T, false);
  e.out.push([n, To, t === null ? arm(e, s, k, cols, []) : tree(e, s, t, []), t !== null]);
}
function adt_emit(e, cols, n, tld) {
  const { s, ps, xs, T } = tele_open2(e, scope_nil(), tld.T, cols, tld.n);
  const K = term_wnf(e.book, T);
  if (K.$ !== "Typ") {
    oos("a datatype kind");
  }
  const G = Math.max(1, quant_eval(e, s, K.g));
  const am = fresh(e, n + ".arms");
  const t = s.D;
  const fs4 = (c) => alls(tele_open2(e, s, tele_fill(e.book, c.T, xs, ctx_nil()), [], Infinity).ps, { $: "Enu", ks: ["()"] }, "Sig");
  const arms = tld.c.reduceRight((m, c) => ({ $: "Mat", k: name_tt(c.k), h: fs4(c), m }), { $: "Efq" });
  const Enu = { $: "Enu", ks: tld.c.map((c) => name_tt(c.k)) };
  e.out.push([am, alls(ps, { $: "All", q: 1, l: t, A: Enu, B: { $: "Typ", q: G } }), lams(ps, arms), false]);
  const at = (k) => ps.reduce((f, [q, l]) => ({ $: "App", q, f, x: { $: "Var", l } }), { $: "Ref", k });
  e.out.push([n, alls(ps, { $: "Typ", q: G }), lams(ps, { $: "Sig", q: 1, l: t, A: Enu, B: { $: "App", q: 1, f: at(am), x: { $: "Var", l: t } } }), false]);
  if (tld.c.length === 0) {
    e.out.push([fresh(e, n + ".efq"), alls(ps, { $: "All", q: 1, l: t, A: at(n), B: { $: "Enu", ks: [] } }), lams(ps, { $: "Prj", h: { $: "Efq" } }), false]);
  }
}
function tele_open2(e, s, T, cols, n) {
  const r = { s, ps: [], xs: [], T };
  for (let j = 0;j < n; j++) {
    const F = term_wnf(e.book, r.T);
    if (F.$ !== "All") {
      break;
    }
    const q = quant(F.q);
    if (cols[j] == null) {
      r.ps.push([q, r.s.D, term(e, r.s, F.A, false)]);
      r.s = scope_kq(scope_bind(r.s, { $: "Var", l: r.s.D }, F.A, true), r.s.D, q);
    }
    r.xs.push(cols[j] ?? Var(F.k, r.s.d - 1));
    r.T = F.B(r.xs[j]);
  }
  return r;
}
function spec_of(e, k) {
  let sp = e.spec.get(k);
  if (sp === undefined) {
    e.spec.set(k, []);
    const tld = e.book.tlds[k];
    const got = new Set;
    const go = (t, q) => {
      if (typeof t !== "object" || t === null) {
        return;
      }
      const o = t;
      if (o.$ === "Var" && q) {
        got.add(o.i);
      }
      const [h, xs] = o.$ === "ADT" ? [o, o.x] : o.$ === "App" ? term_unapply(o) : [o, []];
      const hs = (h.$ === "Ref" || h.$ === "ADT") && e.book.tlds[h.k] !== undefined ? spec_of(e, h.k) : [];
      xs.forEach((x, j) => go(x, q || hs[j] === true));
      if (xs.length === 0) {
        Object.entries(o).forEach(([f, v]) => f !== "s" && go(v, q || o.$ === "Typ"));
      }
    };
    [tld.T, ...tld.$ === "ADT" ? tld.c.map((c) => c.T) : []].forEach((T) => go(term_lower(T), false));
    sp = tele_unbind(e.book, tld.T).doms.slice(0, tld.n).map(([, , A], j) => got.has(j) || is_qnt(e, A) || tld.$ === "Def" && j < tld.x);
    e.spec.set(k, sp);
  }
  return sp;
}
function spec_val(e, s, x) {
  const v = term_snf(e.book, subst(x, s.d, (o) => o.$ === "Var" && o.i >= 0 && o.i < s.d ? s.c[o.i]?.v ?? Var(o.k, o.i) : undefined));
  if (mentions(term_lower(v, s.d), (i) => i >= 0 && i < s.d)) {
    oos("a kind that depends on a run-time value");
  }
  return v;
}
function subst(t, d, f) {
  const go = (u) => {
    if (typeof u !== "object" || u === null) {
      return u;
    }
    const o = u;
    const v = f(o);
    return v !== undefined ? Var(o.k, -1, undefined, v) : Array.isArray(u) ? u.map(go) : Object.fromEntries(Object.entries(o).map(([k, x]) => [k, k === "s" ? x : go(x)]));
  };
  return term_higher(go(term_lower(t, d)));
}
function type_drop(e, T, cols) {
  if (!cols.some((v) => v !== null)) {
    return T;
  }
  const F = term_wnf(e.book, T);
  if (F.$ !== "All") {
    return T;
  }
  if (cols[0] !== null) {
    return type_drop(e, F.B(cols[0]), cols.slice(1));
  }
  return All(F.q, F.k, F.i, F.A, (x) => type_drop(e, F.B(x), cols.slice(1)));
}
function model(e, T) {
  return model_by(e, T, false) ?? model_by(e, T, true);
}
function model_by(e, T, proj) {
  const probe2 = { left: MODEL_FUEL, depth: MODEL_DEPTH, cut: true };
  let m = null;
  for (;probe2.cut && probe2.left > 0; probe2.depth *= 2) {
    probe2.cut = false;
    const v = model_at(e, T, 0, [], [], proj, probe2);
    m = probe2.cut ? m ?? v : v;
  }
  return m;
}
function model_key(F, d) {
  const at = (i) => typeof i === "number" && i >= d ? "^" + (i - d) : i;
  return JSON.stringify(term_lower(F, d), (k, v) => k === "s" ? undefined : k !== "i" ? v : Array.isArray(v) ? v.map(at) : at(v));
}
function model_at(e, T, d, path3, hs, proj, probe2) {
  if (path3.length + d > probe2.depth || probe2.left <= 0) {
    probe2.cut = true;
    return null;
  }
  probe2.left -= 1;
  const F = term_wnf(e.mb, T);
  const hyp = () => hs.find(([, A]) => term_compare("EQ", e.mb, A, F, d))?.[0] ?? null;
  switch (F.$) {
    case "Typ": {
      return ADT("Unit", []);
    }
    case "All": {
      const x = Var(F.k, d);
      const t = model_at(e, F.B(x), d + 1, path3, F.q.$ === "None" ? hs : [...hs, [x, F.A]], proj, probe2);
      return t === null ? null : Ann(Lam(F.k, d, (v) => subst(t, d + 1, (o) => o.$ !== "Var" || o.i > d ? undefined : o.i === d ? v : Var(o.k, o.i))), F);
    }
    case "ADT": {
      const key = model_key(F, d);
      probe2.left -= key.length;
      const tld = e.mb.tlds[F.k];
      const h = proj ? hyp() : null;
      for (const c of path3.includes(key) || h !== null ? [] : tld.c.filter((c2) => !F.r.includes(c2.k))) {
        const xs = [];
        let U = term_wnf(e.mb, tele_fill(e.mb, c.T, F.x, ctx_nil()));
        let x = null;
        while (U.$ === "All" && (x = model_at(e, U.A, d, [...path3, key], [], proj, probe2)) !== null) {
          xs.push(x);
          U = term_wnf(e.mb, U.B(x));
        }
        if (U.$ !== "All") {
          return Ann(Ctr(c.k, xs), F);
        }
      }
      return hyp();
    }
    case "Eql": {
      return term_compare("EQ", e.mb, F.a, F.b, d) ? Ann(Rfl(), F) : null;
    }
    default: {
      return hyp();
    }
  }
}
function fresh(e, n) {
  let k = n;
  while (e.taken.has(k)) {
    k += "_";
  }
  e.taken.add(k);
  return k;
}
function name_tt(k) {
  return name_key(k).replace(/[^A-Za-z0-9_.]|^[.0-9]/g, (c) => "_" + (c.codePointAt(0) ?? 0).toString(16) + "_");
}
function quant(q) {
  return q.$ === "None" ? 0 : q.$ === "Lone" ? 1 : 2;
}
function is_qnt(e, T) {
  return term_wnf(e.book, T).$ === "Qnt";
}
function quant_eval(e, s, t) {
  const x = spec_val(e, s, t);
  return x.$ === "Qua" ? quant(x.q) : oos("a Quant that is not a literal");
}
function scope_nil() {
  return { c: [], d: 0, D: 0, cols: [], self: "", empty: [], sub: false, kq: [], tags: [], dry: false, again: false };
}
function scope_bind(s, o, T, kb, v) {
  const c = s.c.slice();
  c[s.d] = { o, T, v };
  return { ...s, c, d: s.d + 1, D: s.D + (kb ? 1 : 0) };
}
function scope_hide(s) {
  return { ...s, D: s.D + 1 };
}
function scope_kq(s, l, q) {
  const kq = s.kq.slice();
  kq[l] = q;
  return { ...s, kq };
}
function scope_move(s, a, b) {
  const mv = (o) => o.$ === "Var" ? o.l === a ? { $: "Var", l: b } : o : Object.fromEntries(Object.entries(o).map(([k, v]) => [k, is_o(v) ? mv(v) : v]));
  return {
    ...s,
    c: s.c.map((x) => x === undefined ? x : { ...x, o: mv(x.o) }),
    empty: s.empty.map(mv),
    tags: s.tags.flatMap((t) => t === a ? [t, b] : [t])
  };
}
function convoy_bind(e, s, cv, t, fs4) {
  if (cv.length === 0) {
    return typeof t === "function" ? t(s) : tree(e, s, t, fs4);
  }
  const l = s.D;
  const f = convoy_bind(e, scope_move(scope_kq(scope_hide(s), l, 1), cv[0], l), cv.slice(1), t, fs4);
  return lams([[1, l]], f);
}
function open(t) {
  let T = null;
  let x = term_force(t);
  while (x.$ === "Ann") {
    T ??= term_force(x.T);
    x = term_force(x.x);
  }
  return [x, T];
}
function unapply(t) {
  const xs = [];
  let [x] = open(t);
  let h = t;
  while (x.$ === "App") {
    xs.push(x.x);
    h = x.f;
    [x] = open(x.f);
  }
  return [h, xs.reverse()];
}
function tree(e, s, t, fs4) {
  const top = fs4[fs4.length - 1];
  if (top !== undefined && top.n === 0) {
    return { $: "Mat", k: "()", h: convoy_bind(e, s, top.cv, t, fs4.slice(0, -1)), m: { $: "Efq" } };
  }
  const [x, T] = open(t);
  const all = all_of(e, T);
  const v = top === undefined ? s.cols[0] ?? null : null;
  if (v !== null && x.$ === "Lam") {
    const s2 = scope_bind({ ...s, cols: s.cols.slice(1) }, { $: "Efq" }, all?.A ?? null, false, v);
    return tree(e, s2, x.f(Var(x.k, s.d)), fs4);
  }
  if (v !== null && (x.$ === "Mat" || x.$ === "Efq")) {
    const [arm, vs] = pick(e, x, v);
    return tree(e, { ...s, cols: [...vs, ...s.cols.slice(1)] }, arm, fs4);
  }
  if (x.$ === "Lam" && all !== null && is_qnt(e, all.A)) {
    oos("a Quant parameter bound inside a match");
  }
  if (x.$ !== "Lam" && x.$ !== "Mat" && x.$ !== "Efq") {
    if (all !== null) {
      return tree(e, s, eta(t, all), fs4);
    }
    return top === undefined ? term(e, s, t, true) : oos("a match arm with no known type");
  }
  const fs22 = top === undefined ? fs4 : [...fs4.slice(0, -1), { ...top, n: top.n - 1 }];
  const wrap = (o2) => top === undefined ? o2 : { $: "Prj", h: o2 };
  const s1 = top === undefined ? { ...s, cols: s.cols.slice(1) } : s;
  if (x.$ === "Lam") {
    const l = s.D;
    let q2 = all === null ? 1 : quant(all.q);
    let s2 = scope_kq(scope_bind(s1, { $: "Var", l }, all?.A ?? null, true), l, q2);
    if (q2 > 0 && all !== null && no_ctr(e, all.A)) {
      s2 = { ...s2, empty: [...s2.empty, { $: "App", q: 1, f: { $: "Prj", h: { $: "Efq" } }, x: { $: "Var", l } }] };
    }
    const y = Var(x.k, s.d);
    const f = tree(e, s2, typed(x.f(y), all?.B(y)), fs22);
    if (q2 === 1 && uses(f, l) > 1) {
      if (all !== null && kind(e, s, all.A) === 1) {
        return tree(e, s, rebuild(e, s, x, all) ?? oos("a \u03BB that uses a variable twice, of a type whose fields are not Data (a ~ argument)"), fs4);
      }
      q2 = 2;
    }
    return wrap({ $: "Lam", q: q2, l, f });
  }
  const q = all === null ? 1 : quant(all.q);
  const mat = (cv2, dry) => {
    if (cv2.length === 0) {
      return wrap({ $: "Prj", h: swi(e, { ...s1, dry }, x, T, fs22, []) });
    }
    const l = s.D;
    const sw = swi(e, scope_kq(scope_hide({ ...s1, dry, again: true }), l, q), x, T, fs22, cv2);
    const app = cv2.reduce((f, y) => ({ $: "App", q: 1, f, x: { $: "Var", l: y } }), { $: "App", q, f: { $: "Prj", h: sw }, x: { $: "Var", l } });
    return wrap({ $: "Lam", q, l, f: app });
  };
  const o = mat([], s.dry || s.again);
  const data = (l) => s.c.some((b) => b?.o.$ === "Var" && b.o.l === l && b.T !== null && kind(e, s, b.T) === 2);
  const cv0 = s.kq.flatMap((k, l) => k === 1 && l < s.D && uses(o, l) > 1 && !data(l) ? [l] : []);
  const cv = [...new Set(cv0.flatMap((l) => s.tags.includes(l) ? [l, l + 1] : s.tags.includes(l - 1) ? [l - 1, l] : [l]))].sort((a, b) => a - b);
  if (s.dry) {
    return [...Array(s.D).keys()].filter((l) => uses(o, l) > 0).reduce((f, l) => ({ $: "App", q: 1, f, x: { $: "Var", l } }), { $: "Efq" });
  }
  if (cv.length === 0 && !s.again) {
    return o;
  }
  return mat(cv, false);
}
function swi(e, s, t, T, fs4, cv) {
  const [x, U] = open(t);
  const all = all_of(e, U ?? T);
  switch (x.$) {
    case "Efq": {
      if (all === null || no_ctr(e, all.A) || s.empty.length === 0) {
        return { $: "Efq" };
      }
      const q = quant(all.q);
      const f = convoy_bind(e, scope_hide(scope_hide(s)), cv, (s2) => s2.empty[0], fs4);
      return { $: "Lam", q, l: s.D, f: { $: "Lam", q, l: s.D + 1, f } };
    }
    case "Mat": {
      const ctr = e.book.ctrs[x.k];
      if (ctr === undefined) {
        oos("an unknown constructor " + name_key(x.k));
      }
      const [hT, mT] = goals(e, all, ctr);
      const h = tree(e, s, typed(x.h, hT), [...fs4, { n: ctr.n, cv }]);
      const dead = mT?.$ === "All" && no_ctr(e, mT.A) && x.m.$ !== "Mat";
      const m = swi(e, s, dead ? Efq() : x.m, mT, fs4, cv);
      return { $: "Mat", k: name_tt(x.k), h, m };
    }
    default: {
      if (all === null) {
        return oos("a default arm with no known type");
      }
      const q = quant(all.q);
      const [lt, la] = [s.D, s.D + 1];
      const s2 = scope_hide(scope_hide(s));
      const f = x.$ === "Lam" ? x : open(eta(t, all))[0];
      const pair = { $: "Tup", q: 1, a: { $: "Var", l: lt }, b: { $: "Var", l: la } };
      const s2e = no_ctr(e, all.A) ? { ...s2, empty: [
        ...s2.empty,
        { $: "App", q: 1, f: { $: "Efq" }, x: { $: "Var", l: lt } }
      ] } : s2;
      const s3 = scope_kq(scope_kq({ ...s2e, tags: [...s2e.tags, lt] }, lt, q), la, q);
      const y = Var(f.k, s.d);
      const body = convoy_bind(e, scope_bind(s3, pair, all.A, false), cv, typed(f.f(y), all.B(y)), fs4);
      const r2 = uses(body, lt) > 1 || uses(body, la) > 1 ? 2 : q;
      return { $: "Lam", q: r2, l: lt, f: { $: "Lam", q: r2, l: la, f: body } };
    }
  }
}
function goals(e, all, c) {
  const A = all === null ? null : term_wnf(e.book, all.A);
  if (all === null || A?.$ !== "ADT") {
    return [null, null];
  }
  const go = (U, xs) => {
    const F = term_wnf(e.book, U);
    return F.$ === "All" ? All(F.q, F.k, F.i, F.A, (x) => go(F.B(x), [...xs, x])) : all.B(Ctr(c.k, xs));
  };
  return [go(tele_fill(e.book, c.T, A.x, ctx_nil()), []), { ...all, A: { ...A, r: [...A.r, c.k] } }];
}
function typed(t, T) {
  return T == null || open(t)[1] !== null ? t : Ann(t, T);
}
function pick(e, t, v) {
  const w = term_wnf(e.book, v);
  const c = w.$ === "Lit" ? term_higher(lit_step(w)) : w;
  let [m] = open(t);
  while (m.$ === "Mat" && c.$ === "Ctr" && m.k !== c.k) {
    [m] = open(m.m);
  }
  if (c.$ !== "Ctr" || m.$ === "Efq") {
    return oos("a specialized argument that is not a constructor");
  }
  return m.$ === "Mat" ? [m.h, c.x] : [m, [c]];
}
function rebuild(e, s, x, all) {
  const F = term_wnf(e.book, all.A);
  if (F.$ !== "ADT") {
    return null;
  }
  const data = (U) => {
    const G = term_wnf(e.book, U);
    return G.$ !== "All" || kind(e, s, term_wnf(e.book, G.A)) === 2 && data(G.B(Var(G.k, -1)));
  };
  const arm = (k, U, xs) => {
    const G = term_wnf(e.book, U);
    return G.$ !== "All" ? x.f(Ann(Ctr(k, xs), F)) : Lam(G.k, 0, (v) => arm(k, G.B(v), [...xs, v]));
  };
  const cs = e.book.tlds[F.k].c.filter((c) => !F.r.includes(c.k)).map((c) => [c.k, tele_fill(e.book, c.T, F.x, ctx_nil())]);
  return cs.every(([, U]) => data(U)) ? Ann(cs.reduceRight((m, [k, U]) => Mat(k, arm(k, U, []), m), Efq()), all) : null;
}
function all_of(e, T) {
  const G = T === null ? null : term_wnf(e.book, T);
  return G?.$ === "All" ? G : null;
}
function eta(t, all) {
  return Ann(Lam(all.k, 0, (y) => Ann(App(t, y), all.B(y))), all);
}
function mentions(t, p) {
  if (typeof t !== "object" || t === null) {
    return false;
  }
  const o = t;
  if (o.$ === "Var" && p(o.i)) {
    return true;
  }
  return Object.entries(o).some(([k, v]) => k !== "s" && mentions(v, p));
}
function no_ctr(e, T) {
  const x = term_wnf(e.book, T);
  const tld = x.$ === "ADT" ? e.book.tlds[x.k] : undefined;
  return x.$ === "ADT" && tld?.$ === "ADT" && tld.c.every((c) => x.r.includes(c.k));
}
function kind(e, s, T) {
  const [x] = open(T);
  const [h, xs] = x.$ === "ADT" ? [x, x.x] : unapply(x);
  const [f] = open(h);
  const tld = f.$ === "ADT" || f.$ === "Ref" ? e.book.tlds[f.k] : undefined;
  if (tld === undefined) {
    return null;
  }
  try {
    const K = term_wnf(e.book, tele_fill(e.book, tld.T, xs, ctx_nil()));
    return K.$ === "Typ" ? Math.max(1, quant_eval(e, s, K.g)) : null;
  } catch {
    return null;
  }
}
function term(e, s0, t, live) {
  const [x, T] = open(t);
  const s = s0.sub && x.$ !== "Ctr" && x.$ !== "Lit" ? { ...s0, sub: false } : s0;
  switch (x.$) {
    case "Var": {
      const b = s.c[x.i];
      if (b === undefined) {
        oos("a free variable " + x.k);
      }
      return b.v !== undefined ? term(e, s0, typed(b.v, b.T), live) : b.o;
    }
    case "Ref":
    case "App": {
      return spine(e, s, t, live);
    }
    case "ADT": {
      const tld = e.book.tlds[x.k];
      if (tld?.$ !== "ADT") {
        oos("an unknown datatype " + name_key(x.k));
      }
      return args(e, s, x.k, tld.T, x.x, live);
    }
    case "Typ": {
      return { $: "Typ", q: Math.max(1, quant_eval(e, s, x.g)) };
    }
    case "All": {
      if (is_qnt(e, x.A)) {
        oos("a type over Quant");
      }
      const l = s.D;
      const A = term(e, s, x.A, false);
      const Bo = term(e, scope_bind(s, { $: "Var", l }, x.A, true), x.B(Var(x.k, s.d)), false);
      return { $: "All", q: quant(x.q), l, A, B: Bo };
    }
    case "Lam":
    case "Mat":
    case "Efq": {
      return tree(e, { ...s, cols: [] }, t, []);
    }
    case "Let": {
      return let_term(e, s, x, live);
    }
    case "Ctr": {
      return ctr_term(e, s, x, T, live);
    }
    case "Lit": {
      if (x.k === "Nat" && x.v > NAT_MAX) {
        const [q, r] = [Math.floor(x.v / NAT_MAX), x.v % NAT_MAX];
        const mul = App(App(Ref("Nat.mul"), Lit("Nat", q)), Lit("Nat", NAT_MAX));
        return term(e, s, App(App(Ref("Nat.add"), mul), Lit("Nat", r)), live);
      }
      return term(e, s, term_higher(lit_step(x)), live);
    }
    case "Eql": {
      return { $: "Eql", a: arg_term(e, s, x.a, x.T, false), b: arg_term(e, s, x.b, x.T, false), T: term(e, s, x.T, false) };
    }
    case "Rfl": {
      return { $: "Rfl" };
    }
    case "Rwt": {
      return rwt_term(e, s, x, live);
    }
    case "Qnt": {
      return { $: "Enu", ks: ["Q0", "Q1", "Q2"] };
    }
    case "Qua":
    case "Min": {
      return { $: "Lab", k: "Q" + String(quant_eval(e, s, x)) };
    }
    case "Hol": {
      return oos("a hole");
    }
    default: {
      return oos("a " + x.$ + " term");
    }
  }
}
function spine(e, s, t, live) {
  const [h, xs] = unapply(t);
  const [f, T] = open(h);
  if (f.$ !== "Ref") {
    const U = f.$ === "Var" ? s.c[f.i]?.T ?? null : T;
    const o = term(e, s, h, live);
    return args(e, s, inferable(o) ? o : { $: "Ann", x: o, T: term(e, s, U ?? oos("an application with no known head type"), false) }, U, xs, live);
  }
  const g = e.inst.get(f.k);
  const [k, ys] = g === undefined ? [f.k, xs] : [g[0], [...g[1], ...xs]];
  const tld = e.book.tlds[k] ?? oos("an unknown name " + name_key(k));
  if (tld.$ === "Def" && ys.length < tld.x) {
    oos("a template " + name_key(k) + " short of its ~ arguments");
  }
  return args(e, s, k, tld.T, ys, live);
}
function args(e, s, k, T, xs, live) {
  const sp = typeof k === "string" ? spec_of(e, k) : [];
  const ps = [];
  let U = T;
  xs.forEach((x, j) => {
    const F = U === null ? U : term_wnf(e.book, U);
    if (F?.$ !== "All") {
      return oos("an application past its head's known type");
    }
    if (typeof k !== "string" && is_qnt(e, F.A)) {
      oos("a Quant argument to a variable");
    }
    const v = sp[j] === true ? spec_val(e, s, x) : null;
    ps.push([quant(F.q), x, F.A, v]);
    U = F.B(v ?? x);
  });
  let n;
  try {
    const g = typeof k === "string" ? group_of(e, k) : null;
    if (g !== null) {
      return group_call(e, s, g, k, ps, U, live);
    }
    n = typeof k === "string" ? item_ref(e, k, ps.map((p) => p[3]), live) : null;
  } catch (x) {
    if (x instanceof Reroute) {
      return args(e, s, k, T, xs, live);
    }
    throw x;
  }
  const a = { ...s, sub: live && n === s.self };
  return ps.filter((p) => p[3] === null).reduce((f, [q, x, A]) => ({ $: "App", q, f, x: arg_term(e, a, x, A, live && q > 0) }), n === null ? k : { $: "Ref", k: n });
}
function group_of(e, k) {
  return e.groups.get(k) ?? null;
}
function regroup(e, key) {
  const ns = e.stack.slice(e.stack.indexOf(key)).map((x) => x.split(`
`)[0]);
  const gs = [...new Set(ns.filter((x) => x[0] === "\t").map((x) => group_of(e, x.slice(1))))];
  const ms = [...new Set(ns.flatMap((x) => x[0] === "\t" ? group_of(e, x.slice(1)).ms : [x]))];
  if (ms.length < 2 || gs.length === 1 && ms.length === gs[0].ms.length) {
    oos("a recursion through " + name_key(ms[0]) + " at other specialized arguments");
  }
  const at = (x) => e.book.order.lastIndexOf(x);
  const k = ms.reduce((a, b) => at(b) > at(a) ? b : a);
  const g = group_new(e, k, ms.filter((x) => x !== k).sort((a, b) => at(a) - at(b))) ?? oos("a mutual recursion through " + ms.map(name_key).join(", ") + " that no live parameter of " + name_key(k) + " leads");
  for (const x of g.ms) {
    e.groups.set(x, g);
  }
  e.grew ||= gs.length > 0;
  throw new Regroup(key);
}
function group_new(e, k, hs) {
  const lead = Math.min(...hs.map((h) => {
    const t = e.book.tlds[h].e;
    let n = 0;
    for (let x = t;x.$ === "Ann" || x.$ === "Lam"; x = x.$ === "Ann" ? x.x : x.f) {
      n += x.$ === "Lam" ? 1 : 0;
    }
    const cs = back(t, k);
    const at = (x, j2) => x?.$ === "Ann" ? at(x.x, j2) : x?.$ === "Var" && x.i === j2;
    let j = 0;
    while (j < n && cs.length > 0 && cs.every((xs) => at(xs[j], j))) {
      j++;
    }
    return j;
  }));
  const doms = tele_unbind(e.book, e.book.tlds[k].T).doms.slice(0, lead);
  if (hs.length === 0 || !doms.some(([q], j) => q.$ !== "None" && spec_of(e, k)[j] !== true)) {
    return null;
  }
  return { k, ms: [k, ...hs], qs: doms.map(([q]) => quant(q)) };
}
function back(t, k) {
  if (typeof t !== "object" || t === null) {
    return [];
  }
  let [f, xs] = [t, []];
  while (f.$ === "App" || f.$ === "Ann") {
    [f, xs] = f.$ === "App" ? [f.f, [f.x, ...xs]] : [f.x, xs];
  }
  return f.$ === "Ref" && f.k === k && xs.length > 0 ? [xs] : Object.entries(t).flatMap(([j, v]) => j === "s" ? [] : back(v, k));
}
function trail(e) {
  return [e.out.length, e.names.size, e.seen.size, e.todo.length, e.taken.size, e.fail.size];
}
function undo(e, m) {
  e.out.length = m[0];
  e.todo.length = m[3];
  for (const [x, n] of [[e.names, m[1]], [e.seen, m[2]], [e.taken, m[4]], [e.fail, m[5]]]) {
    [...x.keys()].slice(n).forEach((k) => x.delete(k));
  }
}
function group_call(e, s, g, m, ps, R, live) {
  const n = g.qs.length;
  if (ps.length < e.book.tlds[m].n || ps.slice(n).some((p) => p[3] !== null)) {
    oos("a partial or specialized call to " + m + ", mutually recursive");
  }
  const k = item_ref(e, "\t" + g.k, ps.slice(0, n).map((p) => p[3]), live);
  const a = { ...s, sub: live && k === s.self };
  const args2 = (xs, qs) => xs.flatMap(([q, x2, A, v], j) => v !== null ? [] : [[qs[j] ?? q, arg_term(e, a, x2, A, live && (qs[j] ?? q) > 0)]]);
  const sel = { $: "Tup", q: 1, a: { $: "Lab", k: name_tt(g.k) }, b: { $: "Lab", k: "()" } };
  const x = [
    ...args2(ps.slice(0, n), g.qs),
    [1, m === g.k ? sel : { $: "Tup", q: 1, a: { $: "Lab", k: name_tt(m) }, b: sel }],
    ...args2(ps.slice(n), [])
  ].reduce((f, [q, x2]) => ({ $: "App", q, f, x: x2 }), { $: "Ref", k });
  return { $: "Ann", x, T: term(e, s, R, false) };
}
function group_emit(e, g, cols, n) {
  const { s, ps: ls, xs: lead } = tele_open2(e, { ...scope_nil(), self: n }, e.book.tlds[g.k].T, cols, g.qs.length);
  const rest = (s1, m) => {
    const sp = spec_of(e, m);
    const r = tele_open2(e, s1, e.book.tlds[m].T, lead, sp.length);
    const qs = tele_unbind(e.book, e.book.tlds[m].T).doms.map(([q]) => quant(q));
    return { ...r, vs: r.xs.flatMap((x, j) => sp[j] ? [] : [[qs[j], term(e, r.s, x, false)]]), cs: r.xs.map((x, j) => sp[j] ? x : null) };
  };
  const efq = { $: "Efq" };
  const unit = (h) => ({ $: "Mat", k: "()", h, m: efq });
  const sel = (f) => ({ $: "Prj", h: g.ms.reduceRight((m, k, i) => ({
    $: "Mat",
    k: name_tt(k),
    m,
    h: i === 0 ? unit(f(k)) : { $: "Prj", h: { $: "Mat", k: name_tt(g.k), h: unit(f(k)), m: efq } }
  }), efq) });
  const l0 = s.D;
  const s0 = scope_kq(scope_hide(s), l0, 1);
  const mode = sel((m) => {
    const r = rest(s0, m);
    return alls(r.ps, term(e, r.s, r.T, false));
  });
  const Sel = { $: "Sig", q: 1, l: l0, A: { $: "Enu", ks: g.ms.map(name_tt) }, B: {
    $: "App",
    q: 1,
    x: { $: "Var", l: l0 },
    f: g.ms.reduceRight((m, k, i) => ({ $: "Mat", k: name_tt(k), m, h: i === 0 ? { $: "Enu", ks: ["()"] } : { $: "Sig", q: 1, l: l0 + 1, A: { $: "Enu", ks: [name_tt(g.k)] }, B: { $: "Enu", ks: ["()"] } } }), efq)
  } };
  const To = alls(ls, { $: "All", q: 1, l: l0, A: Sel, B: { $: "App", q: 1, f: mode, x: { $: "Var", l: l0 } } });
  const ks = ls.filter(([q]) => q === 1).map(([, l]) => l);
  const body = sel((m) => convoy_bind(e, s0, ks, (s2) => {
    const r = rest(s2, m);
    return lams(r.ps, arm(e, r.s, m, r.cs, r.vs));
  }, []));
  const v = ks.reduce((f, l) => ({ $: "App", q: 1, f, x: { $: "Var", l } }), { $: "App", q: 1, f: body, x: { $: "Var", l: l0 } });
  e.out.push([n, To, lams([...ls, [1, l0]], v), false]);
}
function arm(e, s, k, cols, vs) {
  const tld = e.book.tlds[k];
  const ps = new Map(tele_unbind(e.book, tld.T).doms.slice(0, tld.x).map(([, p], j2) => [k + "~" + p, cols[j2]]));
  const t0 = term_higher(tld.e);
  let t = tld.x === 0 ? t0 : subst(t0, 0, (o) => o.$ === "Ref" ? ps.get(o.k) ?? undefined : undefined);
  let si = { ...s, c: [], d: 0, cols: cols.slice(tld.x), sub: false };
  let j = 0;
  for (let [x, T] = open(t);x.$ === "Lam" && T !== null; [x, T] = open(t)) {
    const F = term_wnf(e.book, T);
    const v = si.cols[0] ?? null;
    if (F.$ !== "All" || v === null && j === vs.length) {
      break;
    }
    si = { ...si, cols: si.cols.slice(1) };
    si = v !== null ? scope_bind(si, { $: "Efq" }, F.A, false, v) : scope_bind(si, vs[j++][1], F.A, false);
    t = x.f(Var(x.k, si.d - 1));
  }
  return vs.slice(j).reduce((f, [q, x]) => ({ $: "App", q, f, x }), tree(e, si, t, []));
}
function arg_term(e, s, x, A, live) {
  const [y, T] = open(x);
  const tree2 = y.$ === "Lam" || y.$ === "Mat" || y.$ === "Efq";
  const all = all_of(e, A);
  if (!tree2 && all !== null && (!(live && s.sub) || T !== null && !qsig_eq(e, T, A, s.d))) {
    return term(e, s, eta(x, all), live);
  }
  return term(e, s, T === null && tree2 ? Ann(x, A) : x, live);
}
function qsig_eq(e, T, A, d) {
  const F = term_wnf(e.book, T);
  const G = term_wnf(e.book, A);
  if (F.$ === "Typ" && G.$ === "Typ") {
    const [a, b] = [term_wnf(e.book, F.g), term_wnf(e.book, G.g)];
    return a.$ !== "Qua" || b.$ !== "Qua" || Math.max(1, quant(a.q)) === Math.max(1, quant(b.q));
  }
  if (F.$ !== "All" || G.$ !== "All") {
    return F.$ !== "All" && G.$ !== "All";
  }
  const x = Var(G.k, d);
  return F.q.$ === G.q.$ && qsig_eq(e, F.B(x), G.B(x), d + 1);
}
function ctr_term(e, s, x, T, live) {
  const ctr = e.book.ctrs[x.k];
  if (ctr === undefined) {
    oos("an unknown constructor " + name_key(x.k));
  }
  const w = u32_from_term(x) ?? u32_from_term(x, "F32");
  if (!s.sub && w !== null) {
    return word_ref(e, x.k, w);
  }
  const fam = e.book.tlds[book_fam(e.book, x.k)];
  const G = T === null ? null : term_wnf(e.book, T);
  const ps = G?.$ === "ADT" ? G.x : Array.from({ length: fam.n }, () => Var("_", -1));
  let F = tele_fill(e.book, ctr.T, ps, ctx_nil());
  const fs4 = [];
  for (const a of x.x) {
    const A = term_wnf(e.book, F);
    if (A.$ !== "All") {
      oos("a constructor past its fields");
    }
    const q = quant(A.q);
    fs4.push([q, arg_term(e, s, a, A.A, live && q > 0)]);
    F = A.B(a);
  }
  const k = name_tt(x.k);
  const tail = fs4.reduceRight((b, [q, a]) => ({ $: "Tup", q, a, b }), { $: "Lab", k: "()" });
  return { $: "Tup", q: 1, a: { $: "Lab", k }, b: tail };
}
function word_ref(e, T, n) {
  const key = "\tword " + T + " " + String(n);
  let k = e.names.get(key);
  if (k === undefined) {
    k = fresh(e, T + ".lit" + String(n));
    e.names.set(key, k);
    const v = term(e, { ...scope_nil(), sub: true }, Ctr(T, [word_to_term(n)]), true);
    e.out.push([k, { $: "Ref", k: item_ref(e, T, [], false) }, v, false]);
  }
  return { $: "Ref", k };
}
function let_term(e, s, x, live, put = new Set) {
  let s2 = s;
  const ls = [];
  for (let j = 0;j < x.k.length; j++) {
    const q = quant(x.q[j]);
    const at = { ...s, D: s2.D, kq: s2.kq };
    const v = term(e, at, x.v[j], live && q > 0);
    const V = open(x.v[j])[1];
    if (v.$ === "Var" || put.has(j)) {
      s2 = scope_bind(s2, v, V, false);
    } else {
      const l = s2.D;
      const w = inferable(v) ? v : V === null ? oos("a let with no known type") : { $: "Ann", x: v, T: term(e, at, V, false) };
      ls.push([q, l, w, j]);
      s2 = scope_kq(scope_bind(s2, { $: "Var", l }, V, true), l, q);
    }
  }
  const xs = x.k.map((k, j) => Var(k, s.d + j));
  const f = term(e, s2, x.f(xs), live);
  const more = ls.filter(([, l, v]) => live && v.$ !== "App" && v.$ !== "Ref" && self_arg(f, s.self, l)).map(([, , , j]) => j);
  if (more.length > 0) {
    return let_term(e, s, x, live, new Set([...put, ...more]));
  }
  return ls.reduceRight((b, [q, l, v]) => ({ $: "Let", q: q === 1 && uses(b, l) > 1 ? 2 : q, l, v, f: b }), f);
}
function rwt_term(e, s, x, live) {
  const E0 = open(x.e)[1];
  const e0 = term(e, s, x.e, live);
  const ev = inferable(e0) || E0 === null ? e0 : { $: "Ann", x: e0, T: term(e, s, E0, false) };
  const [p] = open(x.p);
  if (p.$ !== "Lam") {
    oos("a rewrite motive that is not a \u03BB");
  }
  const l = s.D;
  const Q = E0 === null ? null : term_wnf(e.book, E0);
  const q = Q !== null && Q.$ === "Eql" ? Q : null;
  const s2 = scope_bind(s, { $: "Var", l }, q && q.T, true);
  const [p2] = open(p.f(Var(p.k, s.d)));
  if (p2.$ !== "Lam") {
    oos("a rewrite motive that is not a \u03BB over its evidence");
  }
  const s3 = scope_bind(s2, { $: "Var", l: l + 1 }, q && Eql(q.a, Var(p.k, s.d), q.T), true);
  const P = term(e, s3, p2.f(Var(p2.k, s2.d)), false);
  return { $: "Rwt", e: ev, l, P, f: term(e, s, x.f, live) };
}
function self_arg(o, k, l) {
  let h = o;
  let found = false;
  while (h.$ === "App") {
    found ||= h.x.$ === "Var" && h.x.l === l && h.q > 0;
    h = h.f;
  }
  return found && h.$ === "Ref" && h.k === k || Object.values(o).some((v) => is_o(v) && self_arg(v, k, l));
}
function o_refs(o, out = new Set) {
  if (o.$ === "Ref") {
    out.add(o.k);
  }
  for (const v of Object.values(o)) {
    if (is_o(v)) {
      o_refs(v, out);
    }
  }
  return out;
}
function is_o(v) {
  return typeof v === "object" && v !== null && "$" in v;
}
function alls(ps, b, $ = "All") {
  return ps.reduceRight((B, [q, l, A]) => ({ $, q, l, A, B }), b);
}
function lams(ps, b) {
  return ps.reduceRight((f, [q, l]) => ({ $: "Lam", q: q === 1 && uses(f, l) > 1 ? 2 : q, l, f }), b);
}
function inferable(o) {
  return o.$ === "App" ? inferable(o.f) : ["Var", "Ref", "Ann", "Typ", "All", "Enu", "Eql"].includes(o.$);
}
function uses(o, l) {
  switch (o.$) {
    case "Var":
      return o.l === l ? 1 : 0;
    case "Ann":
      return uses(o.x, l);
    case "Let":
      return (o.q > 0 ? uses(o.v, l) : 0) + uses(o.f, l);
    case "Lam":
      return uses(o.f, l);
    case "App":
      return uses(o.f, l) + (o.q > 0 ? uses(o.x, l) : 0);
    case "Tup":
      return (o.q > 0 ? uses(o.a, l) : 0) + uses(o.b, l);
    case "Prj":
      return uses(o.h, l);
    case "Mat":
      return uses(o.h, l) + uses(o.m, l);
    case "Rwt":
      return uses(o.e, l) + uses(o.f, l);
    default:
      return 0;
  }
}
function book_show(e) {
  let p = "x";
  while ([...e.taken].some((k) => new RegExp("^" + p + "[0-9]+$").test(k))) {
    p += "x";
  }
  return e.out.map(([k, T, v, m]) => (m ? "opaque " : "") + k + " : " + o_show(T, p) + ` =
  ` + o_show(v, p)).join(`

`) + `
`;
}
function mark(q) {
  return q === 0 ? "-" : q === 2 ? "+" : "";
}
function o_show(o, p) {
  const nm = (l) => p + String(l);
  switch (o.$) {
    case "Var":
      return nm(o.l);
    case "Ref":
      return o.k;
    case "Ann":
      return "{" + o_show(o.x, p) + " : " + o_show(o.T, p) + "}";
    case "Let":
      return "!" + mark(o.q) + nm(o.l) + " = " + o_show(o.v, p) + "; " + o_show(o.f, p);
    case "Typ":
      return "*" + String(o.q);
    case "All":
      return "\u2200" + mark(o.q) + nm(o.l) + " : " + o_show(o.A, p) + " -> " + o_show(o.B, p);
    case "Lam":
      return "\u03BB" + mark(o.q) + nm(o.l) + " => " + o_show(o.f, p);
    case "App": {
      const xs = [];
      let f = o;
      while (f.$ === "App") {
        xs.push(mark(f.q) + o_show(f.x, p));
        f = f.f;
      }
      return "(" + o_show(f, p) + " " + xs.reverse().join(" ") + ")";
    }
    case "Sig":
      return "\u03A3" + mark(o.q) + nm(o.l) + " : " + o_show(o.A, p) + " -> " + o_show(o.B, p);
    case "Tup":
      return "(" + mark(o.q) + o_show(o.a, p) + ", " + o_show(o.b, p) + ")";
    case "Prj":
      return "\u03BB{(,): " + o_show(o.h, p) + "}";
    case "Enu":
      return "<" + o.ks.join(", ") + ">";
    case "Lab":
      return o.k === "()" ? "()" : "." + o.k;
    case "Mat":
      return "\u03BB{" + o_show({ $: "Lab", k: o.k }, p) + ": " + o_show(o.h, p) + "; " + o_show(o.m, p) + "}";
    case "Efq":
      return "\u03BB{}";
    case "Eql":
      return "{" + o_show(o.a, p) + " == " + o_show(o.b, p) + " : " + o_show(o.T, p) + "}";
    case "Rfl":
      return "{==}";
    case "Rwt":
      return "%" + o_show(o.e, p) + " : " + nm(o.l) + ", " + nm(o.l + 1) + " => " + o_show(o.P, p) + "; " + o_show(o.f, p);
  }
}
function kernel_bin() {
  const env = process.env.BENDTT;
  if (env !== undefined && env !== "") {
    return env;
  }
  const src = path2.join(BEND_DIR, "bendtt.lean");
  const text = fs3.readFileSync(src, "utf8");
  const hash = crypto2.createHash("sha256").update(text).digest("hex").slice(0, 16);
  const dir = path2.join(os2.homedir(), ".bend", "bendtt", hash);
  const bin = path2.join(dir, "bendtt");
  if (fs3.existsSync(bin)) {
    return bin;
  }
  const home = path2.join(os2.homedir(), ".elan", "toolchains", "leanprover--lean4---v4.34.0", "bin");
  const tool = (t) => fs3.existsSync(path2.join(home, t)) ? path2.join(home, t) : t;
  fs3.mkdirSync(dir, { recursive: true });
  fs3.copyFileSync(src, path2.join(dir, "bendtt.lean"));
  const run = (bin2, args2) => {
    const [got, text2] = run_read(bin2, args2, { cwd: dir });
    if (got.status !== 0) {
      throw new Error("the kernel did not build (" + bin2 + ": " + (got.error?.message ?? text2.slice(0, 300)) + "); --verdict needs Lean v4.34.0 (elan toolchain leanprover/lean4:v4.34.0), or $BENDTT set to a built kernel");
    }
  };
  run(tool("lean"), ["-c", "bendtt.c", "bendtt.lean"]);
  run(tool("leanc"), ["-O3", "-DNDEBUG", "bendtt.c", "-o", "bendtt"]);
  return bin;
}
function run_read(bin, args2, opts = {}) {
  const dir = fs3.mkdtempSync(path2.join(os2.tmpdir(), "bend-run-"));
  const log = path2.join(dir, "out");
  const fd = fs3.openSync(log, "w");
  try {
    const got = child.spawnSync(bin, args2, { ...opts, stdio: ["ignore", fd, fd] });
    return [got, fs3.readFileSync(log, "utf8")];
  } finally {
    fs3.closeSync(fd);
    fs3.rmSync(dir, { recursive: true, force: true });
  }
}
function kernel_check(text) {
  const env = { ...process.env, LEAN_STACK_SIZE_KB: "4194304" };
  const dir = fs3.mkdtempSync(path2.join(os2.tmpdir(), "bendtt-"));
  const inp = path2.join(dir, "in.bendtt");
  fs3.writeFileSync(inp, text, { flag: "wx" });
  const [got, out] = run_read(kernel_bin(), [inp], { env });
  fs3.rmSync(dir, { recursive: true });
  return got.status === 0 && out.trim() === "ALL PROOFS CHECK";
}
function safe_emit(book, out) {
  const got = safe_book(book);
  fs3.writeFileSync(out, got.text);
  return got.oos.map(([k, why]) => "- " + name_key(k) + ": " + why + `
`);
}
function safe_check(book) {
  const got = safe_book(book);
  return got.oos.length === 0 && kernel_check(got.text);
}

// ../bend2-core/.claude/worktrees/rel-2035/bend2/main.ts
var VERSION = "2.0.35";
var USAGE = [
  ["bend <file.bend> [args]", "check the file, then run main with args"],
  ["bend <file.bend> -o <out>", "build a binary, or C, JS, .mjs or BendTT by extension"],
  ["bend <file.bend> --check-only", "check the file and its imports; run nothing"],
  ["bend <file.bend> --verdict", "check it, then recheck it with the proven kernel"],
  ["bend <file.bend> --publish [<name>@<version>]", "publish the file and its imports; a name needs login"],
  ["bend link <name>@<version> 0x<hash>", "name a package already on the hub"],
  ["bend login", "log in to Bender for --publish <name>@\u2026"],
  ["bend <page.html> -o <dir>", "bundle a page that imports .bend files"],
  ["bend base [--types|<name>]", "print Base, its types, or a name and subnames"],
  ["bend update", "install the latest bend (curl | sh, shown first)"],
  ["bend version", "print the version"],
  ["bend guide", "print the Bend guide"]
];
var USE_W = Math.max(...USAGE.map(([use]) => use.length));
var HELP = `Bend ${VERSION}: check, run, build and publish Bend programs.

usage:
${USAGE.map(([use, say]) => `  ${use.padEnd(USE_W)}  ${say}`).join(`
`)}

Read the guide (\`bend guide\`) before writing Bend code.
`;
var BASE = BASE_BEND;
var GUIDE = path3.join(BEND_DIR, "..", "guide");
var ORIGIN = process.env.BEND_ORIGIN ?? "https://bend-lang.com";
var BENDER = path3.join(os3.homedir(), ".bend", "bender.json");
var CHECK = path3.join(os3.homedir(), ".bend", "check.json");
var DAY = 86400000;
var PASS = "ALL PROOFS CHECK";
var FAIL = "SOME PROOFS FAIL";
var HINT = "Use --verdict for mathematical validity.";
var MISMATCH = "Sorry - this is a mismatch between the TypeScript implementation," + " and the formalized BendTT kernel. Your proofs may or may not be correct, and" + " we cannot validate them yet. This will be addressed in a future update." + " Meanwhile, feel free to open an issue to report this bug.";
var TERMS = "https://bend-lang.com/bender/terms#s18";
var SPDX_RE = /^\s*SPDX-License-Identifier:\s*([A-Za-z0-9.+\-() ]{1,80}?)\s*$/;
var POW_JS = `
const crypto = require("node:crypto");
const { parentPort, workerData: { pre, lim, from, step } }
  = require("node:worker_threads");
for (let n = from;; n += step) {
  const h = crypto.hash("sha256", pre + n, "buffer");
  if ((h[0] * 16777216 + (h[1] << 16) + (h[2] << 8) + h[3]) * 2097152
    + ((h[4] * 16777216 + (h[5] << 16) + (h[6] << 8) + h[7]) >>> 11) < lim) {
    parentPort.postMessage(n);
    break;
  }
}`;
var PLUGIN = {
  name: "bend",
  setup(build) {
    build.onLoad({ filter: /\.bend$/ }, async (args2) => ({ contents: await load_js(args2.path), loader: "js" }));
  }
};
async function cli() {
  const args2 = process.argv.slice(2);
  if (args2[0] === "version" && args2.length === 1) {
    return cli_say(1, "bend " + VERSION + `
`);
  }
  if (args2[0] === "update" && args2.length === 1) {
    return cli_update();
  }
  if (args2[0] === "login" || args2[0] === "link") {
    if (args2.length !== (args2[0] === "link" ? 3 : 1)) {
      cli_fail(args2[0] === "link" ? "link takes <name>@<version> and 0x<hash>" : args2[0] + " takes no argument");
    }
    try {
      await (args2[0] === "login" ? cli_login() : cli_link(args2[1], args2[2]));
    } catch (e) {
      cli_say(2, book_err(e) + `
`);
      process.exitCode = 1;
    }
    return;
  }
  if (args2[0] === "guide" && args2.length <= 2) {
    cli_guide(args2[1] ?? "guide");
  } else if (args2[0] === "base" && args2.length <= 2) {
    cli_base(args2[1]);
  } else {
    await cli_file(args2);
  }
  await check();
}
function cli_guide(name) {
  const file = path3.join(GUIDE, name.toUpperCase() + ".md");
  if (!fs4.existsSync(file)) {
    cli_fail("no guide named " + name);
  }
  cli_say(1, fs4.readFileSync(file, "utf8"));
}
function cli_update() {
  const cmd = "curl -fsSL " + ORIGIN + "/install.sh | sh";
  cli_say(2, cmd + `
`);
  process.exitCode = child2.spawnSync("sh", ["-c", cmd], { stdio: "inherit" }).status ?? 1;
}
async function check() {
  if (process.env.BEND_NO_TELEMETRY) {
    return;
  }
  let last = { t: 0, ver: VERSION, notice: "" };
  try {
    last = { ...last, ...JSON.parse(fs4.readFileSync(CHECK, "utf8")) };
  } catch {}
  try {
    if (Date.now() - last.t > DAY) {
      last.t = Date.now();
      fs4.mkdirSync(path3.dirname(CHECK), { recursive: true });
      fs4.writeFileSync(CHECK, JSON.stringify(last) + `
`);
      const res = await fetch(ORIGIN + "/check?v=" + VERSION + "&os=" + "linux" + "&arch=" + "arm64", { signal: AbortSignal.timeout(3000) });
      const got = await res.json();
      last.ver = typeof got.ver === "string" ? got.ver : VERSION;
      last.notice = typeof got.notice === "string" ? got.notice : "";
      fs4.writeFileSync(CHECK, JSON.stringify(last) + `
`);
    }
  } catch {}
  if (ver_newer(last.ver)) {
    cli_say(2, "bend " + last.ver + ` is available: run bend update
` + (last.notice === "" ? "" : last.notice.replace(/[\x00-\x1f\x7f]/g, "").slice(0, 200) + `
`));
  }
}
function ua_fetch() {
  const raw = globalThis.fetch;
  globalThis.fetch = Object.assign((u, o = {}) => {
    const to = u instanceof Request ? u.url : String(u);
    return !to.startsWith(BEND_HUB) && !to.startsWith(ORIGIN) ? raw(u, o) : raw(u, { ...o, headers: {
      ...Object.fromEntries(new Headers(o.headers ?? (u instanceof Request ? u.headers : undefined))),
      "user-agent": "bend/" + VERSION
    } });
  }, raw);
}
function ver_newer(ver) {
  const a = ver.split(".").map(Number);
  const b = VERSION.split(".").map(Number);
  return a.length === 3 && a.every(Number.isInteger) && (a[0] - b[0] || a[1] - b[1] || a[2] - b[2]) > 0;
}
async function cli_file(args2) {
  const outs = [];
  const argv = [];
  let file;
  let only = false;
  let verdict = false;
  let checkup = false;
  let publish = false;
  let named;
  for (let i = 0;i < args2.length; i += 1) {
    const a = args2[i];
    if (a === "--help" || a === "-h") {
      return cli_say(1, HELP);
    } else if (a === "--check-only") {
      only = true;
    } else if (a === "--verdict") {
      verdict = true;
    } else if (a === "--checkup") {
      checkup = true;
    } else if (a === "--publish") {
      publish = true;
      if (args2[i + 1]?.includes("@")) {
        i += 1;
        named = args2[i];
        named_parts(named);
      }
    } else if (a === "-o") {
      i += 1;
      outs.push(args2[i] ?? cli_fail("-o needs an output file"));
    } else if (a === "--") {
      argv.push(...args2.splice(i + 1));
    } else if (a.startsWith("-")) {
      cli_fail("unknown option " + a);
    } else if (file !== undefined) {
      argv.push(a);
    } else {
      file = a;
    }
  }
  if (file === undefined) {
    cli_say(1, HELP);
    process.exit(1);
  }
  if (file.endsWith(".html")) {
    if (outs.length !== 1 || only || checkup || publish) {
      cli_fail("a page bundles with -o <dir>");
    }
    return cli_bundle(file, outs[0]);
  }
  if (publish && (outs.length !== 0 || only || verdict || checkup)) {
    cli_fail("--publish takes no other option");
  }
  if ((only || verdict) && (outs.length !== 0 || checkup || only && verdict)) {
    cli_fail((verdict ? "--verdict" : "--check-only") + " takes no other option");
  }
  if (argv.length !== 0 && (outs.length !== 0 || only || checkup || publish)) {
    cli_fail("arguments go to a run: bend <file.bend> [args]");
  }
  if (checkup && outs.length !== 0) {
    cli_fail("--checkup takes no -o: a binary holds one main, so build each" + " import alone");
  }
  try {
    if (publish) {
      return await cli_publish(file, named);
    }
    if (checkup) {
      return await cli_checkup(file);
    }
    const seen = new Map;
    const book = await book_read(file, undefined, seen);
    if (only || verdict) {
      process.exitCode = cli_verdict(book, verdict);
      return;
    }
    if (outs.length === 0) {
      process.exitCode = book_run(book, [file, ...argv]);
      return;
    }
    const ins = new Set([...seen.keys(), ...Object.values(book.tlds).flatMap((t) => t.$ === "Def" && t.i !== undefined ? t.i.map(path_real) : [])]);
    for (const out of outs) {
      const at = path_real(out);
      if (ins.has(at) || fs4.existsSync(at) && fs4.statSync(at).isDirectory()) {
        cli_fail("-o " + out + " is a file the program reads, or a directory");
      }
      cli_emit(book, out);
    }
  } catch (e) {
    cli_say(2, book_err(e) + `
`);
    process.exitCode = 1;
  }
}
async function cli_checkup(file) {
  const base = await book_read(BASE);
  let bad = false;
  for (const raw of fs4.readFileSync(file, "utf8").split(`
`)) {
    const m = /^import\s+(\S+)\s+as\s+[A-Za-z_][A-Za-z0-9_]*\s*$/.exec(raw.trim());
    if (m === null) {
      continue;
    }
    const at = m[1].startsWith("/") ? m[1] : path3.join(path3.dirname(file), m[1]);
    cli_say(1, "--- " + m[1] + ` ---
`);
    let code = 1;
    try {
      const own = /^import Base$/m.test(fs4.readFileSync(at, "utf8"));
      code = book_run(await book_read(at, own ? base : undefined), [at]);
    } catch (e) {
      cli_say(2, book_err(e) + `
`);
    }
    if (code !== 0) {
      cli_say(1, "exit " + String(code) + `
`);
      bad = true;
    }
  }
  if (bad) {
    process.exit(1);
  }
}
function path_real(p) {
  return fs4.existsSync(p) ? fs4.realpathSync(p) : path3.resolve(p);
}
function cli_emit(book, out) {
  if (out.endsWith(".mjs")) {
    fs4.writeFileSync(out, js_lib(book, true));
  } else if (/\.c?js$/.test(out)) {
    fs4.writeFileSync(out, js_book(book));
  } else if (out.endsWith(".c")) {
    fs4.writeFileSync(out, compile_book(book));
  } else if (out.endsWith(".bendtt")) {
    const oos2 = safe_emit(book, out);
    if (oos2.length !== 0) {
      cli_say(2, "BendTT: out of scope, so not in " + out + `:
` + oos2.join(""));
    }
  } else {
    const dir = fs4.mkdtempSync(path3.join(os3.tmpdir(), "bend-"));
    const c = path3.join(dir, path3.basename(out) + ".c");
    fs4.writeFileSync(c, compile_book(book));
    try {
      cli_build(out, c);
    } finally {
      fs4.rmSync(dir, { recursive: true, force: true });
    }
  }
}
function cc_find(gpu) {
  function dir_list(dir) {
    try {
      return fs4.readdirSync(dir);
    } catch {
      return [];
    }
  }
  const dirs = (process.env.PATH ?? "").split(path3.delimiter);
  const nums = [...new Set(dirs.flatMap(dir_list).filter((f) => /^clang-\d+$/.test(f)))].sort((a, b) => Number(b.slice(6)) - Number(a.slice(6)));
  const olds = [];
  const ccs = [...process.env.CC ? [process.env.CC] : [], "clang", ...nums];
  for (const cc of ccs) {
    const [got, out] = run_read(cc, ["--version"]);
    const m = /^(Apple )?(?:\w+ )?clang version (\d+)/m.exec(out);
    const need = gpu ? m?.[1] === undefined ? 19 : 17 : 14;
    if (m !== null && Number(m[2]) >= need) {
      return cc;
    }
    olds.push(m !== null ? "clang " + m[2] + " as " + cc : got.status === 0 && out ? cc + ", which is not clang" : "no " + cc);
  }
  throw "Error: bend needs clang " + (gpu ? "19 (Apple clang 17)" : "14") + " or newer to build " + (gpu ? "a GPU program" : "binaries") + " (found " + olds.join(", ") + "); on Debian/Ubuntu: curl -fsSL" + " https://apt.llvm.org/llvm.sh | sudo bash -s 19; on macOS: xcode-select" + " --install";
}
function cli_build(bin, file) {
  const c = fs4.readFileSync(file, "utf8");
  const mac = false;
  const cuda = process.env.CUDA_HOME || "/usr/local/cuda";
  const bangs = !/^#define BANGS\s+0$/m.test(c) && (mac || fs4.existsSync(cuda + "/include/nvrtc.h"));
  const cc = cc_find(bangs);
  const objc = mac && (bangs || /^#import /m.test(c)) ? ["-x", "objective-c", "-fobjc-arc", "-fmodules"] : [];
  const libs = [["X11", "X11"], ["alsa", "asound"]].flatMap(([h, l]) => !mac && c.includes("#include <" + h + "/") ? ["-l" + l] : []);
  const cpu = [
    ...objc,
    "-std=c11",
    "-O3",
    file,
    "-lpthread",
    "-lm",
    ...libs,
    "-o",
    path3.resolve(bin)
  ];
  const gpu = mac ? ["-DBEND_METAL=1", ...cpu] : [
    "-DBEND_CUDA=1",
    "-I" + cuda + "/include",
    "-L" + cuda + "/lib64",
    "-L" + cuda + "/lib",
    ...cpu,
    "-lcuda",
    "-lnvrtc"
  ];
  const steps = bangs ? [[cc, gpu], [path3.resolve(bin), ["--gpu-build"]]] : [[cc, cpu]];
  for (const [cmd, args2] of steps) {
    if (child2.spawnSync(cmd, args2, { stdio: "inherit" }).status !== 0) {
      throw "Error: " + path3.basename(cmd) + " failed to build " + bin;
    }
  }
}
function cli_base(what) {
  const src = fs4.readFileSync(BASE, "utf8");
  if (what === undefined) {
    return cli_say(1, src);
  }
  const want = [];
  for (const text of src.split(/\n(?=type |law |def |@)/)) {
    const m = /^(type|law|def) ([^\s(<:?]+)/m.exec(text);
    if (m === null) {
      continue;
    }
    const s = text.replace(/(\n(#[^\n]*)?)+$/, "");
    const last = s.slice(s.lastIndexOf(`
`) + 1);
    const ok = what === "--types" ? m[1] === "type" || m[1] === "law" && /^ *(Type|Data|Kind\(.*\))$/.test(last) : m[2] === what || m[2].startsWith(what + ".");
    if (ok) {
      want.push(s);
    }
  }
  if (want.length === 0) {
    cli_fail("Base has no " + what);
  }
  cli_say(1, want.join(`

`) + `
`);
}
async function cli_bundle(page, dir) {
  const out = await Bun.build({
    entrypoints: [page],
    outdir: dir,
    target: "browser",
    minify: true,
    plugins: [PLUGIN]
  });
  for (const a of out.outputs) {
    cli_say(1, a.path + " (" + (a.size / 1024).toFixed(1) + `kb)
`);
  }
}
async function cli_publish(file, named) {
  const seen = new Map;
  const book = await book_read(file, undefined, seen);
  const files = pkg_files(file, book, seen);
  const entry = Object.keys(files)[0];
  const name = path3.basename(entry, ".bend");
  if (name === "") {
    cli_fail("a published file needs a name before .bend");
  }
  const paths = Object.keys(files).sort();
  const bytes = paths.reduce((n, p) => n + Buffer.byteLength(files[p]), 0);
  const hash = "0x" + sha256(paths.map((p) => sha256(files[p]) + " " + p + `
`).join("")).slice(0, 32);
  const lic = paths.filter((p) => path3.posix.basename(p) === "LICENSE").sort((a, b) => a.split("/").length - b.split("/").length)[0];
  const spdx = lic === undefined ? undefined : files[lic].split(`
`).slice(0, 5).map((l) => SPDX_RE.exec(l)?.[1]).find((id) => /[A-Za-z]/.test(id ?? ""))?.replace(/\s+/g, " ");
  cli_say(2, "Publishing to BendHub: public and permanent, under " + TERMS + `
License: ` + (lic === undefined ? "MIT-0, the default (no LICENSE file): " + TERMS + `.4
warning: no file is named exactly LICENSE, so the package is` + " MIT-0; to license it otherwise, put the license in a file named LICENSE" + " beside " + entry : spdx === undefined ? "see " + lic : spdx + " (" + lic + ")") + `
`);
  const auth = named === undefined ? null : await hub_check(named);
  cli_say(2, "publishing " + String(paths.length) + " files, " + String(bytes) + " bytes, as " + hash + ` (mining its proof of work)
`);
  const nonce = await pow_mine(hash, bytes);
  const res = await fetch(BEND_HUB, {
    method: "POST",
    headers: auth === null ? {} : { authorization: "Bearer " + auth.key },
    body: JSON.stringify({ files, nonce })
  });
  if (res.status === 401) {
    key_dead();
  }
  const got = (await res.text()).trim();
  if (!res.ok || got !== hash) {
    throw "Error: " + BEND_HUB + " answered: " + got;
  }
  cli_say(1, hash + `
`);
  if (auth !== null) {
    await hub_name(auth, hash).catch((e) => {
      throw String(e) + `
` + hash + " is published but not named: bend link " + auth.named + " " + hash;
    });
    cli_say(1, "published " + auth.named + `
`);
  }
  cli_say(1, "import " + (auth === null ? hash : auth.named) + "/" + entry + " as " + name[0].toUpperCase() + name.slice(1) + `
`);
}
async function cli_link(named, hash) {
  if (!/^0x[0-9a-f]{32}$/.test(hash)) {
    cli_fail("link takes the package's hash: 0x and 32 hex digits");
  }
  await hub_name(await hub_check(named), hash);
  cli_say(1, "linked " + named + " to " + hash + `
`);
}
function named_parts(named) {
  const m = NAMED.exec(named);
  return m === null ? cli_fail("a package is named <name>@<version>: a-z, 0-9 and -," + " 1 to 64 characters, at four numbers like 1.0.0.0") : [m[1], m[2]];
}
async function hub_check(named) {
  const [name, version] = named_parts(named);
  let key = "";
  try {
    key = String(JSON.parse(fs4.readFileSync(BENDER, "utf8")).key ?? "");
  } catch {}
  if (key === "") {
    key = await cli_login();
  }
  const got = await hub_ask("/publish-check?name=" + name + "&version=" + version, key);
  if (got.name !== "yours" && got.name !== "free" || got.version_ok !== true) {
    throw "Error: " + String(got.reason);
  }
  return { named, key, free: got.name === "free" };
}
async function hub_name(auth, hash) {
  const [name, version] = named_parts(auth.named);
  if (auth.free) {
    await hub_ask("/register", auth.key, { name });
    cli_say(2, "registered " + name + `
`);
  }
  await hub_ask("/link", auth.key, { name, version, hash });
}
async function hub_ask(route, key, body) {
  const res = await fetch(BEND_HUB + route, {
    method: body === undefined ? "GET" : "POST",
    headers: { authorization: "Bearer " + key, "content-type": "application/json" },
    body: JSON.stringify(body)
  }).catch(() => null);
  if (res === null) {
    throw "Error: " + BEND_HUB + " could not be reached";
  }
  if (res.status === 401) {
    key_dead();
  }
  const got = await res.json().catch(() => null);
  if (!res.ok || got === null) {
    throw "Error: " + BEND_HUB + route + " answered: " + (typeof got?.reason === "string" ? got.reason : String(res.status));
  }
  return got;
}
function key_dead() {
  fs4.rmSync(BENDER, { force: true });
  throw "Error: " + BEND_HUB + " does not know this login: run bend login";
}
async function cli_login() {
  const st = await fetch(ORIGIN + "/bender/cli/start", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ machine: os3.hostname() })
  }).then((r) => r.json()).catch(() => null);
  if (st === null || typeof st.poll_secret !== "string" || typeof st.verify_url !== "string") {
    throw "Error: " + ORIGIN + " did not start a login";
  }
  cli_say(2, "log in at " + st.verify_url + `
`);
  try {
    Bun.spawn(["xdg-open", st.verify_url], { stdout: "ignore", stderr: "ignore" });
  } catch {}
  const until = Date.parse(st.expires_at ?? "") || Date.now() + 600000;
  while (Date.now() < until) {
    await new Promise((r) => setTimeout(r, Math.max(1000, st.interval_ms ?? 2000)));
    const got = await fetch(ORIGIN + "/bender/cli/poll", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ poll_secret: st.poll_secret })
    }).then((r) => r.json()).catch(() => null);
    if (got?.status === "authorized" && typeof got.key === "string") {
      fs4.mkdirSync(path3.dirname(BENDER), { recursive: true });
      fs4.writeFileSync(BENDER, JSON.stringify({ key: got.key, login: got.login ?? "" }) + `
`, { mode: 384 });
      cli_say(2, "logged in as " + String(got.login ?? "") + `
`);
      return got.key;
    }
    if (got?.status === "expired") {
      break;
    }
  }
  throw "Error: the login was not authorized in time: run bend login again";
}
function pkg_files(file, book, seen) {
  const dir = fs4.realpathSync(path3.dirname(file)) + "/";
  const raws = [
    ...[...seen].flatMap(([real, ns]) => real === BASE || ns === null || ns.startsWith("0x") ? [] : [[ns === "" ? path3.basename(file) : ns + ".bend", real]]),
    ...Object.entries(book.tlds).flatMap(([k, tld]) => tld.$ !== "Def" || tld.i === undefined || tld.b === true || k.startsWith("0x") ? [] : tld.i.map((f) => [f.startsWith(dir) ? f.slice(dir.length) : f, f]))
  ];
  const ups = raws.map(([p]) => path3.posix.normalize(p).split("/").filter((s) => s === "..").length);
  const anc = fs4.realpathSync(path3.dirname(file)).split("/").slice(-Math.max(0, ...ups) || Infinity);
  const files = {};
  for (const [raw, real] of raws) {
    const p = path3.posix.join(...anc, raw);
    if (p.startsWith("/") || p.startsWith("..")) {
      throw "Error: " + real + " cannot be published (an absolute import," + " or a climb above the file system)";
    }
    if (p.split("/").slice(0, -1).some((s) => s.toLowerCase() === "license")) {
      throw "Error: " + real + " cannot be published: it is in a directory" + " named license, which clashes with a LICENSE file; rename it";
    }
    files[p] = fs4.readFileSync(real, "utf8").replace(/^\uFEFF/, "");
    if (fs4.readdirSync(path3.dirname(real)).includes("LICENSE")) {
      files[path3.posix.join(path3.posix.dirname(p), "LICENSE")] = fs4.readFileSync(path3.join(path3.dirname(real), "LICENSE"), "utf8").replace(/^\uFEFF/, "");
    }
  }
  return files;
}
function sha256(text) {
  return crypto3.createHash("sha256").update(text).digest("hex");
}
async function pow_mine(hash, bytes) {
  const pow = Number((await hub_ask("/pow.json", "")).pow);
  const step = os3.availableParallelism();
  const lim = 2 ** 53 / (pow * Math.max(1, bytes / 262144));
  const ws = Array.from({ length: step }, (_, k) => new thr.Worker(POW_JS, { eval: true, workerData: { pre: hash + " ", lim, from: k, step } }));
  const n = await new Promise((res) => ws.forEach((w) => w.on("message", res)));
  ws.forEach((w) => w.terminate());
  return n;
}
function cli_verdict(book, kernel) {
  const bad = book_promises(book);
  if (bad.length !== 0) {
    cli_say(2, FAIL + `
Error: ` + String(bad.length) + " def" + (bad.length === 1 ? " relies" : "s rely") + ` on unsafe or foreign code:
` + bad.map((k) => "- " + name_key(k) + `
`).join(""));
    return 1;
  }
  if (kernel && !safe_check(book)) {
    cli_say(2, FAIL + `
` + MISMATCH + `
`);
    return 1;
  }
  cli_say(1, PASS + `
` + (kernel ? "" : HINT + `
`));
  return 0;
}
function book_promises(book) {
  const own = [...new Set(book.order)].filter((k) => book.tlds[k].b !== true);
  const bad = new Set(Object.keys(book.tlds).filter((k) => {
    const t = book.tlds[k];
    return t.u === true || t.i !== undefined && t.b !== true;
  }));
  const uses2 = Object.create(null);
  const seen = new Set;
  for (const q = bad.size === 0 ? [] : own.slice();q.length > 0; ) {
    const k = q.pop();
    const t = book.tlds[k];
    if (t !== undefined && !seen.has(k)) {
      seen.add(k);
      const rs = new Set;
      for (const c of t.$ === "ADT" ? t.c : [t]) {
        term_refs(term_lower(c.T), rs);
      }
      term_refs(t.$ === "Def" ? t.e : undefined, rs);
      for (const r of rs) {
        (uses2[r] ??= []).push(k);
        q.push(r);
      }
    }
  }
  for (const k of bad) {
    uses2[k]?.forEach((j) => bad.add(j));
  }
  return own.filter((k) => bad.has(k));
}
function term_refs(tm, out) {
  if (typeof tm === "object" && tm !== null) {
    const { $, k } = tm;
    if (($ === "Ref" || $ === "ADT") && k !== undefined) {
      out.add(k);
    }
    for (const [f, v] of Object.entries(tm)) {
      if (f !== "s") {
        term_refs(v, out);
      }
    }
  }
}
function cli_say(fd, text) {
  try {
    fs4.writeSync(fd, text);
  } catch (e) {
    if (e.code !== "EPIPE") {
      throw e;
    }
  }
}
function cli_fail(msg) {
  cli_say(2, "bend: " + msg + ` (see bend --help)
`);
  process.exit(1);
}
async function book_read(file, base, seen = new Map) {
  const book = base === undefined ? book_nil() : book_seed(base);
  if (base !== undefined) {
    seen.set(BASE, "");
  }
  try {
    BVY_PD_PHASE("book_load", "enter");
    await book_load(book, file, "", seen);
    BVY_PD_PHASE("book_load", "exit");
    const laws = path3.join(path3.dirname(file), "LAWS.bend");
    if (path3.basename(file) === "PROOF.bend" && fs4.existsSync(laws) && !seen.has(fs4.realpathSync(laws))) {
      throw "Error: PROOF.bend must import ./LAWS.bend";
    }
    BVY_PD_PHASE("book_valid", "enter");
    book_valid(book, base?.order.length ?? 0);
    BVY_PD_PHASE("book_valid", "exit");
    if (book.hols > 0) {
      throw "Error: " + String(book.hols) + " TODO" + (book.hols === 1 ? "" : "s") + ` found.
The code is incomplete, and not a valid proof yet.`;
    }
  } catch (e) {
    throw new Check_Fail(e);
  }
  return book;
}

class Check_Fail {
  why;
  constructor(why) {
    this.why = why;
  }
}
function book_seed(base) {
  const book = book_nil();
  for (const k of Object.keys(base.tlds)) {
    book.tlds[k] = { ...base.tlds[k] };
  }
  Object.assign(book.ctrs, base.ctrs);
  for (const k of Object.keys(base.tmps)) {
    book.tmps[k] = new Map(base.tmps[k]);
  }
  book.order.push(...base.order);
  return book;
}
function book_main(book) {
  const main = book.tlds["main"];
  return main === undefined || main.$ !== "Def" || main.v === null && main.i === undefined ? null : main;
}
function book_run(book, argv) {
  const main = book_main(book);
  if (main === null) {
    return cli_verdict(book, false);
  }
  if (io_type(book) !== null) {
    return io_run(book, argv);
  }
  const snf = term_snf(book, main.v);
  cli_say(1, term_show(term_lower(snf)) + `
`);
  return 0;
}
function book_err(e) {
  if (e instanceof Check_Fail) {
    return FAIL + `
` + book_err(e.why);
  }
  const err = e;
  if (e instanceof RangeError) {
    return "Error: the machine stack overflowed (a deep recursion, or a" + " literal too large to expand)";
  }
  return err?.$ === "Err" ? err_show(err) : String(e);
}
async function load_js(path4) {
  try {
    return js_lib(await book_read(path4), true);
  } catch (e) {
    throw new Error(book_err(e));
  }
}
async function load(u, context, next) {
  return u.endsWith(".bend") ? {
    format: "module",
    shortCircuit: true,
    source: await load_js(url2.fileURLToPath(u))
  } : next(u, context);
}

// BENDVY diagnostic insertion; copied logic only, no stock qualification.
var BVY_PD_STATE = {start:performance.now(), limit:Number(process.env.BENDVY_DIAG_DEADLINE_MS ?? 0), phase:"startup", stack:[], pass:0, calls:0, definition:null};
function BVY_PD_LOG(event, detail = {}) {
  fs4.writeSync(2, "BENDVY_PHASE " + JSON.stringify({event, phase:BVY_PD_STATE.phase, calls:BVY_PD_STATE.calls, elapsedMs:performance.now()-BVY_PD_STATE.start, ...detail}) + "\n");
}
function BVY_PD_PHASE(name, event) {
  if (event === "enter") BVY_PD_STATE.stack.push(name);
  BVY_PD_STATE.phase=name;
  BVY_PD_LOG("phase-"+event,{name,pass:BVY_PD_STATE.pass});
  if (event === "exit") {
    if (BVY_PD_STATE.stack.pop() !== name) throw new Error("diagnostic phase stack mismatch");
    BVY_PD_STATE.phase=BVY_PD_STATE.stack.at(-1) ?? "startup";
  }
}
function BVY_PD_CHECK(hook, definition) {
  BVY_PD_STATE.calls++;
  if (definition !== undefined) BVY_PD_STATE.definition=definition;
  if (BVY_PD_STATE.limit > 0 && performance.now()-BVY_PD_STATE.start >= BVY_PD_STATE.limit) {
    BVY_PD_LOG("deadline",{hook,definition:BVY_PD_STATE.definition,calls:BVY_PD_STATE.calls,limitMs:BVY_PD_STATE.limit,exit:75});
    process.exit(75);
  }
}
BVY_PD_LOG("startup",{deadlineMs:BVY_PD_STATE.limit});
var main_default = PLUGIN;
if (true) {
  if (typeof Bun === "undefined") {
    cli_say(2, "bend runs on Bun: curl -fsSL https://bend-lang.com/install.sh" + ` | sh
`);
    process.exit(1);
  }
  ua_fetch();
  await cli();
  process.exit();
}
export {
  main_default as default,
  load
};
