defmodule Gatekeeper.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Gatekeeper.Repo
  alias Gatekeeper.Member

  def for_token(member = %Member{}), do: { :ok, "Member:#{member.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("Member:" <> id), do: { :ok, Repo.get(Member, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
