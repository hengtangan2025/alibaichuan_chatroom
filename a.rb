require 'net/http'
require 'digest/md5'
require 'digest/sha1'
require 'uri'
require 'net/https'
require 'json'

def make_sign_str(hash, secret)
  # p hash.sort_by{|k,v| k}.map{|k,v| k.to_s + v.to_s}.join()
  # Digest::MD5.hexdigest(hash.sort_by{|k,v| k}.map{|k,v| k.to_s + v.to_s}.join())
  # 参数排序
  sorted_keys = hash.keys.sort
  p sorted_keys
  
  arr = sorted_keys.map do |key|
    value = hash[key]
    "#{key}#{value}"
  end
  p arr

  str = arr.join
  sign = Digest::MD5.hexdigest(secret + str + secret)
end

params = {
  method: 'taobao.item.seller.get',
  app_key: '12345678',
  session: 'test',
  timestamp: '2016-01-01 12:00:00',
  format: 'json',
  v: '2.0',
  sign_method: 'md5',
  fields: 'num_iid,title,nick,price,num',
  num_iid: '11223344',
}

p make_sign_str(params, "helloworld")