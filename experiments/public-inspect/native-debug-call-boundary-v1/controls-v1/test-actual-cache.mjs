// Portable read-only control from the actual failed controls07 artifacts.
import fs from 'node:fs';import zlib from 'node:zlib';
import {bindingSHA} from './checked-book.mjs';
const report=JSON.parse(zlib.gunzipSync(fs.readFileSync(new URL('./evidence-v1/controls07/controls.json.gz',import.meta.url))));
const before=report.active.baselineCheckedBook,after=report.active.baselineCheckedBookAfter.artifact;
if(JSON.stringify(before)===JSON.stringify(after))throw Error('actual mutation absent');
if(bindingSHA(before)!==bindingSHA(after))throw Error('actual cache normalization changed source binding');
function refused(mutate){const changed=structuredClone(after);mutate(changed);if(bindingSHA(before)===bindingSHA(changed))throw Error('changed binding accepted');}
refused(a=>a.definitions.target.v+='wrong-body');
refused(a=>a.definitions.target.T+='wrong-type');
refused(a=>a.templates.target=[['closed-type','targetSimilar']]);
refused(a=>a.definitions.target.n++);
// Root substitution is an object-identity condition, exercised by test-book-identity.
console.log('ACTUAL_CONTROLS07_CACHE_BINDING_PASS: preserved full snapshots; body/type/map/unrelated target refused');
