module Services
  class ImportQbInvoiceService

    def import_data(options)
      counter = 0

      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      if qbo_api.all(:invoices).count > 0
        qbo_api.all(:invoices) do |invoice|
          begin
            if invoice.present?
            unless ::Invoice.find_by_provider_id(invoice['Id'].to_i)
              if invoice['Line'].last['DetailType'].eql?('DiscountLineDetail')
                discount_per =  invoice['Line'].last['DiscountLineDetail']['DiscountPercent'] if invoice['Line'].last['DiscountLineDetail']['PercentBased']
                discount_amount = invoice['Line'].last['Amount']
                discount_type = invoice['Line'].last['DiscountLineDetail']['PercentBased'] ? '%' : invoice['CurrencyRef']['value']
              end
              hash = { provider: 'Quickbooks', provider_id: invoice['Id'].to_i,
                       invoice_number: invoice['DocNumber'],
                       po_number: nil,
                       invoice_date: (invoice['ShipDate'] || invoice['MetaData']['CreateTime']).to_date,
                       # discount_percentage: (invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['PercentBased'] ? invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxPercent'] : nil rescue nil),
                       notes: invoice['PrivateNote'],
                       terms: nil, status: invoice['EmailStatus'] == 'NotSet' ? 'Draft' : 'Sent',
                       company_id: options[:current_company_id],
                       discount_type: discount_type,
                       invoice_total: invoice['TotalAmt'].to_f,
                       discount_percentage: discount_per,
                       discount_amount: discount_amount}
              osb_invoice=  ::Invoice.new(hash)
              osb_invoice.currency = ::Currency.find_by_unit(invoice['CurrencyRef']['value']) if invoice['CurrencyRef'].present? && invoice['CurrencyRef']['value'].present?
              osb_invoice.client = ::Client.find_by_provider_id(invoice['CustomerRef']['value'].to_i) if invoice['CustomerRef'].present? && invoice['CustomerRef']['value'].present?
              osb_invoice.save
              counter+=1
              amount = 0
              invoice['Line'].each do |item|
                if item['SalesItemLineDetail'].present? && item['SalesItemLineDetail']['ItemRef'].present? && item['SalesItemLineDetail']['ItemRef']['name'].present?
                  amount += item['Amount'].to_f
                  qb_tax_id = invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxRateRef']['value'] if invoice['TxnTaxDetail'] && invoice['TxnTaxDetail']['TaxLine'].present? &&
                      invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxRateRef']
                  if qb_tax_id.present?
                    qb_tax = qbo_api.query(%{SELECT * FROM TaxRate  WHERE Id = '#{qb_tax_id.to_i}'}).first
                    osb_tax = ::Tax.find_by_name_and_percentage(qb_tax['Name'], qb_tax['RateValue'].to_f)
                    if osb_tax.present?
                      tax_1 = osb_tax.id
                    else
                      new_tax = ::Tax.create(name: qb_tax['Name'], percentage: qb_tax['RateValue'].to_f)
                      tax_1 = new_tax.id
                    end
                  end
                  item_hash = {item_name: item['SalesItemLineDetail']['ItemRef']['name'],
                               item_description: item['Description'],
                               item_unit_cost: item['SalesItemLineDetail']['UnitPrice'].to_f,
                               item_quantity:  item['SalesItemLineDetail']['Qty'].to_i, tax_1: tax_1}
                  osb_item = osb_invoice.invoice_line_items.new(item_hash)
                  osb_item.save
                end
              end
              osb_invoice.create_line_item_taxes
              osb_invoice.update_attributes(sub_total: amount)
            end
            end
          rescue Exception => e
            p e.inspect
          end
        end
      end
      "invoice #{counter} record(s) successfully imported."
    end
  end
end