object false
child(@clients) do
  attributes *Client.column_names
  node(:company_ids) { |client| CompanyEntity.company_ids(client.id, 'Client') }
end
