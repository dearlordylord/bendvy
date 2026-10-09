const profSession=new (require('node:inspector').Session)();profSession.connect();
const profPost=(method,params={})=>new Promise((resolve,reject)=>profSession.post(method,params,(error,result)=>error?reject(error):resolve(result)));
const profExit=process.exit;let profZero=0,profInvocations=0;
let profPrimary=null,profApplicationError=null;
const profCleanupErrors=[];
process.exit=code=>{if(code!==0)throw Error('nonzero application exit:'+code);profZero++;};
(async()=>{
  let profStarted=false,profResult=null;
  const profRemember=error=>{if(profPrimary===null)profPrimary=error;else profCleanupErrors.push(error);};
  try {
    __PROFILE_START__
    profStarted=true;
    profInvocations++;
    __APP_INVOCATION__
    if(profZero!==1)throw Error('expected one completed invocation');
  } catch(error) {
    profApplicationError=error;profRemember(error);
  } finally {
    if(profStarted) {
      try { __PROFILE_STOP__ } catch(error) { profRemember(error); }
      if(profResult && profResult.profile) {
        try {
          require('node:fs').writeFileSync(__PROFILE_PATH_JSON__,JSON.stringify({profile:profResult.profile,zeroExits:profZero,invocations:profInvocations,mode:__PROFILE_MODE_JSON__,applicationError:profApplicationError===null?null:String(profApplicationError)}),{flag:'wx',mode:0o600});
        } catch(error) { profRemember(error); }
      }
    }
    try { profSession.disconnect(); } catch(error) { profRemember(error); }
    process.exit=profExit;
  }
  if(profPrimary!==null)throw profPrimary;
})().catch(error=>{
  console.error(error);
  for(const cleanup of profCleanupErrors)console.error('Profile cleanup:',cleanup);
  profExit(1);
});
