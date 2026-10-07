import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']){
 let calls=0;const Score=D.Resource()('Score');const G=Schema.bind(Schema.empty(),Schema.defineRoot(root));
 try{const bad=G.System('undeclared',{resources:{score:G.System.writeResource(Score)}},({resources})=>{resources.score.get();calls++;});const rt=G.Runtime.make({services:G.Runtime.services()});const result=rt.tick(G.Schedule(bad));console.log(JSON.stringify({root,ok:result.ok,calls}));}
 catch(e){if(e.message==='undeclared accepted')throw e;}
 
}
