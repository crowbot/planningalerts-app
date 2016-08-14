class SouthwarkAuthorityStats < ActiveRecord::Migration
  def up
    add_column :authority_stats_summaries, :appeal_decided, :integer
    add_column :authority_stats_summaries, :appeal_received, :integer
    add_column :authority_stats_summaries, :application_decided, :integer
    add_column :authority_stats_summaries, :application_withdrawn, :integer
    add_column :authority_stats_summaries, :pending_decision, :integer
    add_column :authority_stats_summaries, :pending_delegated_decision, :integer
    add_column :authority_stats_summaries, :registered_as_valid, :integer
  end

  def down
    remove_column :authority_stats_summaries, :appeal_decided
    remove_column :authority_stats_summaries, :appeal_received
    remove_column :authority_stats_summaries, :application_decided
    remove_column :authority_stats_summaries, :application_withdrawn
    remove_column :authority_stats_summaries, :pending_decision
    remove_column :authority_stats_summaries, :pending_delegated_decision
    remove_column :authority_stats_summaries, :registered_as_valid
  end
end
