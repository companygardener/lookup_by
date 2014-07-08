class CreateTables < ActiveRecord::Migration
  def up
    create_lookup_tables :cities, :states, :postal_codes, :streets, :countries

    create_lookup_table :user_agents
    create_lookup_table :email_addresses

    create_lookup_table :accounts
    create_lookup_table :statuses, small: true

    create_lookup_table :ip_addresses, lookup_type: :inet

    create_lookup_table :uncacheables
    create_lookup_table :unfindables

    create_lookup_table :raisins
    create_lookup_table :read_through_raisins

    enable_extension 'uuid-ossp'

    execute 'CREATE SCHEMA traffic;'

    create_lookup_table :paths, schema: 'traffic', id: :uuid

    create_table :addresses, primary_key: "address_id" do |t|
      t.belongs_to :city
      t.belongs_to :state
      t.belongs_to :postal_code
      t.belongs_to :street
      t.belongs_to :country
    end
  end
end
