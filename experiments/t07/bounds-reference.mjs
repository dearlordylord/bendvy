import {make} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/streams.ts';
const key=Symbol('Ping'),s=make(3),a={streamLastRun:0},b={streamLastRun:0};s.register(key,a);s.register(key,b);
function read(name,last,registered=0){console.log(name+':'+s.since(key,last).map(x=>x+',').join('')+':'+s.lagged(key,last,registered));}
s.append(key,1,[1,2]);s.trim(0);read('capacity:A-first',0);a.streamLastRun=2;
s.append(key,3,[3,4]);s.trim(0);read('capacity:B-failed',0);read('capacity:A-not-lagged',2);read('capacity:B-retry',0);b.streamLastRun=4;
s.append(key,5,[5,6,7,8]);s.trim(0);read('capacity:A-empty',2);read('capacity:B-empty',4);read('capacity:new-reader',0,5);
const zero=make(0);zero.register(key,{streamLastRun:0});zero.append(key,1,[1]);zero.trim(0);console.log('capacity:zero:'+zero.since(key,0).map(x=>x+',').join('')+':'+zero.lagged(key,0,0));
