'use strict';
process.hrtime.bigint();
function releasedCanary(){for(let i=0;i<20000;i++){const value={marker:'released',payload:new Array(40).fill(i)};if(value.payload[0]!==i)throw Error('canary');}}
releasedCanary();global.gc();global.gc();process.hrtime.bigint();
