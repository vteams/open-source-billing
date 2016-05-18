module Services
  class ImportInvoiceService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        invoices = options[:freshbooks].invoice.list per_page: per_page, page: page+1
        return invoices if invoices.keys.include?('error')
        fb_invoices = invoices['invoices']
        total = fb_invoices['total'].to_i
        page+=1
        if fb_invoices['invoice'].present?

          fb_invoices['invoice'].each do |invoice|
            invoice = fb_invoices['invoice'] if total.eql?(1)
            unless ::Invoice.find_by_provider_id(invoice['invoice_id'].to_i)
              hash = { provider: 'Freshbooks', provider_id: invoice['invoice_id'].to_i, updated_at: invoice['update'],
                       created_at: invoice['update'],invoice_number: invoice['number'],po_number: invoice['po_number'],
                       invoice_date: invoice['date'], discount_percentage: invoice['discount'].to_f,notes: invoice['notes'],
                       terms: invoice['terms'], status: invoice['status'], company_id: options[:current_company_id],
                       discount_type: '%', invoice_total: invoice['amount'].to_f, invoice_type: 'Invoiced'
                      }

              osb_invoice=  ::Invoice.new(hash)
              osb_invoice.currency = ::Currency.find_by_unit(invoice['currency_code']) if invoice['currency_code'].present?
              osb_invoice.client = ::Client.find_by_provider_id(invoice['client_id']) if invoice['client_id'].present?
              osb_invoice.save
              counter+=1
              amount = 0
              invoice['lines']['line'].each do |item|
                if item['name'].present?
                  amount += item['amount'].to_f
                  item_hash = {item_name: item['name'], item_description: item['description'],
                               item_unit_cost: item['unit_cost'].to_f, item_quantity: item['quantity'].to_f}
                  osb_item = osb_invoice.invoice_line_items.new(item_hash)
                  osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                  osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                  osb_item.save
                end
              end
              osb_invoice.create_line_item_taxes
              discount_amount = amount * (osb_invoice.discount_percentage/100)
              osb_invoice.update_attributes(sub_total: amount, discount_amount: discount_amount)
            end
          end
        end
      end
      "Invoice #{counter} record(s) successfully imported."
    end

  end
end