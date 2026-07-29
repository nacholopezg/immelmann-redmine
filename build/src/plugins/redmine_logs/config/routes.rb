RedmineApp::Application.routes.draw do
  match 'logs/index',    to: 'logs#index',    via: [:get, :post], as: 'logs_index'
  match 'logs/show',     to: 'logs#show',     via: [:get, :post], as: 'logs_show'
  match 'logs/download', to: 'logs#download', via: [:get, :post], as: 'logs_download'
  match 'logs/delete',   to: 'logs#delete',   via: [:get, :post], as: 'logs_delete'
end
