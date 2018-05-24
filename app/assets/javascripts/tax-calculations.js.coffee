# taxes by category
# @example
#   GST 9%  1,200
#   VAT 3%    400
#   ABC 6     800

# itrate to line items
window.taxByCategory = ->
  taxes = []
  jQuery("table.invoice_grid_fields tr:visible, table.estimate_grid_fields tr:visible").each ->
    # TODO: apply discount on lineTotal
    discountPct = parseFloat($("#invoice_discount_percentage, #recurring_profile_discount_percentage, #estimate_discount_percentage").val())
    discountType = $("select#discount_type").val()

    lineTotal = parseFloat $(this).find(".line_total").text()
    lineTotal = 0 if isNaN(lineTotal)

    tax1Input = $(this).find("#tax_amount")

    # calculate tax1
    tax1Name = $(this).find('td.center-align.tax1').text().trim()
    tax1Pct = parseFloat tax1Input.val()
    tax1Amount = lineTotal * tax1Pct / 100.0

    if $(this).find('td.center-align.tax1').text() != ""
      taxes.push {name: tax1Name, pct: tax1Pct, amount: tax1Amount} #if tax1Name && tax1Pct && tax1Amount

  tlist = {}

  for t in taxes
    #tlist["#{t['name']} #{t['pct']}%"] = (tlist[t["#{t['name']} #{t['pct']}%"]] || 0) + t["amount"] if !isNaN(t["amount"])
    tax_key = t['name'] + " " + t['pct'] + "%"
    tlist[tax_key] = (tlist[tax_key] || 0) + t["amount"] if !isNaN(t["amount"])
    a = (a || 0) + t["amount"] if !isNaN(t["amount"])

  lis_lab = "" # list items
  lis_tax = "" # list items
  for tax, amount of tlist
    lis_lab += $("<span><li><span>#{tax}</span></li></span>").html()
    tax_val = $("<span>#{amount}</span>").formatCurrency({symbol: window.currency_symbol}).html()
    lis_tax += $("<span><li><span>" + tax_val + "</span></li></span>").html()

  jQuery(".invoice-total-left .new-invoice-footer-row.taxes_total").html("<ul>#{lis_lab}</ul>")
  jQuery(".invoice-total-right .new-invoice-footer-row.taxes_total").html("<ul>#{lis_tax}</ul>")