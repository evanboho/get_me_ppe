class OnfleetWebhookRequest < ApplicationRecord
  serialize :body, JSON

  ZENDESK_TICKET_ID_KEY = 'zendesk_ticket_id'
  ZENDESK_STATUSES = {
    # TODO
    # 'unassigned' => :open,
    'assigned'   => :open,
    'active'     => :pending,
    'completed'  => :solved,
  }.freeze

  STATES = {
    'unassigned' => 0,
    'assigned'   => 1,
    'active'     => 2,
    'completed'  => 3
  }.freeze

  before_save :update_zendesk_ticket

  private

  def update_zendesk_ticket
    return unless zendesk_ticket_id

    zendesk_attrs = {}

    zendesk_attrs[:status] = zendesk_status if zendesk_status

    if zendesk_attrs.present?
      ZendeskAPI::Ticket.update(zendesk_client, zendesk_attrs.merge(id: zendesk_ticket_id))
    end
    true
  rescue => e
    self.zendesk_sync_error = "#{e.class}: #{e.message}"
    true
  end

  def zendesk_status
    onfleet_state_string = Hash[STATES.to_a.map(&:reverse)][body.dig('data', 'task', 'state')]
    ZENDESK_STATUSES[onfleet_state_string]
  end

  def zendesk_ticket_id
    metadata = body.dig('data', 'task', 'metadata')
    metadata.find { |a| a['name'] == ZENDESK_TICKET_ID_KEY }&.dig('value')
  end

  def zendesk_client
    ZendeskClient.client
  end

end
