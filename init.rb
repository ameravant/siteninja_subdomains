require 'subdomainify'
require 'permalink_fu_replacement.rb'
require 'validation_ext.rb'
for klass in %w(Event Person User Page Menu Article ArticleCategory PersonGroup Feature FeaturableSection Testimonial Gallery Image)  
  if ActiveRecord::Base.connection.tables.include?(klass.downcase.pluralize.tableize)
    klass.constantize.send(:subdomainify)
  end
end
ActiveRecord::Base::Page.send(:uniqueness_validation_for_meta_title)
ActiveRecord::Base::Person.send(:person_extra_methods)
