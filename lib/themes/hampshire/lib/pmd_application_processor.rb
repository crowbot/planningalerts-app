class PMDApplicationProcessor
  # A helper class to extract information from a PublishMyData site

  @@resource_url =  "#{Configuration::PUBLISHMYDATA_BASE_URL}/resource.json"

  def self.extract_description(application)
    description = nil
    if application['http://data.hampshirehub.net/def/planning/hasCaseText']
      description = application['http://data.hampshirehub.net/def/planning/hasCaseText'][0]['@value']
    end
    return description
  end

  def self.extract_status(decision)
    status = Configuration::THEME_HAMPSHIRE_STATUSES['pending']
    if decision
      if decision['http://data.hampshirehub.net/def/planning/decisionIssued']
        outcome = decision['http://data.hampshirehub.net/def/planning/decisionIssued'][0]['@id']
        case outcome
        when 'http://opendatacommunities.org/def/concept/planning/decision-issued/approve'
          status = Configuration::THEME_HAMPSHIRE_STATUSES['approved']
        when 'http://opendatacommunities.org/def/concept/planning/decision-issued/refuse'
          status = Configuration::THEME_HAMPSHIRE_STATUSES['refused']
        else
          warn "unknown status - #{outcome}, from #{decision['@id']}"
        end
      else
        # hmm, data glitch? No decisionIssued in the decision data :(
        # or maybe this is when it's been decided but the decision hasn't
        # been made public yet. Default to 'pending'.
      end
    end
    return status
  end

  def self.extract_decision_date(decision, status)
    decision_date = nil
    # Pending applications in theory don't have a decision, but some weird
    # ones do, so we have to guard against them
    if decision and status != Configuration::THEME_HAMPSHIRE_STATUSES['pending']
      # noticeDate is the official date that notice of the decision is
      # given to the applicant
      if decision['http://data.hampshirehub.net/def/planning/noticeDate']
        decision_date = decision['http://data.hampshirehub.net/def/planning/noticeDate'][0]['@value']
        decision_date = Time.iso8601(decision_date)
      end
    end
    return decision_date
  end

  def self.extract_target_date(application, decision)
    target_date = nil

    # Work out when the application should have been decided by. If there's a
    # decision, we assume that the date given on that as a target is better
    # than the target date on the application, though you'd think they'd be
    # the same.
    if decision and decision['http://data.hampshirehub.net/def/planning/targetDate']
      target_date = decision['http://data.hampshirehub.net/def/planning/targetDate'][0]['@value']
      target_date = Time.iso8601(target_date)
    elsif application['http://data.hampshirehub.net/def/planning/targetDate']
      target_date = application['http://data.hampshirehub.net/def/planning/targetDate'][0]['@value']
      target_date = Time.iso8601(target_date)
    end
    return target_date
  end

  def self.extract_delayed(application, decision, status, decision_date, target_date=nil)
    delayed = nil

    # Use the decision_date if we're given it, otherwise we'll compare
    # the target date to Now to see if it's late
    unless decision_date
      decision_date = Time.now
    end

    unless target_date
      target_date = extract_target_date(application, decision)
    end

    if target_date
      delayed = target_date < decision_date
    end

    return delayed
  end

  def self.extract_council_category(application)
    council_category = nil
    if application['http://data.hampshirehub.net/def/planning/hasDevelopmentCategory']
      council_category = application['http://data.hampshirehub.net/def/planning/hasDevelopmentCategory'][0]['@id']
    end
    return council_category
  end

  def self.extract_category(council_category, description, classifier)
    # We determine some by Q/R code, and others using a Bayesian classifier
    category = nil
    if council_category
      householder_developments = 'http://opendatacommunities.org/def/concept/planning/application/6000/6014'
      major_development_categories = [
        'http://opendatacommunities.org/def/concept/planning/application/6000/6001',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6002',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6003',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6004',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6005',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6006',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6023',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6024',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6025',
      ]
      tree_and_hedge_categories = [
        'http://opendatacommunities.org/def/concept/planning/application/6000/6019',
        'http://opendatacommunities.org/def/concept/planning/application/6000/6022',
      ]

      if council_category == householder_developments
        if description
          category = classifier.classify(description)
        end
      elsif major_development_categories.include?(council_category)
        category = 'major developments'
      elsif tree_and_hedge_categories.include?(council_category)
        category = 'trees and hedges'
      end
    end
    return category
  end

  def self.extract_address(application)
    # Pull in the localisation record
    place_json = RestClient::Request.new(
      :method => :get,
      :url => @@resource_url,
      :headers => {
        :params => {
            :uri => application['http://schema.org/location'][0]['@id']
        },
      },
      :user => Configuration::PUBLISHMYDATA_USER,
      :password => Configuration::PUBLISHMYDATA_PASSWORD,
    ).execute
    # the "resource" endpoint returns an array despite not being plural
    JSON.parse(place_json)[0]
  end

  def self.extract_location(place)
    # Some places, e.g http://data.hampshirehub.net/id/planning-application/district-council/rushmoor/14/00311/CONDPP/location
    # don't have easting/northings
    location = nil
    if place['http://data.ordnancesurvey.co.uk/ontology/spatialrelations/easting'] \
       and place['http://data.ordnancesurvey.co.uk/ontology/spatialrelations/northing']
      radians_location = GlobalConvert::Location.new(
        :input => {
          :projection => :osgb36,
          :lon => place['http://data.ordnancesurvey.co.uk/ontology/spatialrelations/easting'][0]['@value'].to_f,
          :lat => place['http://data.ordnancesurvey.co.uk/ontology/spatialrelations/northing'][0]['@value'].to_f
        },
        :output => {
          :projection => :wgs84
        }
      )
      # Global convert returns the location lat/lng in Radians, which is ace
      # because our search engine also works in Radians, however the planning
      # alerts convention (and, well, most people's convention) is degrees,
      # so we convert to degrees here
      location = {
        :lat => radians_location.lat * (180 / Math::PI),
        :lng => radians_location.lon * (180 / Math::PI)
      }
    end
    return location
  end

  def self.extract_decision(application)
    decision = nil
    if application['http://data.hampshirehub.net/def/planning/hasDecision']
      decision_json = RestClient::Request.new(
        :method => :get,
        :url => @@resource_url,
        :headers => {
          :params => {
              :uri => application['http://data.hampshirehub.net/def/planning/hasDecision'][0]['@id']
          },
        },
        :user => Configuration::PUBLISHMYDATA_USER,
        :password => Configuration::PUBLISHMYDATA_PASSWORD,
      ).execute
      decision = JSON.parse(decision_json)[0]
    end
    return decision
  end
end