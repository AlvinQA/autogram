def navigate_login(driver, domain)
    puts "Navigating to login page."
    go_to_url(driver, 'http://www.instagram.com')
    sleep random_wait_length
end

def login(driver, username='', password='')
	enter_username(driver, username)
    sleep random_wait_length
	enter_password(driver, password)
    sleep random_wait_length
	click_login_button(driver)
    sleep random_wait_length
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
