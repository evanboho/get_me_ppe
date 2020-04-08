class AddZendeskSyncErrorToOnfleetWebRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :onfleet_webhook_requests, :zendesk_sync_error, :string
  end
end
