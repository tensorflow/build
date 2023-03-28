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

let modal_is_open = false;

$(".commit-modal").on('show.bs.modal', function(e) {
  modal_is_open = true;
  let source = e.relatedTarget
  name = $(source).closest('.card').attr("data-name")
  $(this).find("td span").filter(function() {
    return $(this).text() === name
  }).closest("tr").toggleClass("table-info")
  $(this).attr("data-tf-trigger", name)
})

$(".commit-modal").on('hidden.bs.modal', function(e) {
  modal_is_open = false;
  let name = $(this).attr("data-tf-trigger") 
  $(this).find("td span").filter(function() {
    return $(this).text() === name
  }).closest("tr").toggleClass("table-info")
})

function humanizeTimestamp() {
  let str = moment($('#tf-now').attr("data-isonow"), moment.ISO_8601).fromNow()
  $('#tf-ago').text("(" + str + ")")
}
function autoRefresh() {
  if (!modal_is_open) {
    location.reload()
  }
}
setInterval(autoRefresh, 300000) // Every 5 mins, refresh unless modal is open
setInterval(humanizeTimestamp, 60000) // Every 1 min, update the timestamp
humanizeTimestamp()
