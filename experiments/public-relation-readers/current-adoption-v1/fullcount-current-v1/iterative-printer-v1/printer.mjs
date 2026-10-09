function show_val(D, N, d, v, chain) {
  const chunks = [];
  const work = [{d, v, chain}];
  while (work.length) {
    const task = work.pop();
    if (typeof task === "string") { chunks.push(task); continue; }
    const {d, v, chain} = task;
    if (D[d] === 7) {
      const fs = Object.values(typeof v === "boolean"
        ? { $: v ? "True" : "False" } : v);
      let a = d + 3;
      for (; N[D[a]] !== fs[0]; a += 4 + 2 * D[a + 2]) {}
      const o = "{[("[D[a + 3]];
      chunks.push(o === "{" ? fs[0] + "{" : chain === o ? "" : o);
      if (o === "{" || chain !== o) work.push("}])"[D[a + 3]]);
      for (let j = fs.length - 2; j >= 0; --j) {
        work.push({d: D[a + 5 + 2 * j], v: fs[j + 1],
          chain: j === 1 && o !== "{" ? o : 0});
        if (o === "[" ? j === 0 && chain === o : j > 0) work.push(", ");
      }
    } else if (D[d] <= 5) {
      chunks.push(D[d] === 0 ? String(v)
        : D[d] === 1 ? f32_show(v).replace(/^-?\d+(?=e|$)/, "$&.0")
        : D[d] === 2 ? v + "n"
        : D[d] === 3 ? "'" + show_chr(v.codePointAt(0), "'") + "'"
        : D[d] === 4 ? "\"" + [...v].map((c) =>
          show_chr(c.codePointAt(0), "\"")).join("") + "\""
        : "{==}");
    } else {
      chunks.push("["); work.push("]");
      for (let j = v.length - 1; j >= 0; --j) {
        work.push({d: D[d + 1], v: v[j], chain: 0});
        if (j > 0) work.push(", ");
      }
    }
  }
  return chunks.join("");
}

export {show_val};
