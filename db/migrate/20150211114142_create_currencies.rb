class CreateCurrencies < ActiveRecord::Migration
  def self.up
    unless table_exists? :currencies
      create_table(:currencies, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
        t.string   "title"
        t.string   "code"
        t.string   "unit"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
    end
  end

  def self.down
    drop_table :currencies if table_exists? :currencies
  end
end
