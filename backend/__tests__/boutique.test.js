// __tests__/boutique.test.js
const { applyFilter } = require('../utils/boutique');

describe('applyFilter', () => {
  const mockProducts = [
    { name: 'Gants de Boxe', description: 'Gants en cuir', category: 'Boxe' },
    { name: 'Kimono de Judo', description: 'Kimono résistant', category: 'Judo' },
    { name: 'Barre de Musculation', description: 'Barre olympique', category: 'Muscu' },
    { name: 'Corde à sauter MMA', description: 'Corde rapide', category: 'MMA' },
  ];

  test('filtre correctement par recherche et catégorie', () => {
    // Cas de test 1 : Recherche "gants" dans la catégorie "Boxe"
    const result = applyFilter(mockProducts, 'gants', ['Boxe']);
    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Gants de Boxe');
  });

  test('filtre par recherche uniquement si aucune catégorie n\'est sélectionnée', () => {
    // Cas de test 2 : Recherche "corde" sans filtre de catégorie
    const result = applyFilter(mockProducts, 'corde', []);
    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Corde à sauter MMA');
  });

  test('filtre par catégorie uniquement si la recherche est vide', () => {
    // Cas de test 3 : Filtre par catégorie "Judo" sans recherche
    const result = applyFilter(mockProducts, '', ['Judo']);
    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Kimono de Judo');
  });

  test('renvoie tous les produits si la recherche et les filtres sont vides', () => {
    // Cas de test 4 : Ni recherche, ni filtre
    const result = applyFilter(mockProducts, '', []);
    expect(result.length).toBe(mockProducts.length);
  });

  test('gère les filtres multiples', () => {
    // Cas de test 5 : Filtre pour deux catégories
    const result = applyFilter(mockProducts, '', ['MMA', 'Boxe']);
    expect(result.length).toBe(2);
    expect(result[0].category).toBe('Boxe');
    expect(result[1].category).toBe('MMA');
  });

  test('gère les entrées invalides sans planter', () => {
    const result = applyFilter(null, 'test', ['MMA']);
    expect(result).toEqual([]);

    const result2 = applyFilter([], 'test', ['MMA']);
    expect(result2).toEqual([]);
  });
});