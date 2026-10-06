function array_rmw(a, i, f) {
  const at = i % a.length;
  const old = a[at];
  a[at] = f(old);
  return {$: "Tuple", fst: a, snd: old};
}
const log = [];
function first(a) { log.push("prior"); if(a.length) a[1] = {kind:"Type",a:41,b:42,c:43,d:44,stamp:45}; return 7; }
function receive(prefix,pair) { const array = pair.fst; const old = pair.snd; log.push("receiver"); return {prefix,array,old}; }
function swap(a,i) { const value = {kind:"Type",a:91,b:92,c:93,d:94,stamp:95}; return receive(first(a),array_rmw(a,i,()=>value)); }
function stop() { log.push("throw"); throw "expected"; }
function stopped(a,i) { const value = {kind:"Type",a:1,b:2,c:3,d:4,stamp:5}; return receive(stop(),array_rmw(a,i,()=>value)); }
const snapshot = Object.freeze({kind:"Data",a:11,b:12,c:13,d:14,stamp:15});
const raw = {kind:"Type",a:11,b:12,c:13,d:14,stamp:15};
const a = [raw,raw,raw,raw]; const got=swap(a,5); const empty=[]; const emptyGot=swap(empty,3); const preserved=[raw];try {stopped(preserved,0);}catch(e){if(e!=="expected")throw e;}
console.log(JSON.stringify({old:got.old,array:got.array,sameArray:got.array===a,raw,snapshot,emptyOld:emptyGot.old===undefined,emptyWritten:empty.NaN,unchangedAfterPriorThrow:preserved[0]===raw,log}));
