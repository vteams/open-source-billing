class @TaxCalculator
  #window.taxByCategory = ->
  # taxes by category
  # @example
  #   GST 9%  1,200
  #   VAT 3%    400
  #   ABC 6     800

  # itrate to line items
  @applyAllLineItemTaxes = ->
    taxes = []
    jQuery("table.invoice_grid_fields tr:visible, table.estimate_grid_fields tr:visible").each ->
      # TODO: apply discount on lineTotal
      discountPct = parseFloat($("#invoice_discount_percentage, #recurring_profile_discount_percentage, #estimate_discount_percentage").val())
      discountType = $("select#discount_type").val()

      lineTotal = ((parseFloat $(this).find(".cost").val())*(parseFloat $(this).find(".qty").val()))
      lineTotal = 0 if isNaN(lineTotal)
      discountAmount = if discountType == "%" then (lineTotal * discountPct / 100.0 ) else discountPct
      discountAmount = 0 if isNaN(discountAmount)
      discountedLineTotal = lineTotal - discountAmount

      tax1Select = $(this).find("select.tax1 option:selected")
      tax2Select = $(this).find("select.tax2 option:selected")

      tax1Input = $(this).find("#tax_amount")
      discountedLineTotal = 0 if lineTotal == 0

      # calculate tax1
      tax1Name = tax1Select.text()
      tax1Pct = parseFloat tax1Select.attr "data-tax_1"
      tax1Amount = discountedLineTotal * tax1Pct / 100.0

      # calculate tax2
      tax2Name = tax2Select.text()
      tax2Pct = parseFloat tax2Select.attr "data-tax_2"
      tax2Amount = discountedLineTotal * tax2Pct / 100.0

      taxes.push {name: tax1Name, pct: tax1Pct, amount: tax1Amount} if $(this).find("select.tax1 option:selected").text() != "" #if tax1Name && tax1Pct && tax1Amount
      taxes.push {name: tax2Name, pct: tax2Pct, amount: tax2Amount} if $(this).find("select.tax1 option:selected").text() != "" #if tax2Name && tax2Pct && tax2Amount

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

  applySingleLineItemTax = ->
