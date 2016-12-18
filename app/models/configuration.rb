# -*- encoding : utf-8 -*-
class Configuration < ActiveRecord::Base
  validates_presence_of :name
  
  def self.update_configurations!
    self.update_paypal_conversion!
  end
  
  def self.update_paypal_conversion!
    url = URI.parse('http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.xchange where pair in ("USDCOP")&format=json&env=store://datatables.org/alltableswithkeys')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    result = eval res.body
    conversion = '%.2f' % result[:query][:results][:rate][:Rate]
    Configuration[:paypal_conversion] = conversion
  end
  
  class << self
    # This method returns the values of the config simulating a Hash, like:
    #   Configuration[:foo]
    # It can also bring Arrays of keys, like:
    #   Configuration[:foo, :bar]
    # ... so you can pass it to a method using *.
    # It is memoized, so it will be correctly cached.
    def [] *keys
      if keys.size == 1
        get keys.shift
      else
        keys.map{|key| get key }
      end
    end
    def []= key, value
      set key, value
    end
    private

    def get key
      find_by_name(key).value rescue nil
    end

    def set key, value
      begin
        find_by_name(key).update_attribute :value, value
      rescue
        create!(name: key, value: value)
      end
      value
    end

  end
end
