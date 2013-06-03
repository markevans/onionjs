module Onionjs
  module Helper

    def onionjs_app(app_name, preloaded_data={}, opts={})
      app_path = opts[:app_path] || "#{app_name}/#{app_name}_controller"

      pre_require = opts[:pre_require]

      requires = [app_path] + Array.wrap(pre_require)
      controller_name = "#{app_name}_controller".camelize

      html = ""

      html << %(
        <script type="text/javascript">
          require(#{requires.to_json}, function(#{controller_name}){
            window.app = new #{controller_name}({
              preloadedData: #{preloaded_data.to_json}
            }).#{onionjs_app_anchor_action(opts)}('#{onionjs_app_anchor_selector(opts)}')
          })
        </script>
      )

      html << onionjs_app_anchor_element(opts)

      html.html_safe
    end

    def onionjs_app_anchor_selector(opts)
      if opts[:base]
        opts[:base]
      elsif opts[:id]
        '#' + opts[:id].to_s
      else
        '#app'
      end
    end

    def onionjs_app_anchor_element(opts)
      if opts[:base]
        ''
      else
        id = opts[:id] || 'app'
        %(<div id="#{id}"></div>)
      end
    end

    def onionjs_app_anchor_action(opts)
      opts[:anchor] ? 'anchorAt' : 'appendTo'
    end

  end
end
