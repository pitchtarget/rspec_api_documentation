module RspecApiDocumentation
  module Views
    class JekyllExample < MarkupExample
      EXTENSION = 'markdown'
      COMPILED_EXTENSION = 'html'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/jekyll_example"
      end

      def extension
        EXTENSION
      end

      def compiled_filename
        filename.gsub(/#{EXTENSION}/, COMPILED_EXTENSION)
      end

      def requests
        super.map do |hash|
          hash[:request_body_is_json] = hash[:request_content_type] == 'application/json'
          hash[:response_body_is_json] = hash[:response_content_type] == 'application/json'
          
          hash[:request_body_text] = format_json(hash[:request_body]) if hash[:request_body_is_json]
          hash[:response_body_text] = format_json(hash[:response_body]) if hash[:response_body_is_json]

          hash
        end
      end

      private

      def format_json(json_string)
        JSON.pretty_generate(JSON.parse(json_string.to_s))
      end
    end
  end
end
