function getViewport () {
  // https://stackoverflow.com/a/8876069
  const width = Math.max(
    document.documentElement.clientWidth,
    window.innerWidth || 0
  )
  if (width <= 576) return 'xs'
  return 'xl'
}

$(document).ready(function () {
  let viewport = getViewport()
  if ( viewport == 'xs' ) {
    // Update columns width
    document.getElementById("col-search").className = "col-12"
    document.getElementById("col-result").className = "col-12"

    // Create new row
    var div = document.createElement("DIV");
    div.className = "row"
    div.id = "row-result"

    // Append the row to the existing one
    document.getElementById("row-body").append(div)

    // Move results to the new row
    var col = document.getElementById("col-result")
    document.getElementById("row-result").appendChild(col)
  }
})
  