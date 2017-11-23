# encoding: utf-8
require 'spec_helper'
require "logstash/filters/base64splitter"

describe LogStash::Filters::Base64Splitter do
  describe "Set to Hello World" do
    let(:config) do <<-CONFIG
      filter {
        base64splitter {
          message => "Hello World"
        }
      }
    CONFIG
    end

    sample("message" => "some text") do
      expect(subject.get("message")).to eq('Hello World')
    end
  end
end
