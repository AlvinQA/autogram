def login(driver, username='', password='')
  # TODO: Handle the login with facebook case
  change_to_login_form(driver)
  enter_username(driver, username)
  sleep random_wait_length
  enter_password(driver, password)
  sleep random_wait_length
  click_login_button(driver)
  sleep random_wait_length
end

def change_to_login_form(driver)
  account_path = '//*[contains(.,"Have an account")]'
  if driver.find_elements(:xpath => account_path).size > 0
    login_path = '//a[contains(.,"Log in")]'
    driver.find_element(:xpath => login_path).click
  end
end

def enter_username(driver, username)
  puts "Entering username: #{username}"
  wait_until_visible(driver, :name, 'username')
  driver.find_element(:name => 'username').send_keys username
end

def enter_password(driver, password)
  puts "Entering password: HEY! Don't look at my password!"
  wait_until_visible(driver, :name, 'password')
  driver.find_element(:name => 'password').send_keys password
end

def click_login_button(driver)
  puts "Clicking Log in button"
  wait_until_visible(driver, :xpath, '//button[contains(.,"Log in")]')
  driver.find_element(:xpath => '//button[contains(.,"Log in")]').click
end
