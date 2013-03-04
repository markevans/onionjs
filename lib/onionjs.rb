module Onionjs
  class Engine < Rails::Engine

    initializer "onionjs" do |app|
      app.assets.paths << app.root.join('app/assets/modules')

      # If requirejs-rails is present, include mustache files in
      # rake assets:precompile task (which uses r.js)
      if app.config.respond_to?(:requirejs)
        app.config.requirejs.logical_asset_filter += [/\.mustache$/]
      end
    end

  end
end
