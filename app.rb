require 'json'
require 'logger'
require 'rest-client'
require 'docomoru'

post '/callback' do
  params = JSON.parse(request.body.read)
  #logger.info(params.inspect)

  params['result'].each do |msg|
    #message = gen_message(msg['content'])
    message = docomo_dialogue(msg['content'])

    request_content = {
      to: [msg['content']['from']],
      toChannel: 1383378250, # Fixed  value
      eventType: "138311608800106203", # Fixed value
      content: message
    }

    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    content_json = request_content.to_json
    #logger.info(content_json)
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

def gen_message(msg)
  return docomo_dialogue(msg)
end

def docomo_dialogue(msg)
  client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
  response = client.create_dialogue("#{msg}")
  #response = client.create_dialogue("こんにちは")
  if response.status == 200
    body = response.body
    logger.info(body)
    return "#{body["utt"]}"
  end
  msg
end
