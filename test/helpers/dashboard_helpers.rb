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

def close_dialog(driver)
  path = "//button[contains(.,'Close')]"
  wait_until_clickable(driver, :xpath, path)
end

def followers_count
  path = "//*[@data-reactid='.0.1.0.0:0.1.3.1.0.1']"
  return @driver.find_element(:xpath => path).text.to_i
end

def following_count
  path = "//*[@data-reactid='.0.1.0.0:0.1.3.2.0.1']"
  return @driver.find_element(:xpath => path).text.to_i
end

def get_followers
  path = "//*[@class='_4zhc5']"
  followers = Array.new

  if followers_count > 0
    open_followers_list
    wait_for_followers_list
    load_all_followers

    @driver.find_elements(:xpath => path).each do |i|
      followers << i.text
    end
  else
    followers = followers_count
  end
  return followers
end

def get_following
  path = "//*[@class='_4zhc5']"
  following = Array.new

  if following_count > 0
    open_following_list
    wait_for_following_list
    load_all_following
    @driver.find_elements(:xpath => path).each do |i|
      following << i.text
    end
  else
    following = following_count
  end
  return following
end

def open_followers_list
  path = "//*[@data-reactid='.0.1.0.0:0.1.3.1.0.1']"
  @driver.find_element(:xpath => path).click
end

def open_following_list
  path = "//*[@data-reactid='.0.1.0.0:0.1.3.2.0.1']"
  @driver.find_element(:xpath => path).click
end

def wait_for_following_list
  path = "//*[@data-reactid='.2.1.0.0' and contains(.,'Following')]"
  wait_until_visible(@driver, :xpath, path)
end

def wait_for_followers_list
  path = "//*[@data-reactid='.1.1.0.0' and contains(.,'Followers')]"
  wait_until_visible(@driver, :xpath, path)
end

def load_all_followers
  path = "//*[@class='_cx1ua']"
  loop do
    scroll_list(followers_count)
    current_count = @driver.find_elements(:xpath => path).size
    puts "-----"
    puts current_count
    puts followers_count
    puts current_count == followers_count
    puts "-----"
    break if current_count == followers_count
  end
end

def load_all_following
  path = "//*[@class='_cx1ua']"
  loop do
    scroll_list(following_count)
    current_count = @driver.find_elements(:xpath => path).size
    puts "-----"
    puts current_count
    puts following_count
    puts current_count == following_count
    puts "-----"
    break if current_count == following_count
  end
end

def scroll_list(count=100000)
  xpath = "//*[@class=\"_4gt3b\"]"
  element = "document.evaluate('#{xpath}', document, null, \
    XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue"
  @driver.execute_script("#{element}.scrollTo(0,#{count*50});")
  sleep random_wait_length
end



