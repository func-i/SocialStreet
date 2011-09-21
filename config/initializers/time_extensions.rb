require 'rubygems'
require 'active_support'

# Used for rounding up/down to the next/prev 15 minute interval for a given time.
# Eg: 2:13 -> 2:00 or 2:13 -> 2:15
module TimeExtensions
  %w[ round floor ceil ].each do |_method|
    define_method _method do |*args|
      seconds = args.first || 60
      Time.at((self.to_f / seconds).send(_method) * seconds).utc
    end
  end
end

Time.send :include, TimeExtensions
