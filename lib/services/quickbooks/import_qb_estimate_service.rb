module Services
  class ImportQbEstimateService

    def import_data(options)
      counter = 0

      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      qbo_api.all(:estimates).each do |estimate|
        if estimate.present?
          unless ::Estimate.find_by_provider_id(estimate['Id'].to_i)
            hash = { provider: 'Quickbooks', provider_id: estimate['Id'].to_i,
                     estimate_number: estimate['DocNumber'],
                     po_number: nil,
                     estimate_date: (estimate['ShipDate'] || estimate['MetaData']['CreatedTime']).to_date,
                     discount_percentage: nil,
                     notes: estimate['PrivateNote'],
                     terms: nil, status: estimate['EmailStatus'] == 'NotSet' ? 'Draft' : 'Sent',
                     company_id: options[:current_company_id],
                     discount_type: '%', estimate_total: estimate['TotalAmt'].to_f }
            osb_estimate=  ::Estimate.new(hash)
            osb_estimate.currency = ::Currency.find_by_unit(estimate['CurrencyRef']['value']) if estimate['CurrencyRef'].present? && estimate['CurrencyRef']['value'].present?
            osb_estimate.client = ::Client.find_by_provider_id(estimate['CustomerRef']['value'].to_i) if estimate['CustomerRef'].present? && estimate['CustomerRef']['value'].present?
            osb_estimate.save
            counter+=1
            amount = 0
            estimate['Line'].each do |item|
              if item['SalesItemLineDetail'].present? && item['SalesItemLineDetail']['ItemRef'].present? && item['SalesItemLineDetail']['ItemRef']['name'].present?
                amount += item['Amount'].to_f
                item_hash = {item_name: item['SalesItemLineDetail']['ItemRef']['name'],
                             item_description: item['Description'],
                             item_unit_cost: item['SalesItemLineDetail']['UnitPrice'].to_f,
                             item_quantity:  item['SalesItemLineDetail']['Qty'].to_i}
                osb_item = osb_estimate.estimate_line_items.new(item_hash)
                #osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                #osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                osb_item.save
              end
            end
            osb_estimate.create_line_item_taxes
            discount_amount = nil #amount * (osb_estimate.discount_percentage/100)
            osb_estimate.update_attributes(sub_total: amount, discount_amount: discount_amount)
          end
        end
      end
      "Estimate #{counter} record(s) successfully imported."
    end
  end
end