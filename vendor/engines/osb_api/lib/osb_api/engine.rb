module OsbApi
  class Engine < ::Rails::Engine
    isolate_namespace OsbApi
    config.paths.add File.join('app','api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[File.join('app','api', '*')]

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :delete, :patch, :put]
      end
    end

  end
end
