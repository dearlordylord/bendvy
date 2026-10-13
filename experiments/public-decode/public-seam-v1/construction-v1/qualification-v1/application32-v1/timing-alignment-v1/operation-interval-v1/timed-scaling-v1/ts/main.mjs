import { run as commonReport } from '../../../common-reference.mjs';
import * as Clock from '../../timed-v5/ts/timing.mjs';

const selected = process.argv.at(-1);
const repetitions = new Map([['1', 1], ['2', 2], ['4', 4]]).get(selected);
if (repetitions === undefined) throw new Error('repetitions must be 1, 2, or 4');

Clock.reset();
for (let index = 0; index < repetitions; index += 1) {
  Clock.begin(index);
  Clock.capture(commonReport());
  Clock.end();
}
Clock.finish(repetitions);
