import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
for(const test of JSON.parse(fs.readFileSync('controls.json','utf8'))) {
  for(const positive of [true,false]) {
    const file=test.fixture+(positive?'-control':'')+'.bend';
    const result=spawnSync('../t01/bend-check',[file,'--check-only'],{encoding:'utf8'});
    const output=result.stdout+result.stderr;
    fs.writeFileSync(process.argv[2]+'/'+file+'.log',output);
    if(result.error || result.signal || result.status!==(positive?0:1)) throw Error(file+' unexpected exit: '+result.status+' '+result.signal+'\n'+output);
    if(positive) {
      if(!output.split('\n').includes('ALL PROOFS CHECK')) throw Error(file+' missing positive verdict');
    } else {
      for(const line of ['SOME PROOFS FAIL','- expected : '+test.expected,'- observed : '+test.observed,'Location: '+test.location])
        if(!output.split('\n').includes(line)) throw Error(file+' missing diagnostic '+line+'\n'+output);
    }
  }
  console.log(test.fixture+' paired intended-type PASS');
}
