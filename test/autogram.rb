require_relative "test_helper"
require_relative "helpers/navigation_helpers"
require_relative "helpers/login_helpers"
require_relative "helpers/profile_helpers"
require_relative "helpers/account_helpers"

BROWSER = "firefox"

class Autogram < Minitest::Test
  def setup
    @properties = YAML.load_file("test/config/properties.yml")
    configure_driver(BROWSER)
    @domain = "http://www.instagram.com"
    @wait = set_explicit_wait(20)

    @auto_following = YAML.load_file("test/config/auto_following.yml")
    @whitelist = YAML.load_file("test/config/whitelist.yml")
    @greylist = YAML.load_file("test/config/greylist.yml")
    @blacklist = YAML.load_file("test/config/blacklist.yml")
    @tags = load_tags
  end

  def test_autogram
    navigate_to_login
    login
    close_dialog
    load_greylist
    # @whitelist = generate_whitelist
    # @greylist = update_greylist
    loop do
      @greylist.shuffle.each_with_index do |(k, v), i|
        puts "-----------------------------------------------------------------"
        puts "Liking posts for #{k}. #{i+1} out of #{@greylist.size}."
        puts "-----------------------------------------------------------------"
        navigate_to_profile(k)
        if @driver.find_elements(:xpath,"//*[contains(@class,'_8mlbc _t5r8b')]").size > 0
          @driver.find_element(:xpath,"//*[contains(@class,'_8mlbc _t5r8b')]").click
          sleep random_wait_length
          unliked = "//*[contains(@class,'coreSpriteHeartOpen')]"
          next_button = "//*[contains(@class,'coreSpriteRightPaginationArrow')]"
          liked = 0
          likes = 1 + Random.rand(3)
          while liked < likes
            puts "LIKED: #{liked} | TOTAL TO LIKE: #{likes}."
            dice = roll_dice
            if dice > 2
              puts "Rolled a #{dice}! Lady Luck is on #{k}'s side."
              if @driver.find_elements(:xpath, unliked).size > 0
                puts "Liking picture"
                @driver.find_element(:xpath, unliked).click
                liked += 1
                sleep random_wait_length
              else
                puts "No like button. Probably already liked."
              end
            else
              puts "Rolled a #{dice}... The dice did not roll in #{k}'s favor."
            end
            if liked < likes
              if @driver.find_elements(:xpath, next_button).size > 0
                puts "going to next picture"
                @driver.find_element(:xpath, next_button).click
                sleep random_wait_length
              else
                puts "No next button. Probably at the end of #{k}'s pictures."
                break
              end
            end
          end
        else
          puts "Couldn't find any pictures on #{k}'s profile."
        end
      end

      @tags.each.with_index do |tag,i|
        puts "-----------------------------------------------------------------"
        puts "Adding folks for #{tag}. #{i+1} out of #{@tags.size}."
        puts "-----------------------------------------------------------------"
        navigate_to_tag(tag)
        path = "//*[contains(@data-reactid,'$mostRecentSection')]"
        path << "//*[@class='_8mlbc _t5r8b']"
        new_follows = Hash.new
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
            if @driver.find_element(:xpath, follow).text.downcase == "follow"
              @driver.find_element(:xpath, follow).click
              name_path = "//*[@class='_4zhc5 _ook48']"
              name = @driver.find_element(:xpath => name_path).text
              puts "CLICKING FOLLOW FOR: #{name}"
              new_follows[name] = Time.now
            end
          else
            puts "DIDN'T FIND FOLLOW BUTTON. "
            puts "FOUND: #{@driver.find_elements(:xpath, follow).text}"
          end
          sleep random_wait_length
          close_dialog
        end
        @greylist = @greylist.merge(new_follows)
        new_follows.each do |k,v|
          navigate_to_profile(k)
          if followers_count > 0
            follow_followers(50, k)
          end
        end
        File.open('test/config/greylist.yml', 'w+') do |f|
          f.write @greylist.to_yaml
        end
      end
    end
  end

  def teardown
    save_last_run
    @driver.quit
  end
end
