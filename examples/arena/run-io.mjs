export function runIO(action) {
  let value;
  let operation = action(result => { value = result; });
  while (operation !== undefined) {
    if (operation.$ === '$JMP') {
      operation = operation.f(...operation.x);
    } else if (operation.$ === '$FFI') {
      const result = operation.run(...operation.args, operation.kont);
      operation = result === undefined ? undefined : operation.kont(result);
    } else if (operation.$ === 'Halt') {
      throw new Error(operation.message);
    } else {
      throw new Error('Unexpected compiled IO operation');
    }
  }
  return value;
}
