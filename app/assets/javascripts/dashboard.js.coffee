# dashboard related js code
class @Dashboard

  @plot_graph = ->
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
        title: text: I18n.t("views.invoices.invoice_chart")
        legend:
          layout: 'vertical'
          align: 'left'
          verticalAlign: 'top'
          x: 100
          y: 100
          floating: true
          borderWidth: 1
          backgroundColor: Highcharts.theme and Highcharts.theme.legendBackgroundColor or '#FFFFFF'
        xAxis: categories: chart_ticks
        yAxis: title: text: I18n.t("views.invoices.invoice")
        tooltip:
          shared: true
          valuePrefix: currency_code
        credits: enabled: false
        plotOptions: areaspline: fillOpacity: 0.5
        series: [
          {
            name: I18n.t("views.invoices.invoice")
            data: invoices
            color: '#00BDE5'
          }
          {
            name: I18n.t("views.invoices.paid_invoices")
            data: payments
            color: '#8EC42A'
          }
        ],
        exporting: { enabled: false }
# report data
jQuery ->
  $('#currency').chosen
    disable_search: true
  $("#currency").change ->
    window.location = '/dashboard?currency=' + $(this).val()
  Dashboard.plot_graph();