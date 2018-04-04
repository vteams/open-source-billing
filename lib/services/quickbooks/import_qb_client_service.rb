module Services
  class ImportQbClientService
    include ClientsHelper
    include PaymentsHelper
    attr_accessor :email

    def import_data(options)
      counter = 0
      entities = []
      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      if qbo_api.all(:customers).count > 0
        qbo_api.all(:customers) do |client|
          begin
            if client.present?
            email = client['PrimaryEmailAddr']['Address'] if qb_client_email?(client['PrimaryEmailAddr'])
            if email.present? && ::Client.find_by_email(email).nil?
              client_hash = {
                              provider:           'Quickbooks',
                              provider_id:        client['Id'].to_i,
                              first_name:         client['GivenName'],
                              last_name:          client['FamilyName'],
                              email:              email,
                              organization_name:  client['CompanyName'],
                              city:               (client['BillAddr']['City'] if client['BillAddr'].present?),
                              province_state:     (client['BillAddr']['CountrySubDivisionCode'] if client['BillAddr'].present?),
                              country:            (client['BillAddr']['Country'] if client['BillAddr'].present?),
                              postal_zip_code:    (client['BillAddr']['PostalCode'] if client['BillAddr'].present?),
                              business_phone:     client['PrimaryPhone'].present? ? client['PrimaryPhone']['FreeFormNumber'] : nil,
                              fax:                client['Fax'].present? ? client['Fax']['FreeFormNumber'] : nil,
                              mobile_number:      client['Mobile'].present? ? client['Mobile']['FreeFormNumber'] : nil,
                              home_phone:         client['AlternatePhone'].present? ? client['AlternatePhone']['FreeFormNumber'] : nil,
                              address_street1:    (((client['BillAddr']['Line1']).to_s +
                                                         (client['BillAddr']['Line2']).to_s +
                                                         (client['BillAddr']['Line3'].to_s) +
                                                         (client['BillAddr']['Line4'].to_s) +
                                                         (client['BillAddr']['Line5'].to_s)) if client['BillAddr'].present?
                                                   ),
                              address_street2:    (((client['ShipAddr']['Line1']).to_s +
                                                         (client['ShipAddr']['Line2']).to_s +
                                                         (client['ShipAddr']['Line3'].to_s) +
                                                         (client['ShipAddr']['Line4'].to_s) +
                                                         (client['ShipAddr']['Line5'].to_s)) if client['ShipAddr'].present?
                                                   ),
                            }
              osb_client=  ::Client.new(client_hash)
              osb_client.currency = ::Currency.find_by_unit(client['CurrencyRef']['value']) if qb_currency?(client['CurrencyRef'])
              osb_client.save
              counter+=1
              entities << {entity_id: osb_client.id, entity_type: 'Client', parent_id: options[:current_company_id], parent_type: 'Company'}
            end
          end
          rescue Exception => e
            p e.inspect
          end
        end
      end
      ::CompanyEntity.create(entities)
      data_import_result_message = "#{counter} record(s) successfully imported."
      module_name = 'Clients'
      ::UserMailer.delay.qb_import_data_result(data_import_result_message, module_name, options[:user])
    end
  end
end
