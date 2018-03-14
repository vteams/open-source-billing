# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@initUserListingEvents = () ->
  $('#user_add_btn,#user_cancel_btn').on "click", ->
    $('.side-form,#btn_container').toggleClass('hidden')

  $('#user_save_btn').on "click", (event)->
    event.preventDefault()
    event.stopPropagation()
    $('.submit-user-form').click()

  $('select').material_select()

  $('input[id^=user_ck_]').on "change", ->
    if $('input[id^=user_ck_]:checked').length == 1
      $('#user_edit_btn').removeClass('disabled')
      url = '/sub_users/' + $('input[id^=user_ck_]:checked').val() + '/edit'
      $('#user_edit_btn').attr('href', url)
    else
      $('#user_edit_btn').addClass('disabled')
      $('#user_edit_btn').attr('href', 'javascript:;')

jQuery ->
  jQuery('.currency_select').on "change", ->
    currency_id = $(this).val()
    user_id = $(this).data('user-id')
    url = "/settings/"+user_id+"/set_default_currency?currency_id="+currency_id
    jQuery.get url, (response) ->
      window.location.reload()

  $(document).ready ->
    $.get '/sub_users/settings_listing', (data) ->
      $('#users_listing').append(data)
      initUserListingEvents()

