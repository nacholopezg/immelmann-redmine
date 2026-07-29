resources :issues do
  resources :checklists, :only => [:index, :create]
end

resources :checklists, :only => [:destroy, :update, :show] do
  member do
    put :done
  end
end
# <PRO>
resources :projects do
  resources :checklist_templates, :only => [:new, :create, :update, :edit]
end

resources :checklist_templates

resources :checklist_template_categories, :only => [:edit, :update, :new, :create, :destroy]
# </PRO>