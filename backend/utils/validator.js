// backend/utils/validators.js
function isStrongPassword(pw) {
  if (typeof pw !== 'string') return false;
  // >= 8 chars, 1 minuscule, 1 majuscule, 1 chiffre, 1 spécial
  const re =
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[ !"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]).{8,}$/;
  return re.test(pw);
}
module.exports = { isStrongPassword };
