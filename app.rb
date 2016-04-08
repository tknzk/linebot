require 'json'
require 'logger'
require 'rest-client'
require 'docomoru'

post '/callback' do
  params = JSON.parse(request.body.read)
  logger.info(params.inspect)

  params['result'].each do |msg|
    message = gen_message(msg['content'])

    request_content = {
      to: [msg['content']['from']],
      toChannel: 1383378250, # Fixed  value
      eventType: "138311608800106203", # Fixed value
      content: message
    }

    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    content_json = request_content.to_json
    logger.info(content_json)
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

def gen_message(content)
  return docomo_dialogue(content)
end

def docomo_dialogue(content)
  client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
  logger.info(client.inspect)
  response = client.create_dialogue(content)
  logger.info(response)
  if response.status == 200
    body = response.body
    return body['utt']
  end
  content
end
