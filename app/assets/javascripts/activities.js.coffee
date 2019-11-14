# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $('#notification-btn').on 'click', ->
    $('.notification-badge').addClass('hidden')
#    $('.notification-dropdown').scrollTop(0)
    $('.notification-container').infinitePages
      context: '#dropdown'
    $.ajax '/activities/read_notifications',
      type: 'post'

#      loading: ->
#        $(this).text('Loading next page...')
#      error: ->
#        $(this).button('There was an error, please try again')
#user_name: sales@presstigers.com
#password: Jph(T%yUG@$176FF
