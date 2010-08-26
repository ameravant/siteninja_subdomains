class Account < ActiveRecord::Base
  cattr_accessor :current
  has_many :events
  has_many :people
  has_many :pages
  has_many :menus
  named_scope :master, :conditions => "subdomain is null AND name = 'master'"
  def is_master?
    self.name == 'master' && self.subdomain.nil?
  end
end
