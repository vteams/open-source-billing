require "elasticsearch/rails/tasks/import"

namespace :elasticsearch do
  namespace :import do
    task combined: :environment do
      SearchIndexManager.create_index(force: true)
      SearchIndexManager.import
    end
  end
end
