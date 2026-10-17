import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
const [beforePath, afterPath] = process.argv.slice(2);
function helper(path) {
  const text = fs.readFileSync(path, 'utf8');
  const start = text.indexOf('function graph_close(set, edges) {');
  assert(start >= 0);
  const end = text.indexOf('\nfunction ', start + 1);
  assert(end > start);
  return vm.runInNewContext('(' + text.slice(start, end) + ')');
}
const before = helper(beforePath), after = helper(afterPath);
let cases = 0;
function compare(label, seeds, edges) {
  const oldSet = new Set(seeds), newSet = new Set(seeds);
  assert.equal(before(oldSet, edges), oldSet, label + ': same original Set returned');
  assert.equal(after(newSet, edges), newSet, label + ': same candidate Set returned');
  assert.deepEqual([...newSet], [...oldSet], label + ': ordered contents');
  cases++;
}
compare('empty', [], []);
compare('chain fanout', ['a'], [['a','b'],['a','c'],['b','d'],['c','e']]);
compare('cycles self loop', ['a'], [['a','a'],['a','b'],['b','c'],['c','a']]);
compare('duplicates shared diamond', ['a'], [['a','b'],['a','c'],['a','b'],['b','d'],['c','d']]);
compare('multiple seeds insertion order', ['c','a'], [['a','b'],['c','e'],['b','d'],['e','d']]);
compare('absent unreachable seeds', ['absent'], [['a','b'],['b','c']]);
compare('destination NaN then source NaN strict equality', ['a'], [['a',NaN],[NaN,'bad']]);
compare('seed NaN strict equality', [NaN], [[NaN,'bad'],['a','b']]);
compare('signed zero', [-0], [[+0,'a'],[-0,'b']]);
const one = {}, sameShape = {}, third = {};
compare('object identity', [one], [[sameShape,'bad'],[one,third],[third,sameShape]]);
compare('undefined null keys', [undefined], [[undefined,null],[null,'done']]);
compare('encoded lend seeds retained order', ['field<owner','other<slot','owner'], [['owner','field'],['slot','other'],['field','leaf'],['leaf','owner']]);
compare('reverse edge order', ['a'], [['a','c'],['a','b'],['c','e'],['b','d']]);
for (let size = 1; size <= 64; size++) {
  const keys = Array.from({length:size}, (_,i) => 'node~'+i);
  const edges = [];
  for (let i = 0; i < size; i++) {
    edges.push([keys[i],keys[(i+1)%size]], [keys[i],keys[(i*7+3)%size]]);
    if (i%3 === 0) edges.push([keys[i],keys[(i+1)%size]]);
  }
  compare('dense generated forward '+size, [keys[size-1],keys[0]], edges);
  compare('dense generated reversed '+size, [keys[0],keys[size-1]], [...edges].reverse());
}
console.log(JSON.stringify({status:'PASS',cases,extractedActualHelpers:true,checks:['same Set mutation/return','ordered contents','cycles/self loops','duplicate/shared DAG edges','absent/multiple seeds','strict NaN source equality','signed zero','object identity','encoded lend seed ordering','dense generated graphs'],limits:'Plain static tuple arrays and Sets; no side-effectful edge getters/mutation. No benchmark or compiler whole-output claim.'}));
