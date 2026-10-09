// Exact Book namespace + declared-source join; never infer a generated key.
export function joined(definition, book, seen, declarations) {
 let originTemplate;
 let tld=book.tlds[definition];
 if(!tld || tld.$!=='Def')return {definition,status:'not-declared'};
 if(typeof tld.m!=='string') {
  const origins=Object.entries(book.tmps ?? {}).filter(([,instances]) => instances instanceof Map && [...instances.values()].includes(definition)).map(([key]) => key);
  if(origins.length>1)return {definition,status:'ambiguous-template',originTemplates:origins};
  if(origins.length===1) {originTemplate=origins[0];tld=book.tlds[originTemplate];}
 }
 const origin=originTemplate===undefined?{}:{originTemplate};
 if(!tld || tld.$!=='Def')return {definition,status:'missing-template-definition',...origin};
 const sourceKey=originTemplate ?? definition;
 const ns=tld.m;
 if(typeof ns!=='string')return {definition,status:'missing-namespace',...origin};
 const local=ns===''?sourceKey:sourceKey.startsWith(ns+':')?sourceKey.slice(ns.length+1):null;
 if(local===null)return {definition,status:'namespace-mismatch',namespace:ns,...origin};
 const files=[...seen].filter(([,namespace])=>namespace===ns).map(([path])=>path);
 const rows=declarations.filter(row=>files.includes(row.source)&&row.definition===local);
 if(rows.length!==1)return {definition,status:rows.length?'ambiguous-source':'no-lexical-source',namespace:ns,files,...origin};
 const row=rows[0];
 return {definition,status:'mapped',namespace:ns,localName:row.definition,source:row.source,line:row.line,sourceSHA256:row.sourceSHA256,...origin};
}

// def_inst registers the exact generated key as each Map value; no suffix guessing.
export function templateInstances(book) {
 return Object.entries(book.tmps ?? {}).map(([template,instances]) => {
  if(!(instances instanceof Map))throw new Error('template instance registry is not a Map');
  const values=[...new Set(instances.values())];
  if(values.some(value=>typeof value!=='string'))throw new Error('invalid template instance key');
  return {template,instances:values};
 });
}
