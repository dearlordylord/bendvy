export type Raw =
  | {readonly $:'Missing'|'Null'}
  | {readonly $:'Number';readonly value:number}
  | {readonly $:'SignedInteger';readonly negative:boolean;readonly magnitude:number}
  | {readonly $:'Float';readonly value:number}
  | {readonly $:'Binary64';readonly high:number;readonly low:number}
  | {readonly $:'Text';readonly value:string}
  | {readonly $:'Utf16Text';readonly units:ReadonlyArray<number>}
  | {readonly $:'Boolean';readonly value:boolean}
  | {readonly $:'Handle';readonly namespace:number;readonly id:number}
  | {readonly $:'Array';readonly items:ReadonlyArray<Raw>}
  | {readonly $:'Object';readonly fields:ReadonlyArray<{readonly $:'Field';readonly name:string;readonly value:Raw}>};
export interface Issue {readonly message:string;readonly path?:ReadonlyArray<PropertyKey|{readonly key:PropertyKey}>}
export interface StandardSchema<Output> {readonly '~standard':{readonly version:1;readonly vendor:string;readonly validate:(value:unknown)=>{readonly value:Output;readonly issues?:undefined}|{readonly issues:ReadonlyArray<Issue>}|Promise<{readonly value:Output;readonly issues?:undefined}|{readonly issues:ReadonlyArray<Issue>}>}}
export type Result<T,E> = {readonly ok:true;readonly value:T}|{readonly ok:false;readonly error:E};
export interface Constructor<T,E> {readonly result:(raw:unknown)=>Result<T,E>;readonly decode:(raw:unknown)=>Result<T,E>}
export function fromStandardSchema<Output>(schema:StandardSchema<Output>):Constructor<Output,ReadonlyArray<Issue>>;
export function constructorDecoderOf<T,E>(constructor:{readonly result:(raw:unknown)=>Result<T,E>;readonly decode?:((raw:unknown)=>Result<T,E>)|undefined}):(raw:unknown)=>Result<T,E>;
export function checkedRaw(raw:unknown):Raw;
export function typedRawConstructor<Output>(schema:StandardSchema<Output>,boundary:{readonly input:(raw:Raw)=>unknown;readonly output:(value:Output)=>Raw;readonly issues:(issues:ReadonlyArray<Issue>)=>Raw}):{readonly result:(raw:Raw)=>Result<Raw,Raw>&{readonly input?:Raw;readonly issues?:ReadonlyArray<Issue>};readonly decode:(raw:Raw)=>Result<Raw,Raw>&{readonly input?:Raw;readonly issues?:ReadonlyArray<Issue>}};
