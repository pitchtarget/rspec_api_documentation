module RspecApiDocumentation
  module Writers
    class JekyllWriter < GeneralMarkupWriter
      EXTENSION = 'markdown'

      def markup_index_class
        RspecApiDocumentation::Views::JekyllIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::JekyllExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
