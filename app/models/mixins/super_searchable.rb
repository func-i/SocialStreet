# Brought in by KV from span6.com project

module Mixins
  module SuperSearchable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def make_searchable(opts={})
        cattr_accessor :search_fields
        cattr_accessor :search_includes
        self.search_fields = opts.delete(:fields)
        self.search_includes = opts.delete(:include)
        # need to account for joins (removed it now due to Arel syntax)
        scope :with_keywords, lambda { |query|
          chain = nil
          if self.search_includes && self.search_includes.size > 0 # always expect array
            self.search_includes.each {|j| chain = chain ? chain.includes(j.to_sym) : includes(j.to_sym) }
          end
          chain ? chain.where(build_search_conditions(query)) : where(build_search_conditions(query))
        }
      end

      def build_search_conditions(query)
        words = query.strip.upcase.split.collect{|w| w.strip }
        query = []
        params = {}
        words.each_with_index do |word, i|
          key = "word#{i}"
          query << build_query_string_for_key(key)
          params[key.to_sym] = "#{word}%"
        end
        query = query.join(" AND ")
        [query, params]
      end

      # This will build something like "(UPPER(videos.name) LIKE :#{key} OR UPPER(videos.description) LIKE :#{key} OR UPPER(videos.tags) LIKE :#{key})"
      def build_query_string_for_key(key)
        "(" + self.search_fields.collect {|field| "UPPER(CAST(#{field.to_s} AS varchar)) LIKE :#{key}"  }.join(" OR ") + ")"
      end
    end
  end
end