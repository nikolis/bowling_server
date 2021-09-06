defmodule BowlingServer.GameUtils do

  alias BowlingServer.Bowling

  #Compute the next play for a particular player in a particular frame
  #Return nil if the user has no play left in the current frame 
  def compute_players_next_play(frame, player) do
    frame = BowlingServer.Repo.preload(frame, :plays)

    #filter plays by player id 
    #Get the play with the biggest attempt value
    last_play = 
      Enum.filter(frame.plays, fn pl -> pl.player_id == player.id end)
      |> Enum.max_by(fn p -> p.attempt end, fn -> nil end)


    case last_play do
      nil -> 
        #Nil means the player has no prior attempt in the current frame
        %{frame_order: frame.order, frame_id: frame.id, attempt: 1, player_id: player.id, player_name: player.nick_name}
      play ->
        play = Bowling.get_play!(play.id) 
        case should_have_extra_attempt(player.id, frame) do
          false ->
            #Means the user has completed his tern in the current frame
            nil
          true ->
            #The user has more attempts in the current frame
            new_att = play.attempt + 1
            %{frame_order: frame.order, frame_id: frame.id, attempt: new_att, player_id: player.id, player_name: player.nick_name}
        end
    end
  end


  def should_have_extra_attempt(player_id, frame) do
    frame_plays = Enum.filter(frame.plays, fn pl -> pl.player_id == player_id end)
    total_pins_knocked = Enum.reduce(frame_plays, 0, fn x, acc -> acc + x.knocked_pins end)
    last_play_attempt =  
      case Enum.max_by(frame_plays , fn p -> p.attempt end, fn -> nil end) do
        nil -> nil
        lat_p -> lat_p.attempt
      end
    case last_play_attempt do
      nil ->
        true
      1 ->
        if frame.order != 10 and total_pins_knocked >= 10 do
          false
        else
          true
        end
      2 ->
        if frame.order == 10 and total_pins_knocked >= 10 do
          true
        else
          false
        end
      _ ->
        false
    end

  end


  #Computes the next play for the current frame
  #by computing all players next play and returning the first
  # Returns Nil if no player has any plays in the current frame
  def get_next_play(frame, players) do
    par_compute_players_next_play = fn x -> compute_players_next_play(frame, x) end
    players = Enum.map(players, par_compute_players_next_play)
    result = Enum.find(players, fn pl -> not is_nil(pl) end)
    result
  end

end
