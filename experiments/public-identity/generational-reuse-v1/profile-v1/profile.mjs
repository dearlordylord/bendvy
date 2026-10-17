import inspector from 'node:inspector';
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
import {PerformanceObserver} from 'node:perf_hooks';

const [mode, generated, destination] = process.argv.slice(2);
if (!['cpu', 'heap'].includes(mode) || !generated || !destination || fs.existsSync(destination)) {
  throw Error('expected cpu|heap, unchanged generated module, absent profile path');
}
const session = new inspector.Session();
session.connect();
const post = (method, params = {}) => new Promise((resolve, reject) => {
  session.post(method, params, (error, result) => error ? reject(error) : resolve(result));
});
const gc = [];
const observer = new PerformanceObserver(list => {
  for (const entry of list.getEntries()) gc.push({duration: entry.duration, kind: entry.detail.kind});
});
observer.observe({entryTypes: ['gc']});
const originalExit = process.exit;
let zeroExits = 0;
process.exit = code => {
  if (code !== 0) return originalExit.call(process, code);
  zeroExits++;
};
try {
  if (mode === 'cpu') {
    await post('Profiler.enable');
    await post('Profiler.setSamplingInterval', {interval: 100});
    await post('Profiler.start');
  } else {
    await post('HeapProfiler.enable');
    await post('HeapProfiler.startSampling', {
      samplingInterval: 32768,
      includeObjectsCollectedByMajorGC: true,
      includeObjectsCollectedByMinorGC: true
    });
  }
  await import(pathToFileURL(generated).href);
  if (zeroExits !== 1) throw Error('generated IO did not complete with exactly one exit(0)');
  await new Promise(resolve => process.stdout.write('', resolve));
  await new Promise(resolve => setTimeout(resolve, 20));
  const result = await post(mode === 'cpu' ? 'Profiler.stop' : 'HeapProfiler.stopSampling');
  fs.writeFileSync(destination, JSON.stringify({mode, zeroExits, gc, node: process.version, profile: result.profile}), {flag: 'wx'});
} finally {
  process.exit = originalExit;
  observer.disconnect();
  session.disconnect();
}
