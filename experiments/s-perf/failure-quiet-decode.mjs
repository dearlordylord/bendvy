import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {decode,fold} from './failure-quiet-codec.mjs';
const lines=readFileSync(process.argv[3],'utf8').split('\n');
const value=prefix=>lines.find(x=>x.startsWith(prefix))?.slice(prefix.length);
const tuple=JSON.parse(value('FAILURE-TUPLE:'));assert.equal(fold(tuple),Number(value('FAILURE-FOLD:')));
console.log(JSON.stringify({...decode(process.argv[2],tuple),elapsed:Number(value('FAILURE-TIMING:')),countLine:value('FAILURE-COUNTS:')??null,captures:value('FAILURE-CAPTURE:')?JSON.parse(value('FAILURE-CAPTURE:')):null}));
