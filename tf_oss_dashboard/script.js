// Navbar toggle switches
// When the page loads or when the navbar toggles are switched, toggle the
// class on the HTML <body> tag that controls those features (colorblind or
// show-the-build-cop-section support).
if (localStorage.getItem('tf-colorblind') == 'true') {
  $('#tf-colorblind').prop('checked', true)
  $('body').toggleClass('tf-colorblind')
}
if (localStorage.getItem('tf-show-buildcop') == 'true') {
  $('#tf-show-buildcop').prop('checked', true)
  $('body').toggleClass('tf-show-buildcop')
}
// Note: $(this) in jQuery yields the element upon which this event is called
$('#tf-colorblind').change(function () {
  localStorage.setItem('tf-colorblind', $(this).prop('checked'))
  $('body').toggleClass('tf-colorblind')
})
$('#tf-show-buildcop').change(function () {
  localStorage.setItem('tf-show-buildcop', $(this).prop('checked'))
  $('body').toggleClass('tf-show-buildcop')
})

// Update the human-readable timestamp once per minute and when the page loads
// Uses moment.js, which is included in the top of the HTML page
function humanizeTimestamp () {
  const time_ago = moment($('#tf-now').attr('data-isonow'), moment.ISO_8601).fromNow()
  $('#tf-ago').text(`(${time_ago})`)
}
setInterval(humanizeTimestamp, 60500)
humanizeTimestamp()

// Check every minute if it's time to refresh the page, which is controlled
// by a flag that gets set after five minutes. Delay the refresh if there is
// currently a modal open, because that means someone is probably interacting
// with the page right now and would be annoyed their view changed (because of
// the way the line highlighting works, no job is highlighted when the page
// refreshes, even though the same modal pops up).
let autoRefreshASAP = false
let modalIsOpen = false
function refreshIfNeeded () {
  if (!modalIsOpen && autoRefreshASAP) {
    location.reload()
  }
}
setInterval(refreshIfNeeded, 60500)
setInterval(function () { autoRefreshASAP = true }, 300000)

// MODAL HANDLING
//
// We hook into the modals' open and close events to track whether any modal
// is open (to avoid refreshing the page, see above) and to highlight the
// clicked-on job (which is a very nice quality-of-life feature).
//
// See:
//  - https://getbootstrap.com/docs/5.2/components/modal/#via-javascript
//  - https://getbootstrap.com/docs/5.2/components/modal/#methods
//  - https://getbootstrap.com/docs/5.2/components/modal/#events
//
// NOTE: These all go into jQuery's $(function() {}), which executes the content
// only after the whole page has loaded and the DOM is ready. This allows us
// to have all of the scripts in one file: since the script is loaded just
// after the navbar is placed, the code above can modify the page for styles
// and card placement before the cards and modals (which take up most of the
// page size) are loaded. This means there's generally no flashing when the page
// loads.
lastClicked = null
$(function () {
  // Highlight the clicked job when a modal appears (doesn't work when a commit
  // is linked directly).
  $('.tf-commit-modal').on('show.bs.modal', function (e) {
    modalIsOpen = true
    // Outline the last-clicked dot so you can see which you looked at last
    if (lastClicked !== null) {
      lastClicked.removeClass("tf-last-clicked")
    }
    lastClicked = $(e.relatedTarget)
    lastClicked.addClass("tf-last-clicked")
    job_name = $(lastClicked).closest('.card').attr('data-name')
    $(this).find('td span').filter(function () {
      return $(this).text() === job_name
    }).closest('tr').toggleClass('tf-selected-row')
    $(this).attr('data-tf-job-name', job_name)

    // Set the window location hash to this commit ID without corrupting history
    history.replaceState(undefined, undefined, '#' + $(this).attr('id'))
  })

  // Undo the previous when the modal is hidden
  $('.tf-commit-modal').on('hidden.bs.modal', function () {
    modalIsOpen = false
    const job_name = $(this).attr('data-tf-job-name')
    $(this).find('td span').filter(function () {
      return $(this).text() === job_name
    }).closest('tr').toggleClass('tf-selected-row')
    // Set the window location hash to nothing (remove the #...) without
    // corrupting history
    history.replaceState(null, null, ' ')
  })

  // When the page loads, if there is a commit ID in the location hash, show
  // the matching modal -- that is, if you load dashboard#commit, show the modal
  // for that commit. Also, show the matching modal if a CL is provided instead.
  unescaped = decodeURIComponent(window.location.hash).replace("#", "").replace("+", "")
  // Nothing to do if no hash in the URL
  if (window.location.hash.length <= 1) {
     // Empty!
  // If the hash matches a Category on the page, then scroll to it
  } else if (document.getElementById(unescaped)) {
    if (document.hasFocus()) {
      document.getElementById(unescaped).scrollIntoView();
    } else {
      let scrolled = false
      $(window).focus(function() {
        if (!scrolled) {
          setTimeout(function () {
            document.getElementById(unescaped).scrollIntoView();
          }, 100);
          scrolled = true
        }
      })
    }
  // If the hash is exactly 41 chars (hash sign # plus a 40-char sha hash),
  // just show that modal.
  } else if (window.location.hash.length == 41) {
    if ($(window.location.hash).length) {
      new bootstrap.Modal(window.location.hash).show()
    } else {
      new bootstrap.Modal("#tf-no-commit-modal").show()
    }
  // And if it's not a commit sha, it's either a PR or a CL, so try and find a
  // modal matching that PR number if the length is short (CLs will always
  // be nine or more characters)
  } else if (window.location.hash.length < 10) {
    let pr = $(".modal p:first-child").filter(function() {
      return $(this).text().indexOf("Merge pull request " + window.location.hash) >= 0;
    })
    const modal_id = "#" + pr.closest(".modal").attr('id')
    if ($(modal_id).length) {
      new bootstrap.Modal(modal_id).show()
    } else {
      new bootstrap.Modal("#tf-no-pr-modal").show()
    }
  // And if it's neither, it's a CL, so try and find a modal
  // matching that CL number
  } else {
    const cl = window.location.hash.substring(1).replace("cl/", "")
    const modal_id = '#' + $(`.modal[data-cl=${cl}]`).attr('id')
    if ($(modal_id).length) {
      new bootstrap.Modal(modal_id).show()
    } else {
      new bootstrap.Modal("#tf-no-cl-modal").show()
    }
  }

  let revealed = null
  $(".tf-reveal").click(function() {
    if (revealed !== null) {
      $(".badge[data-bs-target='" + revealed + "']").removeClass("tf-revealed")
    }
    revealed = $(this).attr("data-tf-reveal")
    $(".badge[data-bs-target='" + revealed + "']").removeClass("tf-last-clicked").addClass("tf-revealed")
  })
})
