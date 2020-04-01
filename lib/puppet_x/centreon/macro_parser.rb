require_relative '../puppet_x.rb'

module PuppetX::Centreon
  # Parse JSON to macro object
  class MacroParser
    def initialize(macros)
      @macros = []
      @macros << macros.reject(&:nil?).map do |macro|
        # expand port to to_port and from_port
        new_macro = Marshal.load(Marshal.dump(macro))
        new_macro[:name] = new_macro[:name].upcase unless new_macro[:name].nil?

        new_macro
      end
      @macros = @macros.flatten
    end

    def macros_to_create(macros)
      stringify_values(@macros) - stringify_values(macros)
    end

    def macros_to_delete(macros)
      stringify_values(macros) - stringify_values(@macros)
    end

    private

    def stringify_values(macros)
      macros.map do |obj|
        obj.each { |k, v| obj[k] = v.to_s }
      end
    end
  end
end
