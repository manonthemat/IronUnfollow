require 'oauth'
require 'json'
require 'fileutils'
require 'tempfile'

# Enter your https://dev.twitter.com/apps credentials below
consumer_key = 'Create an App at dev.twitter.com/apps'
consumer_secret = 'Set the Access level to Read/Write'
access_token = 'Enable Sign in with Twitter'
access_secret = 'and enter your generated twitter app credentials here'

@consumer = OAuth::Consumer.new(consumer_key, consumer_secret)
@access_token = OAuth::Token.new(access_token, access_secret)

@base_url = 'https://api.twitter.com/1.1'

def verify_credentials
  url_verify = URI("#{@base_url}/account/verify_credentials.json")

  https = Net::HTTP.new(url_verify.host, url_verify.port)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER

  request = Net::HTTP::Get.new(url_verify.request_uri)
  request.oauth! https, @consumer, @access_token

  https.start
  response = https.request request

  if response.code == '200'
    puts 'Credentials verified'
  else
    puts 'Invalid credentials'
  end
end

def get_friends()
  url_following = URI("#{@base_url}/friends/ids.json")

  https = Net::HTTP.new(url_following.host, url_following.port)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER

  request = Net::HTTP::Get.new(url_following.request_uri)
  request.oauth! https, @consumer, @access_token

  https.start
  response = https.request request

  if response.code == '200'
    File.open('friends.txt', 'w') do |file|
      file.puts JSON.parse(response.body)['ids']
    end
  else
    puts 'Aborted. Verify your credentials first'
  end
end

def print_help
  puts "Usage: IronUnfollow [command]

         verify - check credentials
         getFriends - get your list and save their id, screen_name and name into friends.txt
         unfollow (filename = default friends.txt) (limit = default 100) - check the first (limit) people on the list...
           if they're not following you, unfollow them
           save their id, screen_name and name in unfollowed.txt or following.txt when they follow you...
           remove the handled id from the friends file
  "
end

def unfollow(filename='friends.txt', limit=100)
  # twitter allows upto 100 comma-separated user ids per request
  if limit.to_i > 100
    limit = 100
  end
  ids = Array.new
  File.open(filename, 'r') do |file|
    limit.to_i.times do
      ids.push(file.readline.split(';')[0])
    end
  end
  user_ids = ids.join(',').gsub("\n", '')

  url_friendsdetail = URI("https://api.twitter.com/1.1/friendships/lookup.json?user_id=#{user_ids}")

  https = Net::HTTP.new(url_friendsdetail.host, url_friendsdetail.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url_friendsdetail.request_uri)
  request.oauth! https, @consumer, @access_token

  https.start
  response = https.request(request)

  File.open('unfollowed.txt', 'a') do |ufile|
    friends = JSON.parse(response.body)
    File.open('following.txt', 'a') do |ffile|
      for friend in friends
        if friend['connections'].include?('followed_by')
          ffile.puts "#{friend['id_str']};#{friend['screen_name']};#{friend['name']}"
          puts "#{friend['name']} follows you"
        else
          ufile.puts "#{friend['id_str']};#{friend['screen_name']};#{friend['name']}"
          url_unfollow = URI("#{@base_url}/friendships/destroy.json?user_id=#{friend['id_str']}")
          https = Net::HTTP.new(url_unfollow.host, url_unfollow.port)
          https.use_ssl = true
          request = Net::HTTP::Post.new(url_unfollow.request_uri)
          request.oauth! https, @consumer, @access_token
          https.start
          response = https.request(request)

          puts "You unfollowed #{friend['name']}"
        end
      end
    end
  end

  tmp = Tempfile.new('temp')
  File.open(filename, 'r').each do |line|
    tmp << line unless ids.include?(line)
  end
  tmp.close
  FileUtils.mv(tmp.path, filename)
end

if ARGV[0] != nil
  if ARGV[0].downcase == 'verify'
    verify_credentials
  elsif ARGV[0].downcase == 'getfriends'
    get_friends
  elsif ARGV[0].downcase == 'unfollow'
    if ARGV[1] != nil
      if ARGV[2] != nil
        unfollow(filename=ARGV[1], limit=ARGV[2])
      else
      unfollow(filename=ARGV[1])
      end
    else
      unfollow
    end
  end
else
  print_help
end

