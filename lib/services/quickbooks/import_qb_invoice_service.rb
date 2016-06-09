module Services
  class ImportQbInvoiceService

    def import_data(options)
      counter = 0
      invoices = Quickbooks::Service::Invoice.new(:access_token => options[:token_hash], :company_id => options[:realm_id] )
      invoices = invoices.all
      if invoices.present?
        invoices.each do |invoice|
          unless ::Invoice.find_by_provider_id(invoice.id.to_i)
            hash = { provider: 'Quickbooks', provider_id: invoice.id.to_i,
                     invoice_number: invoice.doc_number,
                     po_number: nil,
                     invoice_date: (invoice.ship_date || invoice.meta_data.create_time).to_date,
                     discount_percentage: nil,notes: invoice.private_note,
                     terms: nil, status: 'sent' , company_id: options[:current_company_id],
                     discount_type: '%', invoice_total: invoice.total.to_f }
            osb_invoice=  ::Invoice.new(hash)
            osb_invoice.currency = ::Currency.find_by_unit(invoice.currency_ref.value) if invoice.currency_ref.value.present?
            osb_invoice.client = ::Client.find_by_provider_id(invoice.customer_ref.value.to_i) if invoice.customer_ref.value.present?
            osb_invoice.save
            counter+=1
            amount = 0
            invoice.line_items.each do |item|
              if item.try(:sales_line_item_detail).try(:item_ref).try(:name).present?
                amount += item.amount.to_f
                item_hash = {item_name: item.try(:sales_line_item_detail).try(:item_ref).try(:name), item_description: item.description,
                             item_unit_cost: item.sales_line_item_detail.try(:unit_price).to_f,
                             item_quantity:  item.try(:sales_line_item_detail).try(:quantity)}
                osb_item = osb_invoice.invoice_line_items.new(item_hash)
                #osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                #osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                osb_item.save
              end
            end
            osb_invoice.create_line_item_taxes
            discount_amount = nil #amount * (osb_invoice.discount_percentage/100)
            osb_invoice.update_attributes(sub_total: amount, invoice_total:  amount, discount_amount: discount_amount)
          end
        end
      end
      "invoice #{counter} record(s) successfully imported."
    end
  end
end