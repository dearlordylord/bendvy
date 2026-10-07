// Harness-only UTF-8/FNV-1a32 transport. No timed ECS operations are substituted.
let featureStart = null;
let featureChunks = [];
let featureDigest = 2166136261;
let featureBytes = 0;
function io_feature_begin() {
  if (featureStart !== null) throw Error("nested feature timer");
  featureChunks = [];
  featureDigest = 2166136261;
  featureBytes = 0;
  featureStart = process.hrtime.bigint();
  return {$: CID(Unit)};
}
function io_feature_capture(text) {
  if (featureStart === null) throw Error("capture outside feature timer");
  const bytes = io_bytes(text + "\n");
  for (const byte of bytes) featureDigest = Math.imul(featureDigest ^ byte, 16777619) >>> 0;
  featureBytes += bytes.length;
  featureChunks.push(bytes);
  return {$: CID(Unit)};
}
function io_feature_end() {
  if (featureStart === null) throw Error("end without feature timer");
  const elapsedNs = process.hrtime.bigint() - featureStart;
  featureStart = null;
  io_out(2, io_bytes(JSON.stringify({elapsedNs: elapsedNs.toString(), bytes: featureBytes, digest: featureDigest}) + "\n"));
  for (const bytes of featureChunks) io_out(1, bytes);
  featureChunks = [];
  return {$: CID(Unit)};
}
io_eff(CID(begin), io_feature_begin);
io_eff(CID(capture), io_feature_capture);
io_eff(CID(end), io_feature_end);
