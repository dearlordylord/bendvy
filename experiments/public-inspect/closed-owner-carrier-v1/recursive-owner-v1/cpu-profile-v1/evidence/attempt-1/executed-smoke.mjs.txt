// Real builtin profiler helper smoke, no Bend/compiler imported.
import { withProfile } from './profile-helper.mjs';
const [path] = process.argv.slice(2);
if (!path) throw new Error('absent profile path required');
await withProfile(() => {
  const end = Date.now() + 30;
  let accumulator = 0;
  while (Date.now() < end) accumulator += Math.sqrt(accumulator + 1);
  return accumulator;
}, path);
