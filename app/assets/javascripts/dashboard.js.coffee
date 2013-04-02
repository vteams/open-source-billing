# dashboard related js code

# report data
jQuery ->

  # chart options
  chart_ticks = gon.chart_data["ticks"] if gon?

  chart_defaults =
    renderer: jQuery.jqplot.BarRenderer
    rendererOptions:
      fillToZero: true
      barWidth: 10
      barPadding: 0

  chart_series =  [
    label: "Invoices"
    shadow: false
    color: '#00BDE5'
  ,
    label: "Paid Invoices"
    shadow: false
    color: '#8EC42A'
  ]

  chart_legend = show: true, placement: "insideGrid"

  chart_xaxis =
    renderer: jQuery.jqplot.CategoryAxisRenderer
    ticks: chart_ticks
    tickOptions:
      showGridline: false


  chart_yaxis = pad: 0, tickOptions:
    formatString: "$%d"
    showMark: false

  chart_axis =
    xaxis: chart_xaxis
    yaxis: chart_yaxis

  chart_grid =
    background: '#FFFFFF'
    drawBorder: false
    shadow: false
    borderWidth: 0.5

  chart_options =
    seriesDefaults: chart_defaults
    series: chart_series
    legend: chart_legend
    axes: chart_axis
    grid: chart_grid
    axesDefaults:
      rendererOptions:
        drawBaseline: false

  if gon?
    invoices = gon.chart_data["invoices"]
    payments = gon.chart_data["payments"]
    chart_data = [invoices, payments]

  try
    jQuery.jqplot "dashboard-chart", chart_data, chart_options
  catch e




