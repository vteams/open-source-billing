object false
child(@items) do
  attributes :id, :item_name, :item_description, :unit_cost, :quantity, :tax_1, :tax_2, :deleted_at
  node(:company_ids) { |item| CompanyEntity.company_ids(item.id, 'Item') }
end