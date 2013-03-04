module Onion
  class ModuleGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :name, :type => :string

    def create_stuff
      template "controller.coffee.erb", "app/assets/modules/#{module_dirname}/#{controller_basename}.coffee"
      template "view.coffee.erb", "app/assets/modules/#{module_dirname}/#{view_basename}.coffee"
      template "template.mustache.erb", "app/assets/modules/#{module_dirname}/#{template_filename}"
      template "view.css.scss.erb", "app/assets/modules/#{module_dirname}/#{stylesheet_filename}"
    end

    private

    def basename
      @basename ||= name.camelize.sub(/Controller$/, '').underscore
    end

    def module_dirname
      basename
    end

    def controller_name
      "#{basename.camelize}Controller"
    end

    def controller_basename
      controller_name.underscore
    end

    def view_name
      "#{basename.camelize}View"
    end

    def view_basename
      view_name.underscore
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
