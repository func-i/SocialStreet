# Brought in by KV from span6.com project

module Mixins
  module GeneralHelpers
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def humanize_price(field_name)
        # dynamically create getter and setter wrappers around field_name
        self.class_eval %{
          def #{field_name}_in_dollars
            #{field_name}.to_f / 100.00 if #{field_name}
          end
          def #{field_name}_in_dollars=(new_val)
            self.#{field_name} = (new_val.to_f * 100.00).round
            new_val
          end
        }
      end
    end
  end
end

