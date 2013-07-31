module Onionjs
  module Helper

    # Usage:
    #
    #   <%= onionjs_app(:calendar) %>
    #
    # Attach to an existing element:
    #
    #   <%= onionjs_app(:calendar, attach_to: '#some-element') %>
    #
    # Append to an existing element:
    #
    #   <%= onionjs_app(:calendar, append_to: '#some-element') %>
    #
    # Make pre-loaded JSON data available in the app as a "preloadedData" model
    #
    #   <%= onionjs_app(:calendar, preloaded_data: {user: current_user}) %>
    #
    # Other options:
    #
    #   <%= onionjs_app(:calendar,
    #         require_path: 'calendar/calendar_controller',
    #         pre_require: ['augment.min.js', 'supplement.min.js'],
    #         controller_name: 'CalendarController',
    #       ) %>
    #
    def onionjs_app(app_name, opts={})
      # Preloaded data
      preloaded_data = opts[:preloaded_data] || {}

      # Requires
      app_path = opts[:require_path] || "#{app_name}/#{app_name}_controller"
      pre_require = opts[:pre_require]
      requires = [app_path] + Array.wrap(pre_require)

      # Controller Name
      controller_name = opts[:controller_name] || "#{app_name}_controller".camelize

      # Return the script tag
      %(
        <script type="text/javascript">
          require(#{requires.to_json}, function(#{controller_name}){
            window.app = new #{controller_name}({ preloadedData: #{preloaded_data.to_json} })
            #{onionjs_app_insert_code(opts)}
            app.run()
          })
        </script>
      ).html_safe
    end

    private

    def onionjs_app_insert_code(opts)
      if opts[:append_to]
        "app.appendTo('#{opts[:append_to]}')"
      elsif opts[:attach_to]
        "app.attachTo('#{opts[:attach_to]}')"
      else
        "app.appendTo('body')"
      end
    end

  end
end

