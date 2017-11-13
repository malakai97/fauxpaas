module Fauxpaas

  # Uniquely identifies an app at a point in time, including the machinery
  # used to deploy it.
  class ReleaseSignature

    def self.from_hash(hash)
      new(
        source: GitReference.from_hash(hash[:source]),
        infrastructure: GitReference.from_hash(hash[:infrastructure]),
        deploy: GitReference.from_hash(hash[:deploy]),
      )
    end

    # @param source [GitReference]
    # @param infrastructure [GitReference]
    # @param deploy [GitReference]
    def initialize(source:, infrastructure:, deploy:)
      @source = source
      @infrastructure = infrastructure
      @deploy = deploy
    end

    attr_reader :source, :infrastructure, :deploy

    def eql?(other)
      to_hash == other.to_hash
    end

    def to_hash
      {
        source: source.to_hash,
        infrastructure: infrastructure.to_hash,
        deploy: deploy.to_hash
      }
    end
  end

end
