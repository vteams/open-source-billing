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

    currentUserSelected = false
    # error msg on selecting invalid user
    $('input[name^=user_ids].disabled:checked').each (index, element) =>
      showErrorMsg(I18n.t('views.users.cannot_delete_current_user'))
      currentUserSelected = true

    userIds = []
    $('input[name^=user_ids]:not(.disabled):checked').each (index, element) =>
      userIds.push($(element).val())

    # Bulk user delete ajax request while clicking on delete btn
    if userIds.length > 0 && !currentUserSelected
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
    # active/deactive delete button on selecting/deselecting users
    if $('input[id^=user_ck_]:checked').length > 0
      $('#user_delete_btn').removeClass('disabled')
    else
      $('#user_delete_btn').addClass('disabled')

    # Add/remove error class if invalid user is selected
    if $('input[name^=user_ids].disabled:checked').length > 0
      $('#user_delete_btn').addClass('error')
    else
      $('#user_delete_btn').removeClass('error')

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
    currentCompanySelected = false
    # Error msg on selecting invalid company
    $('input[name^=company_ids].disabled:checked').each (index, element) =>
      showErrorMsg(I18n.t('views.companies.current_company_action', action: 'deleted'))
      currentCompanySelected = true

    $('input[name^=company_ids]:not(.disabled):checked').each (index, element) =>
      companyIds.push($(element).val())

    # Ajax call for deleteing bulk companies while clicking on delete btn
    if companyIds.length > 0 && !currentCompanySelected
      $.ajax '/companies/destroy_bulk',
        type: 'delete'
        data: {company_ids: companyIds}
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          showSuccessMsg(data.notice)
          $('#companies_listing').html(data.html)
          initCompanyListingEvents()
  @Company.init_settings_form()

  $('select').material_select()

  $('input[id^=company_ck_]').on "change", ->
    # disable/enable delete btn on selecting/deselecting companies
    if $('input[id^=company_ck_]:checked').length > 0
      $('#company_delete_btn').removeClass('disabled')
    else
      $('#company_delete_btn').addClass('disabled')

    # Add/remove error class if invalid company is selected
    if $('input[name^=company_ids].disabled:checked').length > 0
      $('#company_delete_btn').addClass('error')
    else
      $('#company_delete_btn').removeClass('error')

  $('.company-side-form').addClass('hidden')

@loadUsersActivitiesSection = () ->
  $.get '/sub_users/settings_listing', (data) ->
    $('#users_listing').append(data)
    initUserListingEvents()

@loadCompaniesActivitiesSection = () ->
  $.get '/companies/settings_listing', (data) ->
    $('#companies_listing').append(data)
    initCompanyListingEvents()

jQuery ->
  jQuery('.country-item').on "click", ->
    currency_id = $(this).data('id')
    user_id = $(this).data('user-id')
    url = "/settings/"+user_id+"/set_default_currency?currency_id="+currency_id
    jQuery.get url, (response) ->
      window.location.reload()
