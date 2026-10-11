// Harness-only operation intervals; output is captured outside every interval.
let intervalActive=false, intervalStart=null, intervalElapsed=0n, intervalCount=0;
let intervalChunks=[], intervalBytes=0, intervalDigest=2166136261, intervalReady=false;
function intervalRequire(ok){if(!ok)throw Error('interval timer protocol failure');}
function io_interval_reset(){intervalRequire(!intervalActive&&!intervalReady);intervalReady=true;intervalElapsed=0n;intervalCount=0;intervalChunks=[];intervalBytes=0;intervalDigest=2166136261;return {$:CID(Unit)};}
function io_interval_begin(){intervalRequire(intervalReady&&!intervalActive);intervalStart=process.hrtime.bigint();intervalActive=true;return {$:CID(Unit)};}
function io_interval_end(){intervalRequire(intervalReady&&intervalActive);intervalElapsed+=process.hrtime.bigint()-intervalStart;intervalActive=false;intervalCount++;return {$:CID(Unit)};}
function io_interval_capture(text){intervalRequire(intervalReady&&!intervalActive);const b=io_bytes(text+'\n');for(const x of b)intervalDigest=Math.imul(intervalDigest^x,16777619)>>>0;intervalBytes+=b.length;intervalChunks.push(b);return {$:CID(Unit)};}
function io_interval_finish(){intervalRequire(intervalReady&&!intervalActive&&intervalCount===17);io_out(2,io_bytes(JSON.stringify({elapsedNs:intervalElapsed.toString(),bytes:intervalBytes,digest:intervalDigest,intervals:intervalCount})+'\n'));for(const b of intervalChunks)io_out(1,b);intervalChunks=[];intervalReady=false;return {$:CID(Unit)};}
io_eff(CID(reset),io_interval_reset);io_eff(CID(begin),io_interval_begin);io_eff(CID(end),io_interval_end);io_eff(CID(capture),io_interval_capture);io_eff(CID(finish),io_interval_finish);
