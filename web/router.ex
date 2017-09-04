defmodule Gatekeeper.Router do
  use Gatekeeper.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :requires_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, on_failure: { Gatekeeper.PageController, :unauthenticated }
  end

  pipeline :application do
    plug Gatekeeper.DoorLockStatusPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", Gatekeeper do
    pipe_through :browser

    if Mix.env == :dev do
      get "/automatic", AuthenticationController, :automatic
    end
    get "/:provider", AuthenticationController, :request
    get "/:provider/callback", AuthenticationController, :callback
    delete "", AuthenticationController, :delete
  end

  scope "/", Gatekeeper do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", Gatekeeper do
    pipe_through [:browser, :requires_auth, :application]

    resources "/companies", CompanyController do
      resources "/members", MemberController do
        resources "/rfid_tokens", RfidTokenController
      end
    end

    resources "/rfid_tokens", RfidTokenController

    resources "/doors", DoorController do
      post "/flipflop", DoorController, :flipflop
      get "/flipflop", DoorController, :flipflop
    end
    resources "/door_groups", DoorGroupController
    resources "/door_access_attempts", DoorAccessAttemptController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Gatekeeper do
  #   pipe_through :api
  # end
end
