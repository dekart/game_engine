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
      printf("%-24s%-20s%-10s%-18s%-18s%-18s\n\n", 'Group', 'Number of Requests', 'Total', 'Average', 'Min', 'Max')

      host = YAML.load_file(Rails.root.join('config', 'facebooker.yml'))['performance_test']['callback_url'].sub('http://', '')
      header = @cookies.empty? ? "" : "Cookie: #{@cookies}"

      @files.each do |file|
        output = `httperf --hog --server=#{host} --rate=10 --verbose --wsesslog=100,2,#{file[:path]} --add-header='#{header}\n'`
        res = parse_output(output)

        printf("%-24s%-20s%-10s%-18s%-18s%-18s\n",
          file[:name],
          "#{res['requests']} requests",
          "#{res['total']}s",
          "#{res['avg']}r/s (#{res['tavg']}ms)",
          "#{res['min']}r/s (#{res['tmin']}ms)",
          "#{res['max']}r/s (#{res['tmax']}ms)")
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
          when /^Reply rate .* min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d)/
            %w{min avg max}.each_with_index do |x, ind|
              rate = $~[ind].to_f

              res[x] = rate
              res["t#{x}"] = rate > 0 ? (100000/rate).to_i.to_f/100 : '--'
            end
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