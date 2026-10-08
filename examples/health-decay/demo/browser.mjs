import Demo from './dist/api.mjs';

const entities = document.querySelector('#entities');
const tick = document.querySelector('#tick');
const step = document.querySelector('#step');
const reset = document.querySelector('#reset');
const error = document.querySelector('#error');
let state;

function accept(packet) {
  if (packet.$ === 'Failed') throw new Error(packet.error);
  if (packet.$ !== 'Packet') throw new Error('Unexpected Bend result');
  // Keep only the returned affine owner; never reuse the consumed world.
  state = packet.state;
  const frame = JSON.parse(packet.frame);
  if (frame.entities.some(entity => entity.error)) throw new Error('Could not observe entity components');
  tick.textContent = `Tick ${frame.tick}`;
  entities.replaceChildren(...frame.entities.map(entity => {
    const selected = entity.decay !== null;
    const card = document.createElement('article');
    card.classList.toggle('skipped', !selected);
    const top = document.createElement('div');
    top.className = 'top';
    const title = document.createElement('strong');
    title.textContent = `Entity ${entity.id}`;
    const badge = document.createElement('span');
    badge.className = 'badge';
    badge.textContent = selected ? 'Matches query' : 'Skipped · no HealthDecay';
    top.append(title, badge);
    const components = document.createElement('div');
    components.className = 'components';
    for (const text of [`Health { ${Number(entity.health.toPrecision(6))} }`, ...(selected ? [`HealthDecay { ${entity.decay} }`] : [])]) {
      const component = document.createElement('code');
      component.className = 'component';
      component.textContent = text;
      components.append(component);
    }
    const bar = document.createElement('progress');
    bar.max = 30;
    bar.value = entity.health;
    bar.setAttribute('aria-label', `Entity ${entity.id} health`);
    card.append(top, components, bar);
    return card;
  }));
}
function run(operation) {
  try {
    error.hidden = true;
    accept(operation());
    step.disabled = reset.disabled = false;
  } catch (failure) {
    state = undefined;
    step.disabled = true;
    reset.disabled = false;
    error.textContent = failure.message;
    error.hidden = false;
  }
}
step.addEventListener('click', () => {
  const owned = state;
  state = undefined;
  run(() => Demo.step(owned));
});
reset.addEventListener('click', () => run(() => Demo.start()));
run(() => Demo.start());
