/** Source-only case inventory. The actual runner must evaluate this adapter at runtime and forward argv unchanged. */
import {runtimeInvocation} from './host-wire.mjs';
const text=value=>({$: 'Text',value});
const number=value=>({$: 'Number',value});
export const boundary={
  input:raw=>raw.$==='Text'||raw.$==='Number'?raw.value:raw,
  output:value=>typeof value==='string'?text(value):number(value),
  issues:issues=>({$:'Array',items:issues.map(issue=>({$:'Object',fields:[{$:'Field',name:'message',value:text(issue.message)}]}))})
};
export const schemas={
  First:{'~standard':{version:1,vendor:'runtime-first',validate:value=>
    value==='deny-first'?{issues:[{message:'first host refusal',path:['first']}]}:
    {value:typeof value==='string'&&value.startsWith('source:')?value.slice(7):value}}},
  Second:{'~standard':{version:1,vendor:'runtime-second',validate:value=>
    value==='deny-second'?{issues:[{message:'second host refusal',path:['second']}]}:
    {value:typeof value==='string'&&value.startsWith('pair(')&&value.endsWith(')')?value.slice(5,-1):value}}}
};
const encoded=(schema,pair)=>text(schema==='First'?'source:'+pair:'pair('+pair+')');
export const cases=['First','Second'].flatMap(schema=>[
  ['spawn','spawn',encoded(schema,'7,8')],
  ['insert','insert',encoded(schema,'7,8')],
  ['resource','resource',encoded(schema,'7,8')],
  ['parseRefusal','spawn',encoded(schema,'7;q')],
  ['wrongKind','spawn',number(7)],
  ['downstreamRefusal','spawn',encoded(schema,'9,8')],
  ['resourceParseRefusal','resource',encoded(schema,'7;q')],
  ['resourceWrongKind','resource',number(7)],
  ['resourceDownstreamRefusal','resource',encoded(schema,'9,8')],
  ['failure','failure',encoded(schema,'7,8')],
  ['failedInsert','failed-insert',encoded(schema,'7,8')],
  ['failedResource','failed-resource',encoded(schema,'7,8')],
  ['skip','skip',encoded(schema,'7,8')],
  ['hostRefusal','spawn',text(schema==='First'?'deny-first':'deny-second')]
].map(([label,operation,input])=>({schema,label,operation,input})));
export const packet = item=>runtimeInvocation(schemas[item.schema],boundary,item.input,item.schema,item.operation);
