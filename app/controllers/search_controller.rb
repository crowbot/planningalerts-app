require 'httparty'
require 'json'

class SearchController < ApplicationController
  def index
  end

  def _postcode_lookup
    # should probably validate this
    postcode = CGI::escape(params[:postcode].gsub(" ", ""))

    url = "http://mapit.mysociety.org/postcode/#{postcode}"
    begin
      content = HTTParty.get(url).body
      data    = JSON.parse(content)
      lat = data["wgs84_lat"]
      lng = data["wgs84_lon"]
      redirect_to search_index_path({:lat => lat, :lng => lng})
    rescue SocketError, Errno::ETIMEDOUT, RSS::NotWellFormedError
      redirect_to search_index_path
    end
  end

  def _address_lookup
    # should probably validate this
    address = CGI::escape(params[:address])

    r = Location.geocode(address)
    if r.success
      redirect_to search_index_path({:lat => r.lat, :lng => r.lng})
    else
      redirect_to search_index_path
    end
  end
end