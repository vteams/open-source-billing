module ProjectsHelper

  def load_clients_for_project
    Client.all.map{|c| [c.organization_name, c.id]}
  end

  def load_billing_methods_for_project
    CONST::BillingMethod::TYPES.map{|bm| [bm, bm]}
  end
end
