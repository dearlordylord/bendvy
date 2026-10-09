/** JS host adapter. World-facing input/output/error cross a checked Raw DTO. */
const asyncIssue = [{message: 'Asynchronous validation is not supported: descriptor constructors run synchronously'}];
export function fromStandardSchema(schema) {
  const validate = raw => {
    const result = schema['~standard'].validate(raw);
    if (result instanceof Promise) {
      result.catch(() => {});
      return {ok: false, error: asyncIssue};
    }
    return result.issues === undefined
      ? {ok: true, value: result.value}
      : {ok: false, error: result.issues};
  };
  return {result: validate, decode: validate};
}
export function constructorDecoderOf(constructor) {
  return typeof constructor.decode === 'function' ? constructor.decode : constructor.result;
}
const shape = (value, keys) => {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) throw new TypeError('Raw record required');
  if (![Object.prototype, null].includes(Object.getPrototypeOf(value))) throw new TypeError('Raw record prototype');
  const own = Reflect.ownKeys(value);
  if (own.length !== keys.length || keys.some(key => !own.includes(key))) throw new TypeError('Raw record fields');
  for (const key of keys) if (!Object.hasOwn(Object.getOwnPropertyDescriptor(value,key),'value')) throw new TypeError('Raw accessor refused');
};
const uint = n => {
  if (!Number.isInteger(n) || n < 0 || n > 0xffffffff) throw new TypeError('Raw U32 required');
};
const list = (values, visit) => {
  if (!Array.isArray(values)) throw new TypeError('Raw list required');
  for (let n=0; n<values.length; n++) {
    const property=Object.getOwnPropertyDescriptor(values,String(n));
    if (!property || !Object.hasOwn(property,'value')) throw new TypeError('Raw sparse/accessor list refused');
    visit(property.value);
  }
  if (Reflect.ownKeys(values).length !== values.length + 1) throw new TypeError('Raw extra list fields');
};
/** Exhaustive representation guard, not the authored component's Decode codec. */
export function checkedRaw(raw) {
  const active=new Set();
  const walk = value => {
    if (active.has(value)) throw new TypeError('cyclic Raw refused');
    active.add(value);
    const tag=Object.getOwnPropertyDescriptor(value ?? {},'$');
    if (!tag || !Object.hasOwn(tag,'value')) throw new TypeError('Raw tag required');
    switch (tag.value) {
      case 'Missing': case 'Null': shape(value,['$']); break;
      case 'Number': shape(value,['$','value']); uint(value.value); break;
      case 'SignedInteger':
        shape(value,['$','negative','magnitude']);
        if (typeof value.negative !== 'boolean' || !Number.isSafeInteger(value.magnitude) || value.magnitude<0 || value.magnitude>2**48-1) throw new TypeError('Raw signed Nat required');
        break;
      case 'Float':
        shape(value,['$','value']);
        if (typeof value.value !== 'number' || !Object.is(Math.fround(value.value),value.value)) throw new TypeError('Raw F32 required');
        break;
      case 'Binary64': shape(value,['$','high','low']); uint(value.high);uint(value.low); break;
      case 'Text': shape(value,['$','value']); if(typeof value.value!=='string') throw new TypeError('Raw string required'); break;
      case 'Utf16Text': shape(value,['$','units']); list(value.units,uint); break;
      case 'Boolean': shape(value,['$','value']); if(typeof value.value!=='boolean') throw new TypeError('Raw boolean required'); break;
      case 'Handle': shape(value,['$','namespace','id']);uint(value.namespace);uint(value.id);break;
      case 'Array': shape(value,['$','items']);list(value.items,walk);break;
      case 'Object':
        shape(value,['$','fields']);
        list(value.fields,field=>{shape(field,['$','name','value']);if(field.$!=='Field'||typeof field.name!=='string') throw new TypeError('Raw field required');walk(field.value);});
        break;
      default: throw new TypeError('unknown Raw constructor');
    }
    active.delete(value);
  };
  walk(raw);
  return raw;
}
const detached = raw => {
  const value=structuredClone(checkedRaw(raw));
  const freeze = object => {if(object&&typeof object==='object'){for(const value of Object.values(object))freeze(value);Object.freeze(object);}return object;};
  return freeze(value);
};
/** Encoders are explicit trusted author providers; no implicit unknown→World. */
export function typedRawConstructor(schema, boundary) {
  const host=fromStandardSchema(schema);
  const decode = input => {
    const original=detached(input);
    const result=constructorDecoderOf(host)(boundary.input(original));
    return result.ok
      ? {ok:true,value:detached(boundary.output(result.value))}
      : {ok:false,input:original,error:detached(boundary.issues(result.error)),issues:result.error};
  };
  return {result:decode,decode};
}
