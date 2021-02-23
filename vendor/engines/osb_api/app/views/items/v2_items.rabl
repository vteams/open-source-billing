object false
node(:total_records) {|m| @items.total_count }
node(:total_pages) {|m| @items.total_pages }
node(:current_page) {|m| @items.current_page }
node(:per_page) {|m| @items.limit_value }
company = Company.find(@current_user.current_company)
node(:max_quantity) {|m| company.items.count > 0 ? company.items.with_deleted.maximum('quantity').to_f : 0 }
node(:max_item_cost) {|m| company.items.count > 0 ? company.items.with_deleted.maximum('unit_cost').to_f : 0 }
child(@items) do
  attributes :id, :item_name, :item_description, :unit_cost, :quantity, :tax_1, :tax_2, :deleted_at
  node(:company_ids) { |item| CompanyEntity.company_ids(item.id, 'Item') }
end