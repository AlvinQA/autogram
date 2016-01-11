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

def seed_followers?(driver, pending)
    # This is going to be true if it's a new account that isn't following anyone.
    # Instagram gives new users a suggested user list
    if driver.find_elements(:xpath => '//h1[contains(.,"Suggested accounts to follow")]').size > 0
        # TODO: Add specific users for seeding, not just the suggested users
        puts "Following suggested accounts"
        follow_all_suggested(driver, pending)
        return true
    else
        puts "Already following accounts. No suggested accounts to follow"
        return false
    end
end

def follow_all_suggested(driver, pending)
    # TODO: Validate when each person is added
    driver.find_elements(:xpath => '//li[contains(@data-reactid,".0.1.0.1:$userList/=10")]').each { |i|
        pending["#{i.find_element(:xpath => './/*/div/div/div/a').attribute('title')}"] = Time.now
        i.find_element(:xpath => './/button[contains(.,"Follow")]').click
        sleep random_wait_length
    }
    File.open('config/pending.yml', 'w+') {|f| f.write pending.to_yaml }
end