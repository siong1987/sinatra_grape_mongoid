class API < Grape::API
  get :hello do
    event = Event.create
    {hello: "world", id: event.id, count: Event.count}
  end
end
