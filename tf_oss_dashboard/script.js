function reorder() {
  let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
  $('.favorites-section .card-section').empty()
  $('.tf-is-listed .favorite').each(function() {
    let current = $(this).closest('.card').attr("data-name")
    if (favorites[current]) {
      $(this).closest('.card').clone(true).appendTo('.favorites-section .card-section')
    }
  })
  if ($('.favorites-section .card-section').children().length > 0) {
    $('.favorites-section').removeClass("d-none")
  } else {
    $('.favorites-section').addClass("d-none")
  }
}

$('.favorite').on('click', function() {
  console.log("clicked")
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

let autorefreshready = false
function humanizeTimestamp() {
  if (!modal_is_open && autorefreshready) {
    location.reload()
  }
  let str = moment($('#tf-now').attr("data-isonow"), moment.ISO_8601).fromNow()
  $('#tf-ago').text("(" + str + ")")
}
function autoRefreshIsReady() {
  autorefreshready = true
}
setInterval(autoRefreshIsReady, 300000) // Every 5 mins, refresh unless modal is open
setInterval(humanizeTimestamp, 60500) // Every 1 min, update the timestamp
humanizeTimestamp()
