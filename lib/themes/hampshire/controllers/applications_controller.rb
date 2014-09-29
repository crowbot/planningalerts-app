load File.expand_path('../controller_base.rb',  __FILE__)

class HampshireTheme
  class ApplicationsController < ControllerBase
    load "validate.rb"

    def address
      if params[:q]
        if MySociety::Validate.is_valid_postcode(params[:q])
          postcode = CGI::escape(params[:q].gsub(" ", ""))
          url = "#{MySociety::Config::get('MAPIT_URL')}/postcode/#{postcode}"
          begin
            result = HTTParty.get(url)
            content = result.body
            data = JSON.parse(content)
            lat = data["wgs84_lat"]
            lng = data["wgs84_lon"]
            if !lat.blank? and !lng.blank?
              redirect_to search_applications_path({:lat => lat, :lng => lng})
            else
              @error = "Postcode is not valid"
            end
          rescue SocketError, Errno::ETIMEDOUT, JSON::ParserError
            @error = "Postcode is not valid"
          end
        else
          address = CGI::escape(params[:q])
          r = Location.geocode(address)
          if r.success
            redirect_to search_applications_path({:lat => r.lat, :lng => r.lng})
          else
            @error = "Address not found"
          end
        end
      end
      # return false to signal to the filter method to halt execution
      # before processing the original controller method
      return false
    end

    def search
      return false
    end
  end
end