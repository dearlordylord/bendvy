import Game from './dist/game.mjs';

const canvas = document.querySelector('#arena');
const ctx = canvas.getContext('2d');
const status = document.querySelector('#status');
const keys = new Set();
let state, frame, paused = false, accumulator = 0, previous = 0;
const STEP = 1000 / 60;

function accept(packet) {
  if (packet.$ === 'Failed') throw new Error(packet.error);
  if (packet.$ !== 'Packet') throw new Error('Unexpected Bend result');
  // Consume the returned owner; never reuse the previous State.
  state = packet.state;
  frame = JSON.parse(packet.frame);
}
function restart() {
  keys.clear(); paused = false; accumulator = 0; previous = 0;
  accept(Game.start());
  canvas.focus();
  render();
}
function render() {
  ctx.clearRect(0, 0, 800, 500);
  ctx.strokeStyle = '#1e2b3b'; ctx.lineWidth = 1;
  for (let x = 0; x <= 800; x += 40) {
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, 500); ctx.stroke();
  }
  for (let y = 0; y <= 500; y += 40) {
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(800, y); ctx.stroke();
  }
  for (const [x, y, kind] of frame.bodies) {
    ctx.fillStyle = kind === 0 ? '#67e8f9' : kind === 1 ? '#fb7185' : '#facc15';
    ctx.globalAlpha = kind === 0 && frame.cooldown > 0 && frame.tick % 10 < 5 ? .35 : 1;
    ctx.beginPath();
    if (kind === 2) {
      ctx.moveTo(x, y - 7); ctx.lineTo(x + 7, y); ctx.lineTo(x, y + 7); ctx.lineTo(x - 7, y); ctx.closePath();
    } else ctx.arc(x, y, kind === 0 ? 11 : 9, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
  status.textContent = `Health ${frame.hp}/5 · Gold ${frame.score} · ${(frame.tick / 60).toFixed(1)}s${paused ? ' · Paused' : ''}`;
  if (!frame.hp || paused) {
    ctx.fillStyle = '#10151ccc'; ctx.fillRect(0, 0, 800, 500);
    ctx.textAlign = 'center'; ctx.fillStyle = '#eef4ff'; ctx.font = 'bold 32px system-ui';
    ctx.fillText(frame.hp ? 'Paused' : 'Caught!', 400, 235);
    ctx.font = '18px system-ui'; ctx.fillText(frame.hp ? 'Space to resume' : `Gold: ${frame.score} · R to play again`, 400, 275);
  }
}
function fail(error) {
  paused = true;
  const element = document.querySelector('#error');
  element.hidden = false;
  element.textContent = `Could not run the game: ${error.message}`;
}
function animation(now) {
  try {
    if (!previous) previous = now;
    accumulator += Math.min(now - previous, 100);
    previous = now;
    if (paused || !frame.hp) accumulator = 0;
    while (accumulator >= STEP) {
      let dx = Number(keys.has('ArrowRight') || keys.has('KeyD')) - Number(keys.has('ArrowLeft') || keys.has('KeyA'));
      let dy = Number(keys.has('ArrowDown') || keys.has('KeyS')) - Number(keys.has('ArrowUp') || keys.has('KeyW'));
      const length = Math.hypot(dx, dy) || 1;
      accept(Game.advance(state, dx / length, dy / length));
      accumulator -= STEP;
    }
    render();
    requestAnimationFrame(animation);
  } catch (error) { fail(error); }
}
const controls = new Set(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','KeyW','KeyA','KeyS','KeyD','Space','KeyR']);
window.addEventListener('keydown', event => {
  if (!controls.has(event.code)) return;
  event.preventDefault();
  if (event.code === 'KeyR' && !event.repeat) { try { restart(); } catch (error) { fail(error); } }
  else if (event.code === 'Space' && !event.repeat) paused = !paused;
  else keys.add(event.code);
});
window.addEventListener('keyup', event => keys.delete(event.code));
window.addEventListener('blur', () => { keys.clear(); paused = true; });
document.addEventListener('visibilitychange', () => { if (document.hidden) { keys.clear(); paused = true; } });
document.querySelector('#restart').addEventListener('click', () => { try { restart(); } catch (error) { fail(error); } });
try { restart(); requestAnimationFrame(animation); } catch (error) { fail(error); }
