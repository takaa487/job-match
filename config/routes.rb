Rails.application.routes.draw do
  root "pages#home"
  get "privacy", to: "pages#privacy"

  devise_for :users

  resources :companies do
    get :filter, on: :collection
  end

  resources :es_drafts, only: %i[ index create destroy ]
  resources :es_generations, only: %i[ new create ]
  resources :diagnoses, only: %i[ new create show ]
  resources :company_searches, only: %i[ create ]

  # 結果の画面の URL（/es_generations など）を開き直したときに「ページがない」と出ないよう、入力の画面へ戻す
  get "es_generations", to: redirect("/es_generations/new", status: 302)
  get "company_searches", to: redirect("/companies/filter", status: 302)

  get "up" => "rails/health#show", as: :rails_health_check
end
