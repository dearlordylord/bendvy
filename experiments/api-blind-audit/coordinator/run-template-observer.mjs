import App from './template-observer.mjs';
const v=App.main();
console.log(JSON.stringify(v));
if(v.$!=='Con'||v.head!==3||v.tail.$!=='Nil')process.exit(1);
