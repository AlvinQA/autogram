def navigate_to_login(driver, domain, uris)
  go_to_url(driver, domain << uris["login"])
  sleep random_wait_length
end

def navigate_to_profile(user=@properties["test_account"]["username"])
  go_to_url(@driver, @domain << user)
  sleep random_wait_length
end

def navigate_to_tag(driver, domain, uris, tag)
  go_to_url(driver, domain << uris["tag_view"] << tag)
  sleep random_wait_length
end
