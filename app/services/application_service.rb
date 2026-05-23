# frozen_string_literal: true

class ApplicationService
  HasDependents = Class.new(StandardError)

  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end
end
