load 'lib/theme_controller_actions.rb'

class AuthoritiesController < ApplicationController
  include ThemeControllerActions
  before_filter :use_theme_controller_actions

  def index
    # map from state name to authorities in that state
    states = Authority.enabled.order('state').pluck('DISTINCT state')

    @authorities = {}
    states.each do |state|
      @authorities[state] = Authority.enabled.find_all_by_state(state, :order => "full_name")
    end
  end

  def show
    @authority = Authority.find_by_short_name_encoded!(params[:id])
  end

  def test_feed
    # TODO: Error on duplicate council_reference
    # TODO: Error if first address can't be geocoded
    # TODO: Error if values set in feed but not making it through to the model (e.g. incorrect date syntax)
    # TODO: Warning on html in descriptions
    # TODO: Warning on lack of whitespace stripping
    @url = params[:url]
    if @url
      authority = Authority.new
      # The loaded applications
      @applications = authority.collect_unsaved_applications_date_range_original_style(@url, Date.today, Date.today)
      # Try validating the applications and return all the errors for the first non-validating application
      @applications.each do |application|
        unless application.valid?
          @errored_application = application
          @applications = nil
          break
        end
      end
    end
  end
end
