# Load the Rails application.
require_relative 'application'

require 'google_sheets'
require 'get_me_ppe/spreadsheets'
require 'lock_manager'
require 'zendesk_client'

# Initialize the Rails application.
Rails.application.initialize!


