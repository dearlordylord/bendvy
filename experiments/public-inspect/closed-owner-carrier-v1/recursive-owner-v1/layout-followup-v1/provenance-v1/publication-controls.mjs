import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import assert from 'node:assert/strict';
import {publish} from './publish-provenance.mjs';
const root=fs.mkdtempSync(path.join(os.tmpdir(),'provenance-publication-'));
try {
 const target=path.join(root,'complete.json');
 const value={earlyFailure:true,rows:Array.from({length:4096},(_,i)=>({key:'definition-'+i,count:i}))};
 let primary;
 try {throw new Error('primary compiler failure');} catch(error) {primary=error;} finally {publish(target,value);}
 assert.equal(primary.message,'primary compiler failure');
 assert.deepEqual(JSON.parse(fs.readFileSync(target,'utf8')),value);
 assert(fs.statSync(target).size>65536);
 assert.throws(()=>publish(target,{changed:true}));
 assert.deepEqual(JSON.parse(fs.readFileSync(target,'utf8')),value);
 const link=path.join(root,'link.json');fs.symlinkSync(target,link);
 assert.throws(()=>publish(link,{}));
 const broken=path.join(root,'broken.json');fs.symlinkSync(path.join(root,'absent'),broken);
 assert.throws(()=>publish(broken,{}));
 const circular={};circular.self=circular;
 const absent=path.join(root,'circular.json');assert.throws(()=>publish(absent,circular));assert(!fs.existsSync(absent));
 console.log('PASS complete >64KiB earlyfailure publication, exclusive/link refusal, serialization failure absent');
} finally {fs.rmSync(root,{recursive:true,force:true});}
