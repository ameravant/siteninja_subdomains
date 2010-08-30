class AddAccountIdToKlasses < ActiveRecord::Migration
  def self.up
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections, :testimonials, :galleries, :images]
      if ActiveRecord::Base.connection.tables.include?(klass.to_s)
        add_column klass, :account_id, :integer, :default => 1
      end
    end
  end

  def self.down
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections, :testimonials, :galleries, :images]
      if ActiveRecord::Base.connection.tables.include?(klass.to_s)
        remove_column klass, :account_id
      end
    end
  end
end