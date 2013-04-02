# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.create([
    {:email => "imran@nxb.com.pk", :crypted_password => "9027ed25057cef842561eb3f58739556e09d85f4"},
    {:email => "muhammad.azeem@nxb.com.pk", :crypted_password => "9027ed25057cef842561eb3f58739556e09d85f4"},
    {:email => "sohail.asghar@nxb.com.pk", :crypted_password => "9027ed25057cef842561eb3f58739556e09d85f4"}
  ])
taxes = Tax.create([{:name => 'VAT', :percentage => 2.5},{:name => 'GST', :percentage => 4}])
tax1,tax2 = taxes.first.id,taxes.last.id

items = Item.create([{
      :item_name => "Item 1",
      :item_description => "Development",
      :unit_cost => "400",
      :quantity => 1,
      :tax_1 => tax1,
      :tax_2 => tax2,
      :track_inventory => true},{
      :item_name => "Item 2",
      :item_description => "Development",
      :unit_cost => "300",
      :quantity => 1,
      :tax_1 => tax1,
      :tax_2 => tax2,
      :track_inventory => true}])
item1,item2 = items.first.id, items.last.id

client = Client.create(
  :organization_name => "NXB",
  :email => "imran@nxb.com.pk",
  :first_name => "Hyper",
  :last_name => "Conversion",
  :home_phone => "000000",
  :mobile_number => "111111",
  :send_invoice_by => "email",
  :country => "Pakistan")

invoice = Invoice.create(
  :invoice_number => "00001",
  :invoice_date => Date.today,
  :discount_percentage => 10,
  :client_id => client.id,
  :terms => "none",
  :notes => "none",
  :sub_total => 700,
  :discount_amount => -70,
  :tax_amount => 37,
  :invoice_total => 667
)

InvoiceLineItem.create([{
      :invoice_id => invoice.id,
      :item_id => item1,
      :item_unit_cost => 400,
      :item_quantity => 1,
      :tax_1 => tax1,
      :tax_2 => tax2},{
      :invoice_id => invoice.id,
      :item_id => item2,
      :item_unit_cost => 300,
      :item_quantity => 1,
      :tax_1 => tax2,
      :tax_2 => tax1
    }])

