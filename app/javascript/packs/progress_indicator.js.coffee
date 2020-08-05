# Progress indicator
square = new Sonic(
  width: 100
  height: 100
  stepsPerFrame: 1
  trailLength: 1
  pointDistance: 0.05
  strokeColor: "#00BDE5"
  fps: 20
  setup: ->
    @_.lineWidth = 4

  step: (point, index) ->
    cx = @padding + 50
    cy = @padding + 50
    _ = @_
    angle = (Math.PI / 180) * (point.progress * 360)
    innerRadius = (if index is 1 then 10 else 25)
    _.beginPath()
    _.moveTo point.x, point.y
    _.lineTo (Math.cos(angle) * innerRadius) + cx, (Math.sin(angle) * innerRadius) + cy
    _.closePath()
    _.stroke()

  path: [["arc", 50, 50, 40, 0, 360]]
)
$ ->
  square.play()
  jQuery("#progress_indicator").append square.canvas

  $(document).ajaxStart ->
    $("#progress_indicator").show()
    $(".alert").hide()

  $(document).ajaxComplete ->
    jQuery(".text-overflow-class").each ->
      rows = jQuery(this).attr('data-overflow-rows') || 2
      jQuery(this).ellipsis row:rows
    setTimeout (->
      $("#progress_indicator").hide()
    ), 100
