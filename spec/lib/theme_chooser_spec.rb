require 'spec_helper'

describe ThemeChooser do

  it 'allows a theme to be set from the environment' do
    ENV.stub(:[]).with('THEME').and_return 'nsw'
    expect(ThemeChooser.choose_theme(double())).to be_a(Themes::NSW::Theme)
  end


end