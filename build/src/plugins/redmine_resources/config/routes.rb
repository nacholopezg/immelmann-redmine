resources :resource_bookings do
  get :issues_autocomplete, on: :collection
  post :split, on: :member
end

get '/projects/:project_id/resources', to: 'resource_bookings#index', as: 'project_resource_bookings'
