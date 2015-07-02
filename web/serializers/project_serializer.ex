defmodule RabbitCICore.ProjectSerializer do
  use JaSerializer

  require RabbitCICore.SerializerHelpers
  alias RabbitCICore.SerializerHelpers

  serialize "projects" do
    attributes [:name, :repo, :inserted_at,
                :updated_at]
    has_many :branches, include: RabbitCICore.BranchSerializer, link: ":branches_link"
  end

  def branches_link(record, conn) do
    RabbitCICore.Router.Helpers.branch_path(conn, :index, record.name)
  end

  def branches(record) do
    case RabbitCICore.Project.latest_build(record) do
      nil -> []
      build ->
        case build.branch do
          nil -> []
          a -> [a]
        end
    end
  end
end
