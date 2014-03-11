module RspecApiDocumentation
  module Views
    class JekyllIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/jekyll_index"
      end

      def examples
        @index.examples.map { |example| JekyllExample.new(example, @configuration) }
      end
    end
  end
end
