Rails.configuration.to_prepare do
  Application.instance_eval do
    scope :in_past_week, where("date_received > ?", 7.days.ago)
    scope :recent, where("date_received >= ?", 14.days.ago)

    def search_index_name
      prefix = ""
      if defined?(Configuration::THEME_SOUTHWARK_HOST)
        prefix = Configuration::THEME_SOUTHWARK_HOST.gsub(/[\.:]/, '_')
      end
      "#{prefix}_application"
    end
  end

  Application.class_eval do
    define_index(search_index_name) do
      indexes council_reference
      indexes description
      indexes address
      indexes suburb
      indexes postcode
      indexes authority(:full_name), :as => :authority, :facet => true
      indexes category, :facet => true
      indexes status, :facet => true

      # Find applications that are near the current application location
      # and/or recently received
      def find_all_nearest_or_recent
        if location
          nearbys(nearby_and_recent_max_distance_km, :units => :km).where('date_received > ?', nearby_and_recent_max_age_months.months.ago)
        else
          []
        end
      end

      # enable geosearch - see http://pat.github.io/thinking-sphinx/geosearching.html
      has 'RADIANS("applications"."lat")', :as => :latitude,  :type => :float
      has 'RADIANS("applications"."lng")', :as => :longitude, :type => :float

      # Postgres-specific bit:
      group_by '"applications"."lat"', '"applications"."lng"'

      has date_received
    end

    validates :category, :inclusion => {
        :in => Configuration::THEME_SOUTHWARK_CATEGORIES,
        :allow_nil => true,
        :message => "%{value} is not an allowed category"
      }

    def status_display
      status ? status.capitalize : ''
    end

    def description_display(cutoff=180)
      return description if description.blank?
      output = description.dup
      if output.length > cutoff
        break_point = output.rindex(" ", cutoff+10)
        output = "#{output[0..break_point]}&hellip;"
      end
      output
    end

    def as_json(options={})
      result = super(options)
      result['application'].merge!({
        'authority' => {
          'short_name_encoded' => authority.short_name_encoded
        },
        'status_display' => status_display,
        'date_received_display' => date_received ? date_received.strftime('%e %b %Y') : nil,
        'decision_date_display' => decision_date ? decision_date.strftime('%e %b %Y') : nil,
        'description_display' => description_display
      })
      result
    end
  end

  Authority.instance_eval do
    has_many :stats, class_name: "AuthorityStatsSummary"
  end

  Authority.class_eval do
    def applications_received_per_week
      # warning - assumes postgres!
      h = applications
        .where("date_received IS NOT NULL")
          .group("date_received - interval '1 day' * EXTRACT(DOW FROM date_received)")
            .count
      h.sort
    end

    def median_applications_received_per_week
      v = applications_received_per_week.select{|a| a[1] > 0}.map{|a| a[1]}.sort
      v[v.count / 2]
    end
  end

  Location.class_eval do
    def self.geocode(address)
      sleep 1
      # Bias towards a specific bounding box
      boundsSW = GeoKit::LatLng.new(Configuration::THEME_SOUTHWARK_BOUNDING_BOX_SW[0],
                                    Configuration::THEME_SOUTHWARK_BOUNDING_BOX_SW[1])
      boundsNE = GeoKit::LatLng.new(Configuration::THEME_SOUTHWARK_BOUNDING_BOX_NE[0],
                                    Configuration::THEME_SOUTHWARK_BOUNDING_BOX_NE[1])
      bounds = GeoKit::Bounds.new(boundsSW, boundsNE)
      r = Geokit::Geocoders::GoogleGeocoder3.geocode(address, :bias => bounds)
      r = r.all.find{|l| Location.new(l).in_correct_country?} || r
      l = Location.new(r)
      l.original_address = address
      l
    end
  end
end