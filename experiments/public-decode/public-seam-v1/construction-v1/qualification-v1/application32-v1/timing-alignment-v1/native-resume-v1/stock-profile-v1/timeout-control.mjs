// Profiler flush capability only; never used as the compiler workload.
const until = Date.now() + 10000;
let value = 1;
while (Date.now() < until) value = Math.imul(value + 1, 17);
console.log(value);
