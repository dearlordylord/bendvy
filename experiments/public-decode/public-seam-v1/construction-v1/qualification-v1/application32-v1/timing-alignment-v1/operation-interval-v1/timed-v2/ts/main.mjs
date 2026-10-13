// One whole fresh 32-case lifecycle. Imports are outside; prepare, all
// applications, the common observer and report materialization are inside.
import { run as commonReport } from '../../../common-reference.mjs';
import * as Clock from './timing.mjs';

Clock.reset();
Clock.begin(0);
Clock.capture(commonReport());
Clock.end();
Clock.finish(1);
