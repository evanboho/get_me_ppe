require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

module GoogleSheets

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze

  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def self.spreadsheet(key:, range:, service: :api_key)
    service = service == :api_key ? api_key_service : oauth_service
    service.get_spreadsheet_values key, range
  end

  def self.api_key_service
    Google::Apis::SheetsV4::SheetsService.new.tap do |service|
      service.key = 'AIzaSyDGVdRSvCxSz9irC_pSVosxOdaGEgnSAW4'
    end
  end

  def self.oauth_service
    # Initialize the API
    Google::Apis::SheetsV4::SheetsService.new.tap do |service|
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
    end
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def self.authorize
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def self.client_id
    @client_id ||= Google::Auth::ClientId.from_file CREDENTIALS_PATH
  end

  def self.token_store
    @token_store ||= Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  end

  def self.authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  end

end
