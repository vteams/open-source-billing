object @client
attributes *Client.all.column_names

child(:invoices) do
  attribute :id
end