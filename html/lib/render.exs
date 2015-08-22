defmodule Template do
  import Html

  def render do
    markup do
      div do
        h1 do
          text "welcime!"
        end
      end
    end
  end
end
