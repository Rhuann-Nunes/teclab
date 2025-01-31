export const formatDate = (dateString) => {
  if (!dateString) return '-'
  const [year, month, day] = dateString.split('-')
  return `${day}/${month}/${year}`
}

export const formatNumber = (number, decimals = 2) => {
  if (number === null || number === undefined) return '-'
  return Number(number).toFixed(decimals)
}

export const formatPercent = (number, decimals = 1) => {
  if (number === null || number === undefined) return '-'
  return `${Number(number).toFixed(decimals)}%`
} 