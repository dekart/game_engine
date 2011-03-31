module HttperfReport
  def httperf_report
    r = Report.new
    yield r
    r.work
  end

  class Report
    def initialize
      @files = []
      @params = {}
    end

    def params(args)
      @params = args
    end

    def group(name)
      @files << {
        :name => name,
        :path => filepath = Rails.root.join("tmp", name.split.join('_'))
      }

      File.open(filepath, 'w') do |file|
        yield Group.new(file, @params)
      end
    end

    def work
      printf "Performance Report\n------------------\n\n"
      printf("%-24s%-20s%-10s%-14s%-14s\n\n", 'Group', 'Number of Requests', 'Total', 'Reply Rate', 'Reply Time')

      @files.each do |file|
        output = `httperf --hog --server=localhost --port=3305 --rate=100 --verbose --wsesslog=1,0,#{file[:path]}\n`
        res = parse_output(output)

        printf("%-24s%-20s%-10s%-14s%-14s\n",
          file[:name],
          "#{res['requests']} requests",
          "#{res['total']}s",
          "#{res['rate']}r/s",
          "#{res['time']}ms")
      end

      @files.each do |file|
        File.delete(file[:path])
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
    def initialize(file, params)
      @file = file
      @params = params
    end

    def get(url, args = {})
      args = @params.merge(args)
      @file.puts("#{url}?#{serialize(args)}")
    end

    def post(url, args = {})
      args = {:_method => 'post'}.merge(@params).merge(args)
      @file.puts("#{url} method=POST contents='#{serialize(args)}'")
    end

    def put(url, args = {})
      args = {:_method => 'put'}.merge(@params).merge(args)
      @file.puts("#{url} method=POST contents='#{serialize(args)}'")
    end

    def serialize(params)
      return params.collect{|key,value| "#{key.to_s}=#{value.to_s}"}.join("&")
    end
  end
end

include HttperfReport