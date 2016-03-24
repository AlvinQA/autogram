require_relative "test_helper"
require_relative "helpers/navigation_helpers"
require_relative "helpers/login_helpers"
require_relative "helpers/profile_helpers"
require_relative "helpers/account_helpers"

BROWSER = "firefox"

class Autogram < Minitest::Test
  def setup
    @test_beginning_time = Time.now
    @properties = YAML.load_file("test/config/properties.yml")
    @driver = configure_driver(BROWSER)
    @domain = "http://www.instagram.com"
    @wait = set_explicit_wait(20)

    @auto_following = YAML.load_file("test/config/auto_following.yml")
    @whitelist = YAML.load_file("test/config/whitelist.yml")
    @greylist = YAML.load_file("test/config/greylist.yml")
    @blacklist = YAML.load_file("test/config/blacklist.yml")
    @tags = load_tags
  end

  def test_login
    navigate_to_login
    login
    close_dialog
    @whitelist = generate_whitelist
    @greylist = update_greylist
    new_follows = Array.new
    # like all friendly people's posts
    @tags.each do |tag|
      navigate_to_tag(tag)
      path = "//*[contains(@data-reactid,'$mostRecentSection')]"
      path << "//*[@class='_8mlbc _t5r8b']"
      @driver.find_elements(:xpath => path).each do |image|
        image.click
        sleep random_wait_length
        unliked = "//*[contains(@class,'coreSpriteHeartOpen')]"
        if @driver.find_elements(:xpath, unliked).size > 0
          @driver.find_element(:xpath, unliked).click
        end
        sleep random_wait_length
        follow = "//button[contains(.,'Follow')]"
        if @driver.find_elements(:xpath, follow).size > 0
          if @driver.find_element(:xpath, follow).text == "FOLLOW"
            @driver.find_element(:xpath, follow).click
            name_path = "//*[@class='_4zhc5 _ook48']"
            new_follows << @driver.find_element(:xpath => name_path).text
          end
        end
        sleep random_wait_length
        close_dialog
        new_follows.each do |account|
          navigate_to_profile(account)
          if following_count > 0
            open_followers_list
            load_followers(100)
            puts "done loading folks"
            new_follows += follow_all_followers
          end
        end
      end
    end
    #loop through all followers
    # => Follow ones that aren't followed
    # => Add to new_follows list
    # Loop through all new follows
    # => Look at who follows them
    # => follow everyone not followed by us
    # => add each person followed to the greylist
  end

  def teardown
    save_last_run
    @driver.quit
  end
end
