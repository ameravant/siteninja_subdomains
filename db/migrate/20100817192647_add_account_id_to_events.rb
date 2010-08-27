class AddAccountIdToEvents < ActiveRecord::Migration
  def self.up
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections, :testimonials, :galleries, :images]
      if ActiveRecord.connection.tables.include?(klass.to_s.downcase.pluralize)
        add_column klass, :account_id, :integer, :default => 1
      end
    end
  end

  def self.down
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections, :testimonials, :galleries, :images]
      if ActiveRecord.connection.tables.include?(klass.to_s.downcase.pluralize)
        remove_column klass, :account_id
      end
    end
  end
end
