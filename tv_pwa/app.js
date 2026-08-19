if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('./sw.js');
}

let currentIndex = 0;
const cards = document.querySelectorAll('.card');

document.addEventListener('keydown', (e) => {
  cards[currentIndex].classList.remove('focused');
  
  if (e.key === 'ArrowRight' && currentIndex % 2 === 0) currentIndex++;
  if (e.key === 'ArrowLeft' && currentIndex % 2 === 1) currentIndex--;
  if (e.key === 'ArrowDown' && currentIndex < 2) currentIndex += 2;
  if (e.key === 'ArrowUp' && currentIndex >= 2) currentIndex -= 2;
  
  cards[currentIndex].classList.add('focused'); // Actualiza foco visual[cite: 2]
});