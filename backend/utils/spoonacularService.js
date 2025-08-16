
const API_KEY = '91f7622b5e59422fb84b2b29c6d0281f';

const fetchRecipes = async (maxCalories, diet = '') => {
  const params = new URLSearchParams({
    number: '8',
    apiKey: API_KEY,
    addRecipeNutrition: 'true',
    maxCalories: maxCalories,
  });

  if (diet && diet !== 'all') {
    params.set('diet', diet);
  }

  const url = `https://api.spoonacular.com/recipes/complexSearch?${params.toString()}`;
  const response = await fetch(url);

  if (response.ok) {
    const data = await response.json();
    return data.results;
  }

  throw new Error(`Échec du chargement : ${response.status}`);
};

const fetchRecipeDetails = async (id) => {
  const url = `https://api.spoonacular.com/recipes/${id}/information?includeNutrition=true&apiKey=${API_KEY}`;
  const response = await fetch(url);

  if (response.ok) {
    return await response.json();
  }

  throw new Error(`Échec du chargement : ${response.status}`);
};

module.exports = { fetchRecipes, fetchRecipeDetails };