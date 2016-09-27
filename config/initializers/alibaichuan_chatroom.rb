require 'net/http'
require 'digest/md5'
require 'uri'
require 'net/https'
require 'json'  

PlayAuth::User.class_eval do |variable|
  after_create :add_im_user

  def make_sign_str(params, secret)
    sorted_str = params.sort.flatten.join
    sign = Digest::MD5.hexdigest(secret + sorted_str + secret).upcase
  end
  
  def add_im_user
    params = {
      method: 'taobao.openim.users.add',
      app_key: '23459018',
      timestamp: Time.now.strftime("%F %T"),
      format: 'json',
      v: '2.0',
      sign_method: 'md5',
      userinfos: '{userid:"' + self.id + '", password:"12545"}',
    }

    params[:sign] = make_sign_str(params, '21052185adfbdae2b6e7bf4896c96d15')

    url = URI.parse("http://gw.api.taobao.com/router/rest")

    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Post.new(url.path)
      req['Content-Type'] = 'multipart/form-data'
      req['charset'] = 'utf-8'
      req.set_form_data(params)
    end
  end
end