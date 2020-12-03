object false
node(:total_records) {|m| @items.total_count }
node(:total_pages) {|m| @items.total_pages }
node(:current_page) {|m| @items.current_page }
node(:per_page) {|m| @items.limit_value }

child(@items) do
  attributes :id, :item_name, :item_description, :unit_cost, :quantity, :tax_1, :tax_2
  node(:company_ids) { |item| CompanyEntity.company_ids(item.id, 'Item') }
end