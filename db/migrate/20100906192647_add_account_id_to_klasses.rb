class AddAccountIdToKlasses < ActiveRecord::Migration
  def self.up
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        add_column table_name.to_sym, :account_id, :integer, :default => 1
        add_column table_name.to_sym, :global, :boolean, :default => false
        add_index table_name.to_sym, :account_id
      end
    end
  end

  def self.down
    for table_name in TableNames
      if ActiveRecord::Base.connection.tables.include?(table_name)
        remove_column table_name.to_sym, :global
        remove_column table_name.to_sym, :account_id
      end
    end
  end
end
