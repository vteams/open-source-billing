# Inline form handling inside Chosen list
class window.InlineForms

  constructor: (@dropdownId) ->
    # our dropdown and formcontainer to retrieve form html
    @dropdown = jQuery("##{@dropdownId}")
    @formContainerId = @dropdown.attr("data-form-container")
    @resource = @formContainerId.replace /_holder/, ''
    # clients|items|taxes|terms
    # chosen elements
    @chznContainerWidth = @dropdown.attr("data-dropdown-width")
    @chznContainer = jQuery("##{@dropdownId}_chzn")
    @chznDrop = @chznContainer.find(".chzn-drop")
    @chznResults = @chznContainer.find(".chzn-results")
    @chznSearchBox = @chznContainer.find(".chzn-drop .chzn-search input[type=text]")
    @addNewRecordButton = @chznContainer.find(".add-new")
    @inlineFormContainer = null
    # will be set later in showForm method below
    @chznContainerOriginalWidth = parseInt(@chznContainer.css("width"), 10)
    # trigger these event from .js.erb file when record is saved
    @dropdown.on "inlineform:save", (e, new_record) =>
      @dropdown.append(new_record).trigger("liszt:updated")
      @dropdown.trigger("change").trigger("click")
      @appendToAllDropdowns(new_record)
      @hideForm()
      @revertChosenWidth()
      @showQtip()

    # trigger these event from .js.erb file when use press "save & add more"
    @dropdown.on "inlineform:save_and_add_more", (e, new_record) =>
      @dropdown.append(new_record).trigger("liszt:updated")
      @dropdown.trigger("change")
      @appendToAllDropdowns(new_record)
      @showForm()


  # append newly added record to all dropdowns
  appendToAllDropdowns: (new_record) ->
    dropdown_class = @dropdown.attr('class').split(' ')[0]
    dropdown_id = @dropdown.attr('id')
    all_dropdowns = jQuery(".#{dropdown_class}:not('##{dropdown_id}')").append(new_record.replace('selected','')).trigger("liszt:updated")


  # show qtip when record is successfully added and selected
  showQtip: ->
    current_dropdown = @chznContainer
    setTimeout (->
      current_dropdown.qtip({content:
        text: "Record saved and selected",
        hide: event: false, show: event: false,
        position: at: 'bottomMiddle', style: tip: corner: 'topLeft',
        api: onShow:  setTimeout (-> current_dropdown.qtip "destroy"),10000})
      current_dropdown.qtip().show()),300

  showForm: ->
    # code to show form
    @addFormToList()
    # hide chosen list
    @chznResults.hide()
    # hide add new button
    @addNewRecordButton.hide()
    # ajust chosen list width to fit the form
    @adjustChosenWidth()
    # Show form
    @inlineFormContainer.show().find("input:eq(0)").focus()
    # bind the hideForm to form's close button
    @chznContainer.find(".close_btn").live "click", (e) =>
      @hideForm()
      @revertChosenWidth()
    # setup 'save' and 'save & add more' actions
    @setupSaveActions()

    # listen to dropdown hiding event to revert width ajustments back to original
    @dropdown.unbind "liszt:hiding_dropdown liszt:showing_dropdown"
    @dropdown.on "liszt:hiding_dropdown liszt:showing_dropdown", =>
      @hideForm()
      @revertChosenWidth()
      @chznContainer.find(':input').qtip("hide")

  hideForm: =>
    console.log "hiding form... #{@formContainerId}"
    @inlineFormContainer.removeClass("active-form").hide()
    @chznResults.show()
    @addNewRecordButton.show()

  addFormToList: =>
    # clone the form from DOM and append in chozen list and set the inlineForm
    @inlineFormContainer = jQuery(jQuery("##{@formContainerId}").clone().wrap('<p>').parent().html())
    @inlineFormContainer.addClass("active-form")
    @chznContainer.find("##{@formContainerId}").remove()
    @chznResults.after(@inlineFormContainer)

  setupSaveActions: =>
    @chznContainer.find(".btn_large").live "click", (event) =>
      console.log "validating form"
      return unless @validateForm()
      # serialize the inputs in tiny create form
      form_data = @chznContainer.find(".tiny_create_form :input").serialize()
      # add an extra parameter "add_more" if save & add more button is clicked
      form_data += '&add_more=' if jQuery(event.target).hasClass('btn_save_and_add_more')
      jQuery.ajax "/#{@resource}/create",
        type: 'POST'
        data: form_data
        dataType: 'html'
        success: (data, textStatus, jqXHR) =>
          data = JSON.parse(data)
          # check if record already exists in case of items and taxes
          unless data["exists"]
            @dropdown.trigger(data["action"], data["record"])
          else
            unique_field = @chznContainer.find("input[data-unique]")
            unique_field.qtip({content:
              text: "Already exists choose another and try again",
              show: event: false, hide: event: false, position: at: 'rightMiddle', style: tip: corner: 'leftMiddle'})
            unique_field.qtip().show()
            unique_field.focus()
        error: (jqXHR, textStatus, errorThrown) =>
          alert "Error: #{textStatus}"
      event.stopImmediatePropagation()
      false

  adjustChosenWidth: =>
    console.log "adjusting chosen width"
    if @chznContainerWidth?
      @chznContainer.css width: "#{@chznContainerWidth}px", position: "absolute", "z-index": 9999
      @chznDrop.css width: "#{@chznContainerWidth - 2}px"
      @chznSearchBox.css width: "#{@chznContainerWidth - 37}px"
    else
      console.log "no need to adjust width"

  revertChosenWidth: =>
    console.log "reverting chosen width..."
    if @chznContainerWidth?
      console.log "original width: #{@chznContainerOriginalWidth}"
      @chznContainer.css width: "#{@chznContainerOriginalWidth}px", position: "relative", "z-index": ""
      @chznDrop.css width: "#{@chznContainerOriginalWidth - 2}px"
      @chznSearchBox.css width: "#{@chznContainerOriginalWidth - 37}px"
    else
      console.log "no need to revert width"

  validateForm: =>
    valid_form = true
    # fetch all required inputs with empty value
    @chznContainer.find(".tiny_create_form input[required]").each (e, elem) =>
      unless jQuery(elem).val()
        jQuery(elem).qtip({content:
          text: "This field is require",
          show:
            event: false, hide:
              event: false})
        jQuery(elem).qtip().show()
        jQuery(elem).focus()
        valid_form = false
    valid_form
