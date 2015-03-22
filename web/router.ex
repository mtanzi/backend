defmodule Rabbitci.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :allow_origin
  end

  scope "/", Rabbitci do
    pipe_through :api

    # get "/", PageController, :index

    resources "/projects", ProjectController, except: [:new, :edit]

    get "/projects/:project_id/branches", BranchController, :index
    get "/projects/:project_id/branches/:id", BranchController, :show

    get "/projects/:project_id/branches/:branch_id/builds",
    BuildController, :index
    get "/projects/:project_id/branches/:branch_id/builds/:build_number",
    BuildController, :show

    #resources "/branches", BranchController, except: [:new, :edit]
    #resources "/builds", BuildController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Rabbitci do
  #   pipe_through :api
  # end

  defp allow_origin(conn, _opts) do
    headers = get_req_header(conn, "access-control-request-headers")
    |> Enum.join(", ")

    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-headers", headers)
    |> put_resp_header("access-control-allow-methods", "get, post, options")
    |> put_resp_header("access-control-max-age", "3600")
  end
end
