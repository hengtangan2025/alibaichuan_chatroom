require 'net/http'
require 'digest/md5'
require 'digest/sha1'
require 'uri'
require 'net/https'
require 'json'

class ChatRoomsController < ApplicationController
  helper PlayAuth::SessionsHelper
  include PlayAuth::SessionsHelper
  before_filter :check_login
  def index
    @user = User.all
  end

  def make_sign_str(params, secret)
    sorted_str = params.sort.flatten.join
    sign = Digest::MD5.hexdigest(secret + sorted_str + secret).upcase
  end

  def create_group
    members_str = ""
    params[:members].each do |member|
      members_str += '{uid:"' + member + '", taobao_account:"false", app_key:"23459018"}'
    end 
    members_array = '[' + members_str + ']'
    hash = {
      method: 'taobao.openim.tribe.create',
      app_key: '23459018',
      timestamp: Time.now.strftime("%F %T"),
      format: 'json',
      v: '2.0',
      sign_method: 'md5',
      user: '{uid:"' + params[:create_user] + '", taobao_account:"false", app_key:"23459018"}',
      tribe_name: params[:group_name],
      notice: 'success',
      tribe_type: '1',
      members: members_array
    }

    hash[:sign] = make_sign_str(hash, '21052185adfbdae2b6e7bf4896c96d15')

    url = URI.parse("http://gw.api.taobao.com/router/rest")
    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Post.new(url.path)
      req['Content-Type'] = 'multipart/form-data'
      req['charset'] = 'utf-8'
      req.set_form_data(hash)
      p http.request(req).body
      if http.request(req).body["error_response"].nil?
        render :json => {:result => "创建成功"}.to_json
      else
        render :json => {:result => "创建失败"}.to_json
      end
    end
  end

  def quit_group
    hash = {
      method: 'taobao.openim.tribe.quit',
      app_key: '23459018',
      timestamp: Time.now.strftime("%F %T"),
      format: 'json',
      v: '2.0',
      sign_method: 'md5',
      user: '{uid:"' + params[:quit_user] + '", taobao_account:"false", app_key:"23459018"}',
      tribe_id: params[:tribe_id]
    }

    hash[:sign] = make_sign_str(hash, '21052185adfbdae2b6e7bf4896c96d15')

    url = URI.parse("http://gw.api.taobao.com/router/rest")
    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Post.new(url.path)
      req['Content-Type'] = 'multipart/form-data'
      req['charset'] = 'utf-8'
      req.set_form_data(hash)
      p http.request(req).body
      if http.request(req).body["openim_tribe_dismiss_response"].nil?
        render :json => {:result => "退出成功"}.to_json
      else
        render :json => {:result => "退出失败"}.to_json
      end
    end
  end

  def invite_others
    members_str = ""
    params[:members].each do |member|
      members_str += '{uid:"' + member + '", taobao_account:"false", app_key:"23459018"}'
    end 
    members_array = '[' + members_str + ']'
    hash = {
      method: 'taobao.openim.tribe.invite',
      app_key: '23459018',
      timestamp: Time.now.strftime("%F %T"),
      format: 'json',
      v: '2.0',
      sign_method: 'md5',
      user: '{uid:"' + params[:user] + '", taobao_account:"false", app_key:"23459018"}',
      tribe_id: params[:tribe_id],
      members: members_array
    }

    hash[:sign] = make_sign_str(hash, '21052185adfbdae2b6e7bf4896c96d15')

    url = URI.parse("http://gw.api.taobao.com/router/rest")
    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Post.new(url.path)
      req['Content-Type'] = 'multipart/form-data'
      req['charset'] = 'utf-8'
      req.set_form_data(hash)
      p http.request(req).body
      if http.request(req).body["error_response"].nil?
        render :json => {:result => "邀请成功"}.to_json
      else
        render :json => {:result => "邀请失败"}.to_json
      end
    end
  end

  protected
  def check_login
    if current_user.nil?
      redirect_to "/auth/users/developers"
    end
  end
end