module Services
  class ImportQbEstimateService

    def import_data(options)
      counter = 0
      estimates = Quickbooks::Service::Estimate.new(:access_token => options[:token_hash], :company_id => options[:realm_id] )
      estimates = estimates.all
      if estimates.present?
        estimates.each do |estimate|
          unless ::Estimate.find_by_provider_id(estimate.id.to_i)
            hash = { provider: 'Quickbooks', provider_id: estimate.id.to_i,
                     estimate_number: estimate.doc_number,
                     po_number: nil,
                     estimate_date: estimate.ship_date, discount_percentage: nil,notes: estimate.private_note,
                     terms: nil, status: 'sent' , company_id: options[:current_company_id],
                     discount_type: '%', estimate_total: estimate.total.to_f }
            osb_estimate=  ::Estimate.new(hash)
            osb_estimate.currency = ::Currency.find_by_unit(estimate.currency_ref.value) if estimate.currency_ref.value.present?
            osb_estimate.client = ::Client.find_by_provider_id(estimate.customer_ref.value.to_i) if estimate.customer_ref.value.present?
            osb_estimate.save
            counter+=1
            amount = 0
            estimate.line_items.each do |item|
              if item.try(:sales_line_item_detail).try(:item_ref).try(:name).present?
                amount += item.amount.to_f
                item_hash = {item_name: item.try(:sales_line_item_detail).try(:item_ref).try(:name), item_description: item.description,
                             item_unit_cost: item.sales_line_item_detail.try(:unit_price).to_f,
                             item_quantity:  item.try(:sales_line_item_detail).try(:quantity)}
                osb_item = osb_estimate.estimate_line_items.new(item_hash)
                #osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                #osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                osb_item.save
              end
            end
            osb_estimate.create_line_item_taxes
            discount_amount = nil #amount * (osb_estimate.discount_percentage/100)
            osb_estimate.update_attributes(sub_total: amount, estimate_total:  amount, discount_amount: discount_amount)
          end
        end
      end
      "Estimate #{counter} record(s) successfully imported."
    end
  end
end