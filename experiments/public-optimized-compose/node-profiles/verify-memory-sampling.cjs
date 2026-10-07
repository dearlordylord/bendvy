// Instrumentation canary; no ECS or timing acceptance claim.
const inspector = require('node:inspector');
const session = new inspector.Session();
session.connect();
const post = (method, params = {}) => new Promise((resolve, reject) =>
  session.post(method, params, (error, result) => error ? reject(error) : resolve(result)));
function transientAllocations() {
  for (let i = 0; i < 4000; i++) {
    const disposable = new Array(128).fill(i);
    if (disposable[127] !== i) throw Error('allocation canary');
  }
}
function attributedToCanary(node) {
  const children = node.children || [];
  const total = n => (n.selfSize || 0) + (n.children || []).reduce((sum, child) => sum + total(child), 0);
  return node.callFrame.functionName === 'transientAllocations'
    ? total(node) : children.reduce((sum, child) => sum + attributedToCanary(child), 0);
}
(async () => {
  if (typeof global.gc !== 'function') throw Error('Run with --expose-gc');
  await post('HeapProfiler.enable');
  const observations = {};
  for (const includeCollected of [false, true]) {
    await post('HeapProfiler.startSampling', {
      samplingInterval: 256,
      includeObjectsCollectedByMajorGC: includeCollected,
      includeObjectsCollectedByMinorGC: includeCollected
    });
    transientAllocations();
    global.gc();
    const {profile} = await post('HeapProfiler.stopSampling');
    observations[String(includeCollected)] = attributedToCanary(profile.head);
  }
  // Compiled function metadata can remain attributed after collection. Require
  // a broad separation from that retained residue, rather than literal zero.
  if (observations.true <= Math.max(1, observations.false) * 10) {
    throw Error('Collected-object sampling control failed: ' + JSON.stringify(observations));
  }
  session.disconnect();
  console.log(JSON.stringify({status: 'PASS', sampledAttributionBytes: observations,
    scope: 'Canary confirms transient allocation stacks survive collection only with collected-object sampling enabled; not a physical allocation total.'}));
})().catch(error => { console.error(error); process.exitCode = 1; });
