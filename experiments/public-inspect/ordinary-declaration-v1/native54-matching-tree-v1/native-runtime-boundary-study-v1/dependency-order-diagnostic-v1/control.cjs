const fs=require('fs'),vm=require('vm'),assert=require('assert');
const src=fs.readFileSync(process.argv[2],'utf8');
const block=src.slice(src.indexOf('function BVY_N54_ORDER_KEYS('),src.indexOf('function compile_book(book) {'));
function qualify(keys,edges,expected){
 const state={keys,edges,done_defs:()=>keys.slice().reverse().map(k=>[k,{h:k}]),fun_of:(_,k)=>({h:k}),term_any:(_,k,f)=>{for(const dep of edges[k]??[])f({$:"Ref",k:dep});}};
 vm.createContext(state);vm.runInContext(block,state);const got=state.BVY_N54_NATIVE_ORDER({}).map(x=>x[0]);
 assert.deepStrictEqual(Array.from(got),expected);assert.strictEqual(new Set(got).size,keys.length);assert.deepStrictEqual([...got].sort(),[...keys].sort());
 assert.deepStrictEqual(Array.from(state.BVY_N54_NATIVE_ORDER({}).map(x=>x[0])),expected);
}
qualify(['caller','leaf'],{caller:['leaf']},['leaf','caller']);
qualify(['root','shared','deep'],{root:['shared','deep'],deep:['shared']},['shared','deep','root']);
qualify(['a','b','tail'],{a:['b'],b:['a','tail']},['tail','b','a']);
qualify(['a','b'],{a:['a','foreign','b','b']},['b','a']);
qualify([],{},[]);
const keys=Array.from({length:6000},(_,i)=>'k'+i),edges=Object.fromEntries(keys.map((k,i)=>[k,i+1<keys.length?[keys[i+1]]:[]]));qualify(keys,edges,keys.slice().reverse());
console.log('NATIVE_DEPENDENCY_ORDER_CONTROL_PASS');
