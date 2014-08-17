# encoding: utf-8
# HTML → Discuz!代码转换器
# Written by satgo1546
# 适配于符合XML标准的HTML文件。会忽略DOCTYPE。

require 'rexml/document'
require 'rexml/streamlistener'

module HTML2Discuz
	class Processor
		IGNORED_TAGS = [
			:html,
			:head,
			:body,
			:meta
		]
		include REXML::StreamListener
		attr_reader :result
		def initialize
			clear_result
		end
		def clear_result
			@result = ""
		end
		def tag_start(name, attributes)
			return if IGNORED_TAGS.include?(name.to_sym)
			@result << "[#{name}]"
		end
		def tag_end(name)
			return if IGNORED_TAGS.include?(name.to_sym)
			@result << "[/#{name}]"
		end
		def text(text)
			@result << text
		end
	end
	GENERATOR_SIGNATURE = <<ENDBB.chomp
[align=right][font=Microsoft YaHei][size=10pt][color=Silver]此帖子的代码由[b]HTML → Discuz!代码转换器[/b]生成。[/color][/size][/font][/align]
ENDBB
	def self.convert(from, to, options)
		quiet = options.include?("--quiet")
		c = File.read(from,	:encoding => "utf-8")
		c.gsub!(/<!DOCTYPE.*?>/i, "")
		processor = Processor.new
		rx = REXML::Parsers::StreamParser.new(c, processor)
		rx.parse
		result = processor.result.chomp + GENERATOR_SIGNATURE
		File.write(to, result)
	end
end

if __FILE__ == $0
	options = []
	filenames = []
	while option = ARGV.shift
		(option[/^--?/] ? options : filenames) << option
	end
	filenames.each { |fn| HTML2Discuz.convert(fn, "#{fn.sub(/\.html$/, "")}.discuz.txt", options) }
end
