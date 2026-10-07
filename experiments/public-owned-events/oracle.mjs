const payload=(id,mutated=false)=>({id,cells:mutated?[11,99]:[id*10+1,id*10+2],nested:{text:mutated?'publisher-mutated':'event-'+id}});
const read=(reader,values=[])=>({reader,lagged:false,values,identity:values.map(()=>({payload:true,cells:true,nested:true})),sameBatch:true,readCanEmit:false});
export function expected(){return ['OwnedAlpha','OwnedBeta'].flatMap(root=>[
 {root,label:'registered-empty',calls:[read('fast'),read('slow')]},
 {root,label:'fast-shared-payload',calls:[read('fast',[payload(1,true)])]},
 {root,label:'fast-repeat',calls:[read('fast')]},
 {root,label:'slow-independent',calls:[read('slow',[payload(1,true)])]},
 {root,label:'fast-failed',calls:[read('fast',[payload(2)])]},
 {root,label:'fast-retry',calls:[read('fast',[payload(2)])]},
 {root,label:'slow-condition-skipped',calls:[]},
 {root,label:'slow-resume-discards',calls:[read('slow')]},
 {root,label:'other-runtime-empty',calls:[read('fast')]},
 {root,label:'undeclared',calls:[{reader:'undeclared',hasPing:false}]},
 {root,label:'unheld-initial',calls:[{values:[],lagged:false}]},
 {root,label:'default-window-trim',calls:[{values:[],lagged:true}]},
 {root,label:'public-disposal-api',calls:[{runtimeDispose:false,runtimeUnregister:false,streamClear:false}]},
 {root,label:'erased-cross-schema',calls:[read('foreign')]}
]);}
