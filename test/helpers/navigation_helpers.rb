def navigate_to_login(driver, domain, uris)
    puts "Navigating to login page."
    go_to_url(driver, domain << uris["login"])
    sleep random_wait_length
end

def navigate_to_dashboard
    user = @properties["test_account"]["username"]
    puts "Navigating to dashboard."
    go_to_url(@driver, @domain << user)
    sleep random_wait_length
end

def navigate_to_tag(driver, domain, uris, tag)
    puts "Navigating to tag: \#" << tag
    go_to_url(driver, domain << uris["tag_view"] << tag)
    sleep random_wait_length
end
