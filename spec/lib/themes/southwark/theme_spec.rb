require 'spec_helper'

describe Themes::Southwark::Theme do

  around do |test|
    with_modified_env THEME: 'southwark' do
      ThemeChooser.theme
      test.run
    end
  end


  it 'sets ssl_required? to false' do
    expect(described_class.new.ssl_required?).to be false
  end

  it 'sets the protocol to "http"' do
    expect(described_class.new.protocol).to eq "http"
  end

  it 'sets the view path' do
    expected = Rails.root.join("lib",
                               "themes",
                               "southwark",
                               "views")
    expect(described_class.new.view_path).to eq(expected)
  end

end
