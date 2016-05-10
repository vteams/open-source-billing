module Services
  class ImportTaxService

    def initialize(options)
      @taxes = options.tax.list
    end


    def import_data
      return @taxes if @taxes.keys.include?("error")
      return {"error" => "Sorry! We couldn't find tax in your account", "code" => "404"} if @taxes["taxes"]["tax"].blank?
      @taxes["taxes"]["tax"].each do |tax|
        unless ::Tax.find_by_provider_id(tax["tax_id"])
          osb_tax = ::Tax.new(name: tax["name"], percentage: tax["rate"], created_at: tax["updated"],
                          updated_at: tax["updated"], provider: "Freshbooks", provider_id: tax["tax_id"])
          osb_tax.save
        end
      end
      {success: "Tax successfully imported"}
    end

  end
end