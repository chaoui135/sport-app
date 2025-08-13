
const getMoodQuote = async () => {
  // Simule l'appel à une API de citation
  const res = await fetch('https://zenquotes.io/api/random');
  if (res.ok) {
    const data = await res.json();
    return `${data[0].q} — ${data[0].a}`;
  }
  throw new Error("Impossible d'obtenir une citation.");
};

const getSongsForMood = async (mood) => {
  // Simule l'appel à l'API iTunes
  const res = await fetch(`https://itunes.apple.com/search?term=${mood}&media=music&limit=5`);
  if (res.ok) {
    const data = await res.json();
    return data.results.map((item) => ({
      trackName: item.trackName,
      artistName: item.artistName,
      url: item.previewUrl,
      artwork: item.artworkUrl100,
    }));
  }
  throw new Error("Erreur lors de la récupération des chansons.");
};

module.exports = { getMoodQuote, getSongsForMood };