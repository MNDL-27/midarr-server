defmodule MediaServerWeb.StatusesLive.Index do
  use MediaServerWeb, :live_view

  alias MediaServer.Accounts

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(session["user_token"]))
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(page_title: "Continue Watching")
      |> assign(:movie_watch_statuses, socket.assigns.current_user.movie_watch_statuses)
      |> assign(:episode_watch_statuses, socket.assigns.current_user.episode_watch_statuses)
    }
  end
end
