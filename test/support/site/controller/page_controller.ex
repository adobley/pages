defmodule Test.Site.PageController do
  use Phoenix.Controller, layouts: [html: {Test.Site.Layout, :basic}]
  use Phoenix.VerifiedRoutes, endpoint: Test.Site.Endpoint, router: Test.Site.Router
  import Phoenix.Component, only: [to_form: 2]

  def show(conn, _params), do: render(conn, :show)

  def form(conn, _params) do
    data = changeset()

    conn
    |> assign(:form, data |> to_form(as: :form))
    |> render(:form)
  end

  def submit(conn, %{"form" => form_params} = params) do
    changeset = changeset(form_params)
    send(self(), {:page_controller, :submit, params})

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, _} ->
        redirect(conn, to: ~p"/pages/show")

      {:error, changeset} ->
        conn
        |> assign(:form, changeset |> to_form(as: :form))
        |> render(:form)
    end
  end

  # # #

  @required_attrs ~w[string_value]a
  @optional_attrs ~w[]a

  def changeset(params \\ %{}) do
    {%{string_value: "initial"}, %{string_value: :string}}
    |> Ecto.Changeset.cast(params, @required_attrs ++ @optional_attrs)
    |> Ecto.Changeset.validate_required(@required_attrs)
  end
end
