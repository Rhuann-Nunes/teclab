/**
 * Converte uma estaca no formato "XXXXX+ YY" para metros
 * @param {string} estaca - Estaca no formato "XXXXX+ YY"
 * @returns {number} - Valor em metros
 */
export const estacaParaMetros = (estaca) => {
  const [numero, metros] = estaca.split('+').map(part => part.trim())
  return Number(numero) * 20 + Number(metros)
}

/**
 * Converte um valor em metros para o formato de estaca "XXXXX+ YY"
 * @param {number} metros - Valor em metros
 * @returns {string} - Estaca no formato "XXXXX+ YY"
 */
export const metrosParaEstaca = (metros) => {
  const estaca = Math.floor(metros / 20)
  const resto = metros % 20
  return `${estaca}+ ${resto.toString().padStart(2, '0')}`
} 