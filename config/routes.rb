Rails.application.routes.draw do
  devise_for :customers, controllers: {
    registrations: "customers/registrations"
  }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "product#index"

  get "/cart", to: "cart#index", as: :cart
  patch "/cart/items/:id", to: "cart#update_item", as: :cart_item
  delete "/cart/items/:id", to: "cart#destroy_item"
  post "/checkout", to: "checkout#create", as: :checkout
  get "/checkout/success", to: "checkout#success", as: :checkout_success
  get "/checkout/cancel", to: "checkout#cancel", as: :checkout_cancel

  resources :orders, only: %i[index]
  resources :products, only: %i[index show], controller: "product" do
    post :add_to_cart, on: :member
  end
end
