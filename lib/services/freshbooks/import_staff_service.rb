module Services
  class ImportStaffService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0
      entities = []


      while(per_page* page < total)
        staffs = options[:freshbooks].staff.list per_page: per_page, page: page+1
        return staffs if staffs.keys.include?('error')
        fb_staffs = staffs['staff_members']
        total = fb_staffs['total'].to_i
        page+=1
        if fb_staffs['member'].present?
          fb_staffs['member'].each do |staff|
            staff = fb_staffs['member'] if total.eql?(1)
            unless ::Staff.find_by_provider_id(staff['staff_id'].to_i)
              hash = {name: staff['first_name'] + staff['last_name'], email: staff['email'],
                      rate: staff['rate'].to_f, created_at: staff['updated'],
                      updated_at: staff['updated'], provider: 'Freshbooks',
                      provider_id: staff['staff_id'].to_i, company_id: options[:current_company_id]}
              osb_staff = ::Staff.create(hash)
              counter+=1
              options[:company_ids].each do |c_id|
                entities << {entity_id: osb_staff.id, entity_type: 'Staff', parent_id: c_id, parent_type: 'Company'}
              end
            end
          end
        end
      end
      ::CompanyEntity.create(entities)
      "Staff #{counter} record(s) successfully imported."
    end

  end
end