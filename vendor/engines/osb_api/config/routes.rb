OsbApi::Engine.routes.draw do
  mount V1::Osb => '/'
  mount GrapeSwaggerRails::Engine => '/api/docs'
  use_doorkeeper :scope => 'developer'

end
