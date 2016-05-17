module Services
  class ImportEstimateService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        estimates = options[:freshbooks].estimate.list per_page: per_page, page: page+1
        return estimates if estimates.keys.include?('error')
        fb_estimates = estimates['estimates']
        total = fb_estimates['total'].to_i
        page+=1
        if fb_estimates['estimate'].present?

          fb_estimates['estimate'].each do |estimate|
            estimate = fb_estimates['estimate'] if total.eql?(1)
            unless ::Estimate.find_by_provider_id(estimate['estimate_id'].to_i)
              hash = { provider: 'Freshbooks', provider_id: estimate['estimate_id'].to_i, updated_at: estimate['update'],
                       created_at: estimate['update'],estimate_number: estimate['number'],po_number: estimate['po_number'],
                       estimate_date: estimate['date'], discount_percentage: estimate['discount'].to_f,notes: estimate['notes'],
                       terms: estimate['terms'], status: estimate['status'], company_id: options[:current_company_id],
                       discount_type: '%', estimate_total: estimate['amount'].to_f }

              osb_estimate=  ::Estimate.new(hash)
              osb_estimate.currency = ::Currency.find_by_unit(estimate['currency_code']) if estimate['currency_code'].present?
              osb_estimate.client = ::Client.find_by_provider_id(estimate['client_id'].to_i) if estimate['client_id'].present?
              osb_estimate.save
              counter+=1
              amount = 0
              estimate['lines']['line'].each do |item|
                if item['name'].present?
                  amount += item['amount'].to_f
                  item_hash = {item_name: item['name'], item_description: item['description'],
                               item_unit_cost: item['unit_cost'].to_f, item_quantity: item['quantity'].to_f}
                  osb_item = osb_estimate.estimate_line_items.new(item_hash)
                  osb_item.tax_1 = ::Tax.find_by_name_and_percentage(item['tax1_name'], item['tax1_percent'].to_f).try(:id) if item['tax1_name'].present?
                  osb_item.tax_2 = ::Tax.find_by_name_and_percentage(item['tax2_name'],item['tax2_percent'].to_f).try(:id) if item['tax2_name'].present?
                  osb_item.save
                end
              end
              osb_estimate.create_line_item_taxes
              discount_amount = amount * (osb_estimate.discount_percentage/100)
              osb_estimate.update_attributes(sub_total: amount, discount_amount: discount_amount)
            end
          end
        end
      end
      "Estimate #{counter} record(s) successfully imported."
    end

  end
end