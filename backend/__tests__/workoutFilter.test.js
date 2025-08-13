// __tests__/workoutFilter.test.js
const { applyFilter } = require('../utils/workoutFilter');

describe('applyFilter', () => {
  // Données de test (mock)
  const mockExercises = [
    { name: 'Push-ups', type: 'Musculation', muscle: 'chest', description: 'Classic push-up' },
    { name: 'Yoga Pose', type: 'Yoga', muscle: 'all', description: 'A relaxing pose' },
    { name: 'Running', type: 'Cardio', muscle: 'legs', description: 'Running on a track' },
    { name: 'Bench Press', type: 'Musculation', muscle: 'chest', description: 'Heavy lift' },
  ];

  test('filtre correctement par terme de recherche', () => {
    const searchTerm = 'push';
    const filters = [];
    const result = applyFilter(mockExercises, searchTerm, filters);

    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Push-ups');
  });

  test('filtre correctement par sport', () => {
    const searchTerm = '';
    const filters = ['Yoga'];
    const result = applyFilter(mockExercises, searchTerm, filters);

    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Yoga Pose');
  });

  test('filtre par recherche et sport (insensible à la casse)', () => {
    // La recherche est "bench" (insensible à la casse)
    // Le filtre est "musculation" (insensible à la casse)
    // L'exercice "Bench Press" correspond aux deux conditions
    const searchTerm = 'BENCH';
    const filters = ['musculation'];
    const result = applyFilter(mockExercises, searchTerm, filters);

    expect(result.length).toBe(1);
    expect(result[0].name).toBe('Bench Press');
  });

  test('retourne tous les exercices si les filtres sont vides', () => {
    const searchTerm = '';
    const filters = [];
    const result = applyFilter(mockExercises, searchTerm, filters);

    expect(result.length).toBe(4);
  });
});