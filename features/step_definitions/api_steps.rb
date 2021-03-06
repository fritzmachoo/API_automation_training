Given(/^I want to get the users$/) do
  @request = 'get'
end

Then(/^the response is a success$/) do
  p @response.code
  p @response.message
  expect(@response.code).to eq('200')
  expect(@response.message).to eq('OK')

end

Given(/^I want to add a user$/) do
  @json = create_user
  @request = 'post'
end


When(/^I send an api request$/) do
  case @request.downcase
    when 'get'
      send_get(TestConfig['host'], '/api/users')
    when 'post'
      send_post(TestConfig['host'], '/api/users', @json)
    when 'put'
      send_put(TestConfig['host'], '/api/users/1', @json)
    when 'get_with_parameters'
      send_get_with_parameters(TestConfig['host'], '/api/users', @parameters)
    when 'delete'
      send_delete(TestConfig['host'], '/api/users/2')
    when 'register'
      send_post(TestConfig['host'], '/api/register', @json)
    when 'options'
      send_options(TestConfig['host'], '/api/users/')
    else
      raise('Request method not available')
  end
end

Then(/^the user is added$/) do
  p @response.code
  p @response.message
  expect(@response.code).to eq('201')
  expect(JSON.parse(@response.body)['first_name']).to eq(@user.first_name)
  expect(JSON.parse(@response.body)['last_name']).to eq(@user.last_name)
  expect(JSON.parse(@response.body)['createdAt'].to_s[0..9]).to eq(Time.now.to_s[0..9])
  id = JSON.parse(@response.body)['id']
  p "Your User ID is: #{id}"
end

Given(/^I want to update a user$/) do
  @json = update_user
  @request = 'put'
end

And(/^the user is updated$/) do
  response = JSON.parse(@response.body)
  expect(response['first_name']).to eq(@user.first_name)
  expect(response['last_name']).to eq(@user.last_name)
  expect(response['address'][0]['house']).to eq(@user.address[0].house)
  expect(response['updatedAt'].to_s[0..9]).to eq(Time.now.to_s[0..9])
end


Given(/^I want to get the users with parameters$/) do
  @json = send_get
  @request = 'get_with_parameters'
end

And(/^I want to get "([^"]*)" pages with "([^"]*)" users per page$/) do |page, user_number|
  @parameters = "page=#{page}&page_number#{user_number}"
end

Then(/^the response displays "([^"]*)" pages with "([^"]*)" users per page$/) do |page, user_number|
  response = JSON.parse(@response.body)
  expect(response['page']).to eq(page.to_i)
  expect(response['per_page']).to eq(user_number.to_i)
end

Given(/^I want to delete a user$/) do
  @request = 'delete'
end

Then(/^the user is deleted$/) do
  p @response.code
  p @response.message
  expect(@response.code).to eq('204')
  expect(@response.message).to eq('No Content')
end

Given(/^I want to register a user with email (.*) and password (.*)$/) do |email, password|
  @request = 'register'
  @register_user = Credentials.new
  @register_user.email = email
  @register_user.password = password
  @json = JSON.generate(@register_user)
end

Then(/^the following (.*) is returned/) do |response|
  p @response.code
  p @response.message
  expect(JSON.parse(@response.body)['error']).to eq(response)
end

Then(/^the user is successfully created$/) do
  p @response.code
  p @response.message
  expect(@response.code).to eq('201')
  expect(@response.message).to eq('Created')
  expect(JSON.parse(@response.body)['token']).to_not eq(nil)
#  expect(JSON.parse(@response.body)['token']).to eq()
end

Given(/^I want to find out the options$/) do
  @request = 'options'
end

Then(/^the response is not allowed$/) do
  p @response.code
  p @response.message
  expect(@response.code).to eq('204')
  expect(@response.message).to eq('No Content')
  if expect @response.header['access-control-allow-methods'].downcase.include?('options')
    raise ('Options is included')
  end
end