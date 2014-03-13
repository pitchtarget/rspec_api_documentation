require 'multipart_parser/reader'

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
          hash[:request_body_is_json] = hash[:request_content_type] =~ /application\/json/
          hash[:request_body_is_multipart] = hash[:request_content_type] =~ /multipart/
          hash[:response_body_is_json] = hash[:response_content_type] =~ /application\/json/
          
          hash[:request_body_text] = format_json(hash[:request_body]) if hash[:request_body_is_json]
          hash[:request_body_parsed] = parse_multipart(hash[:request_body], hash[:request_content_type]) if hash[:request_body_is_multipart]
          hash[:response_body_text] = format_json(hash[:response_body]) if hash[:response_body_is_json]

          hash
        end
      end

      private

      def format_json(json_string)
        JSON.pretty_generate(JSON.parse(json_string.to_s))
      end

      def parse_multipart(request_body, content_type)
        boundary = MultipartParser::Reader.extract_boundary_value(content_type)
        reader = MultipartParser::Reader.new(boundary)
        parsed = []
        reader.on_part do |part|
          value = ""
          unless part.filename.nil?
            value = "@#{part.filename};type=#{part.mime}"
          else
            part.on_data do |data|
              value += data
            end
          end
          part.on_end do
            value = value.gsub("'", "\\u0027")
            begin
              value = format_json(value)
            rescue => error
              # NOOP
            end
            parsed << { :name => part.name, :value => value }
          end
        end
        reader.write(request_body.to_s)
        parsed
      end
    end
  end
end
