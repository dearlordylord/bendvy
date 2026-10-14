// Run distinct emitted executable modules in one host realm, retaining each
// module's private effect registry and actual IO main. Only successful process
// termination is converted to return so the next ordinary main can execute.
const fs = require("node:fs");
const vm = require("node:vm");
for (const filename of process.argv.slice(2)) {
  const source = fs.readFileSync(filename, "utf8");
  const hostProcess = Object.create(process);
  hostProcess.argv = [process.execPath, filename];
  hostProcess.exit = code => {
    if (code !== 0) throw new Error(`emitted module exit ${code}`);
  };
  const moduleBody = vm.runInThisContext(
    `(function(require,process){\n${source}\n})`, { filename }
  );
  moduleBody(require, hostProcess);
}
