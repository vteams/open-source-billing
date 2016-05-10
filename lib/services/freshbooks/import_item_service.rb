module Services
  class ImportItemService

    def initialize(options)
      @items = options.item.list
    end


    def import_data
      return @items if @items.keys.include?("error")
      return {"error" => "Sorry! We couldn't find item in your account", "code" => "404"} if @items["items"]["item"].blank?
      @items["items"]["item"].each do |item|
        unless ::Item.find_by_provider_id(item["item_id"])
          osb_item = ::Item.new(  item_name: item["name"], item_description: item["description"],
                                  unit_cost: item["unit_cost"], created_at: item["updated"],
                                  updated_at: item["updated"], provider: "Freshbooks",
                                  provider_id: item["item_id"], quantity: item["quantity"]
                              )
          osb_item.tax1 = ::Tax.find_by_provider_id(item["tax1_id"]) unless item["tax1_id"].blank?
          osb_item.tax2 = ::Tax.find_by_provider_id(item["tax2_id"]) unless item["tax2_id"].blank?
          osb_item.save
          ::Company.all.each { |company| company.send(:items) << osb_item }
        end
      end
      {success: "Items successfully imported"}
    end

  end
end