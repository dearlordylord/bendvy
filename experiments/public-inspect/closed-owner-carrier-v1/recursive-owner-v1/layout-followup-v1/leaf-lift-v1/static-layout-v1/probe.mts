import * as fs from 'node:fs';
import * as Bend from '/workspace/formal-proofs/bendvy-worktrees/parity-54-boxed-scan/experiments/public-inspect/closed-owner-carrier-v1/schema-partition-v1/garden-reference-diagnostic-v1/bend.ts';
import {initial_layout_probe} from './probe-comp.ts';
import {publish} from '../../provenance-v1/publish-provenance.mjs';
import {joined,templateInstances} from '../../provenance-v1/book-provenance.mjs';
import {createHash} from 'node:crypto';
const [entry,artifact]=process.argv.slice(2);
if(!entry||!artifact||fs.existsSync(artifact))throw new Error('entry/absent output required');
const book=Bend.book_nil(),seen=new Map<string,string|null>();
await Bend.book_load(book,entry,'',seen);
Bend.book_valid(book);if(book.hols)throw new Error('incomplete Book');
const names=['inspect_target','check_target','inspect_unpack','check_unpack','inspect_packed','check_packed','inspect_unpacked','check_unpacked','inspect_read','check_read','inspect_joined','check_joined','inspect_matches','check_matches','inspect_filter','check_filter','pair_matches_target','pair_project_target'];
const initial=initial_layout_probe(book,names),declarations=[];
for(const [source,namespace]of seen){
 if(namespace===null)throw new Error('missing namespace');
 const bytes=fs.readFileSync(source),sourceSHA256=createHash('sha256').update(bytes).digest('hex');
 bytes.toString().split('\n').forEach((line,index)=>{const m=/^def ([A-Za-z_][A-Za-z_0-9]*)/.exec(line);if(m)declarations.push({source,definition:m[1],line:index+1,sourceSHA256});});
}
publish(artifact,{initial,mapping:initial.selected.map(row=>joined(row.key,book,seen,declarations)),loaded:[...seen],templateInstances:templateInstances(book),requestedNames:names,bookDefinitions:Object.entries(book.tlds).map(([key,value])=>({key,tag:value.$,namespace:value.m ?? null}))});
