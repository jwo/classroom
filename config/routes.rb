Rails.application.routes.draw do

  devise_for :students
  devise_for :instructors

  resources :reports
  authenticate :student do
    get 'dashboard' => 'dashboard#index'
    get 'my-cohort' => 'dashboard#cohort', as: 'my_cohort'

    resources :submissions
    resources :checkins
    resources :adjustments, only: :create

    get 'profile/:id' => 'students#show', as: 'profile'
    get 'profile/:id/edit' => 'students#edit', as: 'edit_profile'

    get 'assignments/current' => 'assignments#current', as: 'current_assignment'
    get 'assignments/:id' => 'assignments#show', as: 'student_assignment'
    get 'assignments/search/:query' => 'assignments#search'

    resources :students
    resources :instructors, only: :show
  end

  authenticate :instructor do
    resources :instructors, only: [:show, :edit, :update]
    resources :ratings, only: [:create, :update]
    resources :tags, only: :create
    resources :badges, except: :index

    patch 'submissions/:id/complete'   => 'submissions#mark_complete',   as: 'mark_submission_complete'
    patch 'submissions/:id/unfinished' => 'submissions#mark_unfinished', as: 'mark_submission_unfinished'

    patch 'adjustments/:id/adjust' => 'adjustments#adjust', as: 'adjust_checkin'
    patch 'adjustments/:id/close'  => 'adjustments#close',  as: 'close_adjustment'

    scope 'instructor' do
      get 'dashboard' => 'instructor_dashboard#index', as: 'instructor_dash'
      resources :cohorts
      resources :assignments
      resources :students, only: [:show, :edit, :update]
      resources :days, only: [:new, :create]
    end
  end

  authenticate :student do
    root 'dashboard#index'
  end

  if Rails.env.production? || ENV['DEBUG']
    get '404', :to => 'application#page_not_found'
    get '422', :to => 'application#server_error'
    get '500', :to => 'application#server_error'
  end
end
