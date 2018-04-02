module Services
  class ImportQbInvoiceService

    def import_data(options)
      counter = 0

      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      if qbo_api.all(:invoices).count > 0
        qbo_api.all(:invoices) do |invoice|
          if invoice.present?
            unless ::Invoice.find_by_provider_id(invoice['Id'].to_i)
              hash = { provider: 'Quickbooks', provider_id: invoice['Id'].to_i,
                       invoice_number: invoice['DocNumber'],
                       po_number: nil,
                       invoice_date: (invoice['ShipDate'] || invoice['MetaData']['CreateTime']).to_date,
                       discount_percentage: (invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['PercentBased'] ? invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxPercent'] : nil rescue nil),
                       notes: invoice['PrivateNote'],
                       terms: nil, status: invoice['EmailStatus'] == 'NotSet' ? 'Draft' : 'Sent',
                       company_id: options[:current_company_id],
                       discount_type: '%', invoice_total: invoice['TotalAmt'].to_f }
              osb_invoice=  ::Invoice.new(hash)
              osb_invoice.currency = ::Currency.find_by_unit(invoice['CurrencyRef']['value']) if invoice['CurrencyRef'].present? && invoice['CurrencyRef']['value'].present?
              osb_invoice.client = ::Client.find_by_provider_id(invoice['CustomerRef']['value'].to_i) if invoice['CustomerRef'].present? && invoice['CustomerRef']['value'].present?
              osb_invoice.save
              counter+=1
              amount = 0
              invoice['Line'].each do |item|
                if item['SalesItemLineDetail'].present? && item['SalesItemLineDetail']['ItemRef'].present? && item['SalesItemLineDetail']['ItemRef']['name'].present?
                  amount += item['Amount'].to_f
                  item_hash = {item_name: item['SalesItemLineDetail']['ItemRef']['name'],
                               item_description: item['Description'],
                               item_unit_cost: item['SalesItemLineDetail']['UnitPrice'].to_f,
                               item_quantity:  item['SalesItemLineDetail']['Qty'].to_i}
                  osb_item = osb_invoice.invoice_line_items.new(item_hash)
                  #osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                  #osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                  osb_item.save
                end
              end
              osb_invoice.create_line_item_taxes
              discount_amount = nil #amount * (osb_invoice.discount_percentage/100)
              osb_invoice.update_attributes(sub_total: amount, discount_amount: discount_amount)
            end
          end
        end
      end
      "invoice #{counter} record(s) successfully imported."
    end
  end
end