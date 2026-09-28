// Uses an externally installed Playwright via NODE_PATH; never a production dependency.
const {chromium}=require('playwright');
const fs=require('fs');
const path=require('path');
const scenarios=['01_main_menu','02_casual_gameplay','03_transition_warning','04_target_mode','05_game_over','06_campaign_map','07_chaos_entry','08_profile','09_settings','10_leaderboards'];
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH||'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',args:['--disable-gpu-sandbox']});
 const context=await browser.newContext({viewport:{width:390,height:844},deviceScaleFactor:1});
 const errors=[];
 for(const scenario of scenarios){
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push({scenario,error:e.message}));
  await page.goto(`http://127.0.0.1:8765/?ui=${scenario}`,{waitUntil:'networkidle'});
  await page.locator('flutter-view').waitFor();
  await page.waitForTimeout(1400);
  await page.screenshot({path:path.join('docs/ui-review/screenshots',`${scenario}.png`)});
  console.log(`Captured ${scenario}`);
  await page.close();
 }
 fs.writeFileSync('docs/ui-review/browser-errors.json',JSON.stringify(errors,null,2));
 await browser.close();
 if(errors.length)process.exitCode=1;
})();
