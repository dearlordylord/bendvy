import {application} from '../ts-semantic-v1/stage-v1/reference.mjs';
import {timed} from '../../../../../benchmarks/parity-features/capture.mjs';
await timed(() => console.log(JSON.stringify(application())));
