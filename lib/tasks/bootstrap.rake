namespace :app do
  desc "Bootstrap application data"
  task :bootstrap => :environment do
    @quests = {
      "Дератизация" => {
        :level        => 1,
        :description  => "Гигантские крысы из подземелий Столицы начали нападать на мирных людей. Убейте всех крыс и спасите мирных жителей!",
        :won_text     => "Вы убили гигантскую крысу!",
        :lost_text    => "Гигантская крыса оказалась слишком сильной, вам пришлось бежать!",
        :win_amount   => 100,
        :winner_title => "Крысолов",
        :ep_cost      => 1,
        :experience   => 1,
        :money_min    => 50,
        :money_max    => 100
      }
    }

    @quests.each_pair do |key, value|
      Quest.find_or_create_by_name(key).update_attributes(value)
    end
  end
end