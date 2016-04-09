require 'json'
require 'logger'
require 'rest-client'
require 'docomoru'
require 'redis'

post '/callback' do
  params = JSON.parse(request.body.read)

  params['result'].each do |msg|
    message = gen_message(msg['content'], msg['content']['from'])

    content = {
      "contentType" => 1,
      "toType" => 1,
      "text" => message
    }

    request_content = {
      to: [msg['content']['from']],
      toChannel: 1383378250,
      eventType: "138311608800106203",
      content: content
    }

    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    content_json = request_content.to_json
    RestClient.proxy = ENV["FIXIE_URL"]
    RestClient.post(endpoint_uri, content_json, {
      'Content-Type' => 'application/json; charset=UTF-8',
      'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
      'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
      'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
    })
  end

  "OK"
end

private

def gen_message(msg, from)
  return docomo_dialogue(msg, from)
end

def docomo_dialogue(msg, from)
  client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
  if get_docomo_context(from).nil?
    logger.info("no-context request")
    response = client.create_dialogue("#{msg}")
  else
    logger.info("context: #{get_docomo_context(from)}")
    response = client.create_dialogue("#{msg}", {context: get_docomo_context(from)})
  end
  if response.status == 200
    body = response.body
    set_docomo_context(from, body["context"])
    return "#{body["utt"]}"
  end
  msg
end

def get_docomo_context(key)
  redis_db.get("dcm_context:#{key}")
end

def set_docomo_context(key, context)
  redis_db.set("dcm_context:#{key}", context)
end

def redis_db
  if ENV['REDIS_URL'] != nil
    uri   = URI.parse ENV['REDIS_URL']
    redis = Redis.new:host => uri.host, :port => uri.port, :password => uri.password
  else
    redis = Redis.new host:"127.0.0.1", port:"6379"
  end
  redis
end
