defmodule BowlingServerWeb.Router do
  use BowlingServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: BowlingServerWeb.ApiSpec

  end

  scope "/", BowlingServerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/" do
    pipe_through :browser
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/v1/openapi"
  end

  scope "/api/v1" do
   pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api/v1", BowlingServerWeb do
    pipe_through :api

    resources "/games", GameController, except: [:new, :edit, :update]
    get "/games/next/:id", GameController, :get_next
    post "/games/record_play", GameController, :record_play

  end


  scope "/api/v1/_docs" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :foilapi_web,
      swagger_file: "swagger.json"    
  end 

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: BowlingServerWeb.Telemetry
    end
  end
end
