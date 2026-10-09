"""Materialize source-only reached controls around the exact proposed entry seams."""
import json, runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
M=runpy.run_path(str(HERE/'instrument.py'))
js='''import assert from 'node:assert/strict';
import vm from 'node:vm';
const original = ORIGINAL;
const changed = CHANGED;
const expected = ['clock','main','late','teardown','clock','clock','printer','bytes','clock','out1','bytes','out2'];
function run(fragment) {
 const seen=[], outputs=[];
 const context={show:[[],[]], main(){seen.push('main');seen.push('late');seen.push('teardown');return {complete:17};},run_loop:x=>x,
 show_val(...args){seen.push('printer');assert.deepEqual(JSON.parse(JSON.stringify(args[3])),{complete:17});return 'Complete{17}';},
 io_bytes:x=>{seen.push('bytes');return x;},io_out:(fd,x)=>{seen.push('out'+fd);outputs.push([fd,x]);},
 process:{hrtime:{bigint(){seen.push('clock');return BigInt(seen.length);}}},JSON};
 vm.runInNewContext(fragment,context);return {seen,outputs};
}
const good=run(changed);assert.deepEqual(good.seen,expected);assert.equal(good.outputs[0][1],'Complete{17}\\n');
const hoisted=changed.replace('      const simulationStart = process.hrtime.bigint();\\n      const simulationValue = run_loop(main());','      const simulationValue = run_loop(main());\\n      const simulationStart = process.hrtime.bigint();');
const included=changed.replace('      const simulationStop = process.hrtime.bigint();','').replace('      const transportStop = process.hrtime.bigint();','      const simulationStop = process.hrtime.bigint();\\n      const transportStop = process.hrtime.bigint();');
assert.notDeepEqual(run(hoisted).seen,expected);assert.notDeepEqual(run(included).seen,expected);
console.log(JSON.stringify({status:'CONTROL_PASS',positive:good.seen,refused:['hoisted-main','included-printer'],stdout:'Complete{17}\\n'}));
'''.replace('ORIGINAL',json.dumps(M['JS_OLD'])).replace('CHANGED',json.dumps(M['JS_NEW']))
(HERE/'controls.mjs').write_text(js)
c='''#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
typedef unsigned long long u64;typedef int Term;typedef int Env;
#define MAIN_PURE 1
#define MAIN_FID 1
#define TERM_HOLE 0
#define H_ROOT_WORD 0
static char witness[256]="";static int calls=0;
static void mark(const char*s){strcat(witness,s);strcat(witness,",");}
static int witness_clock(clockid_t id, struct timespec*p){int r=clock_gettime(id,p);mark("clock");calls++;return r;}
#define clock_gettime witness_clock
static void err_fail(const char*s){fprintf(stderr,"%s",s);exit(2);}
static int task_node(Env e,int f,int hole,int a,int b){mark("task");return 0;}
static int term_tsk(int f,int n){return n;}
static Term corpus_eval(u64*H,Term t){mark("main");mark("late");H[0]=17;mark("teardown");return 0;}
static void show_val(Env e,int d,u64*H,int chain){mark("printer");printf("Complete{%llu}",H[0]);}
static void run(void){u64 H[1]={0};Env e=0;
FRAGMENT
#endif
}
int main(void){run();if(strcmp(witness,"clock,task,main,late,teardown,clock,printer,clock,")){fprintf(stderr,"\\nCONTROL_REFUSED:%s\\n",witness);return 3;}fprintf(stderr,"CONTROL_PASS:%s\\n",witness);return 0;}
'''
fragment=M['C_NEW']
variants={'positive':fragment,'hoisted':fragment.replace('  if (clock_gettime(CLOCK_MONOTONIC, &simulationStart)) err_fail("simulation clock failed");\n','').replace('  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop))','  if (clock_gettime(CLOCK_MONOTONIC, &simulationStart)) err_fail("simulation clock failed");\n  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop))'),'included':fragment.replace('  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop)) err_fail("simulation clock failed");\n','').replace('  if (clock_gettime(CLOCK_MONOTONIC, &transportStop))','  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop)) err_fail("simulation clock failed");\n  if (clock_gettime(CLOCK_MONOTONIC, &transportStop))')}
for name,fragment in variants.items():(HERE/('control-'+name+'.c')).write_text(c.replace('FRAGMENT',fragment))
