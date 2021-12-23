defmodule MediaServerWeb.StreamEpisodeController do
  use MediaServerWeb, :controller

  import Ecto.Query

  alias MediaServer.Providers.Sonarr
  alias MediaServer.Repo
  
  def show(%{req_headers: headers} = conn, %{"episode" => episode}) do

    show = Sonarr |> last(:inserted_at) |> Repo.one

    case HTTPoison.get("#{ show.url }/episode/#{ episode }?apikey=#{ show.api_key }") do

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Jason.decode!(body)

        IO.inspect decoded

        send_video(conn, headers, decoded["episodeFile"]["path"])

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  defp get_offset(headers) do
    case List.keyfind(headers, "range", 0) do
      {"range", "bytes=" <> start_pos} ->
        String.split(start_pos, "-") |> hd |> String.to_integer
      nil ->
        0
    end
  end
  
  defp get_file_size(path) do
    {:ok, %{size: size}} = File.stat path

    size
  end
  
  defp send_video(conn, headers, path) do
    offset = get_offset(headers)
    file_size = get_file_size(path)

    conn
    |> put_resp_header("content-type", "video/mp4")
    |> put_resp_header("content-range", "bytes #{offset}-#{file_size-1}/#{file_size}")
    |> send_file(206, path, offset, file_size - offset)
  end
end