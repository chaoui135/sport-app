
const { fetchRecipes, fetchRecipeDetails } = require('../utils/spoonacularService');

// Simule la fonction 'fetch' globale
global.fetch = jest.fn();

describe('NutritionService', () => {
  beforeEach(() => {
    // Réinitialise le mock avant chaque test
    fetch.mockClear();
  });

  describe('fetchRecipes', () => {
    test('récupère les recettes avec succès pour des calories données', async () => {
      // Données simulées pour un appel réussi
      const mockResponse = {
        ok: true,
        json: () => Promise.resolve({
          results: [{ id: 1, title: 'Salade de test', nutrition: {} }],
        }),
      };
      fetch.mockResolvedValue(mockResponse);

      const recipes = await fetchRecipes(500);

      // Vérifie que fetch a été appelé avec la bonne URL
      expect(fetch).toHaveBeenCalledWith(expect.stringContaining('maxCalories=500'));
      expect(recipes.length).toBe(1);
      expect(recipes[0].title).toBe('Salade de test');
    });

    test('récupère les recettes avec un régime alimentaire', async () => {
      const mockResponse = {
        ok: true,
        json: () => Promise.resolve({ results: [] }),
      };
      fetch.mockResolvedValue(mockResponse);

      await fetchRecipes(800, 'vegetarian');

      // Vérifie que l'URL contient bien le paramètre 'diet'
      expect(fetch).toHaveBeenCalledWith(expect.stringContaining('diet=vegetarian'));
    });

    test('gère les erreurs de l\'API lors de la récupération des recettes', async () => {
      const mockResponse = { ok: false, status: 404 };
      fetch.mockResolvedValue(mockResponse);

      await expect(fetchRecipes(500)).rejects.toThrow('Échec du chargement : 404');
    });
  });

  describe('fetchRecipeDetails', () => {
    test('récupère les détails d\'une recette avec succès', async () => {
      const mockDetails = {
        id: 1,
        title: 'Salade de test',
        summary: 'Une salade saine',
        nutrition: {
          nutrients: [{ name: 'Calories', amount: 300 }]
        }
      };
      const mockResponse = {
        ok: true,
        json: () => Promise.resolve(mockDetails),
      };
      fetch.mockResolvedValue(mockResponse);

      const details = await fetchRecipeDetails(1);

      expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/recipes/1/information'));
      expect(details.title).toBe('Salade de test');
      expect(details.nutrition.nutrients[0].amount).toBe(300);
    });

    test('gère les erreurs lors de la récupération des détails', async () => {
      const mockResponse = { ok: false, status: 500 };
      fetch.mockResolvedValue(mockResponse);

      await expect(fetchRecipeDetails(999)).rejects.toThrow('Échec du chargement : 500');
    });
  });
});