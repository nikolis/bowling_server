defmodule BowlingServer.Schemas do   
  require OpenApiSpex          
  alias OpenApiSpex.Schema     


  defmodule GameJsonSchema do    
    @moduledoc """             
     The schema for the initial data needed to initiate a new bowling game 
    """
    require OpenApiSpex        
  
    OpenApiSpex.schema(%{      
      title: "GameList",   
      description: "basic data of every game in the db",
      type: :object,           
      properties: %{
        title: %Schema{type: :string},
        players: %Schema{type: :array, items: %Schema{type: :string}, description: "a list of the names of the players that should participate in this game"},
      },  
     required: [:players]
    })      
  end


  defmodule GameJsonSchema do    
    @moduledoc """             
     The schema for the initial data needed to initiate a new bowling game 
    """
    require OpenApiSpex        
  
    OpenApiSpex.schema(%{      
      title: "Game",   
      description: "The data that needed in order to iniate a new game",
      type: :object,           
      properties: %{
        title: %Schema{type: :string},
        players: %Schema{type: :array, items: %Schema{type: :string}, description: "a list of the names of the players that should participate in this game"},
      },  
      example: %{
        "data" => %{
          "users" => ["Tatyos Effendi, Tamburi Cemil Bay"],
          "title" => "Optional Game Title"
        }
      },
     required: [:players]
    })      
  end



  defmodule NextPlayJsonSchema do
    OpenApiSpex.schema(%{      
      title: "NextPlay", 
      description: "All the details needed for a particular play",
      type: :object,           
      properties: %{
        frame_order: %Schema{type: :integer},
        frame_id: %Schema{type: :integer},
        attempt: %Schema{type: :integer},
        player_id: %Schema{type: :integer},
        player_name: %Schema{type: :string}
      },  
      example: %{
        "data" => %{
          "frame_order" => 1,
          "frame_id" => 23,
          "attempt" => 2,
          "player_id" => 1,
          "player_name" => "Tatyos Efendi" ,
        }
      },
     required: [:frame_order, :frame_id, :attempt, :player_id, :player_name]
    })      
  end 

  defmodule PlayJsonSchema do
    OpenApiSpex.schema(%{      
      title: "Play", 
      description: "Verification details for created play",
      type: :object,           
      properties: %{
        attempt: %Schema{type: :integer},
        player: %Schema{type: :string},
        knocked_pins: %Schema{type: :integer},
        score: %Schema{type: :integer}

      },  
      example: %{
        "data" => %{
          "attempt" => 1,
          "player_name" =>  "Mohamed",
          "knocked_pins" => 4,
          "score" => 4 ,
        }
      },
      required: [:attempt, :player, :knocked_pins, :score]
    })      
  end 


  defmodule GameDetailsJsonSchema do
    OpenApiSpex.schema(%{      
      title: "GameDetails", 
      description: "The details game object decorated with current state including scores etc",
      type: :object,           
      properties: %{
        title: %Schema{type: :string},
        #id: %Schema{type: :int},
        scores: %Schema{type: :object, additionalProperties:  %Schema{type: :string}, description: "A Map containing player nickname as key and the total score as value"},
        score_board: %Schema{type: :array, items: BowlingServer.Schemas.FrameJsonSchema }
      },  
      example: %{
        "data" => %{
          "users" => ["Tatyos Effendi, Tamburi Cemil Bay"],
          "title" => "Optional Game Title"
        }
      },
      required: [:scores, :score_board]
    })
  end

  defmodule GameDetailsJsonResponseSchema do
    OpenApiSpex.schema(%{      
      title: "GameDetailsResponse", 
      description: "The response object for GameDetails",
      type: :object,           
      properties: %{
        data: BowlingServer.Schemas.GameDetailsJsonSchema
      },  
      example: %{
        "data" => %{
        }
      },
      required: [:data]
    })
  end

  defmodule FrameJsonSchema do
    OpenApiSpex.schema(%{      
      title: "Frame", 
      description: "The details of a particular frame of the game",
      type: :object,           
      properties: %{
        order: %Schema{type: :integer },
        plays: %Schema{type: :array, items: BowlingServer.Schemas.PlayJsonSchema }
      },  
    })      
  end 


end 
