Feature: Generate Jekyll documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require 'sinatra'

      class App < Sinatra::Base
        get '/orders' do
          content_type :json

          [200, [{ name: 'Order 1', amount: 9.99, description: nil },
                 { name: 'Order 2', amount: 100.0, description: 'A great order' }].to_json]
        end

        get '/orders/:id' do
          content_type :json

          [200, { order: { name: 'Order 1', amount: 100.0, description: 'A great order' } }.to_json]
        end

        post '/orders' do
          201
        end

        put '/orders/:id' do
          200
        end

        delete '/orders/:id' do
          200
        end

        get '/help' do
          [200, 'Welcome Henry !']
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.api_name = "Example API"
        config.format = :jekyll
        config.request_headers_to_include = %w[Content-Type Host]
        config.response_headers_to_include = %w[Content-Type Content-Length]
      end

      resource 'Orders' do
        get '/orders' do

          example_request 'Getting a list of orders' do
            status.should eq(200)
            response_body.should eq('[{"name":"Order 1","amount":9.99,"description":null},{"name":"Order 2","amount":100.0,"description":"A great order"}]')
          end
        end

        get '/orders/:id' do
          let(:id) { 1 }

          example_request 'Getting a specific order' do
            status.should eq(200)
            response_body.should == '{"order":{"name":"Order 1","amount":100.0,"description":"A great order"}}'
          end
        end

        post '/orders' do
          parameter :name, 'Name of order', :required => true
          parameter :amount, 'Amount paid', :required => true
          parameter :description, 'Some comments on the order'

          let(:name) { "Order 3" }
          let(:amount) { 33.0 }

          example_request 'Creating an order' do
            status.should == 201
          end
        end

        put '/orders/:id' do
          parameter :name, 'Name of order', :required => true
          parameter :amount, 'Amount paid', :required => true
          parameter :description, 'Some comments on the order'

          let(:id) { 2 }
          let(:name) { "Updated name" }

          example_request 'Updating an order' do
            status.should == 200
          end
        end

        delete "/orders/:id" do
          let(:id) { 1 }

          example_request "Deleting an order" do
            status.should == 200
          end
        end
      end

      resource 'Help' do
        get '/help' do
          example_request 'Getting welcome message' do
            status.should eq(200)
            response_body.should == 'Welcome Henry !'
          end
        end

      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output helpful progress to the console
    Then  the output should contain:
      """
      Generating API Docs
        Orders
        GET /orders
          * Getting a list of orders
        GET /orders/:id
          * Getting a specific order
        POST /orders
          * Creating an order
        PUT /orders/:id
          * Updating an order
        DELETE /orders/:id
          * Deleting an order
        Help
        GET /help
          * Getting welcome message
      """
    And   the output should contain "6 examples, 0 failures"
    And   the exit status should be 0

  Scenario: Index file should look like we expect
    Then the file "doc/api/index.markdown" should contain exactly:
    """
    ---
    layout: default
    title: Example API
    ---

    # Example API

    ## Help

    * [Getting welcome message](help/getting_welcome_message.html)

    ## Orders

    * [Creating an order](orders/creating_an_order.html)
    * [Deleting an order](orders/deleting_an_order.html)
    * [Getting a list of orders](orders/getting_a_list_of_orders.html)
    * [Getting a specific order](orders/getting_a_specific_order.html)
    * [Updating an order](orders/updating_an_order.html)


    """

  Scenario: Example 'Creating an order' file should look like we expect
    Then the file "doc/api/orders/creating_an_order.markdown" should contain exactly:
    """
    ---
    layout: default
    title: Orders API
    ---

    # Orders API

    ## Creating an order

    ### POST /orders


    ### Parameters

    Name | Required? | Description |
    -----|-----------|-------------|
    `name` | Yes | Name of order |
    `amount` | Yes | Amount paid |
    `description` | No | Some comments on the order |

    ### Request

    {% highlight http %}
    POST /orders HTTP/1.1
    Host: example.org
    Content-Type: application/x-www-form-urlencoded

    {% endhighlight %}

    #### Body

    {% highlight text %}
    name=Order+3&amount=33.0
    {% endhighlight %}


    ### Response

    {% highlight http %}
    HTTP/1.1 201 Created
    Content-Type: text/html;charset=utf-8
    Content-Length: 0
    {% endhighlight %}



    """

  Scenario: Example 'Deleting an order' file should be created
    Then a file named "doc/api/orders/deleting_an_order.markdown" should exist

  Scenario: Example 'Getting a list of orders' file should be created
    Then a file named "doc/api/orders/getting_a_list_of_orders.markdown" should exist

  Scenario: Example 'Getting a specific order' file should be created
    Then a file named "doc/api/orders/getting_a_specific_order.markdown" should exist

  Scenario: Example 'Updating an order' file should be created
    Then a file named "doc/api/orders/updating_an_order.markdown" should exist

  Scenario: Example 'Getting welcome message' file should be created
    Then a file named "doc/api/help/getting_welcome_message.markdown" should exist


