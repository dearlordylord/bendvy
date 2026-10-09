/** Runtime transport for the existing typed Raw algebra. No schema callback crosses into Bend. */
import {checkedRaw,typedRawConstructor} from '../adapter.mjs';
const scalarCodes = text => {
  const result=[];
  for (const char of text) {
    const code=char.codePointAt(0);
    if(code>=0xd800 && code<=0xdfff) throw new RangeError('Existing Bend String has no scalar representation for this JS string');
    result.push(String(code));
  }
  return [String(result.length),...result];
};
const bits = value => {
  const view=new DataView(new ArrayBuffer(4));view.setFloat32(0,value,false);return String(view.getUint32(0,false));
};
/** Partial representation encoder only: scalar Text/Field.name, arbitrary explicit Utf16Text units.
 * Representation exceptions are not an ECS refusal or a new adapter contract. Callers retain original DTO.
 */
export function rawTokens(value) {
  checkedRaw(value);
  const encode = raw => {
    switch(raw.$) {
      case 'Missing':return ['missing'];
      case 'Null':return ['null'];
      case 'Number':return ['number',String(raw.value)];
      case 'SignedInteger':return ['signed',raw.negative?'1':'0',String(raw.magnitude)];
      case 'Float':return ['float',bits(raw.value)];
      case 'Binary64':return ['binary64',String(raw.high),String(raw.low)];
      case 'Text':return ['text',...scalarCodes(raw.value)];
      case 'Utf16Text':return ['utf16',String(raw.units.length),...raw.units.map(String)];
      case 'Boolean':return ['bool',raw.value?'1':'0'];
      case 'Handle':return ['handle',String(raw.namespace),String(raw.id)];
      case 'Array':return ['array',String(raw.items.length),...raw.items.flatMap(encode)];
      case 'Object':return ['object',String(raw.fields.length),...raw.fields.flatMap(field=>[...scalarCodes(field.name),...encode(field.value)])];
      default:throw new TypeError('unreachable checked Raw constructor');
    }
  };
  return encode(value);
}
/** No child runner here. The admitted existing collector supplies the runtime argv for generated JS/Native. */
export function runtimeInvocation(schema,boundary,input,ecsSchema,operation) {
  if(!['First','Second'].includes(ecsSchema)||!['spawn','insert','failure','failed-insert','skip','resource','failed-resource'].includes(operation))throw new TypeError('unknown declared runtime route');
  const result=typedRawConstructor(schema,boundary).result(input);
  return result.ok
    ? {host:result,argv:[ecsSchema,operation,...rawTokens(result.value)]}
    : {host:result,argv:null};
}
/** Lossless observation wire decoding; strict whole typed comparison remains collector responsibility. */
export function decodeObservation(value) {
  if(Array.isArray(value))return value.map(decodeObservation);
  if(value===null||typeof value!=='object')return value;
  if(Object.hasOwn(value,'$codepoints')) {
    if(Object.keys(value).length!==1||!Array.isArray(value.$codepoints))throw new TypeError('invalid codepoint wire');
    for(const code of value.$codepoints)if(!Number.isInteger(code)||code<0||code>0x10ffff||(code>=0xd800&&code<=0xdfff))throw new TypeError('invalid scalar wire');
    return value.$codepoints.map(code=>String.fromCodePoint(code)).join('');
  }
  if(Object.hasOwn(value,'$f32Bits')) {
    if(Object.keys(value).length!==1||!Number.isInteger(value.$f32Bits)||value.$f32Bits<0||value.$f32Bits>0xffffffff)throw new TypeError('invalid F32 bit wire');
    const view=new DataView(new ArrayBuffer(4));view.setUint32(0,value.$f32Bits,false);return view.getFloat32(0,false);
  }
  return Object.fromEntries(Object.entries(value).map(([key,v])=>[key,decodeObservation(v)]));
}
