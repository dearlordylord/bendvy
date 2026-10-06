function array_rmw(a, i, f) {
  const at = i % a.length;
  const old = a[at];
  a[at] = f(old);
  return {$: "Tuple", fst: a, snd: old};
}
function receive(prefix,pair) { return pair; }
function swap(a,i) { const value = 5; return receive(7,array_rmw(a,i,()=>value)); }
