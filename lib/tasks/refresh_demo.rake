require 'rake'
namespace :refresh_demo do
  task :refresh_demo_db => :environment do

    if OSB::CONFIG::DEMO_MODE

      Rake::Task['db:drop'].execute
      Rake::Task['db:create'].execute
      Rake::Task['db:migrate'].execute
      Rake::Task['db:seed'].execute

      10.times do
        Company.create!(company_name: Faker::Company.name, account_id: Account.first.id)
      end

      50.times do
        Client.create!(organization_name: Faker::Company.name, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
                       email: Faker::Internet.email, skip_password_validation: true
        )
        CompanyEntity.create!(entity_id: Client.last.id, entity_type: 'Client', parent_id: Account.first.id, parent_type: 'Account')
      end

      50.times do
        Item.create!(item_name: Faker::Commerce.product_name, item_description: Faker::Lorem.sentence(1),
                     unit_cost: Faker::Commerce.price, quantity: 1
        )
        CompanyEntity.create!(entity_id: Item.last.id, entity_type: 'Item', parent_id: Account.first.id, parent_type: 'Account')
      end

      50.times do
        invoice = Invoice.new
        invoice.invoice_date = Date.today
        invoice.due_date = 1.week.from_now
        invoice.payment_terms_id = 5
        invoice.company_id = Company.find(Company.pluck(:id).sample).id
        invoice.client_id = Client.find(Client.pluck(:id).sample).id
        invoice.currency_id = Currency.find(Currency.pluck(:id).sample).id
        invoice.created_by = 1
        invoice.status = "draft"
        invoice.invoice_type = "Invoice"

        i = invoice.invoice_line_items.build
        item=Item.find(Item.pluck(:id).sample)
        i.invoice_id = invoice.id
        i.item_id = item.id
        i.item_name = item.item_name
        i.item_description = item.item_description
        i.item_unit_cost = item.unit_cost
        i.item_quantity = item.quantity
        total = (i.item_unit_cost * i.item_quantity).to_f
        invoice.base_currency_equivalent_total = total
        invoice.save!
      end
      PublicActivity::Activity.where(owner_id: nil).update_all(owner_id: 1, owner_type: "User")

    end

  end

end
