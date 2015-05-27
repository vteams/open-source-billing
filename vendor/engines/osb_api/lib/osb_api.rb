# requires all dependencies
Gem.loaded_specs['osb_api'].dependencies.each do |d|
  require d.name unless d.name == 'rack-cors'
end

require "osb_api/engine"
require 'rack/cors'

module OsbApi

end
