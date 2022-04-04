class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  protect_from_forgery except: [:callback] # CSRF対策無効化
  def index
    @work_date = Date.today
    @punch_in = Time.now
    @attendance_record = Attendance_record.new
  end

  def punch_in
    @attendance_record = Attendance_record.new
    @attendance_record.user_line_id = event['source']['userId']
    @attendance_record.work_date = Date.today
    @attendance_record.start_time = Time.now
    @attendance_record.start_place = event.message['address']
    if @attendance_record.save
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

    events.each{ |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event['source']['userId']
          }
          client.reply_message(event['replyToken'], message)
        end

        case event.type
        when Line::Bot::Event::MessageType::Location
          message = {
            type: 'text',
            text: event.message['address']
          }
          client.reply_message(event['replyToken'], message)
        end

      end
    }
    "OK"
  end
end