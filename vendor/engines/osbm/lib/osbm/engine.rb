module Osbm
  class Engine < ::Rails::Engine
    isolate_namespace Osbm

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer "osbm.assets.precompile" do |app|
      app.config.assets.precompile += %w(application.css application.js)
    end

    initializer :helper_configuration do |app|

    end
  end
end
