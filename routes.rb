# resources :events, :as => events_path, :has_many => :images, :collection => { :past => :get } do |event|
#   event.resources :event_registration_groups,
#     :belongs_to => :people,
#     :has_many => :event_registrations,
#     :member => { :pay => :get, :complete => :get }
# end
# 
# namespace :admin do |admin|
#   admin.resources :events, :has_many => [ :event_price_options, :features, :assets ] do |event|
#   admin.resources :event_categories, :has_many => { :features, :menus } do |event_category|
#     event_category.resources :menus
#     event_category.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put }
#   end
#     event.resources :images, :member => { :reorder => :put }, :collection => { :reorder => :put }
#     event.resources :event_registration_groups,
#       :has_many => :contacts,
#       :member => {:paid => :get, :unpaid => :get }, 
#       :collection => {:csv => :get}
#   end
# end
# resources :event_categories