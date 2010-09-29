require 'subdomainify/validation_ext.rb'
require 'subdomainify/permalink_fu_replacement.rb'
require 'subdomainify/konstants.rb'
require 'helpers/subdomains_helper.rb'
include Konstants
module Subdomainify #:nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def uniqueness_validation_for_meta_title
      validate_on_create :metatitle_validation
      after_create :update_menu_account_id
      after_save :update_menu_account_id
      include Subdomainify::InstanceMethods
    end
    def setting_extra_methods
      belongs_to :account
      def self.get_all_settings(conditions = {})
        $CURRENT_ACCOUNT = nil
        with_exclusive_scope{find(:all, :conditions => conditions)}
      end
    end
    def person_extra_methods
      include Subdomainify::InstanceMethods
      after_create :update_user_account_id
    end
    def account_associations(klass)
      has_many klass.table_name.to_sym
    end      
    def subdomainify 
      before_validation :add_account_id
      belongs_to :account
      def self.find(*args)
        if !$CURRENT_ACCOUNT.nil?
          unless $CURRENT_ACCOUNT.is_master? && $ADMIN
            with_scope(:find=>{ :conditions=> "account_id = #{$CURRENT_ACCOUNT.id}" }) do
              super(*args)
            end
          else
            with_scope(:find=>{:order=> "account_id"}) do
             super(*args)
            end
          end
        else
          super(*args)
        end
      end
      include Subdomainify::InstanceMethods
    end
  end
  module InstanceMethods
    def metatitle_validation
      if Page.find(:first, :conditions => "permalink = '#{self.permalink}' AND account_id = #{self.account_id}")
        self.errors.add_to_base("Page title already taken")
      end
    end
    def update_menu_account_id
      current_account = $CURRENT_ACCOUNT
      $CURRENT_ACCOUNT = nil
      menu = Menu.find_all_by_navigatable_id(self.id)
      menu.collect{|m| m.update_attributes(:account_id => self.account_id)} if menu.any?
      $CURRENT_ACCOUNT = current_account
    end
    def add_account_id  
      if $CURRENT_ACCOUNT
        self.account_id = $CURRENT_ACCOUNT.id
      end
    end
    def subdomain
      self.account_id.blank? ? nil : self.account.subdomain
    end
    def update_user_account_id
      self.user.update_attributes(:account_id => self.account_id) if self.user 
    end
  end
end

ActiveRecord::Base.send(:include, Subdomainify)
ActiveRecord::Migration.send(:include, Konstants) 
for klass in Klasses  
  if ActiveRecord::Base.connection.tables.include?(klass.table_name)
    klass.send(:subdomainify) 
  end
end
Page.send(:uniqueness_validation_for_meta_title)
Person.send(:person_extra_methods)
Setting.send(:setting_extra_methods)
