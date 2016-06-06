module Services
  class ImportQbClientService
    attr_accessor :email

    def import_data(options)
      counter = 0
      entities = []

        clients = Quickbooks::Service::Customer.new(:access_token => options[:token_hash], :company_id => options[:realm_id] )
        clients = clients.all
        if clients.present?
          clients.each do |client|
            email = client.try(:primary_email_address).try(:address)
            if email.present? && ::Client.find_by_email(email).nil?
              hash = { provider: 'Quickbooks', provider_id: client.id.to_i, first_name: client.given_name,
                       last_name: client.family_name, email: email, organization_name: client.company_name,
                       address_street1: (client.billing_address.try(:line1)).to_s + (client.billing_address.try(:line2).to_s) + (client.billing_address.try(:line3).to_s) + (client.billing_address.try(:line4).to_s) + (client.billing_address.try(:line5).to_s),
                       address_street2: nil, city: client.billing_address.city,
                       province_state: nil, country: client.billing_address.country, postal_zip_code: client.billing_address.try(:postal_code),
                       business_phone: client.primary_phone.present? ? client.primary_phone.try(:free_form_number) : nil,
                       fax: client.fax_phone.try(:free_form_number), home_phone: client.alternate_phone.try(:free_form_number), mobile_number: client.mobile_phone.try(:free_form_number)
                      }

              osb_client=  ::Client.new(hash)
              osb_client.currency = ::Currency.find_by_unit(client['currency_code']) if client['currency_code'].present?
              osb_client.save
              counter+=1
              entities << {entity_id: osb_client.id, entity_type: 'Client', parent_id: options[:current_company_id], parent_type: 'Company'}

            end

            end
        end
        ::CompanyEntity.create(entities)
        "Client #{counter} record(s) successfully imported."
        end
    end
end