export function layEqual(a, b) {
  if (a === b) return true;
  if (a.ks.length !== b.ks.length) return false;
  for (let i = 0; i < a.ks.length; ++i) if (a.ks[i] !== b.ks[i]) return false;
  if (a.arms === null || b.arms === null) return a.arms === b.arms;
  let at = 0;
  for (const key in a.arms) {
    if (!Object.hasOwn(a.arms, key)) continue;
    let found = false, index = 0;
    for (const other in b.arms) {
      if (!Object.hasOwn(b.arms, other)) continue;
      if (index++ === at) { if (key !== other) return false; found = true; break; }
    }
    if (!found) return false;
    const xs = a.arms[key], ys = b.arms[key];
    if (xs.length !== ys.length) return false;
    for (let i = 0; i < xs.length; ++i) if (!layEqual(xs[i], ys[i])) return false;
    ++at;
  }
  let count = 0;
  for (const key in b.arms) if (Object.hasOwn(b.arms, key)) ++count;
  return count === at;
}
