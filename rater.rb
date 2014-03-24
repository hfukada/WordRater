require 'sinatra'
require 'rubygems'
require 'mongo'
require 'tempfile'
require 'fileutils'
require 'json'

include Mongo

class DictRater
	def initialize()
		host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
		port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

		puts "Connecting to #{host}:#{port}"
		@db = MongoClient.new(host, port).db('wordRater')

	end

	def dumpDict()
	end

	def voteUp( word )
		entry = @db.collection('words').find({'word' => cleanword(word)}).to_a()[0]
		entry['up'] += 1
		@db.collection('words').update({'word' => entry["word"]}, {'$set' => {'up' => entry['up']}})
	end

	def voteDown( word )
		entry = @db.collection('words').find({'word' => cleanword(word)}).to_a()[0]
		entry['down'] += 1
		@db.collection('words').update({"word" => entry["word"]}, {"$set" => {"down" => entry["down"]}})
	end

	def getRandomWord()
		words = @db.collection('words').find.to_a
		words[rand(words.size)-1]
	end

	def cleanword( word )
		word.gsub(/[^0-9a-z]/i, '')
	end

end

rater = DictRater.new

get '/' do
	word = rater.getRandomWord
	erb "<%= word =>", :locals => {:word => word["word"], :up => word["up"], :down => word["down"]}
end

get '/word/' do
	word = rater.getRandomWord
	word.to_json
end

post '/up/:word' do |word|
	rater.voteUp(word)
	return
end

post '/down/:word' do |word|
	rater.voteDown(word)
	return
end
