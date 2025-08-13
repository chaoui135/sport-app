
const { getMoodQuote, getSongsForMood } = require('../utils/moodMusique');


// Simule la fonction 'fetch' globale.
global.fetch = jest.fn();

describe('moodMusic', () => {
  beforeEach(() => {
    // Réinitialise le mock de fetch avant chaque test.
    fetch.mockClear();
  });

  describe('getMoodQuote', () => {
    test('récupère et formate une citation avec succès', async () => {
      const mockResponse = {
        ok: true,
        json: () => Promise.resolve([
          { q: 'Une citation de test', a: 'Auteur de test' },
        ]),
      };
      fetch.mockResolvedValue(mockResponse);

      const quote = await getMoodQuote();

      expect(fetch).toHaveBeenCalledWith('https://zenquotes.io/api/random');
      expect(quote).toBe('Une citation de test — Auteur de test');
    });

    test('gère les erreurs de l\'API de citation', async () => {
      const mockResponse = { ok: false, status: 500 };
      fetch.mockResolvedValue(mockResponse);

      await expect(getMoodQuote()).rejects.toThrow("Impossible d'obtenir une citation.");
    });
  });

  describe('getSongsForMood', () => {
    test('récupère et formate les chansons pour une humeur donnée', async () => {
      const mockResponse = {
        ok: true,
        json: () => Promise.resolve({
          results: [
            {
              trackName: 'Test Song',
              artistName: 'Test Artist',
              previewUrl: 'http://test.url',
              artworkUrl100: 'http://test.artwork.url'
            },
          ],
        }),
      };
      fetch.mockResolvedValue(mockResponse);

      const songs = await getSongsForMood('happy');

      expect(fetch).toHaveBeenCalledWith('https://itunes.apple.com/search?term=happy&media=music&limit=5');
      expect(songs.length).toBe(1);
      expect(songs[0].trackName).toBe('Test Song');
      expect(songs[0].artistName).toBe('Test Artist');
    });

    test('gère les erreurs de l\'API iTunes', async () => {
      const mockResponse = { ok: false, status: 500 };
      fetch.mockResolvedValue(mockResponse);

      await expect(getSongsForMood('sad')).rejects.toThrow("Erreur lors de la récupération des chansons.");
    });
  });
});