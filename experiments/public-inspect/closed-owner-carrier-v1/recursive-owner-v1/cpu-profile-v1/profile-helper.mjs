import { Session } from 'node:inspector';
import * as fs from 'node:fs';
export function post(session, method) {
  return new Promise((resolve, reject) => session.post(method, {}, (error, result) => error ? reject(error) : resolve(result)));
}
export function writeProfile(path, profile) {
  if (fs.existsSync(path)) throw new Error('profile output must start absent');
  const fd = fs.openSync(path, fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW, 0o600);
  try {
    if (!fs.fstatSync(fd).isFile()) throw new Error('profile descriptor must be regular');
    fs.writeFileSync(fd, JSON.stringify(profile));
  } finally { fs.closeSync(fd); }
}
export async function withProfile(work, path, session = new Session()) {
  session.connect();
  let started = false;
  let workError;
  let workFailed = false;
  let stopError;
  let value;
  try {
    await post(session, 'Profiler.enable');
    await post(session, 'Profiler.start');
    started = true;
    try { value = await work(); } catch (error) { workFailed = true; workError = error; }
  } finally {
    try {
      if (started) {
        const { profile } = await post(session, 'Profiler.stop');
        writeProfile(path, profile);
      }
    } catch (error) { stopError = error; }
    finally { session.disconnect(); }
  }
  if (workFailed) {
    if (stopError) console.error('PROFILE_STOP_ERROR ' + String(stopError));
    throw workError;
  }
  if (stopError) throw stopError;
  return value;
}
