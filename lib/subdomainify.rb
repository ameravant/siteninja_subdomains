module ActiveRecord #:nodoc:
  module ValidationExt
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def validates_uniqueness_of(*attr_names)
        configuration = { :case_sensitive => false }
        configuration.update(attr_names.extract_options!)
        
        validates_each(attr_names,configuration) do |record, attr_name, value|
          # The check for an existing value should be run from a class that
          # isn't abstract. This means working down from the current class
          # (self), to the first non-abstract class. Since classes don't know
          # their subclasses, we have to build the hierarchy between self and
          # the record's class.
          class_hierarchy = [record.class]
          while class_hierarchy.first != self
            class_hierarchy.insert(0, class_hierarchy.first.superclass)
          end
        
          # Now we can work our way down the tree to the first non-abstract
          # class (which has a database table to query from).
          finder_class = class_hierarchy.detect { |klass| !klass.abstract_class? }
        
          column = finder_class.columns_hash[attr_name.to_s]
        
          if value.nil?
            comparison_operator = "IS ?"
          elsif column.text?
            comparison_operator = "#{connection.case_sensitive_equality_operator} ?"
            value = column.limit ? value.to_s.mb_chars[0, column.limit] : value.to_s
          else
            comparison_operator = "= ?"
          end
        
          sql_attribute = "#{record.class.quoted_table_name}.#{connection.quote_column_name(attr_name)}"
        
          if value.nil? || (configuration[:case_sensitive] || !column.text?)
            condition_sql = "#{sql_attribute} #{comparison_operator}"
            condition_params = [value]
          else
            condition_sql = "LOWER(#{sql_attribute}) #{comparison_operator}"
            condition_params = [value.mb_chars.downcase]
          end
          configuration[:scope] =  Array(configuration[:scope]) << :account_id if record.respond_to?(:account_id)
          if scope = configuration[:scope]
            Array(scope).map do |scope_item|
              scope_value = record.send(scope_item)
              condition_sql << " AND " << attribute_condition("#{record.class.quoted_table_name}.#{scope_item}", scope_value)
              condition_params << scope_value
            end
          end
        
          unless record.new_record?
            condition_sql << " AND #{record.class.quoted_table_name}.#{record.class.primary_key} <> ?"
            condition_params << record.send(:id)
          end
        
          finder_class.with_exclusive_scope do
            if finder_class.exists?([condition_sql, *condition_params])
              record.errors.add(attr_name, :taken, :default => configuration[:message], :value => value)
            end
          end
        end
      end
    end
  end
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
ActiveRecord::Validations.send(:include, ActiveRecord::ValidationExt)