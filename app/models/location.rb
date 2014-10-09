# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Location < SimpleDelegator
  attr_accessor :original_address

  def initialize(*params)
    if params.count == 2
      super(Geokit::LatLng.new(*params))
    elsif params.count == 1
      super(params.first)
    else
      raise "Unexpected number of parameters"
    end
  end

  def self.geocode(address)
    r = Geokit::Geocoders::GoogleGeocoder3.geocode(address, :bias => Configuration::COUNTRY_CODE.downcase)
    r = r.all.find{|l| Location.new(l).in_correct_country?} || r
    l = Location.new(r)
    l.original_address = address
    l
  end

  def in_correct_country?
    country_code == Configuration::COUNTRY_CODE
  end

  def suburb
    city
  end

  def postcode
    zip
  end

  def error
    # Only checking for errors on geocoding
    if original_address
      if original_address == ""
        "can't be empty"
      elsif lat.nil? || lng.nil?
        "isn't valid"
      elsif !in_correct_country?
        "#{country_code} isn't in #{Configuration::COUNTRY_NAME}"
      elsif accuracy < Configuration::MINIMUM_ACCURACY
        "isn't complete. We saw that address as \"#{full_address}\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state"
      end
    end
  end

  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.new(__getobj__.endpoint(bearing, distance / 1000.0, :units => :kms))
  end

  # Distance (in metres) to other point
  def distance_to(l)
    __getobj__.distance_to(l.__getobj__, :units => :kms) * 1000.0
  end

  def full_address
    to_replace = Configuration::COUNTRY_NAME.gsub(/^the /, "")
    __getobj__.full_address.sub(", #{to_replace}", "")
  end

  def all
    __getobj__.all.find_all{|l| Location.new(l).in_correct_country?}.map{|l| Location.new(l)}
  end

  def ==(a)
    lat == a.lat && lng == a.lng
  end
end