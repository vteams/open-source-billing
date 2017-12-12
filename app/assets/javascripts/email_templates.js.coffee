# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  # Load Email template when a template type is selected from dropdown list
  jQuery(".email_template_class").on "change", "select#email_template_template_type", ->
      elem = jQuery(this)
      jQuery.ajax '/email_templates/load_email_template',
        type: 'POST'
        data: "id=" +  jQuery(this).find('option:selected').attr('value_id')
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          template = JSON.parse(data)
          container = elem.parents(".email_template_class")
          # populate data
          container.find("input#email_template_email_from").val(template[0])
          container.find("input#email_template_subject").val(template[1])
          tinyMCE.activeEditor.setContent(template[2]);