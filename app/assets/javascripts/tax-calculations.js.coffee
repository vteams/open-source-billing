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
    discountAmount = if discountType == "%" then (lineTotal * discountPct / 100.0 ) else discountPct
    discountAmount = 0 if isNaN(discountAmount)
    discountedLineTotal = lineTotal - discountAmount

    tax1Select = $(this).find("select.tax1 option:selected")
    tax2Select = $(this).find("select.tax2 option:selected")

    discountedLineTotal = 0 if lineTotal == 0

    # calculate tax1
    tax1Name = tax1Select.text()
    tax1Pct = parseFloat tax1Select.attr "data-tax_1"
    tax1Amount = discountedLineTotal * tax1Pct / 100.0

    # calculate tax2
    tax2Name = tax2Select.text()
    tax2Pct = parseFloat tax2Select.attr "data-tax_2"
    tax2Amount = discountedLineTotal * tax2Pct / 100.0

    taxes.push {name: tax1Name, pct: tax1Pct, amount: tax1Amount} #if tax1Name && tax1Pct && tax1Amount
    taxes.push {name: tax2Name, pct: tax2Pct, amount: tax2Amount} #if tax2Name && tax2Pct && tax2Amount

  tlist = {}

  for t in taxes
    #tlist["#{t['name']} #{t['pct']}%"] = (tlist[t["#{t['name']} #{t['pct']}%"]] || 0) + t["amount"] if !isNaN(t["amount"])
    tax_key = t['name'] + " " + t['pct'] + "%"
    tlist[tax_key] = (tlist[tax_key] || 0) + t["amount"] if !isNaN(t["amount"])
    a = (a || 0) + t["amount"] if !isNaN(t["amount"])

#  console.log tlist
  lis = "" # list items
  for tax, amount of tlist
    lis += "<li><span class='grid_summary_title'>#{tax}</span> <span class='grid_summary_description tax_amount'>#{amount}</span></li>\n"

  jQuery(".grid_summary_row.taxes_total").html("<ul>#{lis}</ul>").parents(".grid_summary").find("#invoice_sub_total_lbl, #invoice_discount_amount_lbl, #estimate_sub_total_lbl, #estimate_discount_amount_lbl, .tax_amount").formatCurrency({symbol: window.currency_symbol});