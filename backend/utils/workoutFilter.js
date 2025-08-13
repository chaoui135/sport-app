// utils/workoutFilter.js
const applyFilter = (allExercises, searchTerm, filters) => {
  const search = searchTerm.toLowerCase();

  return allExercises.filter(e => {
    const name = (e.name || '').toLowerCase();
    const type = (e.type || '').toLowerCase();
    const desc = (e.description || '').toLowerCase();
    const muscle = (e.muscle || '').toLowerCase();

    // Vérifie si la chaîne de recherche est présente dans les champs
    const matchSearch =
      name.includes(search) ||
      type.includes(search) ||
      desc.includes(search) ||
      muscle.includes(search);

    // Vérifie si l'exercice correspond à au moins un des filtres de sport
    const matchSport =
      filters.length === 0 ||
      filters.some(f => (e.type || '').toLowerCase() === f.toLowerCase());

    return matchSearch && matchSport;
  });
};

module.exports = { applyFilter };