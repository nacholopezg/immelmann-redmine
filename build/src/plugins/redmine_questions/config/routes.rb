# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# match '/news/:id/comments', :to => 'comments#create', :via => :post
# match '/news/:id/comments/:comment_id', :to => 'comments#destroy', :via => :delete
resources :questions do
  collection do
    put :preview
    put :update_form
    # match :preview, :to => 'questions#preview', :via => [:get, :put, :post]
    get :autocomplete_for_subject
    get :topics
    get :index_public
  end
  member do
    get :from_issue
    # post :new_comment
  end
  resources :questions_answers, :as => :answers
end

resources :questions_answers, :except => [:show, :index] do
  collection do
    put :preview
  end
end

match "questions_votes", :to => 'questions_votes#create', :via => [:get, :post], :as => 'questions_votes'

resources :questions_comments do
  member do
    post :update
  end
end

resources :questions_sections
resources :questions_statuses, :except => :show

resources :projects do
  resources :questions_sections
  resources :questions
end

match "projects/:project_id/questions/questions_sections/:section_id" => "questions#index", :via => [:get]
match "questions/questions_sections/:section_id" => "questions#index", :via => [:get]
match 'auto_completes/questions_tags' => 'auto_completes#questions_tags', :via => :get, :as => 'auto_complete_questions_tags'
