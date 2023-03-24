function reorder() {
  let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
  $('.favorite').each(function() {
    let current = $(this).closest('.card').attr("data-name")
    if (favorites[current]) {
      $(this).closest('.card-section').prepend($(this).closest('.card'))
    }
  })
}

$('.favorite').on('click', function() {
  let current = $(this).closest('.card').attr("data-name")
  let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
  if (favorites[current] !== null) {
    favorites[current] = !favorites[current]
  } else {
    favorites[current] = true
  }
  $(this).toggleClass("favorited")
  localStorage.setItem('favorites', JSON.stringify(favorites))
  reorder()
})

let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
$('.favorite').each(function() {
  let current = $(this).closest('.card').attr("data-name")
  if (favorites[current]) {
    $(this).toggleClass("favorited")
  }
})
reorder()

$("a.badge").on('click', function() {
})

$(".commit-modal").on('show.bs.modal', function(e) {
  let source = e.relatedTarget
  name = $(source).closest('.card').attr("data-name")
  $(this).find("td span").filter(function() {
    return $(this).text() === name
  }).closest("tr").toggleClass("table-info")
  $(this).attr("data-tf-trigger", name)
})

$(".commit-modal").on('hidden.bs.modal', function(e) {
  let name = $(this).attr("data-tf-trigger") 
  $(this).find("td span").filter(function() {
    return $(this).text() === name
  }).closest("tr").toggleClass("table-info")
})

function setTimer() {
  let str = moment($('#tf-now').attr("data-isonow"), moment.ISO_8601).fromNow()
  $('#tf-ago').text("(" + str + ")")
}
setInterval(setTimer, 60000) // 1 minute in ms
setTimer()
