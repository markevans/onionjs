module Onionjs
  module Helper

    def onionjs_app(app_name, preloaded_data={}, opts={})
      app_path = opts[:app_path] || "#{app_name}/#{app_name}_controller"
      id = (opts[:id] || "app").html_safe
      pre_require = opts[:pre_require]

      requires = [app_path] + Array.wrap(pre_require)
      controller_name = "#{app_name}_controller".camelize

      html = ""

      html << %(
        <script type="text/javascript">
          require(#{requires.to_json}, function(#{controller_name}){
            window.app = new #{controller_name}({
              preloadedData: #{preloaded_data.to_json}
            }).appendTo('##{id}')
          })
        </script>
      )

      html << %(<div id="#{id}"></div>)

      html.html_safe
    end

  end
end
