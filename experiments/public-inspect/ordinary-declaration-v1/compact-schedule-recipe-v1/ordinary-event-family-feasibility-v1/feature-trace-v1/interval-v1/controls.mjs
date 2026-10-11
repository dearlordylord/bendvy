// Protocol controls only; deterministic clock, no feature performance sample.
import fs from 'node:fs';import vm from 'node:vm';
const script=fs.readFileSync(new URL('./timing.js',import.meta.url),'utf8');
function fresh(){const f={};let t=0n;const chunks=[];const c={CID:x=>x,io_eff:(n,fn)=>f[n]=fn,io_bytes:x=>Buffer.from(x),io_out:(fd,b)=>chunks.push([fd,Buffer.from(b)]),process:{hrtime:{bigint:()=>{t+=10n;return t;}}},console};for(const n of ['Unit','reset','begin','end','capture','finish'])c[n]=n;vm.runInNewContext(script,c);return {f,chunks};}
function rejects(fn){let threw=false;try{fn();}catch{threw=true;}if(!threw)throw Error('control did not refuse');}
{const {f,chunks}=fresh();f.reset();for(let i=0;i<17;i++){f.begin(i);f.end();}f.capture('λ🙂\nline');f.finish();const r=JSON.parse(chunks.find(x=>x[0]===2)[1]);if(r.elapsedNs!=='170'||r.intervals!==17||r.bytes!==Buffer.byteLength('λ🙂\nline\n'))throw Error('complete interval/control bytes mismatch');}
{const {f}=fresh();rejects(()=>f.end());rejects(()=>f.begin(0));rejects(()=>f.capture('x'));f.reset();rejects(()=>f.reset());f.begin(0);rejects(()=>f.begin(0));rejects(()=>f.capture('x'));rejects(()=>f.finish());f.end();rejects(()=>f.end());}
for(const n of [0,16,18]){const {f}=fresh();f.reset();for(let i=0;i<n;i++){f.begin(i);f.end();}rejects(()=>f.finish());}
{const {f}=fresh();f.reset();f.begin(0);f.end();rejects(()=>f.begin(0));rejects(()=>f.begin(2));}
console.log('INTERVAL_PROTOCOL_PASS');
