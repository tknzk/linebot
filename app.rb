require 'json'
require 'logger'
require 'rest-client'
require 'docomoru'

post '/callback' do
  params = JSON.parse(request.body.read)

  params['result'].each do |msg|
    # docomo雑談API
    docomoru = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
    docomo_resp = docomoru.create_dialogue(msg['content'])
    body = docomo_resp.body

    logger.info(docomo_resp.inspect)

    if docomo_resp.status == 200
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: body['utt']
      }

    else

      # オウム返し
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }
    end

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
