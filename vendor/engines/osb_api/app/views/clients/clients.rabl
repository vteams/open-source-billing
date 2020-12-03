object false
node(:total_records) {|m| @clients.total_count }
node(:total_pages) {|m| @clients.total_pages }
node(:current_page) {|m| @clients.current_page }
node(:per_page) {|m| @clients.limit_value }

child(@clients) do
  attributes *Client.column_names
  node(:company_ids) { |client| CompanyEntity.company_ids(client.id, 'Client') }
end
