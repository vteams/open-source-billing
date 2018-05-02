module ReportsHelper
  def all_clients_or_individual_client_name(name)
    name.eql?('All Clients') ? (t('views.common.' + name.parameterize.underscore)) : name.capitalize
  end
end
