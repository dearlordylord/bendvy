import assert from 'node:assert/strict';
import {run} from './reference.mjs';
assert.equal(process.argv.length,3);
assert.ok(['1','2','4'].includes(process.argv[2]));
run(Number(process.argv[2]));
