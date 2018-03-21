# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@showSuccessMsg = (msg) ->
  $('#flash_message').removeClass('hidden').css('display', 'block');
  $('#card-alert.red').css('display', 'none');
  $('#card-alert.green').css('display', 'block');
  $('#card-alert.green').find('p').html(msg);
  $('#card-alert.green').find('button').addClass('hidden');
  setTimeout ->
    $('#flash_message').addClass('hidden')
  , 5000

@showErrorMsg = (msg) ->
  $('#flash_message').removeClass('hidden').css('display', 'block');
  $('#card-alert.green').css('display', 'none');
  $('#card-alert.red').css('display', 'block');
  $('#card-alert.red').find('p').html(msg);
  $('#card-alert.red').find('button').addClass('hidden');
  setTimeout ->
    $('#flash_message').addClass('hidden')
  , 5000

@initUserListingEvents = () ->
  $('#user_add_btn,#user_cancel_btn').on "click", ->
    $('#user_reset_form').click()
    $('.user-side-form,#user_btn_container').toggleClass('hidden')

  $('#user_save_btn').on "click", (event)->
    event.preventDefault()
    event.stopPropagation()
    $('.submit-user-form').click()

  $('#user_delete_btn').on "click", (event)->
    event.preventDefault()
    event.stopPropagation()
    userIds = []
    $('input[name^=user_ids]:checked').each (index, element) =>
      userIds.push($(element).val())

    if userIds.length > 0
      $.ajax '/sub_users/destroy_bulk',
        type: 'delete'
        data: {user_ids: userIds}
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          showSuccessMsg(data.notice)
          $('#users_listing').html(data.html)
          initUserListingEvents()

  $('select').material_select()

  $('input[id^=user_ck_]').on "change", ->
    if $('input[id^=user_ck_]:checked').length == 1
      $('#user_edit_btn').removeClass('disabled')
      url = '/sub_users/' + $('input[id^=user_ck_]:checked').val() + '/edit?remote=1'
      $('#user_edit_btn').attr('href', url)
    else
      $('#user_edit_btn').addClass('disabled')
      $('#user_edit_btn').attr('href', 'javascript:;')

    if $('input[id^=user_ck_]:checked').length > 0
      $('#user_delete_btn').removeClass('disabled')
    else
      $('#user_delete_btn').addClass('disabled')

  $('.user-side-form').addClass('hidden')

@initCompanyListingEvents = () ->
  $('#company_add_btn,#company_cancel_btn').on "click", ->
    $('#company_reset_form').click()
    $('.company-side-form,#company_btn_container').toggleClass('hidden')

  $('#company_save_btn').on "click", (event)->
    event.preventDefault()
    event.stopPropagation()
    $('.submit-company-form').click()

  $('#company_delete_btn').on "click", (event)->
    event.preventDefault()
    event.stopPropagation()
    companyIds = []
    $('input[name^=company_ids]:not(.disabled):checked').each (index, element) =>
      companyIds.push($(element).val())

    if companyIds.length > 0
      $.ajax '/companies/destroy_bulk',
        type: 'delete'
        data: {company_ids: companyIds}
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          showSuccessMsg(data.notice)
          $('#companies_listing').html(data.html)
          initCompanyListingEvents()

  $('select').material_select()

  $('input[id^=company_ck_]').on "change", ->
    if $('input[id^=company_ck_]:checked').length == 1
      $('#company_edit_btn').removeClass('disabled')
      url = '/companies/' + $('input[id^=company_ck_]:checked').val() + '/edit?remote=1'
      $('#company_edit_btn').attr('href', url)
    else
      $('#company_edit_btn').addClass('disabled')
      $('#company_edit_btn').attr('href', 'javascript:;')

    if $('input[id^=company_ck_]:checked').length > 0
      $('#company_delete_btn').removeClass('disabled')
    else
      $('#company_delete_btn').addClass('disabled')

  $('.company-side-form').addClass('hidden')

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

    $.get '/companies/settings_listing', (data) ->
      $('#companies_listing').append(data)
      initCompanyListingEvents()
