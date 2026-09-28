// Records genuine pointer-downs on a production Campaign run with isolated debug storage.
const {chromium}=require('playwright');
const fs=require('fs');
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH||'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'});
 const context=await browser.newContext({viewport:{width:390,height:844},deviceScaleFactor:1,recordVideo:{dir:'docs/ui-review/recordings',size:{width:390,height:844}}});
 const page=await context.newPage();
 await page.goto('http://127.0.0.1:8765/?ui=01_main_menu',{waitUntil:'networkidle'});
 await page.waitForTimeout(1200);
 await page.mouse.click(195,425);
 await page.waitForTimeout(200);
 await page.screenshot({path:'docs/ui-review/recordings/campaign-before.png'});
 await page.mouse.click(190,140);
 await page.waitForTimeout(200);
 await page.screenshot({path:'docs/ui-review/recordings/stages-before.png'});
 await page.mouse.click(195,409);
 // Arena top150, height536 at390×844; shared core seeded42 geometry.
 await page.waitForTimeout(90);
 for(let i=0;i<4;i++){await page.mouse.click(195,514);await page.waitForTimeout(210);}
 await page.screenshot({path:'docs/ui-review/recordings/preview-three.png'});
 for(let i=0;i<3;i++){await page.mouse.click(195,514);await page.waitForTimeout(240);}
 await page.screenshot({path:'docs/ui-review/recordings/activated.png'});
 for(let i=0;i<4;i++){await page.mouse.click(154,311);await page.waitForTimeout(220);}
 await page.screenshot({path:'docs/ui-review/recordings/next-preview.png'});
 for(let i=0;i<3;i++){await page.mouse.click(154,311);await page.waitForTimeout(240);}
 for(let i=0;i<3;i++){await page.mouse.click(207,525);await page.waitForTimeout(230);}
 await page.mouse.click(348,54);
 await page.waitForTimeout(700);
 await page.close();
 const video=await page.video().path();
 fs.renameSync(video,'docs/ui-review/recordings/preview-switch-active.webm');
 await browser.close();
 console.log('Recorded live preview → switch → active input, then paused.');
})();
