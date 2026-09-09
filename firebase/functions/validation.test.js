const {test}=require('node:test');
const assert=require('node:assert/strict');
const {plausible}=require('./validation');
const run={rawTaps:100,score:100,durationMs:20000,mode:'casual',reviveCount:0};
test('normal run passes plausibility',()=>assert.equal(plausible(run),true));
test('fabricated high rate fails',()=>assert.equal(plausible({...run,rawTaps:9000}),false));
test('fabricated multiplier fails',()=>assert.equal(plausible({...run,score:9999}),false));
test('revive remains distinct',()=>assert.equal(plausible({...run,reviveCount:2}),false));
