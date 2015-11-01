defmodule Gatekeeper.Router do
  use Gatekeeper.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Gatekeeper do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/companies", CompanyController do
      resources "/members", MemberController do
        resources "/rfid_tokens", RfidTokenController
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Gatekeeper do
  #   pipe_through :api
  # end
end
