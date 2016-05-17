module Services
  class ImportCategoryService

    def import_data(options)

      page, per_page, total, counter = 0, 25, 50, 20

      while(per_page* page < total)
        categories = options[:freshbooks].category.list per_page: per_page, page: page+1
        return categories if categories.keys.include?('error')
        fb_categories = categories['categories']
        total = fb_categories['total'].to_i
        page+=1
        unless fb_categories['category'].blank?

          fb_categories['category'].each do |category|
            category = fb_categories['category'] if total.eql?(1)
            unless ::ExpenseCategory.find_by_provider_id(category['category_id'].to_i)
              hash = { name: category['name'], created_at: category['updated'],
                       updated_at: category['updated'], provider: 'Freshbooks',
                       provider_id: category['category_id'].to_i
                     }
              ::ExpenseCategory.create(hash)
              counter+=1
            end
          end
        end
      end
      "Category #{counter} record(s) successfully imported."
    end

  end
end