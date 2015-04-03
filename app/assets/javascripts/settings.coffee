# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#jQuery ->
#  jQuery('.currency_select').change ->
#    status = $('.currency_select').attr('checked')=='checked'
#    jQuery.ajax '/settings',
#      type: 'POST'
#      data: 'status'
#      dataType: 'html'
#      error: (jqXHR, textStatus, errorThrown) ->
#        alert "Error: #{textStatus}"
#      success: (data, textStatus, jqXHR) ->
#        data = JSON.parse(data)
#        console.log(data)