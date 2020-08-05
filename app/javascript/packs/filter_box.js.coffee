Array.prototype.getObjectBy = (name, value)->
  for object in this
    return object if object[name] == value
  return null

class @FilterBox
  filterbar = require('./filter_bar.js').filterbar

  constructor: (@element) ->
    @filter_fields = $(@element).data('filter-fields')
    @setupSelect2()
    filterbar.initSearch($(@element).select2('val'))

  setupSelect2: ->
    $(@element).select2(
      placeholder: "Search"
      minimumInputLength: 2
      containerCssClass: 'hd-filter-box-container'
      multiple: true
      formatResult:FilterBox.filterBoxOptionsFormat
      formatSelection:FilterBox.filterBoxTagFormat
      query: (query)=>
        data = {results: []}
        for filter in @filter_fields
          data.results.push {id: "#{filter.key}:#{query.term}", key: filter.key, label: filter.label, term: query.term}
        query.callback data
      initSelection: (element, callback)=>
        data = []
        for k,v of $(@element).data('filter-pre-populate')
          if @filter_fields.getObjectBy('key', k)
            data.push {id: "#{k}:#{v}", key: k, label: @filter_fields.getObjectBy('key', k).label, term: v}
        callback(data)
    ).on('change', (event)->
      FilterBar.setSearch(event.val)
    ).select2('val', 'initValue')

  @filterBoxOptionsFormat: (object, container, query)->
    "#{object.label}: <strong>#{object.term}</strong>"

  @filterBoxTagFormat: (selection)->
    "<span class='label'>#{selection.label}</span> #{selection.term}"


exports.filterbox = @FilterBox