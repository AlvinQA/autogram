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
    new_follows = Hash.new
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
            name = @driver.find_element(:xpath => name_path).text
            new_follows[name] = Time.now
          end
        end
        sleep random_wait_length
        close_dialog
      end
      more_follows = Hash.new
      puts "-----"
      puts "new follows: #{new_follows}"
      puts "-----"
      new_follows.each do |k,v|
        navigate_to_profile(k)
        more_follows = more_follows.merge(follow_followers(20))
        puts "-----"
        puts "more follows: #{more_follows}"
        puts "-----"
      end
      @greylist = @greylist.merge(more_follows)
    end
    File.open('test/config/greylist.yml', 'w+') do |f|
      f.write @greylist.to_yaml
    end
  end

  def teardown
    save_last_run
    @driver.quit
  end
end
