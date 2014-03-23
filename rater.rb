require 'sinatra'
require 'rubygems'
require 'mongo'
require 'tempfile'
require 'fileutils'

class DictRater
	def initialize(dictionaryFile)
		@dictionary = {}
		@stats = "stats.txt"
	end

	def loadFile()
		dicttext = File.open("Words/en.txt")
		dicttext.each_line do |word|
			@dictionary[word] = { :up => 0, :down => 0}
		end
		if File.exist?(@stats)
			dicttext = File.open(@stats)
			dicttext.each_line do |line|
				stat = line.split()
				@dictionary[stat[0]] = { :up = stat[1], :down = stat[2] }
			end
		end
	end

	def dumpDict()
		temp = TempFile.new(@stats)
		@dictionary.each do |key, values|
			temp.puts("#{key} #{value[:up]} #{values[:down]}")
		end
		temp.close
		FileUtils.mv(temp.path, @stats)
	end

	def voteUp( word )
		@dictionary[word][:up] += 1
	end

	def voteDown( word )
		@dictionary[word][:down] += 1
	end

end

def main()

end
main()

get '/' do
end

post '/up/:word' do
end

post '/down/:word' do
end
