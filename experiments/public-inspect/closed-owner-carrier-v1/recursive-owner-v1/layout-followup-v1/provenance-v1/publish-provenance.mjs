import * as fs from 'node:fs';
// Diagnostic-only publication: absent regular descriptor, complete synchronous bytes.
export function publish(path, value) {
  const raw = JSON.stringify(value);
  const fd = fs.openSync(path, fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW, 0o600);
  try {
    if (!fs.fstatSync(fd).isFile()) throw new Error('provenance descriptor must be regular');
    fs.writeFileSync(fd, raw);
    fs.fsyncSync(fd);
  } finally { fs.closeSync(fd); }
}
