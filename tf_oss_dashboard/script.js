function reorder() {
  let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
  $('.important').each(function() {
    $(this).parent().parent().prepend($(this).parent())
  })
  $('.favorite').each(function() {
    let current = $(this).parent().attr("data-name")
    if (favorites[current]) {
      $(this).parent().parent().prepend($(this).parent())
    }
  })
}

$('.favorite').on('click', function() {
  let current = $(this).parent().attr("data-name")
  let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
  if (favorites[current] !== null) {
    favorites[current] = !favorites[current]
  } else {
    favorites[current] = true
  }
  $(this).text(favorites[current] ? '★' : '☆')
  localStorage.setItem('favorites', JSON.stringify(favorites))
  reorder()
})

let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
$('.favorite').each(function() {
  let current = $(this).parent().attr("data-name")
  $(this).text(favorites[current] ? '★' : '☆')
})
reorder()
