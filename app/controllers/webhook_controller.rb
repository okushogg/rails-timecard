class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  protect_from_forgery except: [:callback] # CSRF対策無効化
  def index
    @work_date = Date.today
    @punch_in = Time.now
    @record = Record.new
  end

  def punch_in
    @record = Record.new
    @record.work_date = Date.today
    @record.punch_in = Time.now
    if @record.save
      flash[:notice] = "出勤時間を記録しました。"
      redirect_to("/")
    else
      render("/")
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
    end

    events = client.parse_events_from(body)

    events.each do |event|
      #response = "event.userID" "event.displayName"
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.userID
          }
          client.reply_message(event['replyToken'], message)
        end

        case event.type
        when Line::Bot::Event::MessageType::Location
          #latitude = event.message['latitude']
          #longitude = event.message['longitude']
          #address = event.message['address']
          message = {
            type: 'text',
            text: event.message['address']
          }
          client.reply_message(event['replyToken'], message)
        end

      end

    end

    "OK"
  end
end