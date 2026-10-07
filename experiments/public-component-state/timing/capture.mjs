/** Harness-only capture; equivalent UTF-8 bytes/newlines/FNV-1a32 to Bend effects. */
export async function timed(run) {
  const original = console.log;
  const chunks = [];
  let digest = 2166136261, bytes = 0;
  console.log = text => {
    if (typeof text !== 'string') throw Error('Feature output must be a fully materialized string');
    const chunk = Buffer.from(text + '\n', 'utf8');
    for (const byte of chunk) digest = Math.imul(digest ^ byte, 16777619) >>> 0;
    bytes += chunk.length;
    chunks.push(chunk);
  };
  const start = process.hrtime.bigint();
  let elapsedNs;
  try { await run(); elapsedNs = process.hrtime.bigint() - start; }
  finally { console.log = original; }
  process.stderr.write(JSON.stringify({elapsedNs: elapsedNs.toString(), bytes, digest}) + '\n');
  for (const chunk of chunks) process.stdout.write(chunk);
}
