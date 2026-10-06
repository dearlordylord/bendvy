// Infrastructure capability canary, not an ECS law or performance threshold.
const inspector = require('node:inspector');
if (typeof global.gc !== 'function') throw Error('Run with --expose-gc');
const results = {};
for (const include of [false, true]) {
  global.gc();
  const session = new inspector.Session();
  session.connect();
  let started = false;
  session.post('HeapProfiler.startSampling', {
    samplingInterval: 1024,
    includeObjectsCollectedByMajorGC: include,
    includeObjectsCollectedByMinorGC: include
  }, error => { if (error) throw error; started = true; });
  if (!started) throw Error('Expected synchronous Inspector callback');
  global.canary = Array.from({length: 20000}, (_, x) => ({x, y: x + 1}));
  if (global.canary.length !== 20000) throw Error('Canary work missing');
  global.canary = null;
  global.gc();
  session.post('HeapProfiler.stopSampling', (error, result) => {
    if (error) throw error;
    let size = 0;
    function visit(node) { size += node.selfSize; node.children.forEach(visit); }
    visit(result.profile.head);
    results[include] = {sampledSelfBytes: size, samples: result.profile.samples.length};
  });
  session.disconnect();
}
if (!(results.true.sampledSelfBytes > results.false.sampledSelfBytes))
  throw Error('Collected-object option lacks positive observed witness');
console.log(JSON.stringify({status: 'COLLECTED_OBJECT_CAPABILITY_WITNESS_PASS', node: process.version, results}));
