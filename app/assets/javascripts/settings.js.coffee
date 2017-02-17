# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  jQuery('.currency_select').on "change", ->
    currency_id = $(this).val()
    user_id = $(this).data('user-id')
    url = "/settings/"+user_id+"/set_default_currency?currency_id="+currency_id
    jQuery.get url, (response) ->
      window.location.reload()