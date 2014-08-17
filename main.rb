# encoding: utf-8
# HTML → Discuz!代码转换器
# Written by satgo1546
# 适配于符合XML标准的HTML文件。会忽略DOCTYPE。

require 'rexml/document'
require 'rexml/streamlistener'

module HTML2Discuz
	class Processor
		include REXML::StreamListener
		
		IGNORED_TAGS = [
			:html,
			:head,
			:body,
			:meta
		]
		TAG_LIST = {
			:b => :b,
			:strong => :b,
			:i => :i,
			:em => :i,
			:u => :u,
			:h1 => "size=28px",
			:h2 => "size=21px",
			:h3 => "size=16.38px",
			:h4 => "size=14px",
			:h5 => "size=11.62px",
			:h6 => "size=9.38px",
			:table => :table,
			:tr => :tr,
			:td => :td,
			:ol => "list=1",
			:li => "*",
			:ul => :list,
			:a => :url,
			:del => :s,
			:ins => :u,
			:code => "font=Courier New",
		}
		
		attr_reader :result
		
		def initialize
			clear_result
		end
		def clear_result
			@result = ""
		end
		def tag_start(name, attributes)
			name_sym = name.to_sym
			return if IGNORED_TAGS.include?(name_sym)
			@result << "[#{TAG_LIST[name_sym]}]"
		end
		def tag_end(name)
			name_sym = name.to_sym
			return if IGNORED_TAGS.include?(name_sym)
			@result << "[/#{TAG_LIST[name_sym].to_s.split(/=/)[0]}]"
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
