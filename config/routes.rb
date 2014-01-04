Kiosk::Engine.routes.draw do

  devise_for :users, controllers: {registrations: "kiosk/registrations"}

  resources :users do
    resources :trips, :only => [:show, :index, :new, :create, :destroy, :edit, :update] do
      collection do
        post  'set_traveler'
        get   'unset_traveler'
        get   'search'
        post  'geocode'
      end
      member do
        get   'repeat'          
        get   'select'
        get   'details'
        get   'itinerary'
        post  'email'
        post  'email_provider'
        post  'email_itinerary'
        get   'email_itinerary2_values'
        post  'email2'
        get   'hide'
        get   'unhide_all'
        get   'skip'
        post  'rate'
        post  'comments'
        post  'admin_comments'
        get   'edit_rating'
        get   'email_feedback'
        get   'show_printer_friendly'
      end
    end
    resources :characteristics, :only => [:new, :create, :edit, :update] do
      collection do
        get 'header'
      end
      member do
        put 'set'
      end
    end

    resources :programs, :only => [:new, :create, :edit, :update] do
      member do
        put 'set'
      end
    end

    resources :accommodations, :only => [:new, :create, :edit, :update] do
      member do
        put 'set'
      end
    end
    

  end

end