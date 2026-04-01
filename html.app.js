const app = document.getElementById('app');
const view = document.getElementById('view');
const audio = document.getElementById('audio');
const closeBtn = document.getElementById('close');
const search = document.getElementById('search');
const pauseBtn = document.getElementById('pause');
const resumeBtn = document.getElementById('resume');
const volume = document.getElementById('volume');
const cover = document.getElementById('cover');
const trackTitle = document.getElementById('trackTitle');
const trackArtist = document.getElementById('trackArtist');

const state = {
  tracks: [],
  history: [],
  favorites: {},
  admin: false,
  tab: 'home'
};

function post(name, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
}

function trackCard(track) {
  return `
    <div class="card">
      <img src="${track.cover_url || 'https://placehold.co/300x300'}">
      <div class="title">${track.title}</div>
      <div class="subtitle">${track.artist}${track.album ? ' • ' + track.album : ''}</div>
      <div class="actions">
        <button class="action" onclick="playTrack(${track.id})">Tocar</button>
        <button class="secondary" onclick="toggleFavorite(${track.id})">
          ${state.favorites[track.id] ? 'Desfavoritar' : 'Favoritar'}
        </button>
      </div>
    </div>
  `;
}

function renderHome(list = state.tracks) {
  view.innerHTML = `
    <h2>Catálogo</h2>
    <div class="grid">${list.map(trackCard).join('')}</div>
  `;
}

function renderFavorites() {
  const list = state.tracks.filter(t => state.favorites[t.id]);
  renderHome(list);
}

function renderHistory() {
  view.innerHTML = `
    <h2>Histórico</h2>
    ${state.history.length ? state.history.map(item => `
      <div class="list-row">
        <strong>${item.title}</strong><br>
        <span>${item.artist}${item.album ? ' • ' + item.album : ''}</span>
      </div>
    `).join('') : '<p>Nenhum histórico ainda.</p>'}
  `;
}

function renderAdmin() {
  if (!state.admin) {
    view.innerHTML = '<h2>Admin</h2><p>Você não tem permissão.</p>';
    return;
  }

  view.innerHTML = `
    <h2>Painel Admin</h2>
    <div class="form">
      <input id="adm_title" placeholder="Título">
      <input id="adm_artist" placeholder="Artista">
      <input id="adm_album" placeholder="Álbum">
      <input id="adm_cover" placeholder="URL da capa">
      <input id="adm_audio" placeholder="URL do áudio">
      <input id="adm_duration" placeholder="Duração em segundos">
      <button class="action" onclick="createTrack()">Cadastrar música</button>
    </div>
  `;
}

function render() {
  if (state.tab === 'home') renderHome();
  if (state.tab === 'favorites') renderFavorites();
  if (state.tab === 'history') renderHistory();
  if (state.tab === 'admin') renderAdmin();
}

window.playTrack = (id) => post('playTrack', { id });
window.toggleFavorite = (id) => post('toggleFavorite', { id });

window.createTrack = () => {
  post('createTrack', {
    title: document.getElementById('adm_title')?.value || '',
    artist: document.getElementById('adm_artist')?.value || '',
    album: document.getElementById('adm_album')?.value || '',
    cover_url: document.getElementById('adm_cover')?.value || '',
    audio_url: document.getElementById('adm_audio')?.value || '',
    duration: document.getElementById('adm_duration')?.value || 0
  });
};

window.addEventListener('message', (event) => {
  const msg = event.data;

  if (msg.action === 'open') {
    app.classList.remove('hidden');
    state.admin = !!msg.admin;
    render();
  }

  if (msg.action === 'homeData') {
    state.tracks = msg.data.tracks || [];
    state.history = msg.data.history || [];
    state.favorites = msg.data.favorites || {};
    state.admin = !!msg.data.isAdmin;
    render();
  }

  if (msg.action === 'searchResults') {
    renderHome(msg.results || []);
  }

  if (msg.action === 'favoritesUpdated') {
    state.favorites = msg.favorites || {};
    render();
  }

  if (msg.action === 'playTrack') {
    const track = msg.track;
    audio.src = track.audio_url;
    audio.play();
    cover.src = track.cover_url || 'https://placehold.co/60x60';
    trackTitle.textContent = track.title || 'Sem título';
    trackArtist.textContent = track.artist || '-';
  }

  if (msg.action === 'pause') audio.pause();
  if (msg.action === 'resume') audio.play();
  if (msg.action === 'setVolume') audio.volume = Number(msg.volume || 0.5);
  if (msg.action === 'notify') console.log('[BS Spotify]', msg.message);
});

document.querySelectorAll('.sidebtn').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.sidebtn').forEach(b => b.classList.remove('active'));
    button.classList.add('active');
    state.tab = button.dataset.tab;
    render();
  });
});

closeBtn.addEventListener('click', () => {
  app.classList.add('hidden');
  post('close');
});

pauseBtn.addEventListener('click', () => post('pause'));
resumeBtn.addEventListener('click', () => post('resume'));

volume.addEventListener('input', () => {
  post('setVolume', { volume: volume.value });
});

search.addEventListener('input', () => {
  post('search', { query: search.value });
});
