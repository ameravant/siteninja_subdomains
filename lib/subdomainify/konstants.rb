module Konstants
  tablenames = %w(article_categories articles assets column_sections comments emails event_categories 
                   event_price_options event_registrations event_transactions events featurable_sections
                   features folders galleries images inquiries link_categories links menus newsletter_blasts 
                   newsletters pages people person_groups product_categories product_options products 
                   profiles redirects searches settings taggings testimonials users)
  Klasses = tablenames.reject{|t| !ActiveRecord::Base.connection.tables.include?(t)}.collect{|c| c.camelcase.singularize.constantize}
end
