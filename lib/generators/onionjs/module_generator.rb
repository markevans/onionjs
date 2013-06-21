module Onionjs
  class ModuleGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :name, :type => :string
    class_option :coffee, :type => :boolean, :desc => "generate coffeescript instead of javascript"

    def create_stuff
      if options["coffee"]
        template "controller.coffee.erb", "app/assets/modules/#{module_dirname}/#{controller_basename}.coffee"
        template "view.coffee.erb", "app/assets/modules/#{module_dirname}/#{view_basename}.coffee"
      else
        template "controller.js.erb", "app/assets/modules/#{module_dirname}/#{controller_basename}.js"
        template "view.js.erb", "app/assets/modules/#{module_dirname}/#{view_basename}.js"
      end
      template "template.mustache.erb", "app/assets/modules/#{module_dirname}/#{template_filename}"
      template "view.css.scss.erb", "app/assets/modules/#{module_dirname}/#{stylesheet_filename}"
    end

    private

    def underscored
      @underscored ||= name.camelize.sub(/Controller$/, '').underscore
    end

    def namespace
      @namespace ||= underscored.split('/')[0..-2].join('/')
    end

    def basename
      @basename ||= underscored.split('/').last
    end

    def module_dirname
      namespace.present? ? namespace : basename
    end

    def controller_basename
      "#{basename}_controller"
    end

    def controller_name
      controller_basename.camelize
    end

    def view_basename
      "#{basename}_view"
    end

    def view_name
      view_basename.camelize
    end

    def template_filename
      "#{basename}.mustache"
    end

    def stylesheet_filename
      "#{basename}.css.scss"
    end

    def view_css_class
      view_basename.dasherize
    end

  end
end
