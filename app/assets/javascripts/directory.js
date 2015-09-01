$(function() {
  $('***REMOVED***do-job-search').on('click', function(e) {
    e.preventDefault();
    var params = {
      'compensation': $('***REMOVED***compensation').val(),
      'department': $('***REMOVED***department').val(),
      'per_page': $('***REMOVED***per_page').val(),
      'query': $('***REMOVED***query').val()
    }
    var url = '/jobs/search?' + $.param(params)
    // http://beehive.berkeley.edu/jobs/search?compensation=1&department=1&faculty=481&per_page=32&post_status=1&query=CS
    window.location.replace(url);
  })
})
