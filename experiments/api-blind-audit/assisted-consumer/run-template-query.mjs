import App from './template-query.mjs';
const value = App.main();
console.log(JSON.stringify(value));
if (value.$ !== 'Con' || value.head !== 3 || value.tail.$ !== 'Nil') process.exit(1);
