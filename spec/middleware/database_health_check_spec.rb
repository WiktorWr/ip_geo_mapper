# frozen_string_literal: true

require "rails_helper"
require_relative "../../lib/middleware/database_health_check"

RSpec.describe DatabaseHealthCheck do
  subject(:check_db_health) { middleware.call(env) }

  let!(:app)            { ->(_env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let!(:middleware)     { described_class.new(app) }
  let!(:env)            { Rack::MockRequest.env_for("/") }

  context "when database connection is established" do
    it "returns appropriate status code" do
      expect(check_db_health[0]).to eq(200)
    end

    it "returns appropriate body" do
      expect(check_db_health[2]).to eq(["OK"])
    end
  end

  context "when database connection is not established" do
    before do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(ActiveRecord::ConnectionNotEstablished)
    end

    it "returns appropriate status code" do
      expect(check_db_health[0]).to eq(503)
    end

    it "returns appropriate body" do
      expect(check_db_health[2]).to eq([DatabaseHealthCheck::ERROR_MESSAGE])
    end
  end
end
