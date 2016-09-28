class FRParser

  require 'slack-ruby-bot'

  def initialize(&block)
    show_help
    @show_videos_keywords = ['show', 'videos']
    @show_gifs_keywords = ['show', 'gifs']
    @select_video_keywords = ['use video' , '[0-9]+']
    @timestamp_regex = '[0-9]+:[0-9][0-9]'
    @select_video_with_start_keywords = ['use video' , '[0-9]+', @timestamp_regex]
    @select_video_with_start_and_end_keywords = ['use video' , '[0-9]+', "#{@timestamp_regex} to  #{@timestamp_regex}"]
    @send_gif_keywords = ['send gif', '[0-9]+', 'to ^[a-zA-Z\s]*$]']
    slack_stuff
  end

  def parse(input)
    puts 'INPUT INCOMING:'
    puts input
    show_help if input =~ /^help$/
    show_videos if all_keywords_found(input, @show_videos_keywords)
    show_gifs if all_keywords_found(input, @show_gifs_keywords)
    if all_keywords_found(input, @select_video_with_start_and_end_keywords)
      #most specific video call
      puts 'select video with start and end hit'
      matches = input.match(@timestamp_regex)
      create_gif_with_timestamp(video_number(input), matches[0], matches[1])
    elsif all_keywords_found(input, @select_video_with_start_keywords)
      #create wit hstart only
      puts 'select video with start only hit'
      matches = input.match(@timestamp_regex)
      create_gif_with_timestamp(video_number(input), matches[0])
    elsif all_keywords_found(input, @select_video_keywords)
      #create with video number only
      puts 'select video with vid number only hit'
      create_gif(video_number(input))
    end
  end

  def video_number(input)
    input.match('[0-9]+$')[0]
  end

  def all_keywords_found(input, keyword_array)
    found = true
    keyword_array.each do |keyword|
      found = false unless input =~ /#{keyword}/
    end
    found
  end

  def show_videos
    send_chat 'Show videos called'
  end

  def show_gifs
    send_chat 'show gifs called'
  end

  def create_gif(video_index)
    send_chat "Creating a gif from video \##{video_index}"
  end

  def create_gif_with_timestamp(video_index, begin_time, end_time = nil)
    # if end time is nil, then go from start time to end of video
    send_chat "Creating a gif for video \##{video_index}, from #{begin_time}seconds to #{end_time}seconds"
  end

  def show_help
    send_chat 'You can use the following commands:'
    send_chat 'Show me my videos'
    send_chat 'Use video #1'
    send_chat 'Make gif from 0:09 to 1:15'
    send_chat 'Show me my gifs'
    send_chat 'Send gif #5 to Drexel University'
  end

  def send_chat(text)
    puts 'send_chat called'
    puts text
    send_slack_chat(text)
  end

  def send_slack_chat(text)
    return unless @client
    @client.message channel: @channel, text: text
  end

  def slack_stuff
    Slack.configure do |config|
      config.token = 'xoxb-85129034646-1B9s1yGfBT7cGZa3jaCwEeKu'
    end
    client = Slack::Web::Client.new
    client.auth_test
    slack_real_time
  end

  def slack_real_time
    Slack.configure do |config|
      config.token = 'xoxb-85129034646-1B9s1yGfBT7cGZa3jaCwEeKu'
    end
    @client = Slack::RealTime::Client.new
    @client.on :hello do
      puts 'Connected'
    end
    @client.on :message do |data|
      @channel = data['channel']
      parse(data['text'])
    end
    @client.start!
  end
end
