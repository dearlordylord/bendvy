import * as fs from 'node:fs';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import * as Comp from './cost-comp.ts';
import * as Cost from './cost.mjs';
import {joined,templateInstances} from '/workspace/formal-proofs/bendvy/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/provenance-v1/book-provenance.mjs';
import {publish} from '/workspace/formal-proofs/bendvy/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/provenance-v1/publish-provenance.mjs';
import {createHash} from 'node:crypto';
const [entry,output,costPath]=process.argv.slice(2);
if(!entry||!output||!costPath||[output,costPath].some(path=>fs.existsSync(path)))throw new Error('entry and absent artifacts required');
const book=Bend.book_nil(),seen=new Map<string,string|null>(),declarations=[];
let primary,failed=false;
try{
 await Bend.book_load(book,entry,'',seen);
 Bend.book_valid(book);if(book.hols)throw new Error('incomplete source');
 Cost.arm(25000);
 const result=Comp.compile_book(book);
 const fd=fs.openSync(output,fs.constants.O_WRONLY|fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_NOFOLLOW,0o600);
 try{if(!fs.fstatSync(fd).isFile())throw new Error('C descriptor not regular');fs.writeFileSync(fd,result);fs.fsyncSync(fd);}finally{fs.closeSync(fd);}
}catch(error){failed=true;primary=error;}
finally{
 try{
  for(const [source,namespace]of seen){
   if(namespace===null)throw new Error('incomplete loaded namespace');
   const bytes=fs.readFileSync(source),sourceSHA256=createHash('sha256').update(bytes).digest('hex');
   bytes.toString().split('\n').forEach((line,index)=>{const m=/^def ([A-Za-z_][A-Za-z_0-9.]*)/.exec(line);if(m)declarations.push({source,definition:m[1],line:index+1,sourceSHA256});});
  }
  const observed=Cost.snapshot();
  publish(costPath,{observed,mapping:observed.rows.map(row=>joined(row.key,book,seen,declarations)),loaded:[...seen],templateInstances:templateInstances(book),bookDefinitions:Object.entries(book.tlds).map(([key,value])=>({key,tag:value.$,namespace:value.m ?? null})),compilerCompleted:!failed,primaryError:failed?String(primary):null});
 }catch(error){console.error('COST_PUBLICATION_ERROR '+String(error));if(!failed)throw error;}
}
if(failed)throw primary;
