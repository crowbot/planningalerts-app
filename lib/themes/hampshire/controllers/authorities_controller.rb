load File.expand_path('../controller_base.rb',  __FILE__)
require "#{Rails.root.to_s}/lib/themes/hampshire/models/hampshire_search.rb"

class HampshireTheme
  class AuthoritiesController < ControllerBase
    def index
      @authorities = Authority.enabled
    end

    def show
      # Deal with posts to the authority selector
      if params[:full_name]
        authority = Authority.find_by_short_name_encoded!(params[:full_name])
        if authority
          redirect_to authority_url(authority.short_name_encoded)
        end
      end
      @authorities = Authority.enabled
      @authority = Authority.find_by_short_name_encoded!(params[:id])
      @applications = @authority.applications.paginate(:page => params[:page], :per_page => 30)
      return false
    end
  end
end