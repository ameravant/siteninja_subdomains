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
      #needed to add custom validations
      validate_on_create :metatitle_validation
      #confirm menus are getting the correct account_id
      after_create :update_menu_account_id
      after_save :update_menu_account_id
      include Subdomainify::InstanceMethods
    end
    #methods only for settings
    def setting_extra_methods
      belongs_to :account
      def self.get_all_settings(conditions = {})
        $CURRENT_ACCOUNT = nil
        with_exclusive_scope{find(:all, :conditions => conditions)}
      end
    end
    #methods only for people
    def person_extra_methods
      include Subdomainify::InstanceMethods
      #confirm account id is correct on create of user
      after_create :update_user_account_id
    end
    #add the has_many assocation to accounts based on what modules are available(this isn't being used but should be 
    #instead of having it in the account.rb)
    def account_associations(klass)
      has_many klass.table_name.to_sym
    end
    #this is added to all models      
    def subdomainify 
      #add the $CURRENT_ACCOUNT id to every new record
      before_validation :add_account_id
      #associate it with the $CURRENT_ACCOUNT
      belongs_to :account
      #modify the find method to add a default scope
      def self.find(*args)
        if !$CURRENT_ACCOUNT.nil?
          unless $CURRENT_ACCOUNT.is_master? && $ADMIN 
            with_scope(:find=>{ :conditions=> "account_id = #{$CURRENT_ACCOUNT.id}" }) do # I think the answer is to add a global boolean to everything and 
              super(*args)                                                                # make the conditions either account_id or global == true && visible == true
            end
          else
            #this is the first effort to remove the scope in the admin section of the master account, orders by account
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
#make konstants available to migrations so we can dynamically add account_id to present tables
ActiveRecord::Migration.send(:include, Konstants) 
#dynamically send the subdomainify methods to present models
for table_name in TableNames  
  if ActiveRecord::Base.connection.tables.include?(table_name)
    table_name.camelcase.singularize.constantize.send(:subdomainify) 
  end
end
#add additional extra methods to other models
Page.send(:uniqueness_validation_for_meta_title)
Person.send(:person_extra_methods)
Setting.send(:setting_extra_methods)
