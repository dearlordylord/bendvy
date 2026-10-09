/** Explicit transport-only inventory, not ECS feature qualification. */
import {rawTokens} from './host-wire.mjs';
const field=(name,value)=>({$: 'Field',name,value});
export const rawCases=[
 ['missing',{$:'Missing'}],['null',{$:'Null'}],['number',{$:'Number',value:4294967295}],
 ['signedMaximum',{$:'SignedInteger',negative:true,magnitude:281474976710655}],
 ['positiveZero',{$:'Float',value:0}],['negativeZero',{$:'Float',value:-0}],
 ['subnormal',{$:'Float',value:2**-149}],['nan',{$:'Float',value:NaN}],
 ['infinity',{$:'Float',value:Infinity}],['negativeInfinity',{$:'Float',value:-Infinity}],
 ['binary64',{$:'Binary64',high:4294967295,low:2147483648}],
 ['astral',{$:'Text',value:'A🌍'}],
 ['loneUtf16',{$:'Utf16Text',units:[55296]}],['invalidUtf16Unit',{$:'Utf16Text',units:[65536]}],
 ['boolean',{$:'Boolean',value:false}],['handle',{$:'Handle',namespace:17,id:19}],
 ['emptyArray',{$:'Array',items:[]}],['emptyObject',{$:'Object',fields:[]}],
 ['nestedDuplicate',{$:'Object',fields:[field('x',{$:'Text',value:'first'}),field('x',{$:'Array',items:[{$:'Boolean',value:true},{$:'Null'}]}),field('🌍',{$:'Binary64',high:1,low:2})]}]
].map(([label,raw])=>({label,raw}));
export const malformedCases=[
 ['maximumTextCount',['text','281474976710655']],
 ['maximumUtf16Count',['utf16','281474976710655']],
 ['maximumFieldNameCount',['object','1','281474976710655']],
 ['signedOverflow',['signed','0','281474976710656']],
 ['u32Overflow',['number','4294967296']],
 ['badBoolean',['bool','2']],
 ['nonScalarText',['text','1','55296']],
 ['truncatedArray',['array','2','null']],
 ['extraToken',['null','null']]
].map(([label,argv])=>({label,argv}));
export const knownFrames=[{label:'knownNan',argv:['float','2143289344'],origin:'source-selected frame-only; no JS payload claim'}];
export const packets=()=>[...rawCases.map(item=>({label:item.label,argv:rawTokens(item.raw)})),...knownFrames,...malformedCases];
