require 'spec_helper'
require 'app/helpers/onionjs/helper'

describe "Onionjs::Helper" do
  include Onionjs::Helper

  it "inserts an onionjs app" do
    onionjs_app(:calendar).should match_html %(
      <script type="text/javascript">
        require(["calendar/calendar_controller"], function(CalendarController){
          window.app = new CalendarController({ preloadedData: {} })
          app.appendTo('body')
          app.run()
        })
      </script>
    )
  end

  it "allows appending to a custom place" do
    html = onionjs_app(:calendar, append_to: '#app')
    html.should =~ /app\.appendTo\('#app'\)/
    html.should_not =~ /attachTo/
  end

  it "allows attaching to a custom place" do
    html = onionjs_app(:calendar, attach_to: '#app')
    html.should =~ /app\.attachTo\('#app'\)/
    html.should_not =~ /appendTo/
  end

  it "inserts an onionjs app with options" do
    onionjs_app(:calendar, {
        preloaded_data: {gangnam: 5},
        attach_to: '#app',
        pre_require: ['augment.js', 'supplement.js'],
        require_path: 'doobie/doo',
        controller_name: 'DoobieApp'
      }
    ).should match_html %(
      <script type="text/javascript">
        require(["doobie/doo","augment.js","supplement.js"], function(DoobieApp){
          window.app = new DoobieApp({ preloadedData: {"gangnam":5} })
          app.attachTo('#app')
          app.run()
        })
      </script>
    )
  end
end

