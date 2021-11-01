defmodule MediaServer.Media.Library do
  use Ecto.Schema
  import Ecto.Changeset

  schema "libraries" do
    field :name, :string
    field :path, :string

    has_many :files, MediaServer.Media.File

    timestamps()
  end

  @doc false
  def changeset(library, attrs) do
    library
    |> cast(attrs, [:name, :path])
    |> validate_required([:name, :path])
  end
end