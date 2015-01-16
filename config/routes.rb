MailyHerald::Webui::Engine.routes.draw do
	root to: 'dashboard#index'
  resources "logs" do
    member do
      get "preview"
    end
  end
  resources "lists" do
    member do
      post "subscribe/:entity_id", action: :subscribe, as: :subscribe_to
      post "unsubscribe/:entity_id", action: :unsubscribe, as: :unsubscribe_from
      get "context_variables/:context", action: :context_variables, as: :context_variables
    end
  end
  resources "subscriptions" do
    member do
      post "toggle"
    end
  end
  resources "one_time_mailings" do
    collection do 
      get "archived"
      #post "template"
    end
    member do
      post "toggle"
      post "deliver/(:entity_id)", action: :deliver, as: :deliver
      get "preview/:entity_id", action: :preview, as: :preview
    end
  end
  resources "sequence_mailings"

  post "switch_mode/:mode", to: "sessions#switch_mode", as: "switch_mode"






  #resources "sequences" do
    #resources "mailings", :only => [:new, :create], :controller => "mailings", :mailing_type => :sequence
    #member do
      #get "subscription/:entity_id", :to => :subscription, :as => :subscription
      #get "subscription/:entity_id/toggle", :to => :toggle_subscription, :as => :toggle_subscription
      #get "toggle", :to => :toggle, :as => :toggle
    #end
  #end
  #resources "mailings", :except => [:new, :create] do
    #member do
      #get "subscription/:entity_id", :to => :subscription, :as => :subscription
      #get "subscription/:entity_id/toggle", :to => :toggle_subscription, :as => :toggle_subscription
      #get "dashboard/:entity_id", :to => :dashboard, :as => :dashboard
      #get "deliver/(:entity_id)", :to => :deliver, :as => :deliver
      #get "toggle", :to => :toggle, :as => :toggle
      #get "preview/:subscription_id", :to => :preview, :as => :preview
    #end
    #collection do
      #get "context_attributes/(:context_name)", :to => :context_attributes, :as => :context_attributes
    #end
  #end
  #resources "sequences_mailings", :only => [:index, :new], :controller => "mailings", :mailing_type => :sequence
  #resources "one_time_mailings", :only => [:index, :new, :create], :controller => "mailings", :mailing_type => :one_time
  #resources "periodical_mailings", :only => [:index, :new, :create], :controller => "mailings", :mailing_type => :periodical
  #resources "subscription_groups" do
    #member do
      #get "subscription/:subscription_id/toggle", :to => :toggle_subscription, :as => :toggle_subscription
    #end
  #end
  #resources "dashboard", :only => [:index, :show] do
    #collection do 
      #get "time_travel"
      #get "forget"
    #end
  #end
end
