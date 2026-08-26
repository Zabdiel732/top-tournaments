import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.4.0/firebase-app.js';
import { getFirestore, doc, onSnapshot } from 'https://www.gstatic.com/firebasejs/10.4.0/firebase-firestore.js';

const firebaseConfig = {
  apiKey: 'AIzaSyB_5zlS-c0SaubyBH2uUr4S6SflZ0bMfEw',
  authDomain: 'top-tournaments.firebaseapp.com',
  projectId: 'top-tournaments',
  storageBucket: 'top-tournaments.firebasestorage.app',
  messagingSenderId: '149059459443',
  appId: '1:149059459443:web:2a78646e521c477b7e4d06',
};

const cards = [...document.querySelectorAll('.card')];
const status = document.querySelector('#connection-status');
const focusName = document.querySelector('#focus-name');
let currentIndex = 0;

function selectCard(index) {
  currentIndex = Math.max(0, Math.min(cards.length - 1, index));
  cards.forEach((card, cardIndex) => card.classList.toggle('focused', cardIndex === currentIndex));
  focusName.textContent = cards[currentIndex].querySelector('.label').textContent;
}

function updateMetrics(data) {
  document.querySelector('#tv-ritmo').textContent = data.ritmo ?? 0;
  document.querySelector('#tv-pasos').textContent = data.pasos ?? 0;
  document.querySelector('#tv-calorias').textContent = data.calorias ?? 0;
  document.querySelector('#last-update').textContent = `Actualizado ${new Date().toLocaleTimeString('es-MX')}`;
  status.textContent = 'Firestore conectado';
  status.className = 'status online';
  localStorage.setItem('lastMetrics', JSON.stringify(data));
}

cards.forEach((card, index) => card.addEventListener('click', () => selectCard(index)));
document.addEventListener('keydown', (event) => {
  const { key } = event;
  let next = currentIndex;
  if (key === 'ArrowRight') next = currentIndex % 2 === 0 ? currentIndex + 1 : currentIndex;
  if (key === 'ArrowLeft') next = currentIndex % 2 === 1 ? currentIndex - 1 : currentIndex;
  if (key === 'ArrowDown') next = currentIndex < 2 ? currentIndex + 2 : currentIndex;
  if (key === 'ArrowUp') next = currentIndex >= 2 ? currentIndex - 2 : currentIndex;
  if (key === 'Enter' || key === 'OK') cards[currentIndex].click();
  if (next !== currentIndex) selectCard(next);
  if (key.startsWith('Arrow') || key === 'Enter' || key === 'OK') event.preventDefault();
});

const cached = localStorage.getItem('lastMetrics');
if (cached) updateMetrics(JSON.parse(cached));

try {
  const db = getFirestore(initializeApp(firebaseConfig));
  onSnapshot(doc(db, 'ecosystem', 'current'), (snapshot) => updateMetrics(snapshot.data() ?? {}), (error) => {
    console.error('Firestore:', error);
    status.textContent = 'Sin conexión, usando último dato';
    status.className = 'status offline';
  });
} catch (error) {
  console.error('Firebase:', error);
  status.textContent = 'Modo offline';
  status.className = 'status offline';
}

if ('serviceWorker' in navigator) navigator.serviceWorker.register('./sw.js').catch(console.error);