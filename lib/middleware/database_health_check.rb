# frozen_string_literal: true

class DatabaseHealthCheck
  ERROR_MESSAGE = "Database connection error"

  def initialize(app)
    @app = app
  end

  def call(env)
    ActiveRecord::Base.connection.execute("SELECT 1")
    @app.call(env)
  rescue ActiveRecord::ConnectionNotEstablished => e
    Rails.logger.error("#{ERROR_MESSAGE}: #{e.message}")
    error_response(ERROR_MESSAGE, :service_unavailable)
  end

  private

  def error_response(error, http_code)
    [
      Rack::Utils.status_code(http_code),
      { "Content-Type" => "application/json" },
      [error]
    ]
  end
end
