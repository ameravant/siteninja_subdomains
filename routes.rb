klasses = []
Klasses.each do |klass|
  if ActiveRecord::Base.connection.tables.include?(klass.table_name)
    klasses << klass.table_name.to_sym
  end
end
namespace :admin do |admin|
  admin.resources :accounts do |account| 
    for klass in klasses
      account.resources klass
    end
  end
end
# for klass in klasses
#   resources klass, :belongs_to => :account
# end
    
    