require 'immortal/belongs_to_builder'

module Immortal
  # Includes this to add +association_{with/only}_deleted+ accessors for belongs_to
  # associations.
  module BelongsTo
    def self.included(base)
      base.class_eval do
        class << self
          # Add with/how_deleted singular association readers
          def belongs_to_mortal(name, scope = nil, options = {})
            reflection = BelongsToBuilder.build(self, name, scope, options)
            ActiveRecord::Reflection.add_reflection self, name, reflection
          end

          alias_method :belongs_to_immortal, :belongs_to
          alias_method :belongs_to, :belongs_to_mortal
        end
      end
    end
  end
end
