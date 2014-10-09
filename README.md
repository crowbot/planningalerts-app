# PlanningAlerts

Find out and have your say about development applications in your area.

This is the code for the [web application](http://www.planningalerts.org.au/) side of things written using Ruby on Rails. The original code from [PlanningAlerts.com](http://www.planningalerts.com), which this app is based on, was written using PHP.

If you're interested in contributing a scraper please give us a shout on the [mailing list](http://groups.google.com/group/openaustralia-dev) and we'll point you in the right direction. We're currently in the midst of changing the place that we run scrapers so it's all in a bit of a state of flux.

PlanningAlerts is brought to you by the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au). It was adapted for Australia by Matthew Landauer and Katherine Szuminska, and is based on the UK site PlanningAlerts.com, built by Richard Pope, Mikel Maron, Sam Smith, Duncan Parkes, Tom Hughes and Andy Armstrong.

## Development

[![Build Status](https://travis-ci.org/openaustralia/planningalerts-app.png?branch=master)](https://travis-ci.org/openaustralia/planningalerts-app) [![Dependency Status](https://gemnasium.com/openaustralia/planningalerts-app.png)](https://gemnasium.com/openaustralia/planningalerts-app) [![Coverage Status](https://coveralls.io/repos/openaustralia/planningalerts-app/badge.png?branch=master)](https://coveralls.io/r/openaustralia/planningalerts-app?branch=master) [![Code Climate](https://codeclimate.com/github/openaustralia/planningalerts-app.png)](https://codeclimate.com/github/openaustralia/planningalerts-app)

**Install Dependencies**
 * Install MySql - On OSX download dmg from [http://dev.mysql.com/downloads/](http://dev.mysql.com/downloads/)
 * Install Sphinx - `brew install sphinx`

**Checkout The Project**
 * Fork the project on Github
 * Checkout the project

**Install Ruby Dependencies**
 * Install bundler - `gem install bundler`
 * Install dependencies - `bundle install`

**Setup The Database**
 * Create your own database config file - `cp config/database.yml.example config/database.yml`
 * Update the config/database.yml with your root mysql credentials
 * If you are on OSX change the socket to /tmp/mysql.sock
 * Create the databases - `rake db:create`
 * Load the database schema - `rake db:schema:load`
 * Generate Thinking Sphinx configuration - `bundle exec rake thinking_sphinx:configure`

**Run The Tests**
 * Run the test suite - `rake`

### Deployment

To use capistrano and the OpenAustralia Foundation's default configuration model, ignore this part of the instructions and carry on. To use mySociety's yaml-based configuration system instead you will need to:

1. Get the git submodules with `git submodule update --init`
1. Copy the settings in `config/general.yml-example` and `config/test.yml-example` to `config/general.yml` and `config/test.yml`

This should cause the Configuration object in `app/models/configuration.rb` to be overriden by `lib/themes/hampshire/configuration.rb` which will replace the Configuration object's values with the ones held in the yml files. You can test whether this is working by running `rspec lib/themes/hampshire/spec/models/configuration_spec.rb`

Please note - customisations which are specific to mySociety's Hampshire theme have settings which exist only in the yml files. Config settings which relate to the main application are duplicated in the Configuration object.

### Scraping and sending emails in development

**Step 1 - Seed authorities table**
 * Start the rails server - `rails s`
 * Create an admin user - TODO: Explain how to do this
 * Go to the admin console - http://localhost:3000/admin
 * Create the authority Marrickville with the following data
   * FULL NAME	`Marrickville Council`
   * SHORT NAME	`Marrickville`
   * STATE	`NSW`
   * EMAIL	`council@marrickville.nsw.gov.au`
   * POPULATION 2011	`81489`
   * MORPH NAME	`planningalerts-scrapers/marrickville`
   * DISABLED	`false`

**Step 2 - Scrape DAs**
 * Register on [morph.io](https://morph.io) and [get your api key](https://morph.io/documentation/api).
 * Update `MORPH_API_KEY` in app/models/configuration.rb
 * Run - `rake planningalerts:applications:scrape['marrickville']`

**Step 3 - Setup an Alert**
 * Start the rails server - `rails s`
 * Start MailCatcher - `mailcatcher`
 * Hit the home page - http://localhost:3000
 * Enter an address e.g. 638 King St, Newtown NSW 2042
 * Click the "Email me" link and setup an alert
 * Open MailCatcher and click the confirm link: http://localhost:1080/

**Step 4 - Send email alerts**
 * Run - `rake planningalerts:applications:email`
 * Check the email in your browser: http://localhost:1080/
 * To resend alerts during testing, just set the `last_sent` attribute of your alert to *nil*

## Contributing

* Fork the project on GitHub.
* Make a topic branch from the master branch.
* Make your changes and write tests.
* Commit the changes without making changes to any files that aren't related to your enhancement or fix.
* Send a pull request against the master branch.

## Credits

Our awesome contributors can be found on the [PlanningAlerts site](http://www.planningalerts.org.au/about).

## License

GPLv2, see the LICENSE file for full details.
