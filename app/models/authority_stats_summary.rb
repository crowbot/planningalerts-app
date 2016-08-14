class AuthorityStatsSummary < ActiveRecord::Base
  def self.overview
    AuthorityStatsSummary.where(:category => nil).first
  end

  def self.overview_json
    {
      :percentage_appeal_decided => overview.percentage_appeal_decided,
      :percentage_appeal_received => overview.percentage_appeal_received,
      :percentage_application_decided => overview.percentage_application_decided,
      :percentage_application_withdrawn => overview.percentage_application_withdrawn,
      :percentage_pending_decision => overview.percentage_pending_decision,
      :percentage_pending_delegated_decision => overview.percentage_pending_delegated_decision,
      :percentage_registered_as_valid => overview.percentage_registered_as_valid
    }
  end

  def self.category(name)
    AuthorityStatsSummary.where(:category => name).first
  end

  def method_missing(name,*args,&block)
    if name =~ /^percentage_(.*)$/ and attributes.include?($1) and eval("self.#{$1}").is_a?(Numeric)
      return calculate_percentage($1)
    else
      super
    end
  end

  protected

  def calculate_percentage(attribute)
    if self.total == 0
      return nil
    else
      return (eval("self.#{attribute}").to_f / self.total * 100.0).round
    end
  end
end