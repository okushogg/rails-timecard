class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  protect_from_forgery except: [:callback] # CSRF対策無効化
  def index
    @work_date = Date.today
    @punch_in = Time.now
    @attendance_record = AttendanceRecord.new
  end

  def punch_in
    @attendance_record = AttendanceRecord.new
    @attendance_record.user_line_id = "Uab6b7ea590c88ec959ea84ef13f0431b"
    @attendance_record.work_date = Date.today
    @attendance_record.break_time = 1
    @attendance_record.start_time = Time.now
    @attendance_record.start_address = "〒657-0036 兵庫県神戸市灘区桜口町３丁目２"
    if @attendance_record.save
      flash[:notice] = "出勤時間を記録しました。"
      redirect_to("/")
    else
      render("/")
    end
  end

  def punch_out
    @attendance_record = AttendanceRecord.last
    if @attendance_record.user_line_id == "Uab6b7ea590c88ec959ea84ef13f0431b"
      @attendance_record.finish_time = Time.now
      @attendance_record.finish_address = "〒657-0036 兵庫県神戸市灘区桜口町３丁目２"
      @attendance_record.save
      flash[:notice] = "退勤時間を記録しました。"
      redirect_to("/")
    else
      flash[:notice] = "失敗。"
      render("/")
    end
  end

  def start_work
    @attendance_record = AttendanceRecord.new
    @attendance_record.user_line_id = event['source']['userId']
    @attendance_record.work_date = Date.today
    @attendance_record.break_time = 1
    @attendance_record.start_time = Time.now
    @attendance_record.start_place = event.message['address']
    if @attendance_record.save
      message = {
        type: 'text',
        text: '出勤情報を記録しました。'
      }
      client.reply_message(event['replyToken'], message)
    else
      message = {
        type: 'text',
        text: '出勤情報の記録に失敗しました。'
      }
      client.reply_message(event['replyToken'], message)
    end
  end

  # def attendance_record_check
  #   if AttendanceRecord.last != nil && AttendanceRecord.last.finish_time == nil
  #     punsh_in
  # end

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