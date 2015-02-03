describe ROM::Auth::Configuration do
  it '' do
    config = described_class.new do
    end

    assert{ config.plugins == {} }
  end

  it '' do
    config = described_class.new do |c|
      c.plugin ROM::Auth::Plugins::AuthenticationEventsPlugin
    end

    assert{ config.plugins.keys == [ROM::Auth::Plugins::AuthenticationEventsPlugin] }
  end

  it '' do
    config = described_class.new do |c|
      c.plugin ROM::Auth::Plugins::AuthenticationEventsPlugin do
      end
    end

    plugin_data = config.plugins[ROM::Auth::Plugins::AuthenticationEventsPlugin]

    assert{ plugin_data.is_a?(ROM::Auth::Plugins::AuthenticationEventsPlugin::Configuration) }
  end
end
