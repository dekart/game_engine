module HttperfReport
  def httperf_report
    r = Report.new
    yield r
    r.work
  end

  class Report
    @files

    def initialize
      @files = []
      @cookies = ""
    end

    def cookies(args)
    end

    def group(name)
      puts "adding file #{name} to list"
      @files << {
        :name => name,
        :path => filepath = Rails.root.join("tmp", name.split.join('_'))
      }

      file = File.open(filepath, 'w')
      yield Group.new(file)
      file.close
    end

    def work
      printf "Performance Report\n------------------\n\n"
    end

    private
    def parse_output(output)
    end
  end

  class Group
    @file

    def initialize(file)
      @file = file
    end

    def get(url)
      @file.puts("#{url}")
    end

    def post(url, args)
      arglist = args.collect{|key,value| "#{key.to_s}=#{value.to_s}"}.join("&")
      @file.puts("#{url} method=POST contents=#{arglist}")
    end
  end
end