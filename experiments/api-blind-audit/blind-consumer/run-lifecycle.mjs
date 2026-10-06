import App from './lifecycle.mjs';
const value = App.main();
console.log(JSON.stringify(value));
if (value.$ !== 'Con' || value.head !== 5 || value.tail.$ !== 'Nil') process.exit(1);
