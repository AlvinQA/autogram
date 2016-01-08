def navigate_login(driver, domain, uris)
    puts "Navigating to login page."
    go_to_url(driver, domain + uris['login'])
    sleep random_wait_length
end

def navigate_to_user(driver, domain, uris, user)
    puts "Navigating to user: " + user
    go_to_url(driver, domain + uris['user_view'] + user)
    sleep random_wait_length
end

def navigate_to_tag(driver, domain, uris, tag)
    puts "Navigating to tag: \#" + tag
    go_to_url(driver, domain + uris['tag_view'] + tag)
    sleep random_wait_length
end
