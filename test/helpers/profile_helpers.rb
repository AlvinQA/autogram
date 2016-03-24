def like_all_since_last_login(driver, username='', password='')
  # TODO: Load all posts since last run. We'll have to humanize the stored date,
  # then compare vs. when the run started
end

def load_more(driver)
  if driver.find_elements(:xpath => '//a[contains(.,"Load more")]').size > 0
    driver.find_element(:xpath => '//a[contains(.,"Load more")]').click
  else
    driver.find_element(:xpath => '//footer')
  end
  sleep random_wait_length + 2
end

def close_dialog
  path = "//button[contains(.,'Close')]"
  wait_until_clickable(@driver, :xpath, path)
end

def followers_count
  path = "//a[contains(@href,'/followers/')]"
  count = @driver.find_element(:xpath => path).text
  return count.gsub(/[^0-9]/, '').to_i
end

def following_count
  path = "//a[contains(@href,'/following/')]"
  count = @driver.find_element(:xpath => path).text
  return count.gsub(/[^0-9]/, '').to_i
end

def get_followers
  path = "//*[@class='_4zhc5']"
  followers = Array.new
  if followers_count > 0
    open_followers_list
    wait_for_followers_list
    load_followers

    @driver.find_elements(:xpath => path).each do |i|
      followers << i.text
    end
  else
    followers = followers_count
  end
  close_dialog
  return followers
end

def get_following
  path = "//*[@class='_4zhc5']"
  following = Array.new
  if following_count > 0
    open_following_list
    wait_for_following_list
    load_following
    @driver.find_elements(:xpath => path).each do |i|
      following << i.text
    end
  else
    following = following_count
  end
  close_dialog
  return following
end

def open_followers_list
  path = "//a[contains(@href,'/followers/')]"
  @driver.find_element(:xpath => path).click
end

def open_following_list
  path = "//a[contains(@href,'/following/')]"
  @driver.find_element(:xpath => path).click
end

def wait_for_following_list
  path = "//*[@data-reactid='.1.1.0.0' and contains(.,'Following')]"
  wait_until_visible(@driver, :xpath, path)
end

def wait_for_followers_list
  path = "//*[@data-reactid='.1.1.0.0' and contains(.,'Followers')]"
  wait_until_visible(@driver, :xpath, path)
end

def load_followers(num="all")
  path = "//*[@class='_cx1ua']"
  scroll = 100
  loop do
    scroll = scroll_follow_list(scroll)
    current_count = @driver.find_elements(:xpath => path).size
    break if current_count == followers_count
    if num != "all"
      break if current_count >= num
    end
  end
end

def load_following(num="all")
  path = "//*[@class='_cx1ua']"
  scroll = 100
  loop do
    scroll = scroll_follow_list(scroll)
    current_count = @driver.find_elements(:xpath => path).size
    break if current_count == following_count
    if num != "all"
      break if current_count >= num
    end
  end
end

def scroll_follow_list(scroll=100)
  xpath = "//*[@class=\"_4gt3b\"]"
  element = "document.evaluate('#{xpath}', document, null, \
    XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue"
  @driver.execute_script("#{element}.scrollTo(0,#{scroll});")
  return scroll + 100
end

def follow_followers(num=100)
  num = followers_count if followers_count < num
  path = "//button[contains(.,'Follow') and "
  path << "not(contains(.,'Following'))]"
  new_follows = Hash.new
  scroll = 100
  if num > 0
    open_followers_list
    while @driver.find_elements(:xpath => "//*[@class='_cx1ua']").size < num
      @driver.find_elements(:xpath => path).each do |element|
        sleep 0.5
        begin
          element.click
          name = element.attribute("data-reactid")
          name = name.gsub(".1.1.0.1.0.$","").gsub(".0.1.0.0","")
          name = name.gsub("=1",".")
          new_follows[name] = Time.now
        rescue
          puts "couldn't click the next person"
          break
        end
      end
      scroll = scroll_follow_list(scroll)
    end
  end
  puts "====="
  puts "These were added for user: #{new_follows}"
  puts "====="
  return new_follows
end

def logged_in?
  path = "//*[contains(.,'#{@properties["username"]}')]"
  return @driver.find_elements(:xpath => path).size > 0
end
