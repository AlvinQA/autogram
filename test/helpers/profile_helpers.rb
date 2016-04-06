def like_all_since_last_login(username='', password='')
  # TODO: Load all posts since last run. We'll have to humanize the stored date,
  # then compare vs. when the run started
end

def load_more
  if @driver.find_elements(:xpath => '//a[contains(.,"Load more")]').size > 0
    @driver.find_element(:xpath => '//a[contains(.,"Load more")]').click
  else
    @driver.find_element(:xpath => '//footer')
  end
  sleep random_wait_length + 2
end

def close_dialog
  path = "//button[@class='_3eajp']"
  wait_until_clickable(:xpath, path)
end

def followers_count
  path = "//a[@class='_m2soy']"
  if @driver.find_elements(:xpath => path).size > 0
    count = @driver.find_element(:xpath => path).text
    return count.gsub(/[^0-9]/, '').to_i
  end
  puts "NO FOLLOWERS APPARENTLY"
  return 0
end

def following_count
  path = "//a[@class='_c26bu']"
  if @driver.find_elements(:xpath => path).size > 0
    count = @driver.find_element(:xpath => path).text
    return count.gsub(/[^0-9]/, '').to_i
  end
  puts "THIS IS IN ALL CAPS. NO FOLLOWING APPARENTLY"
  return 0
end

def get_followers
  path = "//*[@class='_4zhc5']"
  followers = Array.new
  if followers_count > 0
    open_followers_list
    wait_until_visible(:class, "_cx1ua")
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
  following = Hash.new
  list_path = "//*[@class='_cx1ua']"
  scroll = 10
  puts "There are #{followers_count} followers."

  open_following_list
  load_following

  @driver.find_elements(:xpath => list_path).each do |element|
    following[element.text.gsub(".1.1.0.1.0.$","")] = Time.now
  end

  puts "======================================================================="
  puts "Following: #{following}"
  puts "======================================================================="

  return following
end

def open_followers_list
  path = "//a[@class='_m2soy']"
  @driver.find_element(:xpath => path).click
  wait_until_visible(:class, "_cx1ua")
end

def open_following_list
  path = "//a[@class='_c26bu']"
  @driver.find_element(:xpath => path).click
  wait_until_visible(:class, "_cx1ua")
end

def load_followers(num="all")
  path = "//*[@class='_cx1ua']"
  scroll = 10
  loop do
    scroll = scroll_follow_list(scroll)
    current_count = @driver.find_elements(:xpath => path).size
    break if current_count == followers_count
    if num != "all"
      break if current_count >= num
    else
      break if current_count >= following_count - 9
    end
  end
end

def load_following(num="all")
  path = "//*[@class='_cx1ua']"
  scroll = 10
  loop do
    scroll = scroll_follow_list(scroll)
    current_count = @driver.find_elements(:xpath => path).size
    puts "Current: #{current_count} | Following: #{following_count}"
    break if current_count == following_count
    if num != "all"
      break if current_count >= num
    else
      break if current_count >= following_count - 9
    end
  end
end

def scroll_follow_list(scroll=10)
  xpath = "//*[@class=\"_4gt3b\"]"
  element = "document.evaluate('#{xpath}', document, null, \
    XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue"
  @driver.execute_script("#{element}.scrollTo(0,#{scroll});")
  return scroll + 10
end

def follow_followers(num=50, user="")
  num = followers_count if followers_count < num
  puts "UP TO #{num} FOLLOWERS TO FOLLOW FOR #{user}"
  new_follows = Hash.new
  list_path = "//*[@class='_cx1ua']"
  follow_btn = "//button[contains(.,'Follow') and "
  follow_btn << "not(contains(.,'Following'))]"
  scroll = 10
  if num > 0
    open_followers_list
    while @driver.find_elements(:xpath => list_path).size < num
      @driver.find_elements(:xpath => follow_btn).each do |element|
        if element.text.downcase == "follow"
          begin
            element.click
            sleep random_wait_length
            name = element.attribute("data-reactid")
            name = name.gsub(".1.1.0.1.0.$","").gsub(".0.1.0.0","")
            name = name.gsub("=1",".")
            puts "FOLLOWING FOLLOWER: #{name}"
            new_follows[name] = Time.now
          rescue
            puts "couldn't click the next person"
            break
          end
        else
          puts "ALREADY FOLLOWING FOLLOWER"
        end
      end
      scroll = scroll_follow_list(scroll)
    end
  end
  puts "======================================================================="
  puts "Added from #{user}: #{new_follows}"
  puts "======================================================================="
  @greylist = @greylist.merge(new_follows)
end

def logged_in?
  path = "//*[contains(.,'#{@properties["username"]}')]"
  return @driver.find_elements(:xpath => path).size > 0
end
