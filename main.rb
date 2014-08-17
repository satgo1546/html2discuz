# encoding: utf-8
# CmdMarkdown的HTML输出 → Discuz!代码转换器
# Written by satgo1546
# 适配于CmdMarkdown导出的HTML文件。

module CmdMarkdownHTML2DiscuzCode # 这确实不是一个好模块名
	GENERATOR_SIGNATURE = <<ENDBB.chomp
[align=right][font=Microsoft YaHei][size=10pt][color=Silver]此帖子的代码由[b]CmdMarkdown的HTML输出 → Discuz!代码转换器[/b]生成。[/color][/size][/font][/align]
ENDBB
	def self.convert(filename)
		quiet = ARGV.include?("--quiet")
		c = File.read(filename,	:encoding => "utf-8")
		# ============================================================================
		c.gsub!(/<(title)>(.*?)<\/\1>/) { puts "Title = #{$2}" unless quiet; "" }
		%w(html head body meta thead tbody).each do |t|
			c.gsub!(/<\/?#{t}.*?>/, "")
		end
		# ============================================================================
		c.gsub!(/<\!DOCTYPE\sHTML>/i, "")
		c.gsub!(/<p><code>.*?<\/code><\/p>/, "")
		c.gsub!("<div class=\"md-section-divider\"></div>", "")
		c.gsub!(/<\/?p>/, "\n")
		c.gsub!(/<hr\s?\/?>/, "[hr]")
		c.gsub!(" class=\"table table-striped-white table-bordered\"", "")
		c.gsub!(/\sid=".*?"/, "")
		{
			:lt => "<",
			:gt => ">",
			:quot => '"',
			:apos => "'",
			:amp => "&"
		}.each_pair { |entity, ch| c.gsub!("&#{entity};", ch) }
		# ============================================================================
		h = {
			:b => :b,
			:strong => :b,
			:i => :i,
			:em => :i,
			:u => :u,
			# Discuz!不识别这些代码
			# :h1 => "size=2em",
			# :h2 => "size=1.5em",
			# :h3 => "size=1.17em",
			# :h4 => "size=1em",
			# :h5 => "size=0.83em",
			# :h6 => "size=0.67em",
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
		h.each_pair do |html, bb|
			c.gsub!("<#{html}>", "[#{bb}]")
			c.gsub!("</#{html}>", "[/#{bb.to_s.split(/\=/)[0]}]")
		end
		c.gsub!("[/*]", "")
		c.gsub!("<th>", "[td][b]")
		c.gsub!("</th>", "[/b][/td]")
		c.gsub!("<a href=\"", "[url=")
		c.gsub!("\" target=\"_blank\">", "]")
		c.gsub!(/<img\ssrc\=\"(.*?)\"\s?\/?>/) { "[img]#{$1}[/img]" }
		c.gsub!(/" alt=".*?" title=".*?\[\/img\]/, "[/img]")
		# ============================================================================
		c.gsub!(/\n+/, "\n")
		c.gsub!(/\[hr\]\n/, "[hr]")
		c.gsub!(/^\n/, "")
		c.chomp!
		c << GENERATOR_SIGNATURE
		# ============================================================================
		File.write("output.txt", c)
	end
end

if __FILE__ == $0
	CmdMarkdownHTML2DiscuzCode.convert("input.html")
end
