import {application} from "./reference.mjs";
import {timed} from "/workspace/formal-proofs/bendvy/benchmarks/parity-features/capture.mjs";
await timed(() => {
 console.log(JSON.stringify(application()));
 console.log(JSON.stringify(application()));
});
