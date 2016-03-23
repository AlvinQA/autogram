require 'rubygems'
require 'selenium-webdriver'
require 'minitest/autorun'
require 'yaml'

def configure_driver(browser="firefox")
  puts "Driver: #{browser}"
  if browser == 'chrome'
    driver = Selenium::WebDriver.for :chrome
  elsif browser == 'safari'
    driver = Selenium::WebDriver.for :safari
  elsif browser == 'firefox'
    driver = Selenium::WebDriver.for :firefox,:profile => configure_firefox_profile
  end
  return driver
end

def set_explicit_wait(wait_time)
  puts "Setting WebDriver explicit wait for #{wait_time} seconds"
  return Selenium::WebDriver::Wait.new(:timeout => wait_time)
end

def configure_firefox_profile
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.dir'] = "Downloads"
  profile['browser.download.folderList'] = 2
  profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf"
  profile['pdfjs.disabled'] = true
  return profile
end

def go_to_url(driver, url)
  driver.get url
end

def email_randomizer
  return "qa" + Time.now.to_s.gsub(/[^0-9A-Za-z]/, '') + "@thecontrolgroup.com"
end

def random_letter
  return (('A'..'P').to_a + ('R'..'W').to_a).sample
end

def random_wait_length
  return 1 + Random.rand(4)
end

def compare_hash(hash1, hash2)
  puts hash1.select{|k,_| hash2.has_key? k}
  puts hash2.select{|k,_| hash1.has_key? k}
  return hash1.select{|k,_| hash2.has_key? k} == hash2.select{|k,_| hash1.has_key? k}
end

def wait_until_visible(driver, type, path, wait_length=15)
  wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
  puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to be visible  "
  beginning_time = Time.now
  #show_wait_spinner{
  wait.until { driver.find_element(type, path).displayed? }
  #}
  puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_until_not_visible(driver, type, path, wait_length=15)
  wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
  puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to no longer be visible"
  beginning_time = Time.now
  #show_wait_spinner{
  wait.until { driver.find_elements(type, path).size == 0 }
  #}
  puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_for_element(driver, type, path, wait_length=15)
  wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
  puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to be in DOM"
  beginning_time = Time.now
  #show_wait_spinner{
  wait.until { driver.find_element(type, path) }
  #}
  puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_for_element_to_disappear(driver, type, path, wait_length=15)
  wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
  puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to no longer be in DOM"
  beginning_time = Time.now
  #show_wait_spinner{
  wait.until { driver.find_elements(type, path).empty? }
  #}
  puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_until_clickable(driver, type, path, wait_length=60)
  wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
  wait_string = "Waiting up to #{wait_length.to_s} seconds for "
  wait_string << "#{path} to be clickable"
  puts wait_string
  beginning_time = Time.now
  wait.until { driver.find_element(type, path).displayed? }
  driver.find_element(type, path).click
  puts "Actually took #{humanize_time(Time.now - beginning_time)}"
end

def get_current_url(driver)
  return driver.current_url
end

def humanize_time seconds # stolen from http://stackoverflow.com/a/4136485
  [[60, :s], [60, :m], [24, :h], [7, :w], [52, :y]].map{ |count, name|
    if seconds > 0
      seconds, n = seconds.divmod(count)
      "#{n.to_i}#{name}"
    end
   }.compact.reverse.join(' ')
 end

 def save_last_run(properties)
  # Converting to proper date format: .strftime("%b %d, %Y")
  properties['test_account']['last_run'] = Time.now
  File.open('config/properties.yml', 'w+') {|f| f.write properties.to_yaml }
end

