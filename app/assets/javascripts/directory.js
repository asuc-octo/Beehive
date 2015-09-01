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
    window.location.replace(url);
  })
})
