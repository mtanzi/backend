defmodule RabbitCICore.BranchControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build

  test "Get all branches for project" do
    project = Repo.insert! %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    for n <- 1..5 do
      Repo.insert! %Branch{name: "branch#{n}", exists_in_git: false,
                          project_id: project.id}
    end

    response = get("/projects/#{project.name}/branches")
    {:ok, body} = response.resp_body |> Poison.decode
    assert response.status == 200
    assert length(body["data"]) == 5
    assert Enum.sort(Map.keys(hd(body["data"])["attributes"])) ==
      Enum.sort(["name", "inserted-at", "updated-at"])
  end

  test "get a single branch" do
    project = Repo.insert! %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    branch = Repo.insert! %Branch{name: "branch1", exists_in_git: false,
                                 project_id: project.id}
    build = Repo.insert! %Build{build_number: 1, branch_id: branch.id,
                               commit: "xyz"}

    response = get("/projects/#{project.name}/branches/#{branch.name}")
    {:ok, body} =
      response.resp_body |> Poison.decode

    assert response.status == 200
    assert is_map(body["data"])
    assert body["data"]["attributes"]["name"] == branch.name
    assert hd(body["data"]["relationships"]["builds"]["data"])["id"] == to_string(build.id)
    assert hd(body["included"])["id"] == to_string(build.id)
  end

  test "branch does not exist" do
    project = Repo.insert! %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    response = get("/projects/#{project.name}/branches/fakebranch")
    assert response.status == 404
  end
end
