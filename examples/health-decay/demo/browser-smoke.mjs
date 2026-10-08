// Optional UI check using an already installed Playwright package.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
const playwright = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const {chromium} = playwright.default || playwright;
const root = fileURLToPath(new URL('.', import.meta.url));
const server = createServer(async (req, res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  const target = path.resolve(root, '.' + pathname);
  if (target !== path.resolve(root) && !target.startsWith(root)) {
    res.writeHead(403).end();
    return;
  }
  const file = target === path.resolve(root) ? path.join(root, 'index.html') : target;
  try {
    const data = await readFile(file);
    res.setHeader('Content-Type', file.endsWith('.html') ? 'text/html' : file.endsWith('.mjs') ? 'text/javascript' : 'application/octet-stream');
    res.end(data);
  } catch { res.writeHead(404).end(); }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
let browser;
try {
  browser = await chromium.launch({headless: true, args: ['--no-sandbox']});
  const page = await browser.newPage({viewport: {width: 1000, height: 1000}});
  page.setDefaultTimeout(5000);
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  await page.waitForFunction(() => document.querySelector('#tick').textContent === 'Tick 0');
  assert.equal(await page.locator('article').count(), 3);
  assert.equal(await page.locator('article.skipped').count(), 1);
  await page.locator('#step').click();
  await page.waitForFunction(() => document.querySelector('#tick').textContent === 'Tick 1');
  assert.deepEqual(await page.locator('progress').evaluateAll(bars => bars.map(bar => bar.value)), [5,5,30]);
  await page.locator('#step').click();
  assert.deepEqual(await page.locator('progress').evaluateAll(bars => bars.map(bar => bar.value)), [2.5,1.25,30]);
  if (process.argv[2]) await page.screenshot({path: process.argv[2], fullPage: true});
  await page.locator('#reset').click();
  await page.waitForFunction(() => document.querySelector('#tick').textContent === 'Tick 0');
  assert.deepEqual(await page.locator('progress').evaluateAll(bars => bars.map(bar => bar.value)), [10,20,30]);
  assert.equal(await page.locator('#error').isVisible(), false);
  assert.deepEqual(errors, []);
  console.log('Browser module, three cards, two ticks and reset: OK');
} finally {
  if (browser) await browser.close();
  await new Promise(resolve => server.close(resolve));
}
