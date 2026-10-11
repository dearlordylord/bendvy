// External WebKit protocol client; the existing Python runner owns the deadline.
import { spawn } from 'node:child_process';
import { readFileSync, appendFileSync, writeFileSync, existsSync, realpathSync } from 'node:fs';

const config = JSON.parse(readFileSync(process.argv[2], 'utf8'));
if (realpathSync(process.execPath) !== realpathSync(config.nodePath)) {
  throw new Error('Executing Node differs from admitted interpreter');
}
for (const path of [config.protocol, config.profile, config.stdout, config.stderr]) {
  if (existsSync(path)) throw new Error('Diagnostic output must start absent: ' + path);
}
for (const path of [config.protocol, config.stdout, config.stderr]) writeFileSync(path, '', { flag: 'wx' });
const child = spawn(config.argv[0], config.argv.slice(1), {
  cwd: config.cwd, env: config.environment, stdio: ['ignore', 'pipe', 'pipe'],
});
let bytes = 0;
function retain(path, data) {
  bytes += Buffer.byteLength(data);
  if (bytes > config.maxBytes) throw new Error('Diagnostic storage bound exceeded');
  appendFileSync(path, data, { flag: 'a' });
}
let connected = false;
let stderr = '';
child.stdout.on('data', data => retain(config.stdout, data));
child.stderr.on('data', data => {
  retain(config.stderr, data);
  stderr += data.toString();
  const match = stderr.replace(/\x1b\[[0-9;]*m/g, '').match(/ws:\/\/(?:127\.0\.0\.1|localhost):\d+\/[^\s]+/);
  if (!connected && match) {
    connected = true;
    observe(match[0]).catch(error => {
      retain(config.protocol, JSON.stringify({ failure: String(error) }) + '\n');
    });
  }
});
child.on('error', error => { throw error; });
child.on('close', (code, signal) => {
  retain(config.protocol, JSON.stringify({ childClose: { code, signal } }) + '\n');
  process.exit(code === 0 ? 0 : 1);
});

async function observe(url) {
  const socket = new WebSocket(url);
  let nextId = 0;
  const waiting = new Map();
  socket.addEventListener('message', event => {
    if (typeof event.data !== 'string') throw new Error('WebKit response must be text');
    retain(config.protocol, event.data + '\n');
    const message = JSON.parse(event.data);
    if (message.method === 'ScriptProfiler.trackingComplete') {
      writeFileSync(config.profile, JSON.stringify(message.params) + '\n', { flag: 'wx' });
    }
    if (waiting.has(message.id)) {
      const { resolve, reject } = waiting.get(message.id);
      waiting.delete(message.id);
      if (message.error) reject(new Error(JSON.stringify(message.error)));
      else resolve(message.result);
    }
  });
  await new Promise((resolve, reject) => {
    socket.addEventListener('open', resolve, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });
  function send(method, params = {}) {
    const id = ++nextId;
    const message = JSON.stringify({ id, method, params });
    retain(config.protocol, JSON.stringify({ request: JSON.parse(message) }) + '\n');
    return new Promise((resolve, reject) => {
      waiting.set(id, { resolve, reject });
      socket.send(message);
    });
  }
  await send('Inspector.enable');
  await send('ScriptProfiler.startTracking', { includeSamples: true });
  // Inspector.initialized releases --inspect-wait after profiler setup.
  const initialized = send('Inspector.initialized');
  setTimeout(() => {
    send('ScriptProfiler.stopTracking').catch(error => {
      retain(config.protocol, JSON.stringify({ stopFailure: String(error) }) + '\n');
    });
  }, config.stopAfterMs);
  await initialized;
}
