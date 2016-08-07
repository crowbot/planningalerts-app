namespace :southwark do
  desc "Calculate authority-wide stats based on currently loaded data"
  task :calculate_authority_stats => :environment do
    # get a list of all the categories
    categories = Configuration::THEME_SOUTHWARK_CATEGORIES

    # Wrap this in one big transaction to make it slightly faster
    # https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
    app_statuses = Configuration::THEME_SOUTHWARK_CATEGORIES
    ActiveRecord::Base.transaction do
      Authority.enabled.each do |authority|
        attributes = {
          :authority_id => authority.id,
          :category => nil,
          :total => authority.applications.count,
          :delayed => authority.applications.where(:delayed => true).count,
          :appeal_decided => authority.applications.where(:status => app_statuses['appeal_decided']).count,
          :appeal_received => authority.applications.where(:status => app_statuses['appeal_received']).count,
          :application_decided => authority.applications.where(:status => app_statuses['application_decided']).count,
          :application_withdrawn => authority.applications.where(:status => app_statuses['application_wihdrawn']).count,
          :pending_decision => authority.applications.where(:status => app_statuses['pending_decision']).count,
          :pending_delegated_decision => authority.applications.where(:status => app_statuses['pending_delegated_decision']).count,
          :registered_as_valid => authority.applications.where(:status => app_statuses['registered_as_valid']).count,
        }

        stats = AuthorityStatsSummary.where(
          :authority_id => authority.id,
          :category => nil
        ).first_or_initialize(attributes)
        unless stats.new_record?
          stats.update_attributes(attributes)
        end
        stats.save!

        categories.each do |category|
          attributes = {
            :authority_id => authority.id,
            :category => category,
            :total => authority.applications.where(:category => category).count,
            :delayed => authority.applications.where(:category => category, :delayed => true).count,
            :appeal_decided => authority.applications.where(:status => app_statuses['appeal_decided']).count,
            :appeal_received => authority.applications.where(:status => app_statuses['appeal_received']).count,
            :application_decided => authority.applications.where(:status => app_statuses['application_decided']).count,
            :application_withdrawn => authority.applications.where(:status => app_statuses['application_wihdrawn']).count,
            :pending_decision => authority.applications.where(:status => app_statuses['pending_decision']).count,
            :pending_delegated_decision => authority.applications.where(:status => app_statuses['pending_delegated_decision']).count,
            :registered_as_valid => authority.applications.where(:status => app_statuses['registered_as_valid']).count,
          }
          stats = AuthorityStatsSummary.where(
            :authority_id => authority.id,
            :category => category
          ).first_or_initialize(attributes)
          unless stats.new_record?
            stats.update_attributes(attributes)
          end
          stats.save!
        end
      end
    end
  end
end