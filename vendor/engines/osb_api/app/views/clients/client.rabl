collection @clients
attributes *Client.column_names
node(:company_ids) { |client| CompanyEntity.company_ids(client.id, 'Client') }