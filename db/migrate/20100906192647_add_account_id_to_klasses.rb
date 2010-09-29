class AddAccountIdToKlasses < ActiveRecord::Migration
  def self.up
    for klass in Klasses
      if ActiveRecord::Base.connection.tables.include?(klass.table_name)
        add_column klass.table_name.to_sym, :account_id, :integer, :default => 1
      end
    end
  end

  def self.down
    for klass in Klasses
      if ActiveRecord::Base.connection.tables.include?(klass.table_name)
        remove_column klass.table_name.to_sym, :account_id
      end
    end
  end
end
