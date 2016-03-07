json.array! @logs do |log|
  #json.extract! log, :id, :name, :description
  json.title "#{log[1].to_i}"
  json.start  log[0].strftime('%Y-%m-%d')
end