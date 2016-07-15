module Services
  #invoice related business logic will go here
  class EstimateService
    include DateFormats
    # build a new estimate object
    def self.build_new_estimate(params)
      date_format = self.new.date_format
      if params[:estimate_for_client]
        company_id = get_company_id(params[:estimate_for_client])
        estimate = ::Estimate.new({:estimate_number => ::Estimate.get_next_estimate_number(nil), :estimate_date => Date.today.strftime(date_format), :client_id => params[:estimate_for_client], :company_id => company_id})
        3.times { estimate.estimate_line_items.build() }
      elsif params[:id]
        estimate = ::Estimate.find(params[:id]).use_as_template
        estimate.estimate_line_items.build()
      else
        estimate = ::Estimate.new({:estimate_number => ::Estimate.get_next_estimate_number(nil), :estimate_date => Date.today.strftime(date_format)})
        3.times { estimate.estimate_line_items.build() }
      end
      estimate
    end

    def self.get_company_id(client_id)
      entities = ::Client.select('company_entities.parent_id').
          joins(:company_entities).
          where("company_entities.entity_id=? AND company_entities.entity_type = 'Client' AND company_entities.parent_type = 'Company'", client_id).
          group(:entity_id)
      entities.first.parent_id if entities.present?
    end

    # estimate bulk actions
    def self.perform_bulk_action(params)
      Services::EstimateBulkActionsService.new(params).perform
    end

    def self.get_estimate_for_preview(encrypted_estimate_id)
      estimate_id = OSB::Util::decrypt(encrypted_estimate_id).to_i rescue estimate_id = nil
      estimate = ::Estimate.find_by_id(estimate_id)
      if estimate.blank?
        return ::Estimate.only_deleted.find_by_id(estimate_id).blank? ? nil : "Estimate deleted"
      end
      estimate
    end

  end
end
