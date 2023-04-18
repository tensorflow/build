//////////////////////////////////////////////////////////////////////////////
// HTML BODY STYLE TOGGLES
//////////////////////////////////////////////////////////////////////////////
// Set styles upon page load
if (localStorage.getItem('cb') == 'true') {
  $("#colorblind").prop("checked", true)
  $("body").toggleClass("colorblind")
}
if (localStorage.getItem('showfailures') == 'true') {
  $("#showfailures").prop("checked", true)
  $("body").toggleClass("showfailures")
}
// Set styles when navbar items toggled
$("#colorblind").change(function(e) {
  localStorage.setItem('cb', $(this).prop('checked'))
  $("body").toggleClass("colorblind")
})
$("#showfailures").change(function(e) {
  localStorage.setItem('showfailures', $(this).prop('checked'))
  $("body").toggleClass("showfailures")
})

//////////////////////////////////////////////////////////////////////////////
// AUTO REFRESH AND TIMESTAMP HANDLING
//////////////////////////////////////////////////////////////////////////////
let autorefreshready = false
let modal_is_open = false;
function humanizeTimestamp() {
  if (!modal_is_open && autorefreshready) {
    location.reload()
  }
  let str = moment($('#tf-now').attr("data-isonow"), moment.ISO_8601).fromNow()
  $('#tf-ago').text("(" + str + ")")
}
function setAutoRefreshReady() {
  autorefreshready = true
}
setInterval(setAutoRefreshReady, 300000) // Every 5 mins, refresh unless modal is open
setInterval(humanizeTimestamp, 60500) // Every 1 min, update the timestamp
humanizeTimestamp()

//////////////////////////////////////////////////////////////////////////////
// MODAL HANDLING
// NOTE: These all go into jQuery's $(function() {}), which executes the content
// only after the whole page has loaded and the DOM is ready. This allows us
// to have all of the scripts in one file: since the script is loaded just
// after the navbar is placed, the code above can modify the page for styles
// and card placement before the cards and modals (which take up most of the
// page size) are loaded. This means there's generally no flashing when the page
// loads, except to reload the favorites, which seems unavoidable.
//////////////////////////////////////////////////////////////////////////////
$(function() {

  //////////////////////////////////////////////////////////////////////////////
  // FAVORITES HANDLING
  //////////////////////////////////////////////////////////////////////////////
  function reorder() {
    let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
    $('.favorites-section .card-section').empty()
    $('.favorite').each(function() {
      let current = $(this).closest('.card').attr("data-name")
      if (favorites[current]) {
        $(this).addClass("favorited")
        $(this).closest('.card').clone(true).appendTo('.favorites-section .card-section')
      } else {
        $(this).removeClass("favorited")
      }
    })
    if ($('.favorites-section .card-section').children().length > 0) {
      $('.favorites-section').removeClass("d-none")
    } else {
      $('.favorites-section').addClass("d-none")
    }
  }

  $('.favorite').on('click', function() {
    let current = $(this).closest('.card').attr("data-name")
    let favorites = JSON.parse(localStorage.getItem('favorites') || '{}')
    if (favorites[current] !== null) {
      favorites[current] = !favorites[current]
    } else {
      favorites[current] = true
    }
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

  // Highlight the clicked job when a modal appears (doesn't work when a commit
  // is linked directly).
  $(".commit-modal").on('show.bs.modal', function(e) {
    modal_is_open = true;
    let source = e.relatedTarget
    name = $(source).closest('.card').attr("data-name")
    $(this).find("td span").filter(function() {
      return $(this).text() === name
    }).closest("tr").toggleClass("tf-table-highlight")
    $(this).attr("data-tf-trigger", name)

    // Set the window location hash to this commit ID without corrupting history
    history.replaceState(undefined, undefined, "#" + $(this).attr("id"))
  })

  // Undo the previous when the modal is hidden
  $(".commit-modal").on('hidden.bs.modal', function(e) {
    modal_is_open = false;
    let name = $(this).attr("data-tf-trigger") 
    $(this).find("td span").filter(function() {
      return $(this).text() === name
    }).closest("tr").toggleClass("tf-table-highlight")
    // Set the window location hash to nothing (remove the #...)
    history.replaceState(null, null, ' ');
  })

  // When the page loads, if there is a commit ID in the location hash, show
  // the matching modal -- that is, if you load dashboard#commit, show the modal
  // for that commit.
  if (window.location.hash.length <= 1) {
    // Nothing to do
  } else if (window.location.hash.length == 41) {
    new bootstrap.Modal(window.location.hash).show()
  // And if it's not a commit sha (which is always 40 chars + a hash symbol),
  // try matching against PR number...
  } else if (window.location.hash.length < 10) {
    let pr = $(".modal p:first-child").filter(function() {
      return $(this).text().indexOf("Merge pull request " + window.location.hash) >= 0;
    })
    new bootstrap.Modal("#" + pr.closest(".modal").attr('id')).show()
  // And if it's a CL, try and find a modal matching that CL number
  } else {
    let cl = $(".modal[data-cl=" + window.location.hash.substring(1) + "]")
    new bootstrap.Modal("#" + cl.attr('id')).show()
  }
})
