class Account < ActiveRecord::Base
  cattr_accessor :current
  for klass in Klasses
    has_many klass.table_name.to_sym
  end
  has_one :setting
  named_scope :master, :conditions => "subdomain is null AND name = 'master'"

  def is_master?
    self.name == 'master' && self.subdomain.nil?
  end
end
