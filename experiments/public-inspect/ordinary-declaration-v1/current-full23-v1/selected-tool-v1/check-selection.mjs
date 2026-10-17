import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=new URL('.',import.meta.url),spec=JSON.parse(fs.readFileSync(new URL('RECIPE.json',here),'utf8'));
const sha=x=>createHash('sha256').update(x).digest('hex');
const elf=fs.readFileSync(spec.elf);assert.equal(sha(elf),spec.elfSHA256);
const prefix=Buffer.from(spec.embeddedPrefixHex,'hex');const at=elf.indexOf(prefix);assert(at>=0);assert.equal(elf.indexOf(prefix,at+1),-1);
const original=elf.subarray(at,at+spec.originalBytes);assert.equal(sha(original),spec.originalSHA256);
let selected=original.toString();for(const p of spec.patches){assert.equal(selected.split(p.original).length-1,1);selected=selected.replace(p.original,p.replacement);}
assert.equal(sha(selected),spec.selectedCLISHA256);assert.equal(fs.readFileSync(new URL('prepared/compiler/cli.mjs',here),'utf8'),selected);
for(const p of [...spec.patches].reverse()){assert.equal(selected.split(p.replacement).length-1,1);selected=selected.replace(p.replacement,p.original);}assert.equal(selected,original.toString());
for(const name of spec.resourceAliases)assert.equal(fs.realpathSync(new URL('prepared/compiler/'+name,here)),fs.realpathSync(spec.resourceRoot+'/'+name));
const wrapper=fs.readFileSync(new URL('bend',here),'utf8');assert(wrapper.includes('unset BUN_OPTIONS BUN_BE_BUN'));assert(wrapper.includes('export BUN_BE_BUN=1'));assert(wrapper.includes('exec '+spec.elf+' "$cli" "$@"'));assert(wrapper.includes('version|--version) exec '+spec.elf+' "$@"'));
const config=JSON.parse(fs.readFileSync(new URL('SUCCESSOR-CONFIG.json',here),'utf8'));assert.equal(config.tools.bend,fs.realpathSync(new URL('bend',here)));assert.equal(config.tools.bendElf,spec.elf);assert.equal(config.discoveryTools.bend,spec.elf);assert.equal(config.selection.cliSHA256,spec.selectedCLISHA256);
for(const b of config.toolAndReachedLinkBindings)assert.equal(sha(fs.readFileSync(b.resolved)),b.sha256);
console.log(JSON.stringify({status:'PROJECT_LOCAL_SELECTION_SOURCE_CONTROL_PASS',inversePatches:spec.patches.length,samePinnedELF:true,wrapperAndCLIInputsPinned:true,underlyingELFDiscovery:true,resourceAliases:true,limits:'Offline source/wiring control, not actual selected-wrapper execution or adoption.'}));
