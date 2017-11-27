# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# ext packages
require "base64"
require "zlib"
require "stringio"
require "json"

# Splits a zipped, base64 encoded payload into
# individual events.

class LogStash::Filters::Base64Splitter < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "base64splitter"

  # Replace the message with this value.
  config :message, :validate => :string, :default => "Hello World!"


  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)
    return unless filter?(event)

    # Assume incoming message is converted to json
    # {
    #   "base64" : "H4si...EAAA==",
    #   "someKey" : "exampleValue"
    # }

    if event.get('base64')
      b64 = Base64.decode64( event.get('base64'))
      s = StringIO.new(b64)
      json = JSON.parse(Zlib::GzipReader.new(s).read)

      json.each do |key|
        e =  LogStash::Event.new(key)
        yield e
      end
      event.cancel
    end

    @logger.debug? && @logger.debug("Message is now: #{event.get('base64')}")

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Base64Splitter
