module Services
  class ImportTaxService

    def import_data(options)
      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        taxes = options[:freshbooks].tax.list per_page: per_page, page: page+1
        return taxes if taxes.keys.include?('error')
        fb_taxes = taxes['taxes']
        total = fb_taxes['taxes'].to_i
        page+=1
        unless fb_taxes['tax'].blank?

          fb_taxes['tax'].each do |tax|
            tax= fb_taxes['tax'] if fb_taxes.eql?(1)
            unless ::Tax.find_by_provider_id(tax['tax_id'].to_i)
              hash = { name: tax['name'], percentage: tax['rate'], created_at: tax['updated'],
                       updated_at: tax['updated'], provider: 'Freshbooks', provider_id: tax['tax_id'].to_i }

              ::Tax.create(hash)
              counter+=1
            end
          end
        end
      end
      "Tax #{counter} record(s) successfully imported."
    end

  end
end