module ActiveRecord #:nodoc:
  module Subdomainify #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def uniqueness_validation_for_meta_title
        validate_on_create :metatitle_validation
        before_save :update_menu_account_id
        include ActiveRecord::Subdomainify::InstanceMethods
      end
      def person_extra_methods
        after_create :update_user_account_id
        include ActiveRecord::Subdomainify::InstanceMethods
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
        include ActiveRecord::Subdomainify::InstanceMethods
      end
    end
    module InstanceMethods
      def metatitle_validation
        if Page.find(:first, :conditions => "permalink = '#{self.permalink}' AND account_id = #{self.account_id}")
          self.errors.add_to_base("Page title already taken")
        end
      end
      def update_menu_account_id
        if menu = Menu.find_all_by_navigatable_id(self.id)
          menu.collect{|m| m.update_attributes(:account_id => self.account_id)}
        end
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
end
ActiveRecord::Base.send(:include, ActiveRecord::Subdomainify)