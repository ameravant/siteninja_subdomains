class AddAccountIdToEvents < ActiveRecord::Migration
  def self.up
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections]
      add_column klass, :account_id, :integer, :default => 1
    end
  end

  def self.down
    for klass in [:events, :people, :person_groups, :users, :pages, :menus, :articles, :article_categories, :features, :featurable_sections]
      remove_column klass, :account_id
    end
  end
end
