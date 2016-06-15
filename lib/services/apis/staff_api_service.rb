module Services
  module Apis
    class StaffApiService

      def self.create(params)
        user = User.find(params[:user_id])
        company_id =  params[:staff][:company_id] || user.current_company || user.first_company_id
        company = ::Company.find(company_id)
        staff = ::Staff.new(staff_params_api(params))
        if staff.save
          associated_company(company, staff)
          {message: 'Successfully created'}
        else
          {error: staff.errors.full_messages}
        end
      end

      def self.update(params)
        staff = ::Staff.find(params[:id])
        company = ::Company.find_by_id(params[:staff][:company_id])  unless params[:staff][:company_id].blank?
        if staff.present?
          if staff.update_attributes(staff_params_api(params))
            associated_company(company, staff, "update") if company.present?
            {message: 'Successfully updated'}
          else
            {error: staff.errors.full_messages}
          end
        else
          {error: 'Account not found'}
        end
      end

      def self.destroy(params)
        if ::Staff.destroy(params)
          {message: 'Successfully deleted'}
        else
          {message: 'Not deleted'}
        end
      end

      private

      def self.staff_params_api(params)
        ActionController::Parameters.new(params).require(:staff).permit(
            :email,
            :name,
            :rate,
            :company_id,
            :created_by,
            :updated_by
        )
      end

      def self.associated_company(company, staff, action=nil)
        if action == "update"
          associated_companies =  CompanyEntity.where(entity_id: staff.id, entity_type: staff.class.to_s)
          associated_companies.map(&:destroy) if associated_companies.present?
        end
        company.send(:staffs) << staff unless company.blank?
      end

    end
  end
end