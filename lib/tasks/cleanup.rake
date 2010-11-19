namespace :app do
  namespace :cleanup do
    def remove_data(scope, batch = 100)
      first  = scope.first
      last   = scope.last

      if first and last
        total = scope.count

        puts "Deleting #{total} records (from #{first.id} to #{last.id})..."

        i = first.id

        while i < last.id
          scope.delete_all ["id BETWEEN ? AND ?", i, i + batch - 1]

          puts "Deleted records from #{i} to #{i + batch - 1} (max #{last.id}, total: #{total})"

          i += batch
        end

        puts "Done!"
      else
        puts "No records found"
      end
    end

    desc "Remove old fights"
    task :fights => :environment do
      time_limit = 1.month.ago

      old_fights = Fight.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old fights..."
      
      remove_data(old_fights)
    end

    desc "Remove old bank operations"
    task :bank_operations => :environment do
      time_limit = 1.month.ago

      old_operations = BankOperation.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old bank operations..."

      remove_data(old_operations)
    end
  end
end