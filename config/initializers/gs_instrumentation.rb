%w{
  mission_success
  monster_attack
  buy_item
  sell_item
}.each do |event|
  ActiveSupport::Notifications.subscribe event do |name, start, finish, id, payload|
    GsSubscriber.send(event, payload)
  end
end