class CreateTables < ActiveRecord::Migration
  def up
    create_lookup_tables :cities, :states, :postal_codes, :streets

    create_lookup_table :ip_addresses
    create_lookup_table :email_addresses

    create_lookup_table :accounts
    create_lookup_table :statuses

    create_table :addresses, primary_key: "address_id" do |t|
      t.belongs_to :city
      t.belongs_to :state
      t.belongs_to :postal_code
      t.belongs_to :street
    end

    State.create(name: "AL")
  end

  def down
  end
end
