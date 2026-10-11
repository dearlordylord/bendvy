"use strict";
const inspector = require("node:inspector");
const fs = require("node:fs");
const session = new inspector.Session();
session.connect();
function post(method, params) {
  let completed = false, failure, result;
  session.post(method, params, (error, value) => { completed = true; failure = error; result = value; });
  if (!completed) throw Error("region profiler response was not synchronous: " + method);
  if (failure) throw failure;
  return result;
}
post("Profiler.enable", {});
post("Profiler.setSamplingInterval", {interval: 100});
let active = false, finished = false;
exports.begin = function() {
  if (active || finished) throw Error("region profiler begins exactly once");
  post("Profiler.start", {});
  active = true;
};
exports.end = function() {
  if (!active || finished) throw Error("region profiler ends exactly once after begin");
  const result = post("Profiler.stop", {});
  active = false; finished = true;
  if (!result || !result.profile) throw Error("region profiler returned no complete profile");
  fs.writeFileSync("/workspace/formal-proofs/bendvy-worktrees/ordinary-custom-store-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/cpu11-v1/region-cpu-v1/actual01/region.cpuprofile", JSON.stringify(result.profile), {flag: "wx"});
  session.disconnect();
};
