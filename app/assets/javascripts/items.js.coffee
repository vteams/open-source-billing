# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#company_association").prop('checked', true)
    # Validate client
  $("form#new_item, form.edit_item,form#create_item").submit ->
    flag = true
    if jQuery.trim($("#item_item_name").val()) is ""
      applyPopover($("#item_item_name"),"Item name is required")
      flag = false
    else if jQuery.trim($("#item_item_description").val()) is ""
      applyPopover($("#item_item_description"),"Description is required")
      flag = false
    else if ($('#company_association').is(':checked') is  false and $('#account_association').is(':checked') is  false)
      $("#company_association").prop('checked', true);
      flag = false
    else if $("#item_unit_cost").val() isnt "" and  isNaN($("#item_unit_cost").val())
      applyPopover($("#item_unit_cost"),"Must be numeric")
      flag = false
    else if $('#company_association').is(':checked')
      if $('.options_content input[type=checkbox]:checked').length is 0
       applyPopover($("#company_association"),"Select a company")
       flag = false
    flag

  applyPopover = (elem,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: "topRight"
      style:
        tip:
          corner: "leftMiddle"
    elem.qtip().show()
    elem.focus()

  hidePopover = (elem) ->
    elem.qtip("hide")

  $("#item_item_name").click ->
    hidePopover($(this))