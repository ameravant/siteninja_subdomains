klasses = []
TableNames.each do |table_name|
  if ActiveRecord::Base.connection.tables.include?(table_name)
    klasses << table_name.to_sym
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
    