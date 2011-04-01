require 'rubygems'
require 'active_support'

module TimeExtensions
  %w[ round floor ceil ].each do |_method|
    define_method _method do |*args|
      seconds = args.first || 60
      Time.at((self.to_f / seconds).send(_method) * seconds).utc
    end
  end
end

Time.send :include, TimeExtensions