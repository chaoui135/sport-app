// boutique-logic.js - Un fichier contenant la logique à tester
const applyFilter = (products, searchTerm, filters) => {
  if (!products || !Array.isArray(products)) {
    return [];
  }

  const search = searchTerm.toLowerCase();

  return products.filter(p => {
    const name = (p.name || '').toLowerCase();
    const desc = (p.description || '').toLowerCase();
    const cat  = p.category;

    const matchSearch = name.includes(search) || desc.includes(search);
    const matchCat    = filters.length === 0 || filters.includes(cat);

    return matchSearch && matchCat;
  });
};

module.exports = { applyFilter };