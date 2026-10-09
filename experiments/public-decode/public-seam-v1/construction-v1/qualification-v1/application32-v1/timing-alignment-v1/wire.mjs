// Exact pure String display framing. Physical/supplement captures are separate.
export function bendPublicWire(bytes){
 const raw=new TextDecoder('utf-8',{fatal:true}).decode(bytes);
 if(!raw.endsWith('\n')||raw.endsWith('\n\n'))throw Error('expected one external LF');
 const text=JSON.parse(raw.slice(0,-1));
 if(typeof text!=='string'||text==='SERIALIZATION_INCOMPLETE')throw Error('expected complete Bend String');
 const value=JSON.parse(text);
 if(!Array.isArray(value)||value.length!==32)throw Error('expected complete32');
 return {raw,text,value};
}
export function tsPublicWire(bytes){
 const raw=new TextDecoder('utf-8',{fatal:true}).decode(bytes);
 const text=raw.endsWith('\n')?raw.slice(0,-1):raw;
 const value=JSON.parse(text);
 if(!Array.isArray(value)||value.length!==32)throw Error('expected complete32');
 return {raw,text,value};
}
