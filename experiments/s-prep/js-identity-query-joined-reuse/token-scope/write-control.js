function writeToken(token){token.$='changed';return 1;}
console.log(writeToken({$:'types.PositionToken'}));
