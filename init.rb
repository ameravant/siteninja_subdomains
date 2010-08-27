require 'subdomainify'
require 'permalink_fu_replacement.rb'
require 'validation_ext.rb'
for klass in [Event, Person, User, Page, Menu, Article, ArticleCategory, PersonGroup, Feature, FeaturableSection, Testimonial, Gallery, Image]  
  if ActiveRecord.connection.tables.include?(klass.to_s.downcase.pluralize)
    klass.send(:subdomainify)
  end
end
Page.send(:uniqueness_validation_for_meta_title)
Person.send(:person_extra_methods)
