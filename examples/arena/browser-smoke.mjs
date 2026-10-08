// Optional browser check. Reuse an installed Playwright; do not install packages.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
const playwright=await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const {chromium}=playwright.default || playwright;
const root=fileURLToPath(new URL('.',import.meta.url));
const server=createServer(async(req,res)=>{
  const target=path.resolve(root,'.'+decodeURIComponent(new URL(req.url,'http://localhost').pathname));
  if(target!==path.resolve(root)&&!target.startsWith(root)){res.writeHead(403).end();return;}
  const file=target===path.resolve(root)?path.join(root,'index.html'):target;
  try {
    const data=await readFile(file);
    res.setHeader('Content-Type',file.endsWith('.html')?'text/html':file.endsWith('.mjs')?'text/javascript':'application/octet-stream');
    res.end(data);
  } catch {res.writeHead(404).end();}
});
await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
let browser;
try {
  browser=await chromium.launch({headless:true,args:['--no-sandbox']});
  const page=await browser.newPage({viewport:{width:1000,height:820}});
  const errors=[];
  page.on('pageerror',error=>errors.push(error.message));
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('Health 5/5'));
  async function playerX() {
    return page.evaluate(()=>{
      const ctx=document.querySelector('canvas').getContext('2d');
      const data=ctx.getImageData(0,0,800,500).data;
      let sum=0,count=0;
      for(let i=0;i<data.length;i+=4) if(data[i]===103&&data[i+1]===232&&data[i+2]===249){sum+=(i/4)%800;count++;}
      return count?sum/count:null;
    });
  }
  const before=await playerX();
  await page.keyboard.down('ArrowRight');
  await page.waitForFunction(()=>Number(document.querySelector('#status').textContent.match(/([\d.]+)s/)?.[1])>=0.3);
  await page.keyboard.up('ArrowRight');
  assert.ok(await playerX()>before+20,'keyboard must move the rendered ECS player');
  await page.keyboard.press('Space');
  await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('Paused'));
  const paused=await page.locator('#status').textContent();
  await page.waitForTimeout(150);
  assert.equal(await page.locator('#status').textContent(),paused);
  await page.keyboard.press('Space');
  await page.waitForFunction(()=>!document.querySelector('#status').textContent.includes('Paused'));
  await page.locator('#restart').click();
  await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('Gold 0'));
  assert.ok(Math.abs(await playerX()-400)<2,'restart resets the player');
  assert.equal(await page.locator('#error').isVisible(),false);
  assert.deepEqual(errors,[]);
  if(process.argv[2]) await page.screenshot({path:process.argv[2],fullPage:true});
  console.log('Browser smoke passes: module loading, canvas, keyboard movement, pause/resume and restart.');
} finally {
  if(browser) await browser.close();
  await new Promise(resolve=>server.close(resolve));
}
