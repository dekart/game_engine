puts "Seeding help pages..."

HelpPage.create!(
  :alias    => "permissions",
  :name     => "Why do we ask for permissions?",
  :content  => "Permissions are necessary to authenticate you as a Facebook user."
)

HelpPage.create!(
  :alias    => "item_packages",
  :name     => "Item Packages",
  :content  => "Some items are sold in packs. These items are priced per pack."
)

HelpPage.create!(
  :alias    => "fights_failure",
  :name     => "Why do I lose?",
  :content  => "In most cases you lose fights because your opponent is stronger and has more powerfull items."
)

HelpPage.create!(
  :alias    => "boost_fight_attack",
  :name     => "Fight Attacking Boosts",
  :content  => "Attacking boosts improve your attack skills during a single fight."
)

HelpPage.create!(
  :alias    => "boost_fight_defence",
  :name     => "Fight Defensive Boosts",
  :content  => "Defensive boosts improve your defence skills during a single fight."
)

HelpPage.create!(
  :alias    => "monster_fight_attack",
  :name     => "Monster Attacking Boosts",
  :content  => "Attacking boosts make your attacks more powerfull and allow you to deal additonal damage to monster."
)

HelpPage.create!(
  :alias    => "equipment_additional",
  :name     => "Additonal Equipment",
  :content  => "This special slot allows you to equip as many items as your alliance can hold. Each few alliance members give you an additional equipment slot of such kind. Invite more friends to your alliance or hire mercenaries to get more item slots."
)

HelpPage.create!(
  :alias    => "monsters_damage_leaders",
  :name     => "Damage Leaders",
  :content  => "This section displayes how much damage was dealt by each fighter. The more damage you'll do the better your chance to get a reward."
)

HelpPage.create!(
  :alias    => "privacy",
  :name     => "Privacy Policy",
  :content  => "Your privacy policy goes here."
)




