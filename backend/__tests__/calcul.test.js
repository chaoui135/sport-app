// __tests__/calcul.test.js

const { calculIMC, calculBMR } = require('../utils/calcul');

describe('calculIMC', () => {
  it('calcule correctement l\'IMC', () => {
    expect(calculIMC(70, 170)).toBeCloseTo(24.22, 2);
  });

  it('lance une erreur si la taille est <= 0', () => {
    expect(() => calculIMC(70, 0)).toThrow();
  });
});

describe('calculBMR', () => {
  it('calcule le BMR pour un homme', () => {
    expect(calculBMR(70, 170, 25, true)).toBeCloseTo(1642.5, 1);
  });

  it('calcule le BMR pour une femme', () => {
    expect(calculBMR(70, 170, 25, false)).toBeCloseTo(1476.5, 1);
  });

  it('lance une erreur si un paramètre manque', () => {
    expect(() => calculBMR(null, 170, 25)).toThrow();
    expect(() => calculBMR(70, 0, 25)).toThrow();
  });
});
