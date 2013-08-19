require 'grape'

class API < Grape::API
  get :hello do
    {hello: "world"}
  end
end
