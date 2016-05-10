module Services
  class ImportClientsService

    def initialize(options)
      @options = options
      @clients = options.client.list
    end


    def import_data
      return @clients if @clients.keys.include?("error")
      return {"error" => "Sorry! We couldn't find client in your account", "code" => 404} if @clients["clients"]["client"].blank?
      @clients["clients"]["client"].each do |client|
        unless ::Client.find_by_email(client["email"])
          osb_client=  ::Client.new(
              provider: "Freshbooks", provider_id: client["client_id"], first_name: client["first_name"],
              last_name: client["last_name"], email: client["email"], organization_name: client["organization"],
              address_street1: client["p_street1"], address_street2: client["p_street2"], city: client["p_city"],
              province_state: client["p_state"], postal_zip_code: client["p_code"], business_phone: client["work_phone"],
              fax: client["fax"], home_phone: client["home_phone"], mobile_number: client["mobile"],
              updated_at: client["update"],  created_at: client["update"]
          )
          osb_client.currency = ::Currency.find_by_unit(client["currency_code"])
          osb_client.save
          ::Company.all.each { |company| company.send(:clients) << osb_client }
        end
      end

      {success: "Client successfully imported"}
    end

  end
end