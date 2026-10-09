import assert from 'node:assert/strict';
import vm from 'node:vm';
const original = "      io_out(1, io_bytes(show_val(...show, 0, run_loop(main()), 0) + \"\\n\"));";
const changed = "      const simulationStart = process.hrtime.bigint();\n      const simulationValue = run_loop(main());\n      const simulationStop = process.hrtime.bigint();\n      const transportStart = process.hrtime.bigint();\n      const simulationText = io_bytes(show_val(...show, 0, simulationValue, 0) + \"\\n\");\n      const transportStop = process.hrtime.bigint();\n      io_out(1, simulationText);\n      io_out(2, io_bytes(JSON.stringify({simulationNs: String(simulationStop-simulationStart), transportNs: String(transportStop-transportStart), bytes: simulationText.length}) + \"\\n\"));";
const expected = ['clock','main','late','teardown','clock','clock','printer','bytes','clock','out1','bytes','out2'];
function run(fragment) {
 const seen=[], outputs=[];
 const context={show:[[],[]], main(){seen.push('main');seen.push('late');seen.push('teardown');return {complete:17};},run_loop:x=>x,
 show_val(...args){seen.push('printer');assert.deepEqual(JSON.parse(JSON.stringify(args[3])),{complete:17});return 'Complete{17}';},
 io_bytes:x=>{seen.push('bytes');return x;},io_out:(fd,x)=>{seen.push('out'+fd);outputs.push([fd,x]);},
 process:{hrtime:{bigint(){seen.push('clock');return BigInt(seen.length);}}},JSON};
 vm.runInNewContext(fragment,context);return {seen,outputs};
}
const good=run(changed);assert.deepEqual(good.seen,expected);assert.equal(good.outputs[0][1],'Complete{17}\n');
const hoisted=changed.replace('      const simulationStart = process.hrtime.bigint();\n      const simulationValue = run_loop(main());','      const simulationValue = run_loop(main());\n      const simulationStart = process.hrtime.bigint();');
const included=changed.replace('      const simulationStop = process.hrtime.bigint();','').replace('      const transportStop = process.hrtime.bigint();','      const simulationStop = process.hrtime.bigint();\n      const transportStop = process.hrtime.bigint();');
assert.notDeepEqual(run(hoisted).seen,expected);assert.notDeepEqual(run(included).seen,expected);
console.log(JSON.stringify({status:'CONTROL_PASS',positive:good.seen,refused:['hoisted-main','included-printer'],stdout:'Complete{17}\n'}));
