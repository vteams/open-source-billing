# dashboard related js code

# report data
jQuery ->
  $('#currency').chosen
    disable_search: true
  $("#currency").change ->
    window.location = '/dashboard?currency=' + $(this).val()

  # chart options
  if gon? and gon.chart_data
    chart_ticks = gon.chart_data["ticks"]
    currency_code = gon.currency_code
    currency_id = gon.currency_id
  else
    currency_code = $("body").attr("currency-unit")

  if gon? and gon.chart_data
    invoices = gon.chart_data["invoices"]
    payments = gon.chart_data["payments"]
    chart_data = [invoices, payments]

    Highcharts.chart 'graph_container',
      chart: type: 'areaspline'
      title: text: 'Invoice Graph  '
      legend:
        layout: 'vertical'
        align: 'left'
        verticalAlign: 'top'
        x: 150
        y: 100
        floating: true
        borderWidth: 1
        backgroundColor: Highcharts.theme and Highcharts.theme.legendBackgroundColor or '#FFFFFF'
      xAxis: categories: chart_ticks
      yAxis: title: text: 'Invoices'
      tooltip:
        shared: true
        valuePrefix: currency_code
      credits: enabled: false
      plotOptions: areaspline: fillOpacity: 0.5
      series: [
        {
          name: 'Invoices'
          data: invoices
          color: '#00BDE5'
        }
        {
          name: 'Paid Invoices'
          data: payments
          color: '#8EC42A'
        }
      ],
      exporting: { enabled: false }