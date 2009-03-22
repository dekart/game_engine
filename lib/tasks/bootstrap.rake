def img(name)
  File.open(File.join(RAILS_ROOT, "db", "pictures", "#{name}.jpg"))
end

namespace :app do
  desc "Bootstrap application data"
  task :bootstrap => :environment do
    @missions = {
      "Дератизация" => {
        :level        => 1,
        :description  => "Гигантские крысы из подземелий Столицы начали нападать на мирных людей. Убейте всех крыс и спасите мирных жителей!",
        :won_text     => "Вы убили гигантскую крысу!",
        :lost_text    => "Гигантская крыса оказалась слишком сильной, вам пришлось бежать!",
        :win_amount   => 5,
        :winner_title => "Крысолов",
        :ep_cost      => 1,
        :experience   => 1,
        :money_min    => 50,
        :money_max    => 100
      },
      "Воришки" => {
        :level        => 1,
        :description  => "В городе орудует банда карманников, крадущих у людей честно заработанные медяки. Поймайте подонков и предайте их суду!",
        :won_text     => "Вы поймали воришку!",
        :lost_text    => "На помощь воришке подошли подельники, вы предпочли сбежать!",
        :win_amount   => 20,
        :winner_title => "Гроза воров",
        :ep_cost      => 2,
        :experience   => 1,
        :money_min    => 70,
        :money_max    => 150
      },

      # ---- 
      "Усмирение минотавров" => {
        :level        => 50,
        :description  => "В горном лабиринте на северной границе страны живут минотавры. Недавно они взбунтовались против справедливых налогов. Ваша задача - уничтожить зачинщиков бунта и вернуть доходы в казну",
        :won_text     => "Вы подкараулили одного из зачинщиков и задали ему взбучку!",
        :lost_text    => "Минотавр оказался неплохим бойцом, вам пришлось отступить!",
        :win_amount   => 5,
        :winner_title => "Укротитель минотавров",
        :ep_cost      => 50,
        :experience   => 50,
        :money_min    => 1000,
        :money_max    => 5000
      }
    }

    @missions.each_pair do |key, value|
      Mission.find_or_create_by_name(key).update_attributes(value)
    end

    @weapons = {
      "Дубинка" => {
        :level => 1,
        :description => "Тяжелая дубовая палка, оружие бедняков",
        :price => 50,
        :attack => 1,
        :image => img("club")
      },
      "Солдатский меч" => {
        :level => 1,
        :description => "Меч рядового солдата, выкованный армейскими кузнецами",
        :price => 100,
        :attack => 2,
        :image => img("sword")
      },
      "Охотничий лук" => {
        :level => 1,
        :description => "Лук лесных охотников, простой и надежный",
        :price => 70,
        :attack => 2,
        :image => img("bow")
      }
    }

    @weapons.each_pair do |key, value|
      Weapon.find_or_create_by_name(key).update_attributes(value)
    end

    @armors = {
      "Кожанный жилет" => {
        :level => 1,
        :description => "Жилет из грубой бычьей кожи, закрывающий грудь и живот",
        :price => 50,
        :defence => 1
      }
    }

    @armors.each_pair do |key, value|
      Armor.find_or_create_by_name(key).update_attributes(value)
    end
  end
end