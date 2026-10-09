let deadline = Infinity;
export class DiagnosticAbort extends Error {
  constructor() { super('cooperative profiling cutoff'); this.name = 'DiagnosticAbort'; }
}
export function armBudget(milliseconds) { deadline = Date.now() + milliseconds; }
export function checkBudget() { if (Date.now() >= deadline) throw new DiagnosticAbort(); }
