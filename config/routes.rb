Rails.application.routes.draw do

  devise_for :users, :controllers => { :confirmations => "confirmations", :passwords => "passwords" }
  get 'welcome/index'

  namespace :admin do
    as :user do
      patch '/users/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
    end
    resources :projects
    resources :requirements do
      collection do
        get :edit_associated
        get :list
      end
    end
    resources :people do
      collection do
        get :edit_associated
      end
      put :change_user_status, :on => :member
    end
    resources :assignments
    resources :attachments
  end


  resources :dashboards
  resources :profiles, :only => [:show, :edit, :update]
  resources :requirements do
    post "clear"
    post "version_rollback"
  end
  resources :projects, :only => :show
  resources :assignments do
    post "clear"
  end
  resources :attachments do
    post "clear"
  end



  authenticated :user do
    root 'dashboards#index', as: "authenticated_root"
  end

  root 'welcome#index'
end
