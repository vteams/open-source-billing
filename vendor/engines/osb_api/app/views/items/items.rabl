collection @items
attributes :id, :item_name, :item_description, :unit_cost, :quantity, :tax_1, :tax_2
node(:company_ids) { |item| CompanyEntity.company_ids(item.id, 'Item') }