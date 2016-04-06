def navigate_to_login
  go_to_url(@domain)
  sleep random_wait_length
end

def navigate_to_profile(user=@properties["username"])
  go_to_url("#{@domain}/#{user}")
  sleep random_wait_length
 end

 def navigate_to_tag(tag)
  go_to_url("#{@domain}/explore/tags/#{tag}")
  sleep random_wait_length
end
