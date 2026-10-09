// Exact Book namespace + declared-source join; never infer a generated key.
export function joined(definition, book, seen, declarations) {
 const tld=book.tlds[definition];
 if(!tld || tld.$!=='Def')return {definition,status:'not-declared'};
 const ns=tld.m;
 if(typeof ns!=='string')return {definition,status:'missing-namespace'};
 const local=ns===''?definition:definition.startsWith(ns+':')?definition.slice(ns.length+1):null;
 if(local===null)return {definition,status:'namespace-mismatch',namespace:ns};
 const files=[...seen].filter(([,namespace])=>namespace===ns).map(([path])=>path);
 const rows=declarations.filter(row=>files.includes(row.source)&&row.definition===local);
 if(rows.length!==1)return {definition,status:rows.length?'ambiguous-source':'no-lexical-source',namespace:ns,files};
 const row=rows[0];
 return {definition,status:'mapped',namespace:ns,localName:row.definition,source:row.source,line:row.line,sourceSHA256:row.sourceSHA256};
}
