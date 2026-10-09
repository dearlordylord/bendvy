import * as fs from 'node:fs';
import * as Bend from '/tmp/bendvy-outline-once-runtime-controls02/compiler/bend.ts';
import * as Comp from '/tmp/bendvy-outline-once-runtime-controls02/compiler/comp.ts';
const [entry,output]=process.argv.slice(2);
if(!entry||!output||fs.existsSync(output))throw new Error('entry and absent output required');
const book=Bend.book_nil(),seen=new Map<string,string|null>();
await Bend.book_load(book,entry,'',seen);Bend.book_valid(book);if(book.hols)throw new Error('incomplete source');
const text=Comp.compile_book(book),fd=fs.openSync(output,fs.constants.O_WRONLY|fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_NOFOLLOW,0o600);
try{if(!fs.fstatSync(fd).isFile())throw new Error('C descriptor not regular');fs.writeFileSync(fd,text);fs.fsyncSync(fd);}finally{fs.closeSync(fd);}
