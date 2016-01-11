def like_all_since_last_login(driver, username='', password='')
	# TODO: Load all posts since last run. We'll have to humanize the stored date,
    # then compare vs. when the run started
end

def load_more(driver)
    puts "Loading new batch of posts"
    if driver.find_elements(:xpath => '//a[contains(.,"Load more")]').size > 0
        driver.find_element(:xpath => '//a[contains(.,"Load more")]').click
    else
        driver.find_element(:xpath => '//footer')
    end
    sleep random_wait_length + 2
end

def seeding_followers?(driver)
    # This is going to be true if it's a new account that isn't following anyone.
    # Instagram gives new users a suggested user list
    if driver.find_elements(:xpath => '//h1[contains(.,"Suggested accounts to follow")]').size > 0
        # TODO: Add specific users for seeding, not just the suggested users
        follow_all_suggested(driver)
        return true
    else
        return false
    end
end

def follow_all_suggested(driver)
    # TODO: Validate when each person is added
    driver.find_elements(:xpath => '//button[contains(.,"Follow")]').each { |i|
        i.click
        sleep random_wait_length
    }
end