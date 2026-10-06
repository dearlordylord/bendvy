import { pathToFileURL } from 'node:url';
const program = (await import(pathToFileURL(process.argv[2]).href)).default;
function normalize(value) {
  if (typeof value === 'number') return value;
  if (value?.$ === 'Nil') return [];
  if (value?.$ === 'Con') {
    const values = [];
    let cursor = value;
    while (cursor.$ === 'Con') {
      values.push(normalize(cursor.head));
      cursor = cursor.tail;
    }
    if (cursor.$ !== 'Nil') throw new Error('Unexpected list tail');
    return values;
  }
  throw new Error(`Unexpected value: ${JSON.stringify(value)}`);
}
console.log(JSON.stringify(normalize(program.main())));
