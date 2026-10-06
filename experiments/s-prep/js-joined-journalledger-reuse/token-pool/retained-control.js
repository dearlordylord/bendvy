function readToken(token){return token.$;}
function reads(){
  const retained={$:'types.PositionToken'};
  const same={$:'types.PositionToken'};
  const opposite={$:'types.VitalsToken'};
  const motionLedger={$:'types.MotionLedgerToken'};
  const healthLedger={$:'types.HealthLedgerToken'};
  return {reads:[readToken(retained),readToken(same),readToken(opposite),readToken(motionLedger),readToken(healthLedger)],sameTag:retained.$===same.$,oppositeTag:retained.$===opposite.$};
}
console.log(JSON.stringify(reads()));
