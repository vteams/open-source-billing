module Services
  class ImportClientService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0
      entities = []

      while(per_page* page < total)
        clients = options[:freshbooks].client.list per_page: per_page, page: page+1
        return clients if clients.keys.include?('error')
        fb_clients = clients['clients']
        total = fb_clients['total'].to_i
        page+=1
        unless fb_clients['clients'].blank?

          fb_clients['clients'].each do |client|
            client = fb_clients['clients'] if total.eql?(1)
            unless ::Client.find_by_email(client['email'])
              hash = { provider: 'Freshbooks', provider_id: client['client_id'].to_i, first_name: client['first_name'],
                       last_name: client['last_name'], email: client['email'], organization_name: client['organization'],
                       address_street1: client['p_street1'], address_street2: client['p_street2'], city: client['p_city'],
                       province_state: client['p_state'], postal_zip_code: client['p_code'], business_phone: client['work_phone'],
                       fax: client['fax'], home_phone: client['home_phone'], mobile_number: client['mobile'],
                       updated_at: client['update'], created_at: client['update'] }

              osb_client=  ::Client.new(hash)
              osb_client.currency = ::Currency.find_by_unit(client['currency_code']) if client['currency_code'].present?
              osb_client.save
              counter+=1
              options[:company_ids].each do |c_id|
                entities << {entity_id: osb_client.id, entity_type: 'Client', parent_id: c_id, parent_type: 'Company'}
              end

            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Client #{counter} record(s) successfully imported."
    end

  end
end