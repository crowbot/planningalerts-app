class Report < ActiveRecord::Base
  belongs_to :comment

  default_scope order('id')

  validates_presence_of :name, :email, :details
  validates_email_format_of :email, :on => :create
end
