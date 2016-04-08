require 'docomoru'
def docomo_dialogue(msg)
  client = Docomoru::Client.new(api_key: "456d3962357a3879714b376950686f44386b694a4771443066713045634e7a5a4d505358514e71785a4233")
  response = client.create_dialogue("#{msg}")
  puts response.inspect
  if response.status == 200
    body = response.body
    return body["utt"]
  end
  msg
end

msg = "こんにちは"
puts docomo_dialogue(msg)

