def login(username=@properties["username"],password=@properties["password"])
  # TODO: Handle the login with facebook case
  change_to_login_form
  enter_username(username)
  sleep random_wait_length
  enter_password(password)
  sleep random_wait_length
  click_login_button
  sleep random_wait_length
  assert(logged_in?, "FAILURE: Failed to log in, you a-hole!")
end

def change_to_login_form
  account_path = '//*[contains(.,"Have an account")]'
  if @driver.find_elements(:xpath => account_path).size > 0
    login_path = '//a[contains(.,"Log in")]'
    @driver.find_element(:xpath => login_path).click
  end
end

def enter_username(username)
  puts "Entering username: #{username}"
  wait_until_visible(@driver, :name, 'username')
  @driver.find_element(:name => 'username').send_keys username
end

def enter_password(password)
  puts "Entering password: HEY! Don't look at my password!"
  wait_until_visible(@driver, :name, 'password')
  @driver.find_element(:name => 'password').send_keys password
end

def click_login_button
  puts "Clicking Log in button"
  path = '//button[contains(.,"Log in")]'
  wait_until_visible(@driver, :xpath, path)
  @driver.find_element(:xpath => path).click
end
