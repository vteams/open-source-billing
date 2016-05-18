module Services
  class ImportItemService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0
      entities = []

      while(per_page* page < total)
        items = options[:freshbooks].item.list per_page: per_page, page: page+1
        return items if items.keys.include?('error')
        fb_items = items['items']
        total = fb_items['total'].to_i
        page+=1
        unless fb_items['item'].blank?

          fb_items['item'].each do |item|
            item = fb_items['item'] if total.eql?(1)
            unless ::Item.find_by_provider_id(item['item_id'].to_i)
              hash = {  item_name: item['name'], item_description: item['description'],
                        unit_cost: item['unit_cost'], created_at: item['updated'],
                        updated_at: item['updated'], provider: 'Freshbooks',
                        provider_id: item['item_id'].to_i, quantity: item['quantity'] }
              osb_item = ::Item.new (hash)
              osb_item.tax1 = ::Tax.find_by_provider_id(item['tax1_id'].to_i) unless item['tax1_id'].blank?
              osb_item.tax2 = ::Tax.find_by_provider_id(item['tax2_id'].to_i) unless item['tax2_id'].blank?
              osb_item.save
              counter+=1
              options[:company_ids].each do |c_id|
                entities << {entity_id: osb_item.id, entity_type: 'Item', parent_id: c_id, parent_type: 'Company'}
              end

            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Item #{counter} record(s) successfully imported."
    end
  end
end