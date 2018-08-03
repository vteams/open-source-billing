class @FilterBar
  @initSearch: (filters)->
    @search_params = {}
    for f in filters
      fp = f.split(":")
      @search_params[fp[0]] = fp[1]

  @setSearch: (filters)->
    @search_params = {}
    for f in filters
      fp = f.split(":")
      @search_params[fp[0]] = fp[1]
    @updatePage()

  @updatePage: ->
    params = {
      search: @search_params
    }
    $.rails.ajax
      url: window.location.href
      dataType: 'script'
      data: params
      success: (data)->
        $('.ajax-reload').each ->
          $(this).html($(data).find("##{$(this).attr('id')}").html())
