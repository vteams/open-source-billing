module Services
  class ImportQbClientService
    attr_accessor :email

    def import_data(options)
      counter = 0
      entities = []
      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      if qbo_api.all(:customers).count > 0
        qbo_api.all(:customers) do |client|
          if client.present?
            email = client['PrimaryEmailAddr']['Address'] if client['PrimaryEmailAddr'].present? && client['PrimaryEmailAddr']['Address'].present?
            if email.present? && ::Client.find_by_email(email).nil?
              hash = { provider: 'Quickbooks', provider_id: client['Id'].to_i, first_name: client['GivenName'],
                       last_name: client['FamilyName'], email: email, organization_name: client['CompanyName'],
                       address_street1: ((
                                          (client['BillAddr']['Line1']).to_s +
                                              (client['BillAddr']['Line2']).to_s +
                                              (client['BillAddr']['Line3'].to_s) +
                                              (client['BillAddr']['Line4'].to_s) +
                                              (client['BillAddr']['Line5'].to_s)) if client['BillAddr'].present?),
                       address_street2: nil, city: (client['BillAddr']['City'] if client['BillAddr'].present?),
                       province_state: nil, country: (client['BillAddr']['CountrySubDivisionCode'] if client['BillAddr'].present?),
                       postal_zip_code: (client['BillAddr']['PostalCode'] if client['BillAddr'].present?),
                       business_phone: client['PrimaryPhone'].present? ? client['PrimaryPhone']['FreeFormNumber'] : nil,
                       fax: client['FaxPhone'].present? ? client['FaxPhone']['FreeFormNumber'] : nil,
                       home_phone: client['AlternatePhone'].present? ? client['AlternatePhone']['FreeFormNumber'] : nil,
                       mobile_number: client['MobilePhone'].present? ? client['MobilePhone']['FreeFormNumber'] : nil
                      }

              osb_client=  ::Client.new(hash)
              osb_client.currency = ::Currency.find_by_unit(client['CurrencyRef']['value']) if client['CurrencyRef'].present? && client['CurrencyRef']['value'].present?
              osb_client.save
              counter+=1
              entities << {entity_id: osb_client.id, entity_type: 'Client', parent_id: options[:current_company_id], parent_type: 'Company'}

            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Client #{counter} record(s) successfully imported."
    end
  end
end