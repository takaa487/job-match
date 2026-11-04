Rails.application.routes.draw do
  root "pages#home"
  get "privacy", to: "pages#privacy"

  devise_for :users

  resources :companies do
    member do
      post :generate_es
    end
    collection do
      get :filter
    end
  end

  resources :es_drafts, only: [:index, :create, :destroy]
  resources :es_generations, only: [:new, :create]
  resources :diagnoses, only: [:new, :create, :show]
  resources :company_searches, only: [:create]

  get "es_generations", to: redirect("/es_generations/new", status: 302)
  get "companies/:id/generate_es", to: redirect("/companies/%{id}", status: 302)
  get "company_searches", to: redirect("/companies/filter", status: 302)

  get "up" => "rails/health#show", as: :rails_health_check
end