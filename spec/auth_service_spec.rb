# frozen_string_literal: true

require "moku/auth_service"

module Moku
  RSpec.describe AuthService do
    # The AuthService is initialized with roles. We use a policy
    # here that checks for roles, not actions, for simplicity.
    class TestPolicy
      def self.for(roles)
        new(roles)
      end

      attr_reader :roles

      def initialize(roles)
        @roles = roles
      end

      def authorized?(role)
        roles.include?(role)
      end
    end

    describe "#authorized?" do
      let(:user) { "bhock" }
      let(:action) { :global }
      let(:entity) { double(:entity, name: "myapp-staging") }

      context "with missing attributes" do
        let(:service) do
          described_class.new(
            policy_factory: TestPolicy,
            global: { "global" => ["bhock"] },
            instances: {
              entity.name => { "local" => ["bhock"] }
            }
          )
        end

        it "handles missing users" do
          expect(service.authorized?(
            user: nil,
            action: action,
            entity: entity
          )).to be false
        end

        it "handles blank users" do
          expect(service.authorized?(
            user: "",
            action: action,
            entity: entity
          )).to be false
        end

        it "handles missing actions" do
          expect(service.authorized?(
            user: user,
            action: nil,
            entity: entity
          )).to be false
        end

        it "handles blank actions" do
          expect(service.authorized?(
            user: user,
            action: "",
            entity: entity
          )).to be false
        end

        it "handles missing entities" do
          expect(service.authorized?(
            user: user,
            action: action,
            entity: nil
          )).to be false
        end
      end

      context "with only top level permissions" do
        let(:service) do
          described_class.new(
            policy_factory: TestPolicy,
            global: { "global" => ["bhock"] },
            instances: {
              entity.name => { "instance" => ["bhock"] }
            }
          )
        end

        it "propogates top level permissions downward" do
          expect(service.authorized?(
            user: user,
            action: :global,
            entity: entity
          )).to be true
        end
      end

      context "with both permission types" do
        let(:service) do
          described_class.new(
            policy_factory: TestPolicy,
            global: { "global" => ["bhock"] },
            instances: {
              entity.name => { "instance" => [], "local" => [] }
            }
          )
        end

        it "doesn't merge global permissions" do
          expect(service.authorized?(
            user: user,
            action: :local,
            entity: entity
          )).to be false
        end
        it "doesn't override global permissions" do
          expect(service.authorized?(
            user: user,
            action: :global,
            entity: entity
          )).to be true
        end
      end
    end
  end
end
