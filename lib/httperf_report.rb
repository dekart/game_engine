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
      @cookies = args.collect{|key,value| "#{key.to_s}=#{value.to_s}"}.join(";")
    end

    def group(name)
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
      printf("%-24s%-20s%-10s%-14s%-14s\n\n", 'Group', 'Number of Requests', 'Total', 'Reply Rate', 'Reply Time')

      host = YAML.load_file(Rails.root.join('config', 'facebooker.yml'))['performance_test']['callback_url'].sub('http://', '')
      header = @cookies.empty? ? "" : "Cookie: #{@cookies}"

      @files.each do |file|
        output = `httperf --hog --server=#{host} --rate=10 --verbose --wsesslog=1,2,#{file[:path]} --add-header='#{header}\n'`
        res = parse_output(output)

        printf("%-24s%-20s%-10s%-14s%-14s\n",
          file[:name],
          "#{res['requests']} requests",
          "#{res['total']}s",
          "#{res['rate']}r/s",
          "#{res['time']}ms")
      end

      @files.each do |file|
        #File.delete(file[:path])
      end
    end

    private
    def parse_output(output)
      res = {}
      output.each do |line|
        case line
          when /^Total: .*requests (\d+) .* test-duration (\d+.\d+)/ then
            res['requests'] = $1
            res['total'] = $2
          when /^Reply rate .* avg (\d+\.\d)/ then res['rate'] = $1
          when /^Reply time .* response (\d+\.\d)/ then res['time'] = $1
        end
      end

      res
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