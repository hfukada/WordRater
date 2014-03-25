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
		if entry.nil?
			insertWord(cleanword(word), 1)
			return
		end
		@db.collection('words').update({'word' => entry["word"]}, {'$set' => {'score' => entry['score']+1, 'weight' => entry['weight']+1}})
	end

	def voteDown( word )
		entry = @db.collection('words').find({'word' => cleanword(word)}).to_a()[0]
		if entry.nil?
			insertWord(cleanword(word), -1)
			return
		end
		@db.collection('words').update({"word" => entry["word"]}, {"$set" => {"score" => entry["score"]-1, 'weight' => entry['weight']+1}})
	end

	def insertWord( word , offset)
		@db.collection('words').insert({"word" => cleanword(word), "score" => offset, "weight" => 1 })
	end

	def getRandomWord()
		words = @db.collection('words').find.to_a
		words[rand(words.size)-1]
	end

	def cleanword( word )
		#word.gsub(/[^0-9a-z]/i, '')
		word
	end

	def isNew( word )
		@db.collection('words').find( "word" => cleanword(word) ).to_a()[0].nil?
	end

	def getWorst()
		@db.collection('words').find({},{:limit => 20}).sort(:score => :asc)
	end

	def getBest()
		@db.collection('words').find({},{:limit => 20}).sort(:score => :desc)
	end

	def getPopular()
		@db.collection('words').find({},{:limit => 20}).sort(:weight => :desc)
	end
end

rater = DictRater.new

get '/' do
	word = rater.getRandomWord
	erb "<%= word =>", :locals => {:word => word["word"], :score => word["score"], :weight => word["weight"], :worst => rater.getWorst, :best => rater.getBest}
end

get '/word/' do
	word = rater.getRandomWord
	word.to_json
end

post '/new/:word' do |word|
	rater.insertWord(word, 0) if rater.isNew(word)
	return
end

post '/up/:word' do |word|
	rater.voteUp(word)
	return
end

post '/down/:word' do |word|
	rater.voteDown(word)
	return
end

configure do
	set :port => 3000 
	set :bind => '0.0.0.0'
end
