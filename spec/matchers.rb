normalize = ->(html){ html.strip.gsub(/ +/, ' ') }

RSpec::Matchers.define :match_html do |expected_html|
  match do |actual_html|
    normalize[actual_html] == normalize[expected_html]
  end

  failure_message_for_should do |actual_html|
    <<-eos
      Failed to match html:
      EXPECTED:
      #{normalize[expected_html]}
      ACTUAL:
      #{normalize[actual_html]}
    eos
  end
end

