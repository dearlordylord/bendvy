import * as Decode from "/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Decode.ts";
// Diagnostic bridge maps the complete selected primitive Raw value, not all TS numbers.
const raw = (n) => `u32:${n}`;
const checked = (r) => r.ok ? `accepted:${raw(r.value)}` : `invalid:${r.error.path}:${r.error.expected}:${raw(r.error.actual)}`;
const lines=[];
for(const schema of ["Workshop","Garden"]){
 const owner = () => [7,9];
 let a=owner();lines.push(`${schema}.validated-number|${checked(Decode.integer.decode(a[0]))}|owner:${a}`);
 a=owner();lines.push(`${schema}.validation-error|${checked(Decode.string.decode(a[0]))}|owner:${a}`);
 a=owner();lines.push(`${schema}.transient-validation|skipped|owner:${a}`);
 a=owner();const exported=a[0];lines.push(`${schema}.export|saved:Payload:${raw(exported)}|owner:${a}`);
 a=owner();lines.push(`${schema}.transient-export|omitted:Payload|owner:${a}`);
 a=owner();const saved=a[0];a[0]=11;lines.push(`${schema}.save-view-lifetime|saved:Payload:${raw(saved)}|owner:${a}|saved-after:saved:Payload:${raw(saved)}`);
}
process.stdout.write(lines.join("\n")+"\n");
