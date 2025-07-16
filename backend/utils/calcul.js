// utils/calcul.js

function calculIMC(poids, tailleCm) {
  if (!poids || !tailleCm || tailleCm <= 0) throw new Error("Entrée invalide");
  return poids / ((tailleCm / 100) * (tailleCm / 100));
}

function calculBMR(poids, tailleCm, age, homme = true) {
  if (!poids || !tailleCm || !age) throw new Error("Entrée invalide");
  return homme
    ? 10 * poids + 6.25 * tailleCm - 5 * age + 5
    : 10 * poids + 6.25 * tailleCm - 5 * age - 161;
}

module.exports = { calculIMC, calculBMR };
