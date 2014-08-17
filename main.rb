# encoding: utf-8
# HTML → Discuz!代码转换器
# Written by satgo1546
# 适配于符合XML标准的HTML文件。会忽略DOCTYPE。

module HTML2Discuz
	GENERATOR_SIGNATURE = <<ENDBB.chomp
[align=right][font=Microsoft YaHei][size=10pt][color=Silver]此帖子的代码由[b]HTML → Discuz!代码转换器[/b]生成。[/color][/size][/font][/align]
ENDBB
	def self.convert(from, to, options)
		quiet = options.include?("--quiet")
		c = File.read(from,	:encoding => "utf-8")
		c.gsub!(/<!DOCTYPE.*?>/i, "")
		# --------------------------------------------------------------------------
		# --------------------------------------------------------------------------
		c.chomp!
		c << GENERATOR_SIGNATURE
		File.write(to, c)
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
