Rails.application.routes.draw do

  mount OsbApi::Engine => "/osb_api"
end
